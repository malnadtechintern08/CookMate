<?php
/**
 * CookMate Web Admin - Comprehensive Recipe Editor (Create & Edit)
 */
require_once __DIR__ . '/config/db.php';
$pdo = get_db_connection();

$id = trim($_GET['id'] ?? '');
$isEdit = !empty($id);
$pageTitle = $isEdit ? 'Edit Recipe' : 'Create New Recipe';

$recipe = [
    'id' => 'rec_' . bin2hex(random_bytes(4)),
    'title' => '',
    'description' => '',
    'chef_name' => 'CookMate Chef',
    'cuisine' => 'Karnataka',
    'image_url' => 'assets/images/recipes/akki_rotti.jpg',
    'prep_time_minutes' => 15,
    'cook_time_minutes' => 20,
    'servings' => 4,
    'difficulty' => 'Medium',
    'category_id' => 'cat_malnad',
    'tags' => 'Malnad Special, Karnataka, Heritage, South Indian',
    'is_favorite' => 0,
    'is_custom' => 1,
    'is_vegetarian' => 1,
    'rating' => 4.8,
    'region' => 'Malnad, Karnataka',
    'subcategory' => 'Breakfast',
    'nutrition' => '210 kcal | 8g Protein | 28g Carbs',
];

$ingredients = [];
$instructions = [];

// If editing, load existing data
if ($isEdit) {
    $stmt = $pdo->prepare("SELECT * FROM recipes WHERE id = ?");
    $stmt->execute([$id]);
    $existing = $stmt->fetch();
    if (!$existing) {
        set_flash_message('danger', 'Recipe not found!');
        header('Location: ' . BASE_URL . '/recipes.php');
        exit;
    }
    $recipe = $existing;

    // Load ingredients
    $ingStmt = $pdo->prepare("SELECT * FROM recipe_ingredients WHERE recipe_id = ? ORDER BY sort_order ASC, id ASC");
    $ingStmt->execute([$id]);
    $ingredients = $ingStmt->fetchAll();

    // Load instructions
    $insStmt = $pdo->prepare("SELECT * FROM recipe_instructions WHERE recipe_id = ? ORDER BY step_number ASC");
    $insStmt->execute([$id]);
    $instructions = $insStmt->fetchAll();
}

// If no ingredients, start with 3 empty rows
if (empty($ingredients)) {
    $ingredients = [
        ['name' => '', 'amount' => '', 'unit' => '', 'notes' => ''],
        ['name' => '', 'amount' => '', 'unit' => '', 'notes' => ''],
    ];
}

// If no instructions, start with 2 empty steps
if (empty($instructions)) {
    $instructions = [
        ['step_number' => 1, 'instruction' => '', 'timer_seconds' => 180, 'tip' => ''],
        ['step_number' => 2, 'instruction' => '', 'timer_seconds' => 300, 'tip' => ''],
    ];
}

