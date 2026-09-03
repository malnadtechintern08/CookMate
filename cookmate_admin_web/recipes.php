<?php
/**
 * CookMate Web Admin - Recipe Catalog (200+ Recipes)
 */
require_once __DIR__ . '/config/db.php';
$pdo = get_db_connection();

$pageTitle = 'Recipe Catalog';

// Filter parameters
$search = trim($_GET['q'] ?? '');
$categoryFilter = trim($_GET['category'] ?? '');
$dietFilter = trim($_GET['diet'] ?? ''); // 'veg', 'nonveg'
$diffFilter = trim($_GET['difficulty'] ?? '');
$sort = trim($_GET['sort'] ?? 'newest');
$page = max(1, (int)($_GET['page'] ?? 1));
$limit = 20;
$offset = ($page - 1) * $limit;

// Build query
$where = [];
$params = [];

if ($search !== '') {
    if (strpos($search, '#') === 0) {
        require_once __DIR__ . '/includes/tag_functions.php';
        $tagNorm = normalize_tag($search);
        $where[] = "r.id IN (
            SELECT rt.recipe_id FROM recipe_tags rt 
            INNER JOIN tags t ON t.id = rt.tag_id 
            WHERE t.name = ?
        )";
        $params[] = $tagNorm;
    } else {
        $where[] = "(r.title LIKE ? OR r.chef_name LIKE ? OR r.cuisine LIKE ? OR r.tags LIKE ? OR r.description LIKE ?)";
        $term = "%$search%";
        $params = array_merge($params, [$term, $term, $term, $term, $term]);
    }
}

if ($categoryFilter !== '') {
    $where[] = "r.category_id = ?";
    $params[] = $categoryFilter;
}

if ($dietFilter === 'veg') {
    $where[] = "r.is_vegetarian = 1";
} elseif ($dietFilter === 'nonveg') {
    $where[] = "r.is_vegetarian = 0";
}

if ($diffFilter !== '') {
    $where[] = "r.difficulty = ?";
    $params[] = $diffFilter;
}

$whereSql = !empty($where) ? 'WHERE ' . implode(' AND ', $where) : '';

// Sort SQL
$orderSql = match ($sort) {
    'title_asc' => 'ORDER BY r.title ASC',
    'title_desc' => 'ORDER BY r.title DESC',
    'rating_desc' => 'ORDER BY r.rating DESC, r.title ASC',
    'time_asc' => 'ORDER BY (r.prep_time_minutes + r.cook_time_minutes) ASC',
    default => 'ORDER BY r.created_at DESC, r.id DESC',
};

// Count total matching
$countStmt = $pdo->prepare("SELECT COUNT(*) FROM recipes r $whereSql");
$countStmt->execute($params);
$totalRecipes = (int)$countStmt->fetchColumn();
$totalPages = ceil($totalRecipes / $limit);

// Fetch page items
$querySql = "
    SELECT r.*, c.name AS category_name, c.color_hex AS category_color
    FROM recipes r
    LEFT JOIN categories c ON r.category_id = c.id
    $whereSql
    $orderSql
    LIMIT $limit OFFSET $offset
";
$stmt = $pdo->prepare($querySql);
$stmt->execute($params);
$recipes = $stmt->fetchAll();

// Fetch categories for filter dropdown
$categories = $pdo->query("SELECT id, name FROM categories ORDER BY name ASC")->fetchAll();

require_once __DIR__ . '/includes/header.php';
?>

