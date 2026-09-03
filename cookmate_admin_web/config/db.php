<?php
/**
 * CookMate Web Admin - Database Connection Configuration
 * 
 * Unified database configuration for InfinityFree MySQL (and local environment fallback)
 */

// Enable error reporting for database debugging
error_reporting(E_ALL);
ini_set('display_errors', 1);

// =============================================================================
// 🌐 INFINITYFREE MYSQL CONFIGURATION (Primary / Production)
// =============================================================================
// MySQL Details from InfinityFree Client Area:
// Hostname: sql304.infinityfree.com (resolves internally via epizy / byetcluster)
// Port: 3306
// Full Database Name: if0_42812074_CookMate
// Username: if0_42812074
// Password: [configured below]
// =============================================================================
define('DB_HOST', getenv('DB_HOST') !== false ? getenv('DB_HOST') : 'sql304.infinityfree.com');
define('DB_PORT', getenv('DB_PORT') !== false ? getenv('DB_PORT') : '3306');
define('DB_NAME', getenv('DB_NAME') !== false ? getenv('DB_NAME') : 'if0_42812074_CookMate');
define('DB_USER', getenv('DB_USER') !== false ? getenv('DB_USER') : 'if0_42812074');
define('DB_PASS', getenv('DB_PASS') !== false ? getenv('DB_PASS') : '31p1SDy96pPstv5');

// Fully automatic Base URL detection (works in root directory, subfolders, or any domain)
if (!defined('BASE_URL')) {
    $scriptDir = str_replace('\\', '/', dirname($_SERVER['SCRIPT_NAME'] ?? ''));
    if (preg_match('#/(api|config|includes)$#', $scriptDir)) {
        $scriptDir = dirname($scriptDir);
    }
    $baseUrl = ($scriptDir === '/' || $scriptDir === '\\' || $scriptDir === '.') ? '' : rtrim($scriptDir, '/');
    define('BASE_URL', $baseUrl);
}

// Direct phpMyAdmin URL for if0_42812074_CookMate on InfinityFree
if (!defined('PHPMYADMIN_URL')) {
    define('PHPMYADMIN_URL', 'https://php-myadmin.net/db_structure.php?db=if0_42812074_CookMate');
}

// Tracks the active connected host and db for UI transparency
$GLOBALS['cm_connected_host'] = DB_HOST;
$GLOBALS['cm_connected_db'] = DB_NAME;

/**
 * Returns a PDO database connection instance with strict error reporting.
 */