// Handle Form Submission
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $recipeId = trim($_POST['id'] ?? '');
    if (empty($recipeId)) {
        $recipeId = 'rec_' . bin2hex(random_bytes(4));
    }

    $title = trim($_POST['title'] ?? 'Untitled Recipe');
    $description = trim($_POST['description'] ?? '');
    $chefName = trim($_POST['chef_name'] ?? 'CookMate Chef');
    $cuisine = trim($_POST['cuisine'] ?? 'Indian');
    $region = trim($_POST['region'] ?? '');
    $subcategory = trim($_POST['subcategory'] ?? '');
    $categoryId = trim($_POST['category_id'] ?? 'cat_lunch_dinner');
    $prepTime = max(0, (int)($_POST['prep_time_minutes'] ?? 0));
    $cookTime = max(0, (int)($_POST['cook_time_minutes'] ?? 0));
    $servings = max(1, (int)($_POST['servings'] ?? 1));
    $difficulty = in_array($_POST['difficulty'] ?? '', ['Easy', 'Medium', 'Hard']) ? $_POST['difficulty'] : 'Medium';
    $rating = min(5.0, max(1.0, (float)($_POST['rating'] ?? 4.5)));
    $isVeg = isset($_POST['is_vegetarian']) ? 1 : 0;
    $isFav = isset($_POST['is_favorite']) ? 1 : 0;
    $isCustom = isset($_POST['is_custom']) ? 1 : ($isEdit ? $recipe['is_custom'] : 1);
    $tags = trim($_POST['tags'] ?? '');
    $nutrition = trim($_POST['nutrition'] ?? '');
    $imageUrl = trim($_POST['image_url'] ?? '');

    // Handle File Upload if present
    if (!empty($_FILES['image_file']['name']) && $_FILES['image_file']['error'] === UPLOAD_ERR_OK) {
        $uploadDir = __DIR__ . '/uploads/';
        if (!is_dir($uploadDir)) {
            mkdir($uploadDir, 0777, true);
        }
        $fileExt = strtolower(pathinfo($_FILES['image_file']['name'], PATHINFO_EXTENSION));
        if (in_array($fileExt, ['jpg', 'jpeg', 'png', 'webp', 'gif'])) {
            $newFileName = 'recipe_' . time() . '_' . bin2hex(random_bytes(3)) . '.' . $fileExt;
            $destPath = $uploadDir . $newFileName;
            if (move_uploaded_file($_FILES['image_file']['tmp_name'], $destPath)) {
                $imageUrl = 'uploads/' . $newFileName;
            }
        }
    }

    try {
        $pdo->beginTransaction();

        if ($isEdit) {
            // Update recipe
            $upSql = "
                UPDATE recipes SET
                    title = ?, description = ?, chef_name = ?, cuisine = ?, image_url = ?,
                    prep_time_minutes = ?, cook_time_minutes = ?, servings = ?, difficulty = ?,
                    category_id = ?, tags = ?, is_favorite = ?, is_custom = ?, is_vegetarian = ?,
                    rating = ?, region = ?, subcategory = ?, nutrition = ?
                WHERE id = ?
            ";
            $upStmt = $pdo->prepare($upSql);
            $upStmt->execute([
                $title, $description, $chefName, $cuisine, $imageUrl,
                $prepTime, $cookTime, $servings, $difficulty,
                $categoryId, $tags, $isFav, $isCustom, $isVeg,
                $rating, $region, $subcategory, $nutrition,
                $recipeId
            ]);
        } else {
            // Insert recipe
            $inSql = "
                INSERT INTO recipes (
                    id, title, description, chef_name, cuisine, image_url,
                    prep_time_minutes, cook_time_minutes, servings, difficulty,
                    category_id, tags, is_favorite, is_custom, is_vegetarian,
                    rating, region, subcategory, nutrition
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ";
            $inStmt = $pdo->prepare($inSql);
            $inStmt->execute([
                $recipeId, $title, $description, $chefName, $cuisine, $imageUrl,
                $prepTime, $cookTime, $servings, $difficulty,
                $categoryId, $tags, $isFav, $isCustom, $isVeg,
                $rating, $region, $subcategory, $nutrition
            ]);
        }

        // Re-sync ingredients: Delete existing and re-insert
        $pdo->prepare("DELETE FROM recipe_ingredients WHERE recipe_id = ?")->execute([$recipeId]);
        $ingNames = $_POST['ing_name'] ?? [];
        $ingAmounts = $_POST['ing_amount'] ?? [];
        $ingUnits = $_POST['ing_unit'] ?? [];
        $ingNotes = $_POST['ing_notes'] ?? [];

        $ingInsert = $pdo->prepare("INSERT INTO recipe_ingredients (id, recipe_id, name, amount, unit, notes, sort_order) VALUES (?, ?, ?, ?, ?, ?, ?)");
        for ($i = 0; $i < count($ingNames); $i++) {
            $name = trim($ingNames[$i] ?? '');
            if ($name !== '') {
                $ingId = $recipeId . '_ing_' . ($i + 1) . '_' . bin2hex(random_bytes(2));
                $amount = trim($ingAmounts[$i] ?? '');
                $unit = trim($ingUnits[$i] ?? '');
                $notes = trim($ingNotes[$i] ?? '');
                $ingInsert->execute([$ingId, $recipeId, $name, $amount, $unit, $notes, $i + 1]);
            }
        }

        // Re-sync instructions: Delete existing and re-insert
        $pdo->prepare("DELETE FROM recipe_instructions WHERE recipe_id = ?")->execute([$recipeId]);
        $stepTexts = $_POST['step_text'] ?? [];
        $stepTimers = $_POST['step_timer'] ?? [];
        $stepTips = $_POST['step_tip'] ?? [];

        $insInsert = $pdo->prepare("INSERT INTO recipe_instructions (id, recipe_id, step_number, instruction, timer_seconds, tip) VALUES (?, ?, ?, ?, ?, ?)");
        $stepNum = 1;
        for ($i = 0; $i < count($stepTexts); $i++) {
            $text = trim($stepTexts[$i] ?? '');
            if ($text !== '') {
                $insId = $recipeId . '_step_' . $stepNum . '_' . bin2hex(random_bytes(2));
                $timer = max(0, (int)($stepTimers[$i] ?? 0));
                $tip = trim($stepTips[$i] ?? '');
                $insInsert->execute([$insId, $recipeId, $stepNum, $text, $timer, $tip]);
                $stepNum++;
            }
        }

        $pdo->commit();
        set_flash_message('success', "Recipe \"$title\" saved successfully!");
        header('Location: ' . BASE_URL . '/recipe-view.php?id=' . urlencode($recipeId));
        exit;
    } catch (Exception $e) {
        $pdo->rollBack();
        $errorMsg = 'Error saving recipe: ' . $e->getMessage();
    }
}

