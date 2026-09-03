# 🚀 CookMate Admin Web & Database Deployment Guide

This guide walks you through deploying the **CookMate Admin Web Panel** and its **MySQL Database** to any live production hosting server (such as cPanel, Hostinger, GoDaddy, Plesk, AWS, DigitalOcean, Apache, or LiteSpeed).

---

## 📦 Deployment Files Ready for You

You have everything prepared and packaged:

1. **Admin Web Zip**: [`cookmate_admin_production.zip`](file:///Users/apple/Desktop/CookMate/cookmate_admin_production.zip) *(21 MB - complete with all 200 food images, styles, scripts, and security configs)*
2. **Database SQL File**: [`database/cookmate_database.sql`](file:///Users/apple/Desktop/CookMate/database/cookmate_database.sql) *(533 KB - contains full schema, 8 categories, 200 recipes, 1,065 ingredients, and 800 instructions)*
3. **Database Configuration**: [`cookmate_admin_web/config/db.php`](file:///Users/apple/Desktop/CookMate/cookmate_admin_web/config/db.php)

---

## 📋 Step-by-Step Deployment Instructions

### Step 1: Create & Import Database

1. Log into your hosting control panel (e.g. **cPanel**, **hPanel**, or **Plesk**).
2. Go to **MySQL Databases**:
   - Create a new database (e.g., `u123456_cookmate`).
   - Create a new database user (e.g., `u123456_cookuser`) with a strong password.
   - Assign the user to the database with **ALL PRIVILEGES**.
3. Open **phpMyAdmin**:
   - Click on your newly created database on the left sidebar.
   - Click the **Import** tab at the top.
   - Choose [`cookmate_database.sql`](file:///Users/apple/Desktop/CookMate/database/cookmate_database.sql) from your computer.
   - Click **Import** (or **Go**).
   - ✅ All 4 tables (`categories`, `recipes`, `recipe_ingredients`, `recipe_instructions`) and all 200 recipes will be imported instantly!

---

### Step 2: Upload Admin Web Code

1. In your hosting panel, open **File Manager** (or connect via **FTP/SFTP**).
2. Choose where to host the admin panel:
   - **Main Domain / Subdomain** (e.g. `https://admin.yourdomain.com`):
     Go to the website's document root (typically `public_html/`).
   - **Subdirectory** (e.g. `https://yourdomain.com/cookmate-admin`):
     Create a folder named `cookmate-admin` inside `public_html/`.
3. Upload [`cookmate_admin_production.zip`](file:///Users/apple/Desktop/CookMate/cookmate_admin_production.zip).
4. Right-click the zip file and choose **Extract**.
5. Ensure the extracted files (including `.htaccess`) are placed in the folder.

---

### Step 3: Configure Database Connection (`config/db.php`)

1. Inside your server's file manager, open `config/db.php` in the code editor.
2. Update lines 8–12 with your server credentials:
   ```php
   define('DB_HOST', 'localhost');          // Usually 'localhost'
   define('DB_PORT', '3306');               // Default MySQL port
   define('DB_NAME', 'your_cpanel_dbname'); // e.g. 'u123456_cookmate'
   define('DB_USER', 'your_cpanel_dbuser'); // e.g. 'u123456_cookuser'
   define('DB_PASS', 'your_db_password');   // The password you set
   ```
3. Save the file.

> [!NOTE]
> **Base URL Auto-Detection**: You do **NOT** need to configure `BASE_URL`. `db.php` automatically detects whether you deployed to the root domain (`https://admin.yourdomain.com`) or a subdirectory (`https://yourdomain.com/cookmate-admin`). If you ever need to force a custom URL, you can define `BASE_URL` in `config/db.php`.

---

### Step 4: Verify Directory Permissions

Ensure the `uploads/` directory is writable for recipe image uploads:
- In File Manager, right-click `uploads/` -> **Change Permissions**.
- Set to `755` (or `775` depending on your host).

---

### Step 5: Test Your Live Admin Panel

Open your browser and visit your site URL:
- `https://admin.yourdomain.com/` (or `https://yourdomain.com/cookmate-admin/`)
- Verify the **Dashboard** shows **200 Total Recipes** and **8 Categories**.
- Test navigating to **All Recipes**, **Add New Recipe**, and **Export Data**.
- Test the REST API: `https://yourdomain.com/api/recipes.php`

---

## 🛠️ Alternative: 1-Click Online Database Setup

If you prefer not to use phpMyAdmin import:
1. Upload the files and configure `config/db.php` with your database credentials.
2. Open in your browser: `https://yourdomain.com/setup_db.php`
3. Click the orange **"Run 1-Click Database Setup & Import 200 Recipes"** button.
4. The system will automatically build the schema and load all 200 recipes!

---

## 🔒 Built-in Security Measures

This production package includes pre-configured Apache `.htaccess` security rules:
- **Direct access blocked** to `config/`, `data/`, SQL dumps, and environment files.
- **Directory listing disabled** (`Options -Indexes`).
- **PHP execution disabled** inside `uploads/` to prevent malicious file execution.
- **Security Headers enabled**: `X-Frame-Options`, `X-Content-Type-Options`, and `X-XSS-Protection`.
