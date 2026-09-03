-- =========================================================================
-- CookMate Database Migration: 002_create_recipe_submissions.sql
-- User Recipe Submission, Admin Moderation, Permissions, and Publishing System
-- =========================================================================

-- 1. Users Table (Stores authenticated app users / contributors)
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    auth_token VARCHAR(64) UNIQUE NOT NULL,
    display_name VARCHAR(100) NOT NULL DEFAULT 'CookMate Chef',
    email VARCHAR(255) NULL,
    device_info VARCHAR(255) NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_user_auth_token (auth_token)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. Admins Table (Stores moderators)
CREATE TABLE IF NOT EXISTS admins (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(64) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    role VARCHAR(32) NOT NULL DEFAULT 'admin',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Seed default admin if not present
INSERT IGNORE INTO admins (id, username, name, email, role)
VALUES (1, 'admin', 'CookMate Admin', 'admin@cookmate.app', 'superadmin');

-- 3. Recipe Submissions Table
CREATE TABLE IF NOT EXISTS recipe_submissions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    recipe_name VARCHAR(255) NOT NULL,
    description TEXT NULL,
    category_id VARCHAR(64) NOT NULL,
    image VARCHAR(500) NULL,
    preparation_time INT NOT NULL DEFAULT 15,
    cooking_time INT NOT NULL DEFAULT 20,
    difficulty VARCHAR(32) NOT NULL DEFAULT 'Medium',
    servings INT NOT NULL DEFAULT 4,
    cuisine VARCHAR(100) NOT NULL DEFAULT 'Homemade',
    food_type VARCHAR(32) NOT NULL DEFAULT 'Vegetarian',
    notes TEXT NULL,
    status ENUM('pending', 'under_review', 'changes_requested', 'approved', 'rejected', 'published') NOT NULL DEFAULT 'pending',
    allow_publication TINYINT(1) NOT NULL DEFAULT 0,
    show_author_name TINYINT(1) NOT NULL DEFAULT 0,
    author_display_name VARCHAR(100) NULL,
    permission_given_at DATETIME NULL,
    permission_version VARCHAR(16) DEFAULT 'v1.0',
    admin_notes TEXT NULL,
    rejection_reason TEXT NULL,
    published_recipe_id VARCHAR(64) NULL,
    submitted_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    reviewed_at DATETIME NULL,
    reviewed_by INT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_submissions_user_id (user_id),
    INDEX idx_submissions_status (status),
    INDEX idx_submissions_category (category_id),
    INDEX idx_submissions_published_recipe (published_recipe_id),
    CONSTRAINT fk_submission_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
    CONSTRAINT fk_submission_category FOREIGN KEY (category_id) REFERENCES categories (id) ON UPDATE CASCADE,
    CONSTRAINT fk_submission_admin FOREIGN KEY (reviewed_by) REFERENCES admins (id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. Recipe Submission Ingredients Table
CREATE TABLE IF NOT EXISTS recipe_submission_ingredients (
    id INT AUTO_INCREMENT PRIMARY KEY,
    submission_id INT NOT NULL,
    ingredient VARCHAR(255) NOT NULL,
    quantity VARCHAR(64) NOT NULL DEFAULT '1',
    unit VARCHAR(32) NOT NULL DEFAULT '',
    position INT NOT NULL DEFAULT 1,
    INDEX idx_sub_ing_submission (submission_id),
    CONSTRAINT fk_sub_ing_submission FOREIGN KEY (submission_id) REFERENCES recipe_submissions (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. Recipe Submission Steps Table
CREATE TABLE IF NOT EXISTS recipe_submission_steps (
    id INT AUTO_INCREMENT PRIMARY KEY,
    submission_id INT NOT NULL,
    step_number INT NOT NULL,
    instruction TEXT NOT NULL,
    timer_seconds INT NOT NULL DEFAULT 0,
    INDEX idx_sub_step_submission (submission_id),
    CONSTRAINT fk_sub_step_submission FOREIGN KEY (submission_id) REFERENCES recipe_submissions (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 6. Recipe Submission Tags Table (Links to existing tags table)
CREATE TABLE IF NOT EXISTS recipe_submission_tags (
    id INT AUTO_INCREMENT PRIMARY KEY,
    submission_id INT NOT NULL,
    tag_id INT NOT NULL,
    UNIQUE KEY uq_submission_tag (submission_id, tag_id),
    INDEX idx_sub_tag_submission (submission_id),
    INDEX idx_sub_tag_tag (tag_id),
    CONSTRAINT fk_sub_tag_submission FOREIGN KEY (submission_id) REFERENCES recipe_submissions (id) ON DELETE CASCADE,
    CONSTRAINT fk_sub_tag_tag FOREIGN KEY (tag_id) REFERENCES tags (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 7. Admin Activity Logs Table
CREATE TABLE IF NOT EXISTS admin_activity_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    admin_id INT NOT NULL DEFAULT 1,
    action VARCHAR(100) NOT NULL,
    submission_id INT NULL,
    details TEXT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_log_action (action),
    INDEX idx_log_submission (submission_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 8. User Notifications Table
CREATE TABLE IF NOT EXISTS user_notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    submission_id INT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) NOT NULL,
    is_read TINYINT(1) NOT NULL DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_user_notifications_user (user_id),
    INDEX idx_user_notifications_unread (user_id, is_read),
    CONSTRAINT fk_notif_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