// Fetch categories for select
$categories = $pdo->query("SELECT * FROM categories ORDER BY name ASC")->fetchAll();

require_once __DIR__ . '/includes/header.php';
?>

<?php if (!empty($errorMsg)): ?>
    <div class="alert alert-danger">
        <?= htmlspecialchars($errorMsg) ?>
    </div>
<?php endif; ?>

<form method="POST" enctype="multipart/form-data" id="recipeForm">
    <input type="hidden" name="id" value="<?= htmlspecialchars($recipe['id']) ?>">

    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px;">
        <div>
            <h2 style="font-size: 24px; font-weight: 800;"><?= $isEdit ? 'Edit Recipe: ' . htmlspecialchars($recipe['title']) : 'Add New Recipe' ?></h2>
            <p style="color: var(--cm-text-secondary); font-size: 13px;">ID: <code><?= htmlspecialchars($recipe['id']) ?></code></p>
        </div>
        <div style="display: flex; gap: 10px;">
            <a href="<?= BASE_URL ?>/recipes.php" class="btn btn-secondary">Cancel</a>
            <button type="submit" class="btn btn-primary">
                <i class="fa-solid fa-floppy-disk"></i> Save Recipe
            </button>
        </div>
    </div>

    <!-- Section 1: Basic Information -->
    <div class="card">
        <div class="card-header">
            <h3 class="card-title"><i class="fa-solid fa-circle-info" style="color: var(--cm-primary);"></i> Basic Information</h3>
        </div>

        <div class="form-group">
            <label class="form-label">Recipe Title *</label>
            <input type="text" name="title" class="form-control" value="<?= htmlspecialchars($recipe['title']) ?>" placeholder="e.g. Mysore Masala Dosa" required style="font-size: 16px; font-weight: 700;">
        </div>

        <div class="form-row">
            <div class="form-group">
                <label class="form-label">Category *</label>
                <select name="category_id" class="form-control" required>
                    <?php foreach ($categories as $cat): ?>
                        <option value="<?= htmlspecialchars($cat['id']) ?>" <?= $recipe['category_id'] === $cat['id'] ? 'selected' : '' ?>>
                            <?= htmlspecialchars($cat['name']) ?>
                        </option>
                    <?php endforeach; ?>
                </select>
            </div>

            <div class="form-group">
                <label class="form-label">Cuisine</label>
                <input type="text" name="cuisine" class="form-control" value="<?= htmlspecialchars($recipe['cuisine']) ?>" placeholder="e.g. Karnataka, South Indian, Mughlai">
            </div>

            <div class="form-group">
                <label class="form-label">Region</label>
                <input type="text" name="region" class="form-control" value="<?= htmlspecialchars($recipe['region']) ?>" placeholder="e.g. Malnad, Mysore, Coastal">
            </div>
        </div>

        <div class="form-row">
            <div class="form-group">
                <label class="form-label">Chef / Author Name</label>
                <input type="text" name="chef_name" class="form-control" value="<?= htmlspecialchars($recipe['chef_name']) ?>" placeholder="e.g. Malnad Aji or Chef Name">
            </div>

            <div class="form-group">
                <label class="form-label">Subcategory / Meal Time</label>
                <input type="text" name="subcategory" class="form-control" value="<?= htmlspecialchars($recipe['subcategory']) ?>" placeholder="e.g. Breakfast, Main Course, Snack">
            </div>
        </div>

        <div class="form-group">
            <label class="form-label">Description</label>
            <textarea name="description" class="form-control" rows="3" placeholder="Describe the recipe history, taste, and serving suggestions..."><?= htmlspecialchars($recipe['description']) ?></textarea>
        </div>
    </div>

    <!-- Section 2: Dietary, Timings & Metrics -->
    <div class="card">
        <div class="card-header">
            <h3 class="card-title"><i class="fa-solid fa-sliders" style="color: var(--cm-primary);"></i> Dietary, Timings & Attributes</h3>
        </div>

        <div class="form-row">
            <!-- Dietary Toggle -->
            <div class="form-group">
                <label class="form-label">Dietary Classification</label>
                <div class="switch-container" style="background: var(--cm-surface); padding: 12px 16px; border-radius: var(--cm-radius-sm); border: 1px solid var(--cm-border);">
                    <label class="switch">
                        <input type="checkbox" name="is_vegetarian" id="vegToggle" value="1" <?= $recipe['is_vegetarian'] ? 'checked' : '' ?> onchange="updateDietBadge()">
                        <span class="slider"></span>
                    </label>
                    <span id="dietLabel" class="badge <?= $recipe['is_vegetarian'] ? 'badge-veg' : 'badge-nonveg' ?>">
                        <?= $recipe['is_vegetarian'] ? 'Pure Vegetarian 🌱' : 'Non-Vegetarian 🍗' ?>
                    </span>
                </div>
            </div>

            <!-- Favorite Toggle -->
            <div class="form-group">
                <label class="form-label">Featured / Favorite</label>
                <div class="switch-container" style="background: var(--cm-surface); padding: 12px 16px; border-radius: var(--cm-radius-sm); border: 1px solid var(--cm-border);">
                    <label class="switch">
                        <input type="checkbox" name="is_favorite" value="1" <?= $recipe['is_favorite'] ? 'checked' : '' ?>>
                        <span class="slider" style="background-color: #333;"></span>
                    </label>
                    <span style="font-size: 13px; font-weight: 700; color: #EF5350;"><i class="fa-solid fa-heart"></i> Favorite Recipe</span>
                </div>
            </div>

            <!-- Rating -->
            <div class="form-group">
                <label class="form-label">Rating (1.0 to 5.0)</label>
                <input type="number" step="0.1" min="1.0" max="5.0" name="rating" class="form-control" value="<?= htmlspecialchars($recipe['rating']) ?>">
            </div>
        </div>

        <div class="form-row">
            <div class="form-group">
                <label class="form-label">Prep Time (Minutes)</label>
                <input type="number" min="0" name="prep_time_minutes" class="form-control" value="<?= htmlspecialchars($recipe['prep_time_minutes']) ?>">
            </div>

            <div class="form-group">
                <label class="form-label">Cook Time (Minutes)</label>
                <input type="number" min="0" name="cook_time_minutes" class="form-control" value="<?= htmlspecialchars($recipe['cook_time_minutes']) ?>">
            </div>

            <div class="form-group">
                <label class="form-label">Servings</label>
                <input type="number" min="1" name="servings" class="form-control" value="<?= htmlspecialchars($recipe['servings']) ?>">
            </div>

            <div class="form-group">
                <label class="form-label">Difficulty</label>
                <select name="difficulty" class="form-control">
                    <option value="Easy" <?= $recipe['difficulty'] === 'Easy' ? 'selected' : '' ?>>Easy</option>
                    <option value="Medium" <?= $recipe['difficulty'] === 'Medium' ? 'selected' : '' ?>>Medium</option>
                    <option value="Hard" <?= $recipe['difficulty'] === 'Hard' ? 'selected' : '' ?>>Hard</option>
                </select>
            </div>
        </div>

        <div class="form-row">
            <div class="form-group">
                <label class="form-label">Nutritional Information</label>
                <input type="text" name="nutrition" class="form-control" value="<?= htmlspecialchars($recipe['nutrition']) ?>" placeholder="e.g. 190 kcal | 8g Protein | 30g Carbs">
            </div>

            <div class="form-group">
                <label class="form-label">Tags (Comma-separated)</label>
                <input type="text" name="tags" class="form-control" value="<?= htmlspecialchars($recipe['tags']) ?>" placeholder="e.g. Malnad Special, Heritage, Breakfast, Healthy">
            </div>
        </div>
    </div>

    <!-- Section 3: Recipe Image -->
    <div class="card">
        <div class="card-header">
            <h3 class="card-title"><i class="fa-solid fa-image" style="color: var(--cm-primary);"></i> Recipe Photo</h3>
        </div>

        <div style="display: flex; gap: 24px; align-items: flex-start;">
            <div style="flex: 1;">
                <div class="form-group">
                    <label class="form-label">Image URL / Asset Path</label>
                    <input type="text" name="image_url" id="imageUrlInput" class="form-control" value="<?= htmlspecialchars($recipe['image_url']) ?>" placeholder="assets/images/recipes/akki_rotti.jpg" oninput="updateImagePreview()">
                    <small style="color: var(--cm-text-muted); display: block; margin-top: 6px;">
                        Path inside the app (e.g. <code>assets/images/recipes/your_image.jpg</code>) or a full web URL.
                    </small>
                </div>

                <div class="form-group">
                    <label class="form-label">Or Upload New Photo from Computer</label>
                    <input type="file" name="image_file" id="imageFileInput" class="form-control" accept="image/*" onchange="previewUpload(this)">
                </div>
            </div>

            <!-- Preview Card -->
            <div style="width: 180px; text-align: center;">
                <label class="form-label">Live Preview</label>
                <?php
                    $previewSrc = !empty($recipe['image_url']) ? BASE_URL . '/' . ltrim($recipe['image_url'], '/') : BASE_URL . '/assets/images/app_icon.png';
                ?>
                <img id="imagePreview" src="<?= htmlspecialchars($previewSrc) ?>" 
                     onerror="this.onerror=null;this.src='<?= BASE_URL ?>/assets/images/app_icon.png';" 
                     style="width: 160px; height: 160px; object-fit: cover; border-radius: 14px; border: 2px solid var(--cm-border); background: var(--cm-surface);" alt="Recipe Preview">
            </div>
        </div>
    </div>

    <!-- Section 4: Ingredients List -->
    <div class="card">
        <div class="card-header">
            <h3 class="card-title"><i class="fa-solid fa-carrot" style="color: var(--cm-primary);"></i> Ingredients</h3>
            <button type="button" class="btn btn-secondary btn-sm" onclick="addIngredientRow()">
                <i class="fa-solid fa-plus"></i> Add Ingredient
            </button>
        </div>

        <div id="ingredientsContainer">
            <?php foreach ($ingredients as $idx => $ing): ?>
                <div class="dynamic-row">
                    <div style="flex: 2;">
                        <input type="text" name="ing_name[]" class="form-control" value="<?= htmlspecialchars($ing['name']) ?>" placeholder="Ingredient name (e.g. Rice flour)" required>
                    </div>
                    <div style="width: 110px;">
                        <input type="text" name="ing_amount[]" class="form-control" value="<?= htmlspecialchars($ing['amount']) ?>" placeholder="Qty (e.g. 2)">
                    </div>
                    <div style="width: 130px;">
                        <input type="text" name="ing_unit[]" class="form-control" value="<?= htmlspecialchars($ing['unit']) ?>" placeholder="Unit (cups, tsp)">
                    </div>
                    <div style="flex: 2;">
                        <input type="text" name="ing_notes[]" class="form-control" value="<?= htmlspecialchars($ing['notes'] ?? '') ?>" placeholder="Notes (optional, finely chopped)">
                    </div>
                    <button type="button" class="remove-row-btn" onclick="this.closest('.dynamic-row').remove()" title="Remove ingredient">
                        <i class="fa-solid fa-trash"></i>
                    </button>
                </div>
            <?php endforeach; ?>
        </div>
    </div>

    <!-- Section 5: Cooking Steps / Instructions -->
    <div class="card">
        <div class="card-header">
            <h3 class="card-title"><i class="fa-solid fa-list-ol" style="color: var(--cm-primary);"></i> Step-by-Step Instructions</h3>
            <button type="button" class="btn btn-secondary btn-sm" onclick="addStepRow()">
                <i class="fa-solid fa-plus"></i> Add Step
            </button>
        </div>

        <div id="stepsContainer">
            <?php foreach ($instructions as $idx => $ins): ?>
                <div class="dynamic-row" style="align-items: flex-start; flex-direction: column;">
                    <div style="display: flex; width: 100%; gap: 12px; align-items: center; margin-bottom: 8px;">
                        <span class="step-badge" style="background: var(--cm-primary); color: #fff; width: 28px; height: 28px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: 800; font-size: 13px;">
                            <?= $idx + 1 ?>
                        </span>
                        <div style="flex: 1;">
                            <textarea name="step_text[]" class="form-control" rows="2" placeholder="Step description..." required><?= htmlspecialchars($ins['instruction']) ?></textarea>
                        </div>
                        <button type="button" class="remove-row-btn" onclick="this.closest('.dynamic-row').remove(); renumberSteps();" title="Remove step">
                            <i class="fa-solid fa-trash"></i>
                        </button>
                    </div>
                    <div style="display: flex; width: 100%; gap: 12px; padding-left: 40px;">
                        <div style="width: 170px;">
                            <label style="font-size: 11px; color: var(--cm-text-muted); font-weight: 700; display: block; margin-bottom: 4px;">Timer (Seconds)</label>
                            <input type="number" min="0" step="10" name="step_timer[]" class="form-control" value="<?= htmlspecialchars($ins['timer_seconds']) ?>" placeholder="e.g. 180">
                        </div>
                        <div style="flex: 1;">
                            <label style="font-size: 11px; color: var(--cm-text-muted); font-weight: 700; display: block; margin-bottom: 4px;">Chef Tip (Optional)</label>
                            <input type="text" name="step_tip[]" class="form-control" value="<?= htmlspecialchars($ins['tip'] ?? '') ?>" placeholder="e.g. Keep flame on medium-low">
                        </div>
                    </div>
                </div>
            <?php endforeach; ?>
        </div>
    </div>

    <!-- Bottom Save Action Bar -->
    <div style="display: flex; justify-content: flex-end; gap: 12px; margin-bottom: 40px;">
        <a href="<?= BASE_URL ?>/recipes.php" class="btn btn-secondary">Cancel</a>
        <button type="submit" class="btn btn-primary" style="padding: 14px 36px; font-size: 16px;">
            <i class="fa-solid fa-check"></i> Save Recipe
        </button>
    </div>
