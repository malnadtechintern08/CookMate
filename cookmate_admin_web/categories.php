<?php
/**
 * CookMate Web Admin - Categories Manager (CRUD)
 */
require_once __DIR__ . '/config/db.php';
$pdo = get_db_connection();

$pageTitle = 'Category Management';

// Handle Delete Category
if (isset($_GET['action']) && $_GET['action'] === 'delete') {
    $delId = trim($_GET['id'] ?? '');
    if (!empty($delId)) {
        try {
            $countStmt = $pdo->prepare("SELECT COUNT(*) FROM recipes WHERE category_id = ?");
            $countStmt->execute([$delId]);
            $linkedRecipes = (int)$countStmt->fetchColumn();

            if ($linkedRecipes > 0) {
                set_flash_message('danger', "Cannot delete category '{$delId}': {$linkedRecipes} recipes are currently assigned to it. Reassign or delete those recipes first.");
            } else {
                $delStmt = $pdo->prepare("DELETE FROM categories WHERE id = ?");
                $delStmt->execute([$delId]);
                if ($delStmt->rowCount() > 0) {
                    set_flash_message('success', "Category '{$delId}' was successfully deleted from the database.");
                } else {
                    set_flash_message('warning', "Category '{$delId}' not found or already deleted.");
                }
            }
        } catch (Exception $e) {
            set_flash_message('danger', "Error deleting category: " . $e->getMessage());
        }
    }
    header('Location: ' . BASE_URL . '/categories.php');
    exit;
}

