<?php
/**
 * CookMate API - User Notifications Endpoint
 * GET /api/notifications/index.php
 * POST /api/notifications/index.php (mark read)
 */

require_once __DIR__ . '/../../config/db.php';
require_once __DIR__ . '/../../includes/auth_middleware.php';

set_cors_headers();

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

$pdo = get_db_connection();
$user = get_authenticated_user($pdo, true);
$userId = (int)$user['id'];

// Handle Mark as Read
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $input = json_decode(file_get_contents('php://input'), true) ?? $_POST;
    $notifId = (int)($input['notification_id'] ?? $input['id'] ?? 0);

    if ($notifId > 0) {
        $up = $pdo->prepare("UPDATE user_notifications SET is_read = 1 WHERE id = ? AND user_id = ?");
        $up->execute([$notifId, $userId]);
    } else {
        // Mark all as read
        $up = $pdo->prepare("UPDATE user_notifications SET is_read = 1 WHERE user_id = ?");
        $up->execute([$userId]);
    }

    json_response(['success' => true, 'message' => 'Notifications updated.']);
}

// GET: Fetch list
try {
    $stmt = $pdo->prepare("
        SELECT id, submission_id, title, message, type, is_read, created_at
        FROM user_notifications
        WHERE user_id = ?
        ORDER BY created_at DESC
        LIMIT 50
    ");
    $stmt->execute([$userId]);
    $notifications = $stmt->fetchAll();

    $unreadCount = (int)$pdo->query("SELECT COUNT(*) FROM user_notifications WHERE user_id = $userId AND is_read = 0")->fetchColumn();

    json_response([
        'success' => true,
        'unread_count' => $unreadCount,
        'count' => count($notifications),
        'data' => array_map(function($n) {
            return [
                'id' => (int)$n['id'],
                'submission_id' => $n['submission_id'] ? (int)$n['submission_id'] : null,
                'title' => $n['title'],
                'message' => $n['message'],
                'type' => $n['type'],
                'is_read' => (bool)$n['is_read'],
                'created_at' => $n['created_at'],
            ];
        }, $notifications)
    ]);
} catch (Exception $e) {
    json_response([
        'success' => false,
        'message' => 'Failed to fetch notifications: ' . $e->getMessage()
    ], 500);
}