</form>

<script>
function updateDietBadge() {
    const isVeg = document.getElementById('vegToggle').checked;
    const badge = document.getElementById('dietLabel');
    if (isVeg) {
        badge.className = 'badge badge-veg';
        badge.innerHTML = 'Pure Vegetarian 🌱';
    } else {
        badge.className = 'badge badge-nonveg';
        badge.innerHTML = 'Non-Vegetarian 🍗';
    }
}

function updateImagePreview() {
    const val = document.getElementById('imageUrlInput').value.trim();
    const preview = document.getElementById('imagePreview');
    if (val.startsWith('http://') || val.startsWith('https://')) {
        preview.src = val;
    } else if (val !== '') {
        preview.src = '<?= BASE_URL ?>/' + val.replace(/^\/+/, '');
    } else {
        preview.src = '<?= BASE_URL ?>/assets/images/app_icon.png';
    }
}

function previewUpload(input) {
    if (input.files && input.files[0]) {
        const reader = new FileReader();
        reader.onload = function(e) {
            document.getElementById('imagePreview').src = e.target.result;
        };
        reader.readAsDataURL(input.files[0]);
    }
}

function addIngredientRow() {
    const container = document.getElementById('ingredientsContainer');
    const div = document.createElement('div');
    div.className = 'dynamic-row';
    div.innerHTML = `
        <div style="flex: 2;">
            <input type="text" name="ing_name[]" class="form-control" placeholder="Ingredient name (e.g. Mustard seeds)" required>
        </div>
        <div style="width: 110px;">
            <input type="text" name="ing_amount[]" class="form-control" placeholder="Qty">
        </div>
        <div style="width: 130px;">
            <input type="text" name="ing_unit[]" class="form-control" placeholder="Unit">
        </div>
        <div style="flex: 2;">
            <input type="text" name="ing_notes[]" class="form-control" placeholder="Notes (optional)">
        </div>
        <button type="button" class="remove-row-btn" onclick="this.closest('.dynamic-row').remove()" title="Remove ingredient">
            <i class="fa-solid fa-trash"></i>
        </button>
    `;
    container.appendChild(div);
}

