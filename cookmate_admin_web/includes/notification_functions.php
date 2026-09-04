<?php
/**
 * CookMate - Notification Functions & Reusable Service Layer
 * Implements relational notification management, the strict 24-hour read retention query rule,
 * idempotent read timestamp handling, and automatic event dispatching.
 */

require_once __DIR__ . '/../config/db.php';

/**
 * Creates a notification in the main catalog table.
 *
 * @param PDO $pdo
 * @param array $data [title, message, type, target_type, target_user_id, related_type, related_id, image, status, created_by_admin_id, expires_at]
 * @return int The created notification ID
 */
function create_system_notification(PDO $pdo, array $data): int {
    $stmt = $pdo->prepare("
        INSERT INTO notifications (
            title,
            message,
            type,
            target_type,
            target_user_id,
            related_type,
            related_id,
            image,
            action_label,
            status,
            created_by_admin_id,
            expires_at,
            created_at
        ) VALUES (
            ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW()
        )
    ");

    $targetType = in_array($data['target_type'] ?? '', ['all', 'specific_user', 'all_except_user', 'selected_users']) ? $data['target_type'] : 'all';
    $status = in_array($data['status'] ?? '', ['active', 'inactive']) ? $data['status'] : 'active';

    $stmt->execute([
        trim($data['title'] ?? ''),
        trim($data['message'] ?? ''),
        trim($data['type'] ?? 'general'),
        $targetType,
        !empty($data['target_user_id']) ? (int)$data['target_user_id'] : null,
        !empty($data['related_type']) ? trim($data['related_type']) : null,
        !empty($data['related_id']) ? trim($data['related_id']) : null,
        !empty($data['image']) ? trim($data['image']) : null,
        !empty($data['action_label']) ? trim($data['action_label']) : null,
        $status,
        !empty($data['created_by_admin_id']) ? (int)$data['created_by_admin_id'] : 1,
        !empty($data['expires_at']) ? $data['expires_at'] : null,
    ]);

    return (int)$pdo->lastInsertId();
}

/**
 * Returns notifications for an authenticated user following the exact 24-hour read rule:
 * - Unread (is_read = 0 or no entry) -> ALWAYS show
 * - Read (is_read = 1 and read_at within 24h) -> SHOW
 * - Read > 24 hours ago -> AUTOMATICALLY HIDE
 *
 * @param PDO $pdo
 * @param int $userId
 * @param int $page
 * @param int $limit
 * @param string|null $filter 'all', 'unread', or null
 * @return array
 */
function get_user_notifications(PDO $pdo, int $userId, int $page = 1, int $limit = 20, ?string $filter = null): array {
    $page = max(1, $page);
    $limit = max(1, min(100, $limit));
    $offset = ($page - 1) * $limit;

    $filterClause = '';
    if ($filter === 'unread') {
        $filterClause = " AND (un.is_read IS NULL OR un.is_read = 0) ";
    }

    $sql = "
        SELECT 
            n.id,
            n.title,
            n.message,
            n.type,
            n.target_type,
            n.target_user_id,
            n.related_type,
            n.related_id,
            n.image,
            n.action_label,
            n.status,
            n.created_at,
            COALESCE(un.is_read, 0) AS is_read,
            un.read_at
        FROM notifications n
        LEFT JOIN user_notifications un 
               ON un.notification_id = n.id AND un.user_id = ?
        WHERE n.status = 'active'
          AND (
               n.target_type = 'all' 
               OR (n.target_type = 'specific_user' AND n.target_user_id = ?)
               OR (n.target_type = 'all_except_user' AND (n.target_user_id IS NULL OR n.target_user_id != ?))
          )
          AND (n.expires_at IS NULL OR n.expires_at > NOW())
          AND (un.is_dismissed IS NULL OR un.is_dismissed = 0)
          AND (
               un.is_read IS NULL 
               OR un.is_read = 0 
               OR (un.is_read = 1 AND un.read_at > NOW() - INTERVAL 24 HOUR)
          )
          {$filterClause}
        ORDER BY n.created_at DESC
        LIMIT ? OFFSET ?
    ";

    $stmt = $pdo->prepare($sql);
    $stmt->bindValue(1, $userId, PDO::PARAM_INT);
    $stmt->bindValue(2, $userId, PDO::PARAM_INT);
    $stmt->bindValue(3, $userId, PDO::PARAM_INT);
    $stmt->bindValue(4, $limit, PDO::PARAM_INT);
    $stmt->bindValue(5, $offset, PDO::PARAM_INT);
    $stmt->execute();
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);

    return array_map(function($r) {
        return [
            'id'           => (int)$r['id'],
            'title'        => $r['title'],
            'message'      => $r['message'],
            'type'         => $r['type'],
            'target_type'  => $r['target_type'],
            'related_type' => $r['related_type'],
            'related_id'   => $r['related_id'],
            'image'        => $r['image'],
            'action_label' => $r['action_label'] ?? null,
            'is_read'      => (bool)$r['is_read'],
            'read_at'      => $r['read_at'],
            'created_at'   => $r['created_at'],
        ];
    }, $rows);
}

/**
 * Returns the exact count of unread notifications for a given user.
 *
 * @param PDO $pdo
 * @param int $userId
 * @return int
 */