<!-- Filter & Search Toolbar -->
<form method="GET" action="<?= BASE_URL ?>/recipes.php" class="filter-bar">
    <div class="search-input-wrapper">
        <i class="fa-solid fa-magnifying-glass search-icon"></i>
        <input type="text" name="q" value="<?= htmlspecialchars($search) ?>" class="form-control" placeholder="Search by title, chef, cuisine, tags...">
    </div>

    <div style="min-width: 170px;">
        <select name="category" class="form-control" onchange="this.form.submit()">
            <option value="">All Categories</option>
            <?php foreach ($categories as $cat): ?>
                <option value="<?= htmlspecialchars($cat['id']) ?>" <?= $categoryFilter === $cat['id'] ? 'selected' : '' ?>>
                    <?= htmlspecialchars($cat['name']) ?>
                </option>
            <?php endforeach; ?>
        </select>
    </div>

    <div style="min-width: 130px;">
        <select name="diet" class="form-control" onchange="this.form.submit()">
            <option value="">All Diets</option>
            <option value="veg" <?= $dietFilter === 'veg' ? 'selected' : '' ?>>🌱 Pure Veg</option>
            <option value="nonveg" <?= $dietFilter === 'nonveg' ? 'selected' : '' ?>>🍗 Non-Veg</option>
        </select>
    </div>

    <div style="min-width: 130px;">
        <select name="difficulty" class="form-control" onchange="this.form.submit()">
            <option value="">All Difficulty</option>
            <option value="Easy" <?= $diffFilter === 'Easy' ? 'selected' : '' ?>>Easy</option>
            <option value="Medium" <?= $diffFilter === 'Medium' ? 'selected' : '' ?>>Medium</option>
            <option value="Hard" <?= $diffFilter === 'Hard' ? 'selected' : '' ?>>Hard</option>
        </select>
    </div>

    <div style="min-width: 150px;">
        <select name="sort" class="form-control" onchange="this.form.submit()">
            <option value="newest" <?= $sort === 'newest' ? 'selected' : '' ?>>Newest First</option>
            <option value="rating_desc" <?= $sort === 'rating_desc' ? 'selected' : '' ?>>Top Rated ⭐</option>
            <option value="title_asc" <?= $sort === 'title_asc' ? 'selected' : '' ?>>Name (A-Z)</option>
            <option value="title_desc" <?= $sort === 'title_desc' ? 'selected' : '' ?>>Name (Z-A)</option>
            <option value="time_asc" <?= $sort === 'time_asc' ? 'selected' : '' ?>>Shortest Cook Time</option>
        </select>
    </div>

    <button type="submit" class="btn btn-primary btn-sm">Filter</button>
    <?php if ($search !== '' || $categoryFilter !== '' || $dietFilter !== '' || $diffFilter !== '' || $sort !== 'newest'): ?>
        <a href="<?= BASE_URL ?>/recipes.php" class="btn btn-secondary btn-sm" title="Clear Filters">Reset</a>
    <?php endif; ?>
</form>

<!-- Results Header & Counter -->
<div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 18px;">
    <div style="color: var(--cm-text-secondary); font-size: 14px;">
        Showing <strong style="color: var(--cm-text-primary);"><?= count($recipes) ?></strong> of <strong style="color: var(--cm-primary);"><?= number_format($totalRecipes) ?></strong> recipes
        <?php if ($search !== ''): ?>
            for "<em><?= htmlspecialchars($search) ?></em>"
        <?php endif; ?>
    </div>
    <a href="<?= BASE_URL ?>/recipe-form.php" class="btn btn-primary btn-sm">
        <i class="fa-solid fa-plus"></i> Add New Recipe
    </a>
</div>

