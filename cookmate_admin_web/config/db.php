<?php
/**
 * CookMate Web Admin - Database Connection Configuration
 */

define('DB_HOST', 'localhost');
define('DB_PORT', '3306');
define('DB_NAME', 'cookmate_db');
define('DB_USER', 'root');
define('DB_PASS', '');

// Base URL for the admin panel
define('BASE_URL', '/cookmate-admin');
define('PHPMYADMIN_URL', '/phpmyadmin/index.php?route=/database/structure&db=cookmate_db');

function get_db_connection() {
    static $pdo = null;
    if ($pdo === null) {
        try {
            $dsn = "mysql:host=" . DB_HOST . ";port=" . DB_PORT . ";dbname=" . DB_NAME . ";charset=utf8mb4";
            $options = [
                PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
                PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
                PDO::ATTR_EMULATE_PREPARES   => false,
            ];
            $pdo = new PDO($dsn, DB_USER, DB_PASS, $options);
        } catch (PDOException $e) {
            die('<div style="font-family:-apple-system,BlinkMacSystemFont,\'Segoe UI\',Roboto,sans-serif;background:#0E0E0E;color:#FFF;padding:40px;text-align:center;min-height:100vh;">' .
                '<div style="max-width:560px;margin:40px auto;background:#1A1A1A;padding:32px;border-radius:16px;border:1px solid #262626;box-shadow:0 8px 32px rgba(0,0,0,0.5);">' .
                '<img src="' . BASE_URL . '/assets/images/cookmate_logo.png" style="height:60px;margin-bottom:20px;" alt="CookMate Logo">' .
                '<h2 style="margin-top:0;"><span style="color:#FFFFFF;font-weight:800;">Cook</span><span style="color:#E53935;font-weight:800;">Mate</span> Database Notice</h2>' .
                '<p style="color:#A5A5A5;font-size:14px;line-height:1.6;">Database <code>cookmate_db</code> needs to be created or connected.<br><small style="color:#757575;">' . htmlspecialchars($e->getMessage()) . '</small></p>' .
                '<p><a href="' . BASE_URL . '/setup_db.php" style="display:inline-block;padding:12px 28px;background:#FF6B35;color:#fff;text-decoration:none;border-radius:10px;font-weight:700;margin-top:16px;box-shadow:0 4px 16px rgba(255,107,53,0.4);">🚀 Run 1-Click Database Setup & Import 200 Recipes</a></p>' .
                '<p style="margin-top:20px;"><a href="/phpmyadmin/" target="_blank" style="color:#FF8C42;text-decoration:none;font-size:14px;">Open phpMyAdmin &rarr;</a></p>' .
                '</div></div>');
        }
    }
    return $pdo;
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
    return '<span class="brand-cookmate ' . htmlspecialchars($extraClass) . '"><span class="cook-part">Cook</span><span class="mate-part">Mate</span></span>';
}