function get_user_unread_count(PDO $pdo, int $userId): int {
    $stmt = $pdo->prepare("
        SELECT COUNT(*)
        FROM notifications n
        LEFT JOIN user_notifications un 
               ON un.notification_id = n.id AND un.user_id = ?
        WHERE n.status = 'active'
          AND (
               n.target_type = 'all' 
               OR (n.target_type = 'specific_user' AND n.target_user_id = ?)
               OR (n.target_type = 'all_except_user' AND (n.target_user_id IS NULL OR n.target_user_id != ?))
          )
          AND (n.expires_at IS NULL OR n.expires_at > NOW())
          AND (un.is_dismissed IS NULL OR un.is_dismissed = 0)
          AND (un.is_read IS NULL OR un.is_read = 0)
    ");
    $stmt->execute([$userId, $userId, $userId]);
    return (int)$stmt->fetchColumn();
}

/**
 * Marks a single notification as read.
 * Strict idempotency rule: If already read, does NOT change read_at!
 *
 * @param PDO $pdo
 * @param int $notificationId
 * @param int $userId
 * @return bool
 */
function mark_notification_as_read(PDO $pdo, int $notificationId, int $userId): bool {
    $stmt = $pdo->prepare("
        INSERT INTO user_notifications (
            notification_id,
            user_id,
            is_read,
            read_at,
            created_at,
            updated_at
        ) VALUES (
            ?,
            ?,
            1,
            NOW(),
            NOW(),
            NOW()
        )
        ON DUPLICATE KEY UPDATE
            is_read = 1,
            read_at = IF(read_at IS NULL, NOW(), read_at),
            updated_at = NOW()
    ");

    return $stmt->execute([$notificationId, $userId]);
}

/**
 * Marks all currently unread notifications as read for a given user.
 * Existing read notifications preserve their original read_at.
 *
 * @param PDO $pdo
 * @param int $userId
 * @return int Number of newly marked notifications
 */
function mark_all_notifications_as_read(PDO $pdo, int $userId): int {
    // 1. Fetch all unread notification IDs applicable to this user
    $stmt = $pdo->prepare("
        SELECT n.id 
        FROM notifications n
        LEFT JOIN user_notifications un 
               ON un.notification_id = n.id AND un.user_id = ?
        WHERE n.status = 'active'
          AND (
               n.target_type = 'all' 
               OR (n.target_type = 'specific_user' AND n.target_user_id = ?)
               OR (n.target_type = 'all_except_user' AND (n.target_user_id IS NULL OR n.target_user_id != ?))
          )
          AND (n.expires_at IS NULL OR n.expires_at > NOW())
          AND (un.is_dismissed IS NULL OR un.is_dismissed = 0)
          AND (un.is_read IS NULL OR un.is_read = 0)
    ");
    $stmt->execute([$userId, $userId, $userId]);
    $unreadIds = $stmt->fetchAll(PDO::FETCH_COLUMN);

    if (empty($unreadIds)) {
        return 0;
    }

    $upsert = $pdo->prepare("
        INSERT INTO user_notifications (
            notification_id,
            user_id,
            is_read,
            read_at,
            created_at,
            updated_at
        ) VALUES (
            ?,
            ?,
            1,
            NOW(),
            NOW(),
            NOW()
        )
        ON DUPLICATE KEY UPDATE
            is_read = 1,
            read_at = IF(read_at IS NULL, NOW(), read_at),
            updated_at = NOW()
    ");

    $count = 0;
    foreach ($unreadIds as $nId) {
        $upsert->execute([(int)$nId, $userId]);
        $count++;
    }

    return $count;
}

/**
 * Marks a notification as unread (Section 15 optional).
 *
 * @param PDO $pdo
 * @param int $notificationId
 * @param int $userId
 * @return bool
 */
function mark_notification_as_unread(PDO $pdo, int $notificationId, int $userId): bool {
    $stmt = $pdo->prepare("
        INSERT INTO user_notifications (
            notification_id,
            user_id,
            is_read,
            read_at,
            created_at,
            updated_at
        ) VALUES (
            ?,
            ?,
            0,
            NULL,
            NOW(),
            NOW()
        )
        ON DUPLICATE KEY UPDATE
            is_read = 0,
            read_at = NULL,
            updated_at = NOW()
    ");

    return $stmt->execute([$notificationId, $userId]);
}

/**
 * Retrieves high-level notification statistics for Admin dashboard.
 *
 * @param PDO $pdo
 * @return array
 */
function get_admin_notification_stats(PDO $pdo): array {
    try {
        $total = (int)$pdo->query("SELECT COUNT(*) FROM notifications")->fetchColumn();
        $active = (int)$pdo->query("SELECT COUNT(*) FROM notifications WHERE status = 'active'")->fetchColumn();
        $today = (int)$pdo->query("SELECT COUNT(*) FROM notifications WHERE DATE(created_at) = CURDATE()")->fetchColumn();
        $readCount = (int)$pdo->query("SELECT COUNT(*) FROM user_notifications WHERE is_read = 1")->fetchColumn();
        $unreadCount = (int)$pdo->query("SELECT COUNT(*) FROM user_notifications WHERE is_read = 0")->fetchColumn();

        return [
            'total'        => $total,
            'active'       => $active,
            'sent_today'   => $today,
            'read_count'   => $readCount,
            'unread_count' => $unreadCount,
        ];
    } catch (Exception $e) {
        return [
            'total'        => 0,
            'active'       => 0,
            'sent_today'   => 0,
            'read_count'   => 0,
            'unread_count' => 0,
        ];
    }
}
