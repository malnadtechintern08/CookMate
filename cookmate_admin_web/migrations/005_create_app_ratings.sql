-- CookMate Database Migration: 005_create_app_ratings.sql
-- Description: Creates table to store mobile app ratings and user feedback (1, 2, 3 stars)

CREATE TABLE IF NOT EXISTS `app_ratings` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `stars` INT NOT NULL,
    `category` VARCHAR(100) DEFAULT 'General',
    `feedback_text` TEXT NOT NULL,
    `user_name` VARCHAR(150) DEFAULT 'App User',
    `user_email` VARCHAR(150) DEFAULT NULL,
    `device_info` VARCHAR(255) DEFAULT NULL,
    `app_version` VARCHAR(50) DEFAULT '2.0.0',
    `status` ENUM('new', 'reviewed', 'resolved', 'archived') DEFAULT 'new',
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX `idx_stars` (`stars`),
    INDEX `idx_status` (`status`),
    INDEX `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