// Handle Add / Edit Category
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $catId = trim($_POST['id'] ?? '');
    $catName = trim($_POST['name'] ?? '');
    $iconName = trim($_POST['icon_name'] ?? 'restaurant');
    $colorHex = trim($_POST['color_hex'] ?? '0xFFE50914');
    $desc = trim($_POST['description'] ?? '');

    if (empty($catId) || empty($catName)) {
        set_flash_message('danger', 'Both Category ID and Name are strictly required.');
    } else {
        try {
            // Check if category already exists
            $checkStmt = $pdo->prepare("SELECT COUNT(*) FROM categories WHERE id = ?");
            $checkStmt->execute([$catId]);
            $isExisting = ((int)$checkStmt->fetchColumn() > 0);

            if ($isExisting) {
                $stmt = $pdo->prepare("
                    UPDATE categories SET
                        name = ?,
                        icon_name = ?,
                        color_hex = ?,
                        description = ?
                    WHERE id = ?
                ");
                $stmt->execute([$catName, $iconName, $colorHex, $desc, $catId]);
                set_flash_message('success', "Category \"$catName\" ($catId) updated successfully in the database!");
            } else {
                $stmt = $pdo->prepare("
                    INSERT INTO categories (id, name, icon_name, color_hex, description)
                    VALUES (?, ?, ?, ?, ?)
                ");
                $stmt->execute([$catId, $catName, $iconName, $colorHex, $desc]);
                if ($stmt->rowCount() > 0) {
                    set_flash_message('success', "New category \"$catName\" ($catId) created successfully in the database!");
                } else {
                    throw new Exception("Failed to insert category into database.");
                }
            }
        } catch (Exception $e) {
            set_flash_message('danger', "Database error: " . $e->getMessage());
        }
    }
    header('Location: ' . BASE_URL . '/categories.php');
    exit;
}

// Fetch categories with recipe count
$categories = $pdo->query("
    SELECT c.*, COUNT(r.id) AS recipe_count 
    FROM categories c 
    LEFT JOIN recipes r ON c.id = r.category_id 
    GROUP BY c.id 
    ORDER BY c.name ASC
")->fetchAll();

require_once __DIR__ . '/includes/header.php';
?>

<div style="display: grid; grid-template-columns: 1fr 360px; gap: 24px; align-items: flex-start;">
    <!-- Left: Categories Table -->
    <div class="card" style="padding: 0; overflow: hidden;">
        <div style="padding: 20px 24px; border-bottom: 1px solid var(--cm-border); display: flex; justify-content: space-between; align-items: center;">
            <h2 class="card-title" style="margin: 0;">Existing Categories (<?= count($categories) ?>)</h2>
            <a href="<?= PHPMYADMIN_URL ?>" target="_blank" class="pma-badge-btn" style="padding: 6px 12px;">
                <i class="fa-solid fa-database"></i> Browse in phpMyAdmin
            </a>
        </div>

        <div class="table-responsive">
            <table class="admin-table">
                <thead>
                    <tr>
                        <th>Category</th>
                        <th>Identifier</th>
                        <th>Color Badge</th>
                        <th>Recipes</th>
                        <th>Description</th>
                        <th style="text-align: right;">Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($categories as $cat): ?>
                        <?php 
                            $hex = !empty($cat['color_hex']) ? str_replace('0xFF', '#', $cat['color_hex']) : '#E50914';
                        ?>
                        <tr>
                            <td>
                                <strong style="color: var(--cm-text-primary); font-size: 15px; font-family: 'Outfit', sans-serif;">
                                    <?= htmlspecialchars($cat['name']) ?>
                                </strong>
                            </td>
                            <td>
                                <code style="color: var(--cm-text-muted);"><?= htmlspecialchars($cat['id']) ?></code>
                            </td>
                            <td>
                                <span class="badge" style="background: <?= $hex ?>25; color: <?= $hex ?>; border: 1px solid <?= $hex ?>60;">
                                    <span style="width: 8px; height: 8px; border-radius: 50%; background: <?= $hex ?>; display: inline-block;"></span>
                                    <?= htmlspecialchars($cat['color_hex']) ?>
                                </span>
                            </td>
                            <td>
                                <a href="<?= BASE_URL ?>/recipes.php?category=<?= urlencode($cat['id']) ?>" style="color: var(--cm-primary); font-weight: 700; text-decoration: none;">
                                    <?= $cat['recipe_count'] ?> recipes
                                </a>
                            </td>
                            <td style="color: var(--cm-text-secondary); font-size: 12px; max-width: 250px;">
                                <?= htmlspecialchars($cat['description']) ?>
                            </td>
                            <td style="text-align: right;">
                                <div style="display: inline-flex; gap: 6px;">
                                    <button type="button" class="btn btn-secondary btn-icon" title="Edit Category"
                                            onclick='editCategory(<?= json_encode($cat) ?>)'>
                                        <i class="fa-regular fa-pen-to-square"></i>
                                    </button>
                                    <a href="<?= BASE_URL ?>/categories.php?action=delete&id=<?= urlencode($cat['id']) ?>" 
                                       class="btn btn-danger btn-icon" 
                                       title="Delete Category" 
                                       onclick="return confirm('Are you sure you want to delete category <?= addslashes($cat['name']) ?>?');">
                                        <i class="fa-regular fa-trash-can"></i>
                                    </a>
                                </div>
                            </td>
                        </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>
        </div>
    </div>

    <!-- Right: Add / Edit Category Panel -->
    <div class="card">
        <div class="card-header">
            <h3 class="card-title" id="formTitle"><i class="fa-solid fa-plus" style="color: var(--cm-primary);"></i> Add / Update Category</h3>
        </div>

        <form method="POST" action="<?= BASE_URL ?>/categories.php" id="catForm">
            <div class="form-group">
                <label class="form-label">Category ID *</label>
                <input type="text" name="id" id="catInputId" class="form-control" placeholder="e.g. cat_chaat or cat_beverages" required>
                <small style="color: var(--cm-text-muted); font-size: 11px;">Unique identifier in database</small>
            </div>

            <div class="form-group">
                <label class="form-label">Category Name *</label>
                <input type="text" name="name" id="catInputName" class="form-control" placeholder="e.g. Street Chaat" required>
            </div>

            <div class="form-group">
                <label class="form-label">Icon Identifier</label>
                <input type="text" name="icon_name" id="catInputIcon" class="form-control" placeholder="e.g. fastfood or local_dining" value="restaurant">
            </div>

            <div class="form-group">
                <label class="form-label">Color Hex (Flutter Format)</label>
                <input type="text" name="color_hex" id="catInputColor" class="form-control" placeholder="e.g. 0xFFE50914" value="0xFFE50914">
            </div>

            <div class="form-group">
                <label class="form-label">Description</label>
                <textarea name="description" id="catInputDesc" class="form-control" rows="3" placeholder="Brief summary of foods in this category..."></textarea>
            </div>

            <div style="display: flex; gap: 8px;">
                <button type="submit" class="btn btn-primary" style="flex: 1;">
                    <i class="fa-solid fa-floppy-disk"></i> Save Category
                </button>
                <button type="button" class="btn btn-secondary" onclick="resetCatForm()" id="resetBtn" style="display: none;">
                    Reset
                </button>
            </div>
        </form>
    </div>
</div>

<script>
function editCategory(cat) {
    document.getElementById('formTitle').innerHTML = '<i class="fa-solid fa-pen-to-square" style="color: var(--cm-primary);"></i> Edit: ' + cat.name;
    document.getElementById('catInputId').value = cat.id;
    document.getElementById('catInputId').readOnly = true;
    document.getElementById('catInputName').value = cat.name;
    document.getElementById('catInputIcon').value = cat.icon_name || 'restaurant';
    document.getElementById('catInputColor').value = cat.color_hex || '0xFFE50914';
    document.getElementById('catInputDesc').value = cat.description || '';
    document.getElementById('resetBtn').style.display = 'inline-block';
}

function resetCatForm() {
    document.getElementById('formTitle').innerHTML = '<i class="fa-solid fa-plus" style="color: var(--cm-primary);"></i> Add / Update Category';
    document.getElementById('catInputId').value = '';
    document.getElementById('catInputId').readOnly = false;
    document.getElementById('catInputName').value = '';
    document.getElementById('catInputIcon').value = 'restaurant';
    document.getElementById('catInputColor').value = '0xFFE50914';
    document.getElementById('catInputDesc').value = '';
    document.getElementById('resetBtn').style.display = 'none';
}
</script>

<?php require_once __DIR__ . '/includes/footer.php'; ?>
