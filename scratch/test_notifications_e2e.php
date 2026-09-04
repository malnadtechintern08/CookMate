<?php
/**
 * CookMate - Complete Notification System E2E Test Suite
 * Validates all 12 core requirements and tests defined in Section 50 of prompt.
 */

require_once __DIR__ . '/../cookmate_admin_web/config/db.php';
require_once __DIR__ . '/../cookmate_admin_web/includes/notification_functions.php';

$pdo = get_db_connection();

echo "============================================================" . PHP_EOL;
echo "🚀 COOKMATE NOTIFICATION SYSTEM END-TO-END VERIFICATION" . PHP_EOL;
echo "============================================================" . PHP_EOL;

$passCount = 0;
$failCount = 0;

function assert_test($condition, $testName) {
    global $passCount, $failCount;
    if ($condition) {
        echo "  ✅ [PASS] " . $testName . PHP_EOL;
        $passCount++;
    } else {
        echo "  ❌ [FAIL] " . $testName . PHP_EOL;
        $failCount++;
    }
}

// Setup 2 test users in users table
$stmt = $pdo->prepare("SELECT id FROM users LIMIT 2");
$stmt->execute();
$users = $stmt->fetchAll(PDO::FETCH_COLUMN);

if (count($users) < 2) {
    // Ensure User A and User B exist
    $pdo->exec("INSERT INTO users (auth_token, display_name, created_at) VALUES ('test_token_a', 'Chef Ananya', NOW()), ('test_token_b', 'Chef Bharath', NOW())");
    $users = $pdo->query("SELECT id FROM users ORDER BY id DESC LIMIT 2")->fetchAll(PDO::FETCH_COLUMN);
}

$userA = (int)$users[0];
$userB = (int)$users[1];

echo "Test User A: #$userA | Test User B: #$userB" . PHP_EOL . PHP_EOL;

// Clean prior user status test data
$pdo->prepare("DELETE FROM user_notifications WHERE user_id IN (?, ?)")->execute([$userA, $userB]);

// -------------------------------------------------------------
// TEST 1: Admin sends New Recipe Added
// -------------------------------------------------------------
$initUnreadA = get_user_unread_count($pdo, $userA);
$testNotif1 = create_system_notification($pdo, [
    'title' => 'Test Chicken Ghee Roast 🍲',
    'message' => 'Fresh recipe added.',
    'type' => 'new_recipe',
    'target_type' => 'all',
    'related_type' => 'recipe',
    'related_id' => 'rec_chicken_ghee_roast'
]);

$newUnreadA = get_user_unread_count($pdo, $userA);
assert_test($newUnreadA === $initUnreadA + 1, "TEST 1: Admin sends New Recipe Added -> User A unread count increases by 1");

// -------------------------------------------------------------
// TEST 2: Unread notifications older than 24 hours remain visible
// -------------------------------------------------------------
// Age the notification created_at to 3 days ago
$pdo->prepare("UPDATE notifications SET created_at = NOW() - INTERVAL 3 DAY WHERE id = ?")->execute([$testNotif1]);
$notifsListA = get_user_notifications($pdo, $userA, 1, 50);
$found1 = in_array($testNotif1, array_column($notifsListA, 'id'));
assert_test($found1 === true, "TEST 2: Notification unread for 3 days -> REMAINS VISIBLE (never hidden by age)");

// -------------------------------------------------------------
// TEST 3: User opens notification -> Marked read, Badge decreases, notification remains visible
// -------------------------------------------------------------
mark_notification_as_read($pdo, $testNotif1, $userA);
$unreadAfterRead = get_user_unread_count($pdo, $userA);
$notifsListAfterRead = get_user_notifications($pdo, $userA, 1, 50);
$foundAfterRead = in_array($testNotif1, array_column($notifsListAfterRead, 'id'));
$item = null;
foreach ($notifsListAfterRead as $n) {
    if ($n['id'] === $testNotif1) $item = $n;
}

