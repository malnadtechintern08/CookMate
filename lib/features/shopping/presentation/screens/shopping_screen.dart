import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/shopping_item.dart';
import '../providers/shopping_provider.dart';

class ShoppingScreen extends ConsumerStatefulWidget {
  const ShoppingScreen({super.key});

  @override
  ConsumerState<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends ConsumerState<ShoppingScreen> {
  final _textController = TextEditingController();
  final _qtyController = TextEditingController();
  final _unitController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    _qtyController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  void _showAddItemDialog() {
    _textController.clear();
    _qtyController.text = '1';
    _unitController.clear();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardBackground : AppColors.lightSurfaceCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: [
            const Icon(Icons.add_shopping_cart_rounded, color: AppColors.primaryOrange, size: 22),
            const SizedBox(width: 8),
            Text(l10n.addGroceryItem, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _textController,
              autofocus: true,
              decoration: InputDecoration(
                labelText: l10n.itemName,
                hintText: l10n.itemNameHint,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _qtyController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: l10n.qty,
                      hintText: '1',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _unitController,
                    decoration: InputDecoration(
                      labelText: l10n.unit,
                      hintText: l10n.unitHint,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel, style: TextStyle(color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              final name = _textController.text.trim();
              if (name.isNotEmpty) {
                final qty = double.tryParse(_qtyController.text.trim()) ?? 1.0;
                final unit = _unitController.text.trim();
                ref.read(shoppingListProvider.notifier).addItem(
                      name: name,
                      amount: qty,
                      unit: unit,
                      recipeName: l10n.customItem,
                    );
                Navigator.of(ctx).pop();
              }
            },
            child: Text(l10n.add),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(shoppingListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    final activeItems = items.where((i) => !i.isCompleted).toList();
    final completedItems = items.where((i) => i.isCompleted).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.shoppingList),
        actions: [
          if (items.isNotEmpty)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded),
              onSelected: (value) {
                if (value == 'clear_completed') {
                  ref.read(shoppingListProvider.notifier).clearCompleted();
                } else if (value == 'clear_all') {
                  ref.read(shoppingListProvider.notifier).clearAll();
                }
              },
              itemBuilder: (ctx) => [
                if (completedItems.isNotEmpty)
                  PopupMenuItem(
                    value: 'clear_completed',
                    child: Row(
                      children: [
                        const Icon(Icons.remove_done_rounded, size: 18, color: AppColors.primaryOrange),
                        const SizedBox(width: 8),
                        Text(l10n.clearDone),
                      ],
                    ),
                  ),
                PopupMenuItem(
                  value: 'clear_all',
                  child: Row(
                    children: [
                      const Icon(Icons.delete_sweep_rounded, size: 18, color: AppColors.nonVegRed),
                      const SizedBox(width: 8),
                      Text(l10n.clearAll),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: items.isEmpty
          ? Center(
              child: AppEmptyState(
                icon: Icons.shopping_cart_outlined,
                title: l10n.emptyShoppingTitle,
                description: l10n.emptyShoppingDesc,
                actionLabel: l10n.addFirstItem,
                onAction: _showAddItemDialog,
              ),
            )
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                // Quick Summary Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.cardBackground : AppColors.lightSurfaceCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isDark ? AppColors.border : AppColors.lightBorder),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryOrange.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.shopping_bag_outlined,
                            color: AppColors.primaryOrange, size: 24),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.itemsToBuy(activeItems.length),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              l10n.purchasedCount(completedItems.length, items.length),
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (completedItems.isNotEmpty)
                        TextButton.icon(
                          icon: const Icon(Icons.cleaning_services_rounded, size: 16),
                          label: Text(l10n.clearDone, style: const TextStyle(fontSize: 12)),
                          onPressed: () {
                            ref.read(shoppingListProvider.notifier).clearCompleted();
                          },
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Active Items
                if (activeItems.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                    child: Text(
                      l10n.toBuy,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: AppColors.primaryOrange,
                      ),
                    ),
                  ),
                  ...activeItems.map((item) => _buildShoppingTile(item, isDark)),
                ],

                // Completed Items
                if (completedItems.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                    child: Text(
                      l10n.completed,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: AppColors.vegGreen,
                      ),
                    ),
                  ),
                  ...completedItems.map((item) => _buildShoppingTile(item, isDark)),
                ],
                const SizedBox(height: 80),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddItemDialog,
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.addItem, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildShoppingTile(ShoppingItem item, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardBackground : AppColors.lightSurfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: item.isCompleted
              ? AppColors.vegGreen.withValues(alpha: 0.3)
              : (isDark ? AppColors.border : AppColors.lightBorder),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        leading: Checkbox(
          value: item.isCompleted,
          activeColor: AppColors.vegGreen,
          onChanged: (_) {
            ref.read(shoppingListProvider.notifier).toggleItem(item.id);
          },
        ),
        title: Text(
          item.name,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            decoration: item.isCompleted ? TextDecoration.lineThrough : null,
            color: item.isCompleted
                ? (isDark ? AppColors.textMuted : AppColors.lightTextMuted)
                : (isDark ? AppColors.textPrimary : AppColors.lightTextPrimary),
          ),
        ),
        subtitle: item.recipeName.isNotEmpty
            ? Text(
                item.recipeName,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? AppColors.textMuted : AppColors.lightTextMuted,
                ),
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.formattedQuantity.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.background : AppColors.lightBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isDark ? AppColors.border : AppColors.lightBorder),
                ),
                child: Text(
                  item.formattedQuantity,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryOrange,
                  ),
                ),
              ),
            IconButton(
              icon: Icon(Icons.close_rounded, size: 18, color: isDark ? AppColors.textMuted : AppColors.lightTextMuted),
              onPressed: () {
                ref.read(shoppingListProvider.notifier).deleteItem(item.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}