function addStepRow() {
    const container = document.getElementById('stepsContainer');
    const stepCount = container.querySelectorAll('.dynamic-row').length + 1;
    const div = document.createElement('div');
    div.className = 'dynamic-row';
    div.style.alignItems = 'flex-start';
    div.style.flexDirection = 'column';
    div.innerHTML = `
        <div style="display: flex; width: 100%; gap: 12px; align-items: center; margin-bottom: 8px;">
            <span class="step-badge" style="background: var(--cm-primary); color: #fff; width: 28px; height: 28px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: 800; font-size: 13px;">
                ${stepCount}
            </span>
            <div style="flex: 1;">
                <textarea name="step_text[]" class="form-control" rows="2" placeholder="Step description..." required></textarea>
            </div>
            <button type="button" class="remove-row-btn" onclick="this.closest('.dynamic-row').remove(); renumberSteps();" title="Remove step">
                <i class="fa-solid fa-trash"></i>
            </button>
        </div>
        <div style="display: flex; width: 100%; gap: 12px; padding-left: 40px;">
            <div style="width: 170px;">
                <label style="font-size: 11px; color: var(--cm-text-muted); font-weight: 700; display: block; margin-bottom: 4px;">Timer (Seconds)</label>
                <input type="number" min="0" step="10" name="step_timer[]" class="form-control" value="180" placeholder="e.g. 180">
            </div>
            <div style="flex: 1;">
                <label style="font-size: 11px; color: var(--cm-text-muted); font-weight: 700; display: block; margin-bottom: 4px;">Chef Tip (Optional)</label>
                <input type="text" name="step_tip[]" class="form-control" placeholder="e.g. Cook until golden brown">
            </div>
        </div>
    `;
    container.appendChild(div);
}

function renumberSteps() {
    const badges = document.querySelectorAll('#stepsContainer .step-badge');
    badges.forEach((b, i) => {
        b.textContent = (i + 1);
    });
}
</script>

<?php require_once __DIR__ . '/includes/footer.php'; ?>