<!-- Recipes Table Card -->
<div class="card" style="padding: 0; overflow: hidden;">
    <div class="table-responsive">
        <table class="admin-table">
            <thead>
                <tr>
                    <th style="width: 54px; text-align: center;">Photo</th>
                    <th>Recipe & Cuisine</th>
                    <th>Category</th>
                    <th>Diet</th>
                    <th>Prep / Cook</th>
                    <th>Difficulty</th>
                    <th>Rating</th>
                    <th style="text-align: right; width: 170px;">Actions</th>
                </tr>
            </thead>
            <tbody>
                <?php if (empty($recipes)): ?>
                    <tr>
                        <td colspan="8" style="text-align: center; padding: 48px; color: var(--cm-text-muted);">
                            <i class="fa-solid fa-bowl-rice" style="font-size: 36px; margin-bottom: 12px; display: block; color: var(--cm-primary);"></i>
                            <h3 style="font-size: 18px; margin-bottom: 6px;">No recipes found</h3>
                            <p style="font-size: 13px;">Try adjusting your search criteria or add a new recipe.</p>
                        </td>
                    </tr>
                <?php else: ?>
                    <?php foreach ($recipes as $r): ?>
                        <?php
                            $thumb = !empty($r['image_url']) ? BASE_URL . '/' . ltrim($r['image_url'], '/') : BASE_URL . '/assets/images/app_icon.png';
                            $catColor = !empty($r['category_color']) ? str_replace('0xFF', '#', $r['category_color']) : '#E50914';
                        ?>
                        <tr>
                            <td style="text-align: center;">
                                <img src="<?= htmlspecialchars($thumb) ?>" 
                                     onerror="this.onerror=null;this.src='<?= BASE_URL ?>/assets/images/app_icon.png';" 
                                     class="recipe-cell-thumb" 
                                     alt="<?= htmlspecialchars($r['title']) ?>">
                            </td>
                            <td>
                                <a href="<?= BASE_URL ?>/recipe-view.php?id=<?= urlencode($r['id']) ?>" class="recipe-cell-title">
                                    <?= htmlspecialchars($r['title']) ?>
                                </a>
                                <span class="recipe-cell-sub">
                                    <?= htmlspecialchars($r['cuisine']) ?> • by <?= htmlspecialchars($r['chef_name']) ?>
                                    <?php if (!empty($r['region'])): ?>
                                        • <span style="color: var(--cm-text-muted);"><?= htmlspecialchars($r['region']) ?></span>
                                    <?php endif; ?>
                                </span>
                            </td>
                            <td>
                                <span class="badge" style="background: <?= $catColor ?>20; color: <?= $catColor ?>; border: 1px solid <?= $catColor ?>40;">
                                    <?= htmlspecialchars($r['category_name'] ?? 'General') ?>
                                </span>
                            </td>
                            <td>
                                <?php if ($r['is_vegetarian']): ?>
                                    <span class="badge badge-veg"><i class="fa-solid fa-leaf"></i> VEG</span>
                                <?php else: ?>
                                    <span class="badge badge-nonveg"><i class="fa-solid fa-drumstick-bite"></i> NON-VEG</span>
                                <?php endif; ?>
                            </td>
                            <td>
                                <span style="font-size: 13px; color: var(--cm-text-secondary); white-space: nowrap;">
                                    <i class="fa-regular fa-clock" style="color: var(--cm-primary);"></i> 
                                    <?= $r['prep_time_minutes'] ?>m prep + <?= $r['cook_time_minutes'] ?>m cook
                                </span>
                            </td>
                            <td>
                                <?php
                                    $diffClass = match (strtolower($r['difficulty'])) {
                                        'easy' => 'badge-diff-easy',
                                        'hard' => 'badge-diff-hard',
                                        default => 'badge-diff-medium'
                                    };
                                ?>
                                <span class="badge <?= $diffClass ?>">
                                    <?= htmlspecialchars($r['difficulty']) ?>
                                </span>
                            </td>
                            <td>
                                <span style="color: var(--cm-gold); font-weight: 700; font-size: 13px; white-space: nowrap;">
                                    <i class="fa-solid fa-star"></i> <?= number_format($r['rating'], 1) ?>
                                </span>
                            </td>
                            <td style="text-align: right;">
                                <div style="display: inline-flex; gap: 6px;">
                                    <a href="<?= BASE_URL ?>/recipe-view.php?id=<?= urlencode($r['id']) ?>" class="btn btn-secondary btn-icon" title="View Recipe">
                                        <i class="fa-regular fa-eye"></i>
                                    </a>
                                    <a href="<?= BASE_URL ?>/recipe-form.php?id=<?= urlencode($r['id']) ?>" class="btn btn-secondary btn-icon" title="Edit Recipe" style="color: var(--cm-primary);">
                                        <i class="fa-regular fa-pen-to-square"></i>
                                    </a>
                                    <a href="<?= BASE_URL ?>/recipe-duplicate.php?id=<?= urlencode($r['id']) ?>" class="btn btn-secondary btn-icon" title="Duplicate Recipe">
                                        <i class="fa-regular fa-copy"></i>
                                    </a>
                                    <a href="<?= BASE_URL ?>/recipe-delete.php?id=<?= urlencode($r['id']) ?>" class="btn btn-danger btn-icon" title="Delete Recipe" onclick="return confirm('Are you sure you want to delete <?= addslashes($r['title']) ?>?');">
                                        <i class="fa-regular fa-trash-can"></i>
                                    </a>
                                </div>
                            </td>
                        </tr>
                    <?php endforeach; ?>
                <?php endif; ?>
            </tbody>
        </table>
    </div>
</div>

<!-- Pagination Links -->
<?php if ($totalPages > 1): ?>
    <div class="pagination">
        <?php
            function build_query_str($p) {
                $params = $_GET;
                $params['page'] = $p;
                return '?' . http_build_query($params);
            }
        ?>
        <?php if ($page > 1): ?>
            <a href="<?= build_query_str(1) ?>" class="page-link" title="First Page">&laquo;</a>
            <a href="<?= build_query_str($page - 1) ?>" class="page-link" title="Previous Page">&lsaquo;</a>
        <?php endif; ?>

        <?php
            $startP = max(1, $page - 3);
            $endP = min($totalPages, $page + 3);
            for ($i = $startP; $i <= $endP; $i++):
        ?>
            <a href="<?= build_query_str($i) ?>" class="page-link <?= $i === $page ? 'active' : '' ?>">
                <?= $i ?>
            </a>
        <?php endfor; ?>

        <?php if ($page < $totalPages): ?>
            <a href="<?= build_query_str($page + 1) ?>" class="page-link" title="Next Page">&rsaquo;</a>
            <a href="<?= build_query_str($totalPages) ?>" class="page-link" title="Last Page">&raquo;</a>
        <?php endif; ?>
    </div>
<?php endif; ?>

<?php require_once __DIR__ . '/includes/footer.php'; ?>
