<?php
/**
 * CookMate Web Admin - REST API endpoint for Recipes
 */
require_once __DIR__ . '/../config/db.php';
$pdo = get_db_connection();

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');

$search = trim($_GET['q'] ?? '');
$category = trim($_GET['category'] ?? '');
$limit = min(200, max(1, (int)($_GET['limit'] ?? 50)));
$offset = max(0, (int)($_GET['offset'] ?? 0));

$where = [];
$params = [];

if ($search !== '') {
    $where[] = "(title LIKE ? OR chef_name LIKE ? OR cuisine LIKE ? OR tags LIKE ?)";
    $term = "%$search%";
    $params = [$term, $term, $term, $term];
}

if ($category !== '') {
    $where[] = "category_id = ?";
    $params[] = $category;
}

$whereSql = !empty($where) ? 'WHERE ' . implode(' AND ', $where) : '';

$stmt = $pdo->prepare("SELECT * FROM recipes $whereSql ORDER BY rating DESC LIMIT $limit OFFSET $offset");
$stmt->execute($params);
$recipes = $stmt->fetchAll();

// Include ingredients and steps for each
foreach ($recipes as &$r) {
    $ingStmt = $pdo->prepare("SELECT name, amount, unit, notes FROM recipe_ingredients WHERE recipe_id = ? ORDER BY sort_order ASC");
    $ingStmt->execute([$r['id']]);
    $r['ingredients'] = $ingStmt->fetchAll();

    $insStmt = $pdo->prepare("SELECT step_number, instruction, timer_seconds, tip FROM recipe_instructions WHERE recipe_id = ? ORDER BY step_number ASC");
    $insStmt->execute([$r['id']]);
    $r['instructions'] = $insStmt->fetchAll();
}

echo json_encode([
    'status' => 'success',
    'count' => count($recipes),
    'data' => $recipes
], JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE);
