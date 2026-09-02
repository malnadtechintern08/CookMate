<?php
/**
 * CookMate Web Admin - Delete Recipe Handler
 */
require_once __DIR__ . '/config/db.php';
$pdo = get_db_connection();

$id = trim($_GET['id'] ?? '');
if (!empty($id)) {
    try {
        $stmt = $pdo->prepare("SELECT title FROM recipes WHERE id = ?");
        $stmt->execute([$id]);
        $title = $stmt->fetchColumn();

        if ($title !== false) {
            $delStmt = $pdo->prepare("DELETE FROM recipes WHERE id = ?");
            $delStmt->execute([$id]);
            set_flash_message('success', "Recipe \"$title\" has been deleted.");
        } else {
            set_flash_message('warning', "Recipe not found.");
        }
    } catch (Exception $e) {
        set_flash_message('danger', "Error deleting recipe: " . $e->getMessage());
    }
}

header('Location: ' . BASE_URL . '/recipes.php');
exit;
