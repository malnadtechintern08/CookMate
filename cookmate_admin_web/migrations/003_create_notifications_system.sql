-- =============================================================================
-- CookMate Database Migration: 003_create_notifications_system.sql
-- Relational Notification Engine & User Status Architecture
-- =============================================================================

-- 1. Main Notifications Catalog Table
CREATE TABLE IF NOT EXISTS notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) NOT NULL DEFAULT 'general',
    target_type VARCHAR(32) NOT NULL DEFAULT 'all',
    target_user_id INT NULL,
    related_type VARCHAR(50) NULL,
    related_id VARCHAR(100) NULL,
    image VARCHAR(500) NULL,
    action_label VARCHAR(100) NULL,
    status ENUM('active', 'inactive') NOT NULL DEFAULT 'active',
    created_by_admin_id INT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    expires_at DATETIME NULL,
    INDEX idx_notif_status (status),
    INDEX idx_notif_created_at (created_at),
    INDEX idx_notif_target (target_type, target_user_id),
    INDEX idx_notif_related (related_type, related_id),
    CONSTRAINT fk_notif_target_user FOREIGN KEY (target_user_id) REFERENCES users (id) ON DELETE CASCADE,
    CONSTRAINT fk_notif_admin FOREIGN KEY (created_by_admin_id) REFERENCES admins (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. User Notification Delivery & Read State Table
-- Drop legacy unindexed table if empty and missing notification_id
DROP TABLE IF EXISTS user_notifications_legacy;

CREATE TABLE IF NOT EXISTS user_notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    notification_id INT NOT NULL,
    user_id INT NOT NULL,
    is_read TINYINT(1) NOT NULL DEFAULT 0,
    read_at DATETIME NULL,
    is_dismissed TINYINT(1) NOT NULL DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_notif_user (notification_id, user_id),
    INDEX idx_un_user (user_id),
    INDEX idx_un_notification (notification_id),
    INDEX idx_un_read_status (is_read),
    INDEX idx_un_read_at (read_at),
    INDEX idx_un_user_read (user_id, is_read, read_at),
    CONSTRAINT fk_un_notification FOREIGN KEY (notification_id) REFERENCES notifications (id) ON DELETE CASCADE,
    CONSTRAINT fk_un_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