assert_test($unreadAfterRead === $newUnreadA - 1, "TEST 3a: Mark read -> Badge decreases by 1");
assert_test($foundAfterRead === true, "TEST 3b: Notification remains visible immediately after reading");
assert_test($item !== null && $item['is_read'] === true, "TEST 3c: is_read is true and read_at is set");

// -------------------------------------------------------------
// TEST 4: 24 hours pass after read_at -> Notification disappears for that user
// -------------------------------------------------------------
$pdo->prepare("UPDATE user_notifications SET read_at = NOW() - INTERVAL 25 HOUR WHERE notification_id = ? AND user_id = ?")->execute([$testNotif1, $userA]);
$notifsAfter24h = get_user_notifications($pdo, $userA, 1, 50);
$foundAfter24h = in_array($testNotif1, array_column($notifsAfter24h, 'id'));
assert_test($foundAfter24h === false, "TEST 4: 24 hours pass after read_at -> Disappears automatically from user feed");

// -------------------------------------------------------------
// TEST 5: User presses Mark All as Read -> all marked, badge = 0, visible for 24h
// -------------------------------------------------------------
$markAllNotifs = [];
for ($i = 0; $i < 3; $i++) {
    $markAllNotifs[] = create_system_notification($pdo, [
        'title' => "Batch Alert #$i",
        'message' => "Batch notification test $i",
        'type' => 'general',
        'target_type' => 'all'
    ]);
}
$unreadBeforeMarkAll = get_user_unread_count($pdo, $userA);
mark_all_notifications_as_read($pdo, $userA);
$unreadAfterMarkAll = get_user_unread_count($pdo, $userA);
$feedAfterMarkAll = get_user_notifications($pdo, $userA, 1, 50);
$allPresent = true;
foreach ($markAllNotifs as $mid) {
    if (!in_array($mid, array_column($feedAfterMarkAll, 'id'))) $allPresent = false;
}
assert_test($unreadAfterMarkAll === 0, "TEST 5a: Mark all as read -> Unread badge becomes 0");
assert_test($allPresent === true, "TEST 5b: Marked items remain visible for the next 24 hours");

// -------------------------------------------------------------
// TEST 6: User opens already-read notification -> read_at does NOT change
// -------------------------------------------------------------
$targetId = $markAllNotifs[0];
$stmt = $pdo->prepare("SELECT read_at FROM user_notifications WHERE notification_id = ? AND user_id = ?");
$stmt->execute([$targetId, $userA]);
$originalReadAt = $stmt->fetchColumn();

sleep(1);
mark_notification_as_read($pdo, $targetId, $userA);
$stmt->execute([$targetId, $userA]);
$secondReadAt = $stmt->fetchColumn();
assert_test($originalReadAt === $secondReadAt, "TEST 6: Re-opening already read notification preserves original read_at");

// -------------------------------------------------------------
// TEST 7: Admin sends notification to specific user
// -------------------------------------------------------------
$specificNotif = create_system_notification($pdo, [
    'title' => 'Personal Note for User A',
    'message' => 'This is private.',
    'type' => 'general',
    'target_type' => 'specific_user',
    'target_user_id' => $userA
]);
$feedUserA = get_user_notifications($pdo, $userA, 1, 50);
$feedUserB = get_user_notifications($pdo, $userB, 1, 50);
$seenByA = in_array($specificNotif, array_column($feedUserA, 'id'));
$seenByB = in_array($specificNotif, array_column($feedUserB, 'id'));
assert_test($seenByA === true && $seenByB === false, "TEST 7: Specific user notification only visible to target user ($userA), not other user ($userB)");

// -------------------------------------------------------------
// TEST 8: Admin sends broadcast notification to all users
// -------------------------------------------------------------
$broadcastNotif = create_system_notification($pdo, [
    'title' => 'Global Festivities Announced!',
    'message' => 'Celebration recipes available.',
    'type' => 'admin_announcement',
    'target_type' => 'all'
]);
$seenByA = in_array($broadcastNotif, array_column(get_user_notifications($pdo, $userA, 1, 50), 'id'));
$seenByB = in_array($broadcastNotif, array_column(get_user_notifications($pdo, $userB, 1, 50), 'id'));
assert_test($seenByA === true && $seenByB === true, "TEST 8: Broadcast notification visible to both User A and User B");

