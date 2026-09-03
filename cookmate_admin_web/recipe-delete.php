<?php
/**
 * CookMate Web Admin - Delete Recipe Handler
 */
require_once __DIR__ . '/config/db.php';
$pdo = get_db_connection();

// Accept ID from POST (preferred) or GET
$id = trim($_POST['id'] ?? $_GET['id'] ?? '');

if (!empty($id)) {
    try {
        $stmt = $pdo->prepare("SELECT title FROM recipes WHERE id = ?");
        $stmt->execute([$id]);
        $title = $stmt->fetchColumn();

        if ($title !== false) {
            $pdo->beginTransaction();

            // CASCADE foreign keys delete child rows, but explicit delete ensures compatibility
            $pdo->prepare("DELETE FROM recipe_instructions WHERE recipe_id = ?")->execute([$id]);
            $pdo->prepare("DELETE FROM recipe_ingredients WHERE recipe_id = ?")->execute([$id]);

            $delStmt = $pdo->prepare("DELETE FROM recipes WHERE id = ?");
            $delStmt->execute([$id]);

            if ($delStmt->rowCount() > 0) {
                $pdo->commit();
                set_flash_message('success', "Recipe \"$title\" has been permanently deleted from database.");
            } else {
                $pdo->rollBack();
                set_flash_message('warning', "Recipe \"$title\" could not be deleted (0 rows affected).");
            }
        } else {
            set_flash_message('warning', "Recipe not found in database (ID: " . htmlspecialchars($id) . ").");
        }
    } catch (Exception $e) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        set_flash_message('danger', "Error deleting recipe: " . $e->getMessage());
    }
} else {
    set_flash_message('warning', "No recipe ID specified for deletion.");
}

header('Location: ' . BASE_URL . '/recipes.php');
exit;
