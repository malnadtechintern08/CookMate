<?php
/**
 * CookMate Web Admin - Recipe Visual Preview
 */
require_once __DIR__ . '/config/db.php';
$pdo = get_db_connection();

$id = trim($_GET['id'] ?? '');
if (empty($id)) {
    header('Location: ' . BASE_URL . '/recipes.php');
    exit;
}

$stmt = $pdo->prepare("
    SELECT r.*, c.name AS category_name, c.color_hex AS category_color
    FROM recipes r
    LEFT JOIN categories c ON r.category_id = c.id
    WHERE r.id = ?
");
$stmt->execute([$id]);
$recipe = $stmt->fetch();

if (!$recipe) {
    set_flash_message('danger', 'Recipe not found!');
    header('Location: ' . BASE_URL . '/recipes.php');
    exit;
}

$pageTitle = $recipe['title'];

// Fetch ingredients
$ingStmt = $pdo->prepare("SELECT * FROM recipe_ingredients WHERE recipe_id = ? ORDER BY sort_order ASC, id ASC");
$ingStmt->execute([$id]);
$ingredients = $ingStmt->fetchAll();

// Fetch instructions
$insStmt = $pdo->prepare("SELECT * FROM recipe_instructions WHERE recipe_id = ? ORDER BY step_number ASC");
$insStmt->execute([$id]);
$instructions = $insStmt->fetchAll();

$thumb = !empty($recipe['image_url']) ? BASE_URL . '/' . ltrim($recipe['image_url'], '/') : BASE_URL . '/assets/images/app_icon.png';
$catColor = !empty($recipe['category_color']) ? str_replace('0xFF', '#', $recipe['category_color']) : '#FF6B35';

require_once __DIR__ . '/includes/header.php';
?>

<!-- Header Action Buttons -->
<div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 24px;">
    <a href="<?= BASE_URL ?>/recipes.php" class="btn btn-secondary">
        <i class="fa-solid fa-arrow-left"></i> Back to All Recipes
    </a>

    <div style="display: flex; gap: 10px;">
        <a href="<?= BASE_URL ?>/recipe-form.php?id=<?= urlencode($recipe['id']) ?>" class="btn btn-primary">
            <i class="fa-regular fa-pen-to-square"></i> Edit Recipe
        </a>
        <a href="<?= BASE_URL ?>/recipe-duplicate.php?id=<?= urlencode($recipe['id']) ?>" class="btn btn-secondary">
            <i class="fa-regular fa-copy"></i> Duplicate
        </a>
        <a href="<?= BASE_URL ?>/recipe-delete.php?id=<?= urlencode($recipe['id']) ?>" class="btn btn-danger" onclick="return confirm('Are you sure you want to delete <?= addslashes($recipe['title']) ?>?');">
            <i class="fa-regular fa-trash-can"></i> Delete
        </a>
    </div>
</div>

<!-- Recipe Hero Card -->
<div class="card" style="padding: 0; overflow: hidden; margin-bottom: 24px;">
    <div style="display: flex; flex-wrap: wrap;">
        <!-- Left: Image -->
        <div style="flex: 1; min-width: 320px; max-width: 460px; height: 360px; background: var(--cm-surface); position: relative;">
            <img src="<?= htmlspecialchars($thumb) ?>" 
                 onerror="this.onerror=null;this.src='<?= BASE_URL ?>/assets/images/app_icon.png';"
                 style="width: 100%; height: 100%; object-fit: cover;" 
                 alt="<?= htmlspecialchars($recipe['title']) ?>">
            <div style="position: absolute; top: 16px; left: 16px; display: flex; gap: 8px;">
                <?php if ($recipe['is_vegetarian']): ?>
                    <span class="badge badge-veg"><i class="fa-solid fa-leaf"></i> PURE VEG</span>
                <?php else: ?>
                    <span class="badge badge-nonveg"><i class="fa-solid fa-drumstick-bite"></i> NON-VEG</span>
                <?php endif; ?>
                
                <?php if ($recipe['is_favorite']): ?>
                    <span class="badge" style="background: rgba(229, 57, 53, 0.2); color: #EF5350; border: 1px solid #EF5350;">
                        <i class="fa-solid fa-heart"></i> FAVORITE
                    </span>
                <?php endif; ?>
            </div>
        </div>

        <!-- Right: Meta & Details -->
        <div style="flex: 2; min-width: 340px; padding: 32px; display: flex; flex-direction: column; justify-content: space-between;">
            <div>
                <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 12px;">
                    <span class="badge" style="background: <?= $catColor ?>25; color: <?= $catColor ?>; border: 1px solid <?= $catColor ?>50; font-size: 12px;">
                        <?= htmlspecialchars($recipe['category_name'] ?? 'General') ?>
                    </span>
                    <span style="color: var(--cm-gold); font-weight: 800; font-size: 14px;">
                        <i class="fa-solid fa-star"></i> <?= number_format($recipe['rating'], 1) ?>
                    </span>
                    <span style="color: var(--cm-text-muted); font-size: 12px;">
                        ID: <code><?= htmlspecialchars($recipe['id']) ?></code>
                    </span>
                </div>

                <h1 style="font-size: 32px; font-weight: 800; margin-bottom: 8px; color: var(--cm-text-primary);">
                    <?= htmlspecialchars($recipe['title']) ?>
                </h1>

                <div style="font-size: 14px; color: var(--cm-text-secondary); margin-bottom: 16px;">
                    Cuisine: <strong style="color: var(--cm-text-primary);"><?= htmlspecialchars($recipe['cuisine']) ?></strong>
                    • Region: <strong style="color: var(--cm-text-primary);"><?= htmlspecialchars($recipe['region'] ?: 'Traditional') ?></strong>
                    • Chef: <strong style="color: var(--cm-primary);"><?= htmlspecialchars($recipe['chef_name']) ?></strong>
                </div>

                <p style="color: #CCCCCC; font-size: 14px; line-height: 1.7; margin-bottom: 24px;">
                    <?= nl2br(htmlspecialchars($recipe['description'])) ?>
                </p>
            </div>

            <!-- Metrics Pills -->
            <div style="display: flex; flex-wrap: wrap; gap: 12px; border-top: 1px solid var(--cm-border); padding-top: 20px;">
                <div style="background: var(--cm-surface); padding: 10px 16px; border-radius: 12px; border: 1px solid var(--cm-border);">
                    <div style="font-size: 11px; color: var(--cm-text-muted); font-weight: 700; text-transform: uppercase;">Prep Time</div>
                    <div style="font-weight: 800; color: var(--cm-text-primary); font-size: 16px;"><?= $recipe['prep_time_minutes'] ?> mins</div>
                </div>

                <div style="background: var(--cm-surface); padding: 10px 16px; border-radius: 12px; border: 1px solid var(--cm-border);">
                    <div style="font-size: 11px; color: var(--cm-text-muted); font-weight: 700; text-transform: uppercase;">Cook Time</div>
                    <div style="font-weight: 800; color: var(--cm-text-primary); font-size: 16px;"><?= $recipe['cook_time_minutes'] ?> mins</div>
                </div>

                <div style="background: var(--cm-surface); padding: 10px 16px; border-radius: 12px; border: 1px solid var(--cm-border);">
                    <div style="font-size: 11px; color: var(--cm-text-muted); font-weight: 700; text-transform: uppercase;">Total Time</div>
                    <div style="font-weight: 800; color: var(--cm-primary); font-size: 16px;"><?= $recipe['prep_time_minutes'] + $recipe['cook_time_minutes'] ?> mins</div>
                </div>

                <div style="background: var(--cm-surface); padding: 10px 16px; border-radius: 12px; border: 1px solid var(--cm-border);">
                    <div style="font-size: 11px; color: var(--cm-text-muted); font-weight: 700; text-transform: uppercase;">Servings</div>
                    <div style="font-weight: 800; color: var(--cm-text-primary); font-size: 16px;"><?= $recipe['servings'] ?> portions</div>
                </div>

                <div style="background: var(--cm-surface); padding: 10px 16px; border-radius: 12px; border: 1px solid var(--cm-border);">
                    <div style="font-size: 11px; color: var(--cm-text-muted); font-weight: 700; text-transform: uppercase;">Difficulty</div>
                    <div style="font-weight: 800; color: var(--cm-text-primary); font-size: 16px;"><?= htmlspecialchars($recipe['difficulty']) ?></div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Nutrition & Tags -->
<?php if (!empty($recipe['nutrition']) || !empty($recipe['tags'])): ?>
    <div class="card" style="margin-bottom: 24px;">
        <div style="display: flex; flex-wrap: wrap; justify-content: space-between; gap: 16px;">
            <?php if (!empty($recipe['nutrition'])): ?>
                <div>
                    <span style="font-size: 12px; font-weight: 800; color: var(--cm-primary); text-transform: uppercase; letter-spacing: 0.5px;">Nutritional Info</span>
                    <div style="font-size: 14px; font-weight: 700; color: var(--cm-text-primary); margin-top: 4px;">
                        <i class="fa-solid fa-fire" style="color: var(--cm-secondary);"></i> <?= htmlspecialchars($recipe['nutrition']) ?>
                    </div>
                </div>
            <?php endif; ?>

            <?php if (!empty($recipe['tags'])): ?>
                <div>
                    <span style="font-size: 12px; font-weight: 800; color: var(--cm-text-muted); text-transform: uppercase; letter-spacing: 0.5px;">Tags</span>
                    <div style="display: flex; flex-wrap: wrap; gap: 6px; margin-top: 6px;">
                        <?php foreach (explode(',', $recipe['tags']) as $t): ?>
                            <span class="badge" style="background: #262626; color: #CCCCCC; font-size: 11px;">
                                <?= htmlspecialchars(trim($t)) ?>
                            </span>
                        <?php endforeach; ?>
                    </div>
                </div>
            <?php endif; ?>
        </div>
    </div>
<?php endif; ?>

<!-- 2 Columns: Ingredients & Instructions -->
<div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(360px, 1fr)); gap: 24px;">
    <!-- Column 1: Ingredients -->
    <div class="card">
        <div class="card-header">
            <h3 class="card-title"><i class="fa-solid fa-basket-shopping" style="color: var(--cm-primary);"></i> Ingredients (<?= count($ingredients) ?>)</h3>
        </div>

        <ul style="list-style: none; padding: 0; margin: 0; display: flex; flex-direction: column; gap: 10px;">
            <?php if (empty($ingredients)): ?>
                <li style="color: var(--cm-text-muted); font-size: 14px;">No ingredients recorded.</li>
            <?php else: ?>
                <?php foreach ($ingredients as $ing): ?>
                    <li style="display: flex; justify-content: space-between; align-items: center; background: var(--cm-surface); padding: 12px 16px; border-radius: 10px; border: 1px solid var(--cm-border);">
                        <span style="font-weight: 700; color: var(--cm-text-primary); font-size: 14px;">
                            <?= htmlspecialchars($ing['name']) ?>
                            <?php if (!empty($ing['notes'])): ?>
                                <small style="display: block; color: var(--cm-text-muted); font-weight: 400;"><?= htmlspecialchars($ing['notes']) ?></small>
                            <?php endif; ?>
                        </span>
                        <span style="font-size: 13px; font-weight: 800; color: var(--cm-primary); background: rgba(255, 107, 53, 0.1); padding: 4px 10px; border-radius: 6px;">
                            <?= htmlspecialchars($ing['amount']) ?> <?= htmlspecialchars($ing['unit']) ?>
                        </span>
                    </li>
                <?php endforeach; ?>
            <?php endif; ?>
        </ul>
    </div>

    <!-- Column 2: Instructions -->
    <div class="card">
        <div class="card-header">
            <h3 class="card-title"><i class="fa-solid fa-fire-burner" style="color: var(--cm-primary);"></i> Instructions (<?= count($instructions) ?> Steps)</h3>
        </div>

        <div style="display: flex; flex-direction: column; gap: 14px;">
            <?php if (empty($instructions)): ?>
                <p style="color: var(--cm-text-muted); font-size: 14px;">No steps recorded.</p>
            <?php else: ?>
                <?php foreach ($instructions as $ins): ?>
                    <div style="display: flex; gap: 14px; background: var(--cm-surface); padding: 16px; border-radius: 12px; border: 1px solid var(--cm-border);">
                        <span style="background: var(--cm-primary); color: #FFF; width: 32px; height: 32px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: 800; font-size: 14px; flex-shrink: 0;">
                            <?= $ins['step_number'] ?>
                        </span>
                        <div style="flex: 1;">
                            <p style="margin: 0; font-size: 14px; line-height: 1.6; color: var(--cm-text-primary);">
                                <?= nl2br(htmlspecialchars($ins['instruction'])) ?>
                            </p>
                            <?php if (!empty($ins['timer_seconds']) && $ins['timer_seconds'] > 0): ?>
                                <span style="display: inline-flex; align-items: center; gap: 5px; font-size: 12px; color: var(--cm-primary); margin-top: 8px; font-weight: 700;">
                                    <i class="fa-regular fa-clock"></i> <?= round($ins['timer_seconds'] / 60, 1) ?> mins timer (<?= $ins['timer_seconds'] ?>s)
                                </span>
                            <?php endif; ?>
                            <?php if (!empty($ins['tip'])): ?>
                                <div style="font-size: 12px; color: #81C784; background: rgba(76, 175, 80, 0.1); padding: 6px 10px; border-radius: 6px; margin-top: 8px; border-left: 3px solid #4CAF50;">
                                    💡 <strong>Chef Tip:</strong> <?= htmlspecialchars($ins['tip']) ?>
                                </div>
                            <?php endif; ?>
                        </div>
                    </div>
                <?php endforeach; ?>
            <?php endif; ?>
        </div>
    </div>
</div>

<?php require_once __DIR__ . '/includes/footer.php'; ?>
