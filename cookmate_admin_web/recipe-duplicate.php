<?php
/**
 * CookMate Web Admin - Duplicate Recipe Handler
 */
require_once __DIR__ . '/config/db.php';
$pdo = get_db_connection();

$id = trim($_GET['id'] ?? '');
if (empty($id)) {
    header('Location: ' . BASE_URL . '/recipes.php');
    exit;
}

try {
    $stmt = $pdo->prepare("SELECT * FROM recipes WHERE id = ?");
    $stmt->execute([$id]);
    $rec = $stmt->fetch();

    if (!$rec) {
        set_flash_message('danger', 'Original recipe not found.');
        header('Location: ' . BASE_URL . '/recipes.php');
        exit;
    }

    $pdo->beginTransaction();

    $newId = 'rec_' . bin2hex(random_bytes(4));
    $newTitle = 'Copy of ' . $rec['title'];

    $inStmt = $pdo->prepare("
        INSERT INTO recipes (
            id, title, description, chef_name, cuisine, image_url,
            prep_time_minutes, cook_time_minutes, servings, difficulty,
            category_id, tags, is_favorite, is_custom, is_vegetarian,
            rating, region, subcategory, nutrition
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1, ?, ?, ?, ?, ?)
    ");
    $inStmt->execute([
        $newId, $newTitle, $rec['description'], $rec['chef_name'], $rec['cuisine'], $rec['image_url'],
        $rec['prep_time_minutes'], $rec['cook_time_minutes'], $rec['servings'], $rec['difficulty'],
        $rec['category_id'], $rec['tags'], 0, $rec['is_vegetarian'],
        $rec['rating'], $rec['region'], $rec['subcategory'], $rec['nutrition']
    ]);

    // Clone ingredients
    $ingStmt = $pdo->prepare("SELECT * FROM recipe_ingredients WHERE recipe_id = ? ORDER BY sort_order ASC");
    $ingStmt->execute([$id]);
    $ingredients = $ingStmt->fetchAll();

    $ingInsert = $pdo->prepare("INSERT INTO recipe_ingredients (id, recipe_id, name, amount, unit, notes, is_optional, sort_order) VALUES (?, ?, ?, ?, ?, ?, ?, ?)");
    foreach ($ingredients as $idx => $ing) {
        $newIngId = $newId . '_ing_' . ($idx + 1) . '_' . bin2hex(random_bytes(2));
        $ingInsert->execute([$newIngId, $newId, $ing['name'], $ing['amount'], $ing['unit'], $ing['notes'], $ing['is_optional'], $ing['sort_order']]);
    }

    // Clone steps
    $insStmt = $pdo->prepare("SELECT * FROM recipe_instructions WHERE recipe_id = ? ORDER BY step_number ASC");
    $insStmt->execute([$id]);
    $steps = $insStmt->fetchAll();

    $insInsert = $pdo->prepare("INSERT INTO recipe_instructions (id, recipe_id, step_number, instruction, timer_seconds, tip) VALUES (?, ?, ?, ?, ?, ?)");
    foreach ($steps as $st) {
        $newStepId = $newId . '_step_' . $st['step_number'] . '_' . bin2hex(random_bytes(2));
        $insInsert->execute([$newStepId, $newId, $st['step_number'], $st['instruction'], $st['timer_seconds'], $st['tip']]);
    }

    $pdo->commit();
    set_flash_message('success', "Recipe duplicated as \"$newTitle\". You can now customize it!");
    header('Location: ' . BASE_URL . '/recipe-form.php?id=' . urlencode($newId));
    exit;
} catch (Exception $e) {
    if ($pdo->inTransaction()) {
        $pdo->rollBack();
    }
    set_flash_message('danger', 'Error duplicating recipe: ' . $e->getMessage());
    header('Location: ' . BASE_URL . '/recipes.php');
    exit;
}
