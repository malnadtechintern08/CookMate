import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/ingredient.dart';

class IngredientListWidget extends StatefulWidget {
  final List<Ingredient> ingredients;
  final int baseServings;

  const IngredientListWidget({
    super.key,
    required this.ingredients,
    required this.baseServings,
  });

  @override
  State<IngredientListWidget> createState() => _IngredientListWidgetState();
}

class _IngredientListWidgetState extends State<IngredientListWidget> {
  late int _currentServings;
  final Set<int> _checkedIngredients = {};

  @override
  void initState() {
    super.initState();
    _currentServings = widget.baseServings > 0 ? widget.baseServings : 2;
  }

  void _incrementServings() {
    setState(() {
      _currentServings++;
    });
  }

  void _decrementServings() {
    if (_currentServings > 1) {
      setState(() {
        _currentServings--;
      });
    }
  }

  void _toggleChecked(int index) {
    setState(() {
      if (_checkedIngredients.contains(index)) {
        _checkedIngredients.remove(index);
      } else {
        _checkedIngredients.add(index);
      }
    });
  }

  String _formatAmount(double amount) {
    if (amount == amount.roundToDouble()) {
      return amount.toInt().toString();
    }
    return amount.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final factor = _currentServings / (widget.baseServings > 0 ? widget.baseServings : 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Servings Stepper Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ingredients',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${widget.ingredients.length} items needed',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceCard : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: _decrementServings,
                    icon: const Icon(Icons.remove, size: 16),
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    padding: EdgeInsets.zero,
                    splashRadius: 18,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      '$_currentServings servings',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _incrementServings,
                    icon: const Icon(Icons.add, size: 16),
                    constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    padding: EdgeInsets.zero,
                    splashRadius: 18,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Checkable Ingredients List
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.ingredients.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final ingredient = widget.ingredients[index];
            final scaledAmount = ingredient.amount * factor;
            final isChecked = _checkedIngredients.contains(index);

            return InkWell(
              onTap: () => _toggleChecked(index),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isChecked
                      ? (isDark ? AppColors.darkSurface : const Color(0xFFF1F3F5))
                      : (isDark ? AppColors.darkSurfaceCard : Colors.white),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isChecked
                        ? Colors.transparent
                        : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isChecked ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                      size: 20,
                      color: isChecked ? AppColors.secondary : AppColors.lightTextMuted,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        ingredient.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          decoration: isChecked ? TextDecoration.lineThrough : null,
                          color: isChecked
                              ? (isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted)
                              : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_formatAmount(scaledAmount)} ${ingredient.unit}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isChecked ? AppColors.lightTextMuted : AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