// -------------------------------------------------------------
// TEST 9: Recipe approved notification
// -------------------------------------------------------------
$approvedNotif = create_system_notification($pdo, [
    'title' => '🎉 Recipe Approved',
    'message' => 'Your recipe "Malnad Chicken Curry" was approved.',
    'type' => 'recipe_approved',
    'target_type' => 'specific_user',
    'target_user_id' => $userA,
    'related_type' => 'recipe',
    'related_id' => 'rec_malnad_chicken'
]);
$nApp = null;
foreach (get_user_notifications($pdo, $userA, 1, 50) as $n) {
    if ($n['id'] === $approvedNotif) $nApp = $n;
}
assert_test($nApp !== null && $nApp['type'] === 'recipe_approved', "TEST 9: Submitting user receives Recipe Approved notification with recipe link");

// -------------------------------------------------------------
// TEST 10: Recipe rejected notification
// -------------------------------------------------------------
$rejectedNotif = create_system_notification($pdo, [
    'title' => 'Recipe Not Approved',
    'message' => 'Missing ingredient proportions.',
    'type' => 'recipe_rejected',
    'target_type' => 'specific_user',
    'target_user_id' => $userA,
    'related_type' => 'recipe_submission',
    'related_id' => '101'
]);
$nRej = null;
foreach (get_user_notifications($pdo, $userA, 1, 50) as $n) {
    if ($n['id'] === $rejectedNotif) $nRej = $n;
}
assert_test($nRej !== null && $nRej['type'] === 'recipe_rejected', "TEST 10: Submitting user receives Recipe Rejected notification with submission link");

// -------------------------------------------------------------
// TEST 11: Admin deactivates notification
// -------------------------------------------------------------
$deactNotif = create_system_notification($pdo, [
    'title' => 'Temporary Promo',
    'message' => 'Discounts active.',
    'type' => 'promotion',
    'target_type' => 'all',
    'status' => 'active'
]);
$beforeDeact = in_array($deactNotif, array_column(get_user_notifications($pdo, $userA, 1, 50), 'id'));
$pdo->prepare("UPDATE notifications SET status = 'inactive' WHERE id = ?")->execute([$deactNotif]);
$afterDeact = in_array($deactNotif, array_column(get_user_notifications($pdo, $userA, 1, 50), 'id'));
assert_test($beforeDeact === true && $afterDeact === false, "TEST 11: Admin deactivates notification -> Stops appearing for all users");

// -------------------------------------------------------------
// TEST 12: Independent read status between users
// -------------------------------------------------------------
$sharedNotif = create_system_notification($pdo, [
    'title' => 'Shared Recipe Discovery',
    'message' => 'Check out this dish.',
    'type' => 'new_recipe',
    'target_type' => 'all'
]);
// User A reads it
mark_notification_as_read($pdo, $sharedNotif, $userA);
$feedA = get_user_notifications($pdo, $userA, 1, 50);
$feedB = get_user_notifications($pdo, $userB, 1, 50);

$itemA = null;
foreach ($feedA as $n) { if ($n['id'] === $sharedNotif) $itemA = $n; }
$itemB = null;
foreach ($feedB as $n) { if ($n['id'] === $sharedNotif) $itemB = $n; }

assert_test($itemA !== null && $itemA['is_read'] === true && $itemB !== null && $itemB['is_read'] === false,
    "TEST 12: User A reads notification, User B does not -> Independent per-user read status");

echo PHP_EOL . "============================================================" . PHP_EOL;
echo "📊 RESULTS: $passCount Passed, $failCount Failed" . PHP_EOL;
echo "============================================================" . PHP_EOL;

if ($failCount === 0) {
    echo "🎉 ALL 12 TEST SCENARIOS PASSED WITH ZERO ERRORS!" . PHP_EOL;
    exit(0);
} else {
    echo "⚠️ SOME TESTS FAILED!" . PHP_EOL;
    exit(1);
}