function get_db_connection() {
    static $pdo = null;
    if ($pdo !== null) {
        return $pdo;
    }

    $options = [
        PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES   => false,
        PDO::ATTR_TIMEOUT            => 3,
    ];

    // Support PHP 8.5+ Pdo\Mysql::ATTR_FOUND_ROWS and backward compatibility
    if (defined('Pdo\Mysql::ATTR_FOUND_ROWS')) {
        $options[\Pdo\Mysql::ATTR_FOUND_ROWS] = true;
    } elseif (defined('PDO::MYSQL_ATTR_FOUND_ROWS')) {
        $options[PDO::MYSQL_ATTR_FOUND_ROWS] = true;
    }

    // Candidate host names for InfinityFree MySQL
    $hostsToTry = [
        DB_HOST,
        'sql304.epizy.com',
        'sql304.byetcluster.com',
    ];
    $hostsToTry = array_unique(array_filter($hostsToTry));

    $lastException = null;

    // 1. Attempt connection using primary InfinityFree credentials
    foreach ($hostsToTry as $host) {
        try {
            $dsn = "mysql:host={$host};port=" . DB_PORT . ";dbname=" . DB_NAME . ";charset=utf8mb4";
            $pdo = new PDO($dsn, DB_USER, DB_PASS, $options);
            $GLOBALS['cm_connected_host'] = $host;
            $GLOBALS['cm_connected_db'] = DB_NAME;
            return $pdo;
        } catch (PDOException $e) {
            $lastException = $e;
        }
    }

    // 2. Local fallback if external connection is blocked (InfinityFree blocks incoming port 3306 from external IPs)
    $isLocal = in_array($_SERVER['SERVER_NAME'] ?? '', ['localhost', '127.0.0.1'])
            || in_array(explode(':', $_SERVER['HTTP_HOST'] ?? '')[0], ['localhost', '127.0.0.1'])
            || php_sapi_name() === 'cli';

    if ($isLocal) {
        // Try local MySQL ports: 3307 (XAMPP Mac) then 3306 (Homebrew/Standard)
        foreach ([3307, 3306] as $localPort) {
            foreach ([DB_NAME, 'cookmate_db'] as $dbCandidate) {
                try {
                    $localDsn = "mysql:host=127.0.0.1;port={$localPort};dbname={$dbCandidate};charset=utf8mb4";
                    $pdo = new PDO($localDsn, 'root', '', $options);
                    $GLOBALS['cm_connected_host'] = "127.0.0.1:{$localPort}";
                    $GLOBALS['cm_connected_db'] = $dbCandidate;
                    return $pdo;
                } catch (PDOException $le) {
                    // Try next candidate
                }
            }
        }
    }

    // If all attempts fail, report the exact error
    $errMsg = $lastException ? $lastException->getMessage() : 'Unable to connect to MySQL database';
    
    if (php_sapi_name() === 'cli') {
        throw new PDOException("Database connection error: " . $errMsg);
    }

    die('<div style="font-family:-apple-system,BlinkMacSystemFont,\'Segoe UI\',Roboto,sans-serif;background:#0E0E0E;color:#FFF;padding:40px;text-align:center;min-height:100vh;">' .
        '<div style="max-width:600px;margin:40px auto;background:#1A1A1A;padding:32px;border-radius:16px;border:1px solid #262626;box-shadow:0 8px 32px rgba(0,0,0,0.5);">' .
        '<img src="' . BASE_URL . '/assets/images/cookmate_logo.png" style="height:60px;margin-bottom:20px;" alt="CookMate Logo">' .
        '<h2 style="margin-top:0;"><span class="brand-cookmate" style="font-family:\'Outfit\',sans-serif;font-weight:800;"><span class="cook-part" style="color:#FFFFFF !important;font-weight:800;">Cook</span><span class="mate-part" style="color:#E50915 !important;font-weight:800;">Mate</span></span> Database Notice</h2>' .
        '<p style="color:#E50915;font-size:15px;font-weight:600;">Unable to connect to MySQL Database: <code>' . htmlspecialchars(DB_NAME) . '</code></p>' .
        '<div style="background:#262626;color:#FF6B6B;padding:12px 16px;border-radius:8px;font-family:monospace;font-size:12px;text-align:left;word-break:break-all;margin:16px 0;">' .
        htmlspecialchars($errMsg) .
        '</div>' .
        '<p style="color:#A5A5A5;font-size:13px;line-height:1.6;">Target Host: <code>' . htmlspecialchars(DB_HOST) . ':' . htmlspecialchars(DB_PORT) . '</code><br>' .
        'Target User: <code>' . htmlspecialchars(DB_USER) . '</code></p>' .
        '<p><a href="' . BASE_URL . '/db_test.php" style="display:inline-block;padding:10px 20px;background:#333;color:#fff;text-decoration:none;border-radius:8px;font-size:13px;margin-right:10px;">Run Connection Diagnostic</a>' .
        '<a href="' . PHPMYADMIN_URL . '" target="_blank" style="display:inline-block;padding:10px 20px;background:#E50915;color:#fff;text-decoration:none;border-radius:8px;font-weight:700;font-size:13px;">Open phpMyAdmin &rarr;</a></p>' .
        '</div></div>');
}

function sanitize($data) {
    return htmlspecialchars(trim($data ?? ''), ENT_QUOTES, 'UTF-8');
}

function set_flash_message($type, $message) {
    if (session_status() === PHP_SESSION_NONE) {
        session_start();
    }
    $_SESSION['flash'] = [
        'type' => $type, // 'success', 'danger', 'warning', 'info'
        'message' => $message
    ];
}

function get_flash_message() {
    if (session_status() === PHP_SESSION_NONE) {
        session_start();
    }
    if (isset($_SESSION['flash'])) {
        $flash = $_SESSION['flash'];
        unset($_SESSION['flash']);
        return $flash;
    }
    return null;
}

function cookmate_brand_html($extraClass = '') {
    return '<span class="brand-cookmate ' . htmlspecialchars($extraClass) . '" style="font-family:\'Outfit\',sans-serif;font-weight:800;display:inline-flex;align-items:baseline;"><span class="cook-part" style="color:#FFFFFF !important;font-weight:800;">Cook</span><span class="mate-part" style="color:#E50915 !important;font-weight:800;">Mate</span></span>';
}
