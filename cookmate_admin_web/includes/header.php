<?php
/**
 * CookMate Web Admin - Global Header & Navigation Shell
 */
require_once __DIR__ . '/../config/db.php';

$currentPage = basename($_SERVER['PHP_SELF']);
$flash = get_flash_message();
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?= isset($pageTitle) ? htmlspecialchars($pageTitle) . ' • ' : '' ?>CookMate Admin</title>
    <link rel="icon" type="image/png" href="<?= BASE_URL ?>/assets/images/app_icon.png">
    
    <!-- Google Fonts: Outfit (brand) & Plus Jakarta Sans (UI) -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@400;600;700;800;900&family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    
    <!-- FontAwesome Icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <!-- CookMate Admin Brand CSS -->
    <link rel="stylesheet" href="<?= BASE_URL ?>/assets/css/admin.css">
</head>
<body>

    <!-- Sidebar Navigation -->
    <aside class="admin-sidebar" id="adminSidebar">
        <div class="sidebar-header">
            <img src="<?= BASE_URL ?>/assets/images/cookmate_logo.png" alt="CookMate Logo" class="sidebar-logo">
            <div class="sidebar-brand-title">
                <span class="brand-cookmate"><span class="cook-part">Cook</span><span class="mate-part">Mate</span></span>
                <span class="sidebar-brand-subtitle">Admin Hub</span>
            </div>
        </div>

        <nav class="sidebar-nav">
            <div class="nav-section-label">Management</div>
            
            <a href="<?= BASE_URL ?>/index.php" class="nav-item <?= $currentPage === 'index.php' ? 'active' : '' ?>">
                <i class="fa-solid fa-gauge-high"></i>
                <span>Dashboard</span>
            </a>

            <a href="<?= BASE_URL ?>/recipes.php" class="nav-item <?= in_array($currentPage, ['recipes.php', 'recipe-view.php']) ? 'active' : '' ?>">
                <i class="fa-solid fa-utensils"></i>
                <span>All Recipes (200+)</span>
            </a>

            <a href="<?= BASE_URL ?>/recipe-form.php" class="nav-item <?= $currentPage === 'recipe-form.php' ? 'active' : '' ?>">
                <i class="fa-solid fa-circle-plus"></i>
                <span>Add New Recipe</span>
            </a>

            <a href="<?= BASE_URL ?>/categories.php" class="nav-item <?= $currentPage === 'categories.php' ? 'active' : '' ?>">
                <i class="fa-solid fa-layer-group"></i>
                <span>Categories</span>
            </a>

            <div class="nav-section-label">Data & Database</div>

            <a href="<?= BASE_URL ?>/export.php" class="nav-item <?= $currentPage === 'export.php' ? 'active' : '' ?>">
                <i class="fa-solid fa-file-export"></i>
                <span>Export JSON / Dart</span>
            </a>

            <a href="<?= BASE_URL ?>/setup_db.php" class="nav-item <?= $currentPage === 'setup_db.php' ? 'active' : '' ?>">
                <i class="fa-solid fa-arrows-rotate"></i>
                <span>Seed / Reset DB</span>
            </a>
        </nav>

        <div class="sidebar-footer">
            <a href="<?= PHPMYADMIN_URL ?>" target="_blank" class="pma-badge-btn" title="Open cookmate_db in phpMyAdmin">
                <span><i class="fa-solid fa-database"></i> phpMyAdmin DB</span>
                <i class="fa-solid fa-arrow-up-right-from-square" style="font-size: 10px;"></i>
            </a>
            
            <div style="display: flex; align-items: center; gap: 8px; font-size: 11px; color: var(--cm-text-muted); padding: 4px 6px;">
                <span style="width: 8px; height: 8px; border-radius: 50%; background: #4CAF50; display: inline-block; box-shadow: 0 0 8px #4CAF50;"></span>
                <span>MySQL: <code>cookmate_db</code></span>
            </div>
        </div>
    </aside>

    <!-- Main Container -->
    <div class="admin-main">
        <header class="admin-header">
            <div style="display: flex; align-items: center; gap: 14px;">
                <button id="sidebarToggle" class="btn btn-secondary btn-icon" style="display: none;" title="Toggle Sidebar">
                    <i class="fa-solid fa-bars"></i>
                </button>
                <h1 class="admin-header-title"><?= isset($pageTitle) ? htmlspecialchars($pageTitle) : 'Admin Dashboard' ?></h1>
            </div>

            <div class="admin-header-actions">
                <a href="<?= BASE_URL ?>/recipe-form.php" class="btn btn-primary btn-sm">
                    <i class="fa-solid fa-plus"></i>
                    <span>Add Recipe</span>
                </a>
                
                <a href="<?= PHPMYADMIN_URL ?>" target="_blank" class="btn btn-secondary btn-sm" title="View in phpMyAdmin">
                    <i class="fa-solid fa-database" style="color: #FFB300;"></i>
                    <span>phpMyAdmin</span>
                </a>
            </div>
        </header>

        <main class="admin-content">
            <?php if ($flash): ?>
                <div class="alert alert-<?= htmlspecialchars($flash['type']) ?>">
                    <span><?= htmlspecialchars($flash['message']) ?></span>
                    <button type="button" onclick="this.parentElement.remove()" style="background:none;border:none;color:inherit;cursor:pointer;font-size:16px;">&times;</button>
                </div>
            <?php endif; ?>
