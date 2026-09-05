-- =============================================================================
-- CookMate Database Migration: 004_create_support_and_pages.sql
-- Support, Legal, Policy Pages, FAQs, and Contact Inquiries
-- =============================================================================

-- 1. Support & Policy Pages Table
CREATE TABLE IF NOT EXISTS support_pages (
    id VARCHAR(64) PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    slug VARCHAR(64) UNIQUE NOT NULL,
    summary VARCHAR(500) NULL,
    content LONGTEXT NOT NULL,
    meta_json LONGTEXT NULL,
    is_published TINYINT(1) NOT NULL DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_page_slug (slug),
    INDEX idx_page_published (is_published)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. Frequently Asked Questions (FAQs) Table
CREATE TABLE IF NOT EXISTS faqs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    category VARCHAR(100) NOT NULL DEFAULT 'General',
    question VARCHAR(500) NOT NULL,
    answer TEXT NOT NULL,
    sort_order INT NOT NULL DEFAULT 0,
    is_published TINYINT(1) NOT NULL DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_faq_category (category),
    INDEX idx_faq_published (is_published),
    INDEX idx_faq_sort (sort_order)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. Contact Inquiries / Messages Table
CREATE TABLE IF NOT EXISTS contact_inquiries (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL,
    subject VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    status ENUM('new', 'read', 'replied', 'archived') NOT NULL DEFAULT 'new',
    ip_address VARCHAR(45) NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_inquiry_status (status),
    INDEX idx_inquiry_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =============================================================================
-- Initial Seed Data: Pages
-- =============================================================================

INSERT INTO support_pages (id, title, slug, summary, content, meta_json, is_published)
VALUES 
(
    'privacy-policy',
    'Privacy Policy',
    'privacy-policy',
    'Understand how CookMate collects, protects, and respects your culinary and device data.',
    '# CookMate Privacy Policy\n\n**Effective Date:** January 1, 2026\n**Last Updated:** September 5, 2026\n\nWelcome to **CookMate**, your personal culinary and recipe companion dedicated to preserving authentic heritage cuisine. Your privacy is paramount to us. This Privacy Policy explains our practices regarding the collection, use, and disclosure of your information when you use our mobile application and website services.\n\n---\n\n### 1. Information We Collect\nCookMate is built with an **offline-first philosophy**. We minimize data collection to provide you with a seamless cooking experience:\n- **Device Preferences:** Selected theme mode (Dark/Light), active language preference, and serving multiplier.\n- **Local Culinary Data:** Favorites, recently viewed recipes, smart shopping lists, and personal kitchen notes are stored directly on your device\'s local database (SQLite) and are never transmitted to external servers without your permission.\n- **Recipe Submissions & Community Contributions:** When you voluntarily submit a recipe or feedback, we collect your contributor name, recipe details, ingredient measurements, preparation steps, and optional dish photos.\n- **Technical & Diagnostics:** Minimal anonymous performance logs and crash metrics to keep CookMate fast and reliable.\n\n---\n\n### 2. Device Permissions\nCookMate only requests permissions strictly necessary to deliver app features:\n- **Camera & Photo Gallery:** Used solely when you choose to attach or take a photo for recipe submissions or dish notes. Photos remain private unless you publish them in a community submission.\n- **Notifications:** Used only to send you timer alerts during cooking and updates on your recipe submissions (you can disable these anytime in device settings).\n- **Storage / Files:** Used for exporting or backing up your notes and shopping list.\n\n---\n\n### 3. How We Use Your Information\nWe use collected information exclusively to:\n1. Provide, maintain, and enhance the recipe discovery and cooking experience.\n2. Review, verify, and publish community recipes with proper contributor credit.\n3. Send cooking timer notifications and submission status updates.\n4. Detect security issues and prevent fraudulent or abusive submissions.\n\nWe **NEVER** sell, rent, or trade your personal data to third-party advertisers.\n\n---\n\n### 4. Data Storage and Security\nWe utilize industry-standard cryptographic practices (SSL/TLS encryption in transit, strict parameterized database queries) to protect any information submitted to our servers. Local app data stays encrypted and isolated within your device sandbox.\n\n---\n\n### 5. Your Rights and Choices\n- **Access & Correction:** You can review and edit your submissions, favorites, notes, and preferences directly within the app.\n- **Data Reset:** You can reset local catalog cache or delete your locally stored notes and shopping list at any time through **Settings > Offline Database > Reset Data**.\n- **Inquiries & Deletion:** To request deletion of your published community submission or contact data, please reach out via our **Contact Us** screen or email `privacy@cookmate.app`.\n\n---\n\n### 6. Updates to This Policy\nWe may periodically update this policy to reflect new features or regulatory requirements. Changes will be posted in this section with an updated revision date.',
    '{"version":"2.1","contact_email":"privacy@cookmate.app","jurisdiction":"India"}',
    1
)
ON DUPLICATE KEY UPDATE title=VALUES(title), content=VALUES(content), meta_json=VALUES(meta_json);

INSERT INTO support_pages (id, title, slug, summary, content, meta_json, is_published)
VALUES 
(
    'contact-us',
    'Contact Us',
    'contact-us',
    'Get in touch with the CookMate team for recipe help, partnership inquiries, or app feedback.',
    '### We Would Love to Hear From You!\n\nWhether you have questions about authentic Malnad recipes, want to report a bug, suggest new culinary features, or collaborate with our culinary research team, our friendly team is here to assist you.',
    '{"support_email":"support@cookmate.app","press_email":"press@cookmate.app","phone":"+91 (80) 4567-8900","whatsapp":"+91 98765 43210","address":"CookMate Culinary Labs, 4th Floor, Brigade Gateway, Malleshwaram, Bengaluru, Karnataka 560055, India","hours":"Monday – Saturday: 9:00 AM – 6:00 PM IST","social":{"instagram":"@cookmate_app","twitter":"@CookMateApp","youtube":"CookMateKitchen"}}',
    1
)
ON DUPLICATE KEY UPDATE title=VALUES(title), content=VALUES(content), meta_json=VALUES(meta_json);

INSERT INTO support_pages (id, title, slug, summary, content, meta_json, is_published)
VALUES 
(
    'help-center',
    'Help Center',
    'help-center',
    'Explore guides, step-by-step tutorials, and tips for making the most out of CookMate.',
    '# CookMate Help Center & User Guide\n\nFind answers, tutorials, and practical tips on using CookMate to master everyday cooking and authentic heritage recipes.\n\n---\n\n### 1. Discovering & Filtering Recipes\n- **Heritage Categories:** Browse collections like Malnad Special, South Indian Breakfast, Royal Curries, Snacks, and Healthy Millets.\n- **Smart Filters:** Filter by Pure Vegetarian / Non-Vegetarian, Difficulty (Easy, Medium, Hard), and Cooking Time.\n- **Hashtag Search:** Tap any hashtag (e.g. `#MalnadSpecial`, `#DosaLove`) to view all recipes tagged with that theme.\n\n---\n\n### 2. Interactive Cooking Mode\n- When viewing a recipe, tap **Start Cooking Mode**.\n- Navigate through steps with large readable text designed for kitchen counters.\n- Built-in interactive timers ring and vibrate when simmering, boiling, or baking steps finish.\n\n---\n\n### 3. Shopping List & Dynamic Servings\n- Adjust the servings counter on any recipe; ingredient quantities dynamically re-scale automatically.\n- Tap **Add to Shopping List** to send missing items to your smart grocery checklist, organized by aisle.\n\n---\n\n### 4. Submitting Your Recipes\n- Tap the **+** button in My Kitchen or Recipe Submissions.\n- Fill in the title, preparation time, servings, step-by-step instructions, and upload a dish photo.\n- Our editorial team reviews submissions within 24-48 hours. Track real-time review progress under **My Submissions**.\n\n---\n\n### 5. Offline Access & Data Sync\n- CookMate works **100% offline**. You can view recipes, use timers, and manage notes without cellular or Wi-Fi connectivity.\n- When internet is available, tap the sync icon to fetch newly approved recipes and notification announcements.',
    '{"topics":["Discovering Recipes","Interactive Cooking Mode","Dynamic Servings","Submitting Recipes","Offline First"]}',
    1
)
ON DUPLICATE KEY UPDATE title=VALUES(title), content=VALUES(content), meta_json=VALUES(meta_json);

INSERT INTO support_pages (id, title, slug, summary, content, meta_json, is_published)
VALUES 
(
    'safety-guidelines',
    'Safety and Guidelines',
    'safety-guidelines',
    'Essential kitchen safety, food hygiene, allergen information, and community recipe guidelines.',
    '# Safety, Hygiene & Community Guidelines\n\nAt CookMate, your health and safety in the kitchen are just as important as the delicious dishes you prepare. Please review these essential guidelines.\n\n---\n\n### 1. Food Hygiene & Preparation Safety\n- **Hand Washing:** Always wash hands with soap and warm water for at least 20 seconds before and after handling raw ingredients.\n- **Cross-Contamination:** Use separate cutting boards and knives for raw poultry/meat/fish and fresh vegetables/cooked foods.\n- **Safe Internal Temperatures:** Ensure meat, poultry, and seafood are cooked to safe minimum internal temperatures (Poultry: 74°C / 165°F; Ground Meat: 71°C / 160°F; Fish: 63°C / 145°F).\n- **Storing Leftovers:** Refrigerate cooked dishes within two hours of preparation in airtight glass or food-safe containers. Reheat thoroughly before eating.\n\n---\n\n### 2. Kitchen Appliance & Equipment Safety\n- **Pressure Cookers:** Always inspect steam vents, safety valves, and rubber gaskets before sealing. Never force open a hot pressure cooker; wait until pressure drops naturally.\n- **Hot Oil & Deep Frying:** Keep pan handles turned inward. Never pour water onto oil fires; use a lid or fire blanket.\n- **Sharp Knives:** Keep knives honed and sharp. Cut on stable cutting boards placed on a damp cloth to prevent slipping.\n\n---\n\n### 3. Allergen Awareness & Ingredient Substitutions\n- Many authentic Indian recipes feature tree nuts (cashews, almonds), dairy (ghee, paneer, milk), mustard seeds, or gluten.\n- Always review recipe tags and allergen notices if cooking for individuals with food allergies.\n- Feel free to use healthy substitutes (e.g. oil instead of ghee for vegan cooking, coconut milk instead of dairy cream).\n\n---\n\n### 4. Community Recipe Submission Standards\nWhen submitting recipes to CookMate, contributors agree to uphold our community trust:\n- **Authenticity:** Submit accurate ingredients, realistic cooking times, and clear step-by-step instructions.\n- **Originality:** Share your own recipes or traditional family techniques. Do not copy copyrighted text from books or commercial websites.\n- **Photo Quality:** Upload genuine, high-quality photos of the actual prepared dish. Stock photos or irrelevant images will be rejected.\n- **Respectful Content:** Promotional spam, non-food advertisements, and abusive language are strictly prohibited.',
    '{"emergency_phone":"112 / 108","allergen_notice_enabled":true}',
    1
)
ON DUPLICATE KEY UPDATE title=VALUES(title), content=VALUES(content), meta_json=VALUES(meta_json);

-- =============================================================================
-- Initial Seed Data: FAQs
-- =============================================================================

INSERT INTO faqs (category, question, answer, sort_order, is_published)
VALUES
(
    'General',
    'What is CookMate and who is it for?',
    'CookMate is an all-in-one culinary companion designed for food enthusiasts, home cooks, and lovers of authentic regional cuisine. It brings together heritage recipes (such as Malnad specialties) alongside modern pan-Indian classics with offline support, step-by-step timers, and smart grocery checklists.',
    1,
    1
),
(
    'General',
    'Does CookMate work without an internet connection?',
    'Yes! CookMate is built offline-first. All core recipes, instructions, ingredients, notes, and timers function completely offline. An internet connection is only needed when syncing newly published community recipes or submitting your own recipes for review.',
    2,
    1
),
(
    'Recipes & Cooking',
    'Can I adjust the recipe servings?',
    'Absolutely. When viewing any recipe details page, tap the plus (+) or minus (-) buttons next to Servings. All ingredient quantities automatically calculate and scale in real time.',
    3,
    1
),
(
    'Recipes & Cooking',
    'How do the cooking timers work?',
    'In both the Recipe Details screen and the interactive Cooking Mode, recipe steps with cooking times show a timer button. Tapping it activates a countdown timer with audio-haptic feedback so you never overcook or burn dishes.',
    4,
    1
),
(
    'Submissions',
    'How do I submit my own family recipe to CookMate?',
    'Navigate to "My Kitchen" or the side drawer and select "Submit Recipe". Enter the title, preparation time, servings, ingredients, instructions, and optionally upload a photo of your dish. Once submitted, our editorial team reviews it before publishing it to the community.',
    5,
    1
),
(
    'Submissions',
    'How long does recipe moderation take?',
    'Our culinary moderation team typically reviews submitted recipes within 24 to 48 hours. You will receive an in-app status notification once your recipe is approved or if modifications are suggested.',
    6,
    1
),
(
    'Dietary & Health',
    'How can I find Pure Vegetarian recipes?',
    'You can tap the "Pure Veg" toggle chip on the Explore or All Recipes screen. Every recipe is also marked with a green indicator for Pure Veg or red for Non-Veg.',
    7,
    1
),
(
    'Dietary & Health',
    'Are nutritional facts available for recipes?',
    'Yes! Each recipe includes estimated calories, protein, and carbohydrates per serving to assist with your meal planning.',
    8,
    1
),
(
    'App & Account',
    'Can I save my favorite recipes and personal notes?',
    'Yes. Tap the heart icon on any recipe to add it to Favorites. You can also write personal cooking notes, secret variations, and tips under the "My Notes" section in settings.',
    9,
    1
),
(
    'App & Account',
    'How do I contact customer support?',
    'You can reach our team anytime via the "Contact Us" screen in the app, or send an email directly to support@cookmate.app.',
    10,
    1
);
