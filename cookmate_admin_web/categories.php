<?php
/**
 * CookMate Web Admin - Categories Manager
 */
require_once __DIR__ . '/config/db.php';
$pdo = get_db_connection();

$pageTitle = 'Category Management';

// Handle Add / Edit Category
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $catId = trim($_POST['id'] ?? '');
    $catName = trim($_POST['name'] ?? '');
    $iconName = trim($_POST['icon_name'] ?? 'restaurant');
    $colorHex = trim($_POST['color_hex'] ?? '0xFFFF6B35');
    $desc = trim($_POST['description'] ?? '');

    if (!empty($catId) && !empty($catName)) {
        try {
            $stmt = $pdo->prepare("
                INSERT INTO categories (id, name, icon_name, color_hex, description)
                VALUES (?, ?, ?, ?, ?)
                ON DUPLICATE KEY UPDATE
                    name = VALUES(name),
                    icon_name = VALUES(icon_name),
                    color_hex = VALUES(color_hex),
                    description = VALUES(description)
            ");
            $stmt->execute([$catId, $catName, $iconName, $colorHex, $desc]);
            set_flash_message('success', "Category \"$catName\" saved successfully!");
        } catch (Exception $e) {
            set_flash_message('danger', "Error: " . $e->getMessage());
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

<div style="display: grid; grid-template-columns: 1fr 340px; gap: 24px; align-items: flex-start;">
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
                        <th style="text-align: right;">Filter</th>
                    </tr>
                </thead>
                <tbody>
                    <?php foreach ($categories as $cat): ?>
                        <?php 
                            $hex = !empty($cat['color_hex']) ? str_replace('0xFF', '#', $cat['color_hex']) : '#FF6B35';
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
                                <strong style="color: var(--cm-text-primary);"><?= $cat['recipe_count'] ?></strong> items
                            </td>
                            <td style="color: var(--cm-text-secondary); font-size: 12px; max-width: 250px;">
                                <?= htmlspecialchars($cat['description']) ?>
                            </td>
                            <td style="text-align: right;">
                                <a href="<?= BASE_URL ?>/recipes.php?category=<?= urlencode($cat['id']) ?>" class="btn btn-secondary btn-sm">
                                    View Recipes &rarr;
                                </a>
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
            <h3 class="card-title"><i class="fa-solid fa-plus" style="color: var(--cm-primary);"></i> Add / Update Category</h3>
        </div>

        <form method="POST">
            <div class="form-group">
                <label class="form-label">Category ID *</label>
                <input type="text" name="id" class="form-control" placeholder="e.g. cat_chaat or cat_beverages" required>
                <small style="color: var(--cm-text-muted); font-size: 11px;">Unique identifier (e.g. <code>cat_snacks</code>)</small>
            </div>

            <div class="form-group">
                <label class="form-label">Category Name *</label>
                <input type="text" name="name" class="form-control" placeholder="e.g. Street Chaat" required>
            </div>

            <div class="form-group">
                <label class="form-label">Icon Identifier</label>
                <input type="text" name="icon_name" class="form-control" placeholder="e.g. fastfood or local_dining" value="restaurant">
            </div>

            <div class="form-group">
                <label class="form-label">Color Hex (Flutter Format)</label>
                <input type="text" name="color_hex" class="form-control" placeholder="e.g. 0xFFFF6B35" value="0xFFFF6B35">
            </div>

            <div class="form-group">
                <label class="form-label">Description</label>
                <textarea name="description" class="form-control" rows="3" placeholder="Brief summary of foods in this category..."></textarea>
            </div>

            <button type="submit" class="btn btn-primary" style="width: 100%;">
                <i class="fa-solid fa-floppy-disk"></i> Save Category
            </button>
        </form>
    </div>
</div>

<?php require_once __DIR__ . '/includes/footer.php'; ?>
