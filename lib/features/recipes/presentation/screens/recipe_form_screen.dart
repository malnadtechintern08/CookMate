import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/recipe_image.dart';
import '../../../categories/presentation/providers/category_providers.dart';
import '../../domain/entities/ingredient.dart';
import '../../domain/entities/instruction_step.dart';
import '../../domain/entities/recipe.dart';
import '../providers/recipe_providers.dart';

class RecipeFormScreen extends ConsumerStatefulWidget {
  final String? recipeId;

  const RecipeFormScreen({
    super.key,
    this.recipeId,
  });

  @override
  ConsumerState<RecipeFormScreen> createState() => _RecipeFormScreenState();
}

class _RecipeFormScreenState extends ConsumerState<RecipeFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _cuisineController = TextEditingController(text: 'Homemade');
  final _chefController = TextEditingController(text: 'Chef You');
  final _prepTimeController = TextEditingController(text: '15');
  final _cookTimeController = TextEditingController(text: '20');
  final _servingsController = TextEditingController(text: '4');

  String? _selectedImagePath;
  final ImagePicker _picker = ImagePicker();

  String _selectedCategoryId = 'cat_quick_snacks';
  RecipeDifficulty _selectedDifficulty = RecipeDifficulty.medium;

  final List<Map<String, TextEditingController>> _ingredientControllers = [];
  final List<Map<String, TextEditingController>> _instructionControllers = [];

  @override
  void initState() {
    super.initState();
    _addIngredientField('Olive Oil', '2', 'tbsp');
    _addIngredientField('Garlic Cloves', '3', 'cloves');
    _addInstructionField('Heat olive oil in a pan over medium heat and sauté garlic.', '2');
    _addInstructionField('Add main ingredients and simmer until cooked through.', '15');
  }

  void _addIngredientField([String name = '', String amount = '1', String unit = 'cup']) {
    setState(() {
      _ingredientControllers.add({
        'name': TextEditingController(text: name),
        'amount': TextEditingController(text: amount),
        'unit': TextEditingController(text: unit),
      });
    });
  }

  void _removeIngredientField(int index) {
    if (_ingredientControllers.length > 1) {
      setState(() {
        _ingredientControllers.removeAt(index);
      });
    }
  }

  void _addInstructionField([String text = '', String timerMins = '']) {
    setState(() {
      _instructionControllers.add({
        'instruction': TextEditingController(text: text),
        'timer': TextEditingController(text: timerMins),
      });
    });
  }

  void _removeInstructionField(int index) {
    if (_instructionControllers.length > 1) {
      setState(() {
        _instructionControllers.removeAt(index);
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _cuisineController.dispose();
    _chefController.dispose();
    _prepTimeController.dispose();
    _cookTimeController.dispose();
    _servingsController.dispose();
    for (final map in _ingredientControllers) {
      map['name']?.dispose();
      map['amount']?.dispose();
      map['unit']?.dispose();
    }
    for (final map in _instructionControllers) {
      map['instruction']?.dispose();
      map['timer']?.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (picked != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final ext = p.extension(picked.path).isEmpty ? '.jpg' : p.extension(picked.path);
        final fileName = 'recipe_${DateTime.now().millisecondsSinceEpoch}$ext';
        final savedFile = await File(picked.path).copy('${appDir.path}/$fileName');
        setState(() {
          _selectedImagePath = savedFile.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not access image: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showImageSourceSheet() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppColors.cardBackground : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'Add Recipe Photo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
                ),
                title: const Text('Take Photo with Camera', style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: const Text('Capture a picture of your dish'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.photo_library_rounded, color: Colors.blue),
                ),
                title: const Text('Choose from Gallery', style: TextStyle(fontWeight: FontWeight.w700)),
                subtitle: const Text('Select a photo from your device'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_selectedImagePath != null)
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                  ),
                  title: const Text('Remove Photo', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700)),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() {
                      _selectedImagePath = null;
                    });
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveRecipe() async {
    if (!_formKey.currentState!.validate()) return;

    final ingredients = <Ingredient>[];
    for (final map in _ingredientControllers) {
      final name = map['name']!.text.trim();
      final amount = double.tryParse(map['amount']!.text.trim()) ?? 1.0;
      final unit = map['unit']!.text.trim();
      if (name.isNotEmpty) {
        ingredients.add(Ingredient(name: name, amount: amount, unit: unit.isEmpty ? 'item' : unit));
      }
    }

    final instructions = <InstructionStep>[];
    for (int i = 0; i < _instructionControllers.length; i++) {
      final map = _instructionControllers[i];
      final text = map['instruction']!.text.trim();
      final timerMins = int.tryParse(map['timer']!.text.trim());
      if (text.isNotEmpty) {
        instructions.add(InstructionStep(
          stepNumber: i + 1,
          instruction: text,
          timerSeconds: timerMins != null && timerMins > 0 ? timerMins * 60 : null,
        ));
      }
    }

    final newRecipe = Recipe(
      id: const Uuid().v4(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? 'A delicious homemade recipe prepared with fresh ingredients.'
          : _descriptionController.text.trim(),
      chefName: _chefController.text.trim().isEmpty ? 'Chef' : _chefController.text.trim(),
      cuisine: _cuisineController.text.trim().isEmpty ? 'Homemade' : _cuisineController.text.trim(),
      imageUrl: (_selectedImagePath != null && _selectedImagePath!.isNotEmpty)
          ? _selectedImagePath!
          : 'assets/images/recipes/samosa.jpg',
      prepTimeMinutes: int.tryParse(_prepTimeController.text.trim()) ?? 15,
      cookTimeMinutes: int.tryParse(_cookTimeController.text.trim()) ?? 20,
      servings: int.tryParse(_servingsController.text.trim()) ?? 4,
      difficulty: _selectedDifficulty,
      categoryId: _selectedCategoryId,
      tags: ['Custom', _cuisineController.text.trim()],
      isFavorite: false,
      isCustom: true,
      createdAt: DateTime.now(),
      ingredients: ingredients,
      instructions: instructions,
    );

    try {
      await ref.read(recipeControllerProvider.notifier).createRecipe(newRecipe);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recipe created successfully! 🎉'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating recipe: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Custom Recipe ✍️'),
        actions: [
          TextButton(
            onPressed: _saveRecipe,
            child: const Text(
              'Save',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Basic Info Section
            _buildSectionHeader('BASIC INFORMATION'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Recipe Title *',
                hintText: 'e.g., Grandma\'s Secret Lasagna',
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'Title is required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description / Story',
                hintText: 'Describe flavors, textures, or history...',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cuisineController,
                    decoration: const InputDecoration(
                      labelText: 'Cuisine',
                      hintText: 'e.g., Italian, Mexican',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _chefController,
                    decoration: const InputDecoration(
                      labelText: 'Chef / Author',
                      hintText: 'Your name',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildPhotoPicker(isDark),
            const SizedBox(height: 24),

            // Category & Timing Section
            _buildSectionHeader('CATEGORY & SPECS'),
            const SizedBox(height: 12),
            categoriesAsync.when(
              data: (categories) {
                if (!categories.any((c) => c.id == _selectedCategoryId) && categories.isNotEmpty) {
                  _selectedCategoryId = categories.first.id;
                }
                return DropdownButtonFormField<String>(
                  initialValue: _selectedCategoryId,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: categories
                      .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name)))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCategoryId = val);
                  },
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (error, stack) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<RecipeDifficulty>(
              initialValue: _selectedDifficulty,
              decoration: const InputDecoration(labelText: 'Difficulty Level'),
              items: RecipeDifficulty.values
                  .map((d) => DropdownMenuItem(value: d, child: Text(d.label)))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedDifficulty = val);
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _prepTimeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Prep Time (m)',
                      suffixText: 'min',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _cookTimeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Cook Time (m)',
                      suffixText: 'min',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _servingsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Servings',
                      suffixText: 'ppl',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Dynamic Ingredients Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionHeader('INGREDIENTS'),
                TextButton.icon(
                  onPressed: () => _addIngredientField(),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Item'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _ingredientControllers.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final map = _ingredientControllers[index];
                return Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: map['name'],
                        decoration: const InputDecoration(
                          hintText: 'Ingredient (e.g. Flour)',
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        controller: map['amount'],
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'Qty',
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: map['unit'],
                        decoration: const InputDecoration(
                          hintText: 'Unit (g, tbsp)',
                          contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: AppColors.error, size: 20),
                      onPressed: () => _removeIngredientField(index),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 28),

            // Dynamic Instructions Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionHeader('INSTRUCTIONS / STEPS'),
                TextButton.icon(
                  onPressed: () => _addInstructionField(),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Step'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _instructionControllers.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final map = _instructionControllers[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceCard : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Step ${index + 1}',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                            onPressed: () => _removeInstructionField(index),
                          ),
                        ],
                      ),
                      TextFormField(
                        controller: map['instruction'],
                        maxLines: 2,
                        decoration: const InputDecoration(
                          hintText: 'Describe this cooking step...',
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: map['timer'],
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          hintText: 'Optional Timer (in minutes, e.g. 10)',
                          prefixIcon: Icon(Icons.timer_outlined, size: 18),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 36),

            // Save CTA Button
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _saveRecipe,
                icon: const Icon(Icons.check_rounded),
                label: const Text('Save Custom Recipe', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
              ),
            ),
            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: AppColors.primary,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildPhotoPicker(bool isDark) {
    final hasImage = _selectedImagePath != null && _selectedImagePath!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surface : const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasImage ? AppColors.primary.withValues(alpha: 0.5) : (isDark ? AppColors.border : const Color(0xFFE0E0E0)),
          width: hasImage ? 1.5 : 1.0,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasImage) ...[
            Stack(
              children: [
                RecipeImage(
                  imagePath: _selectedImagePath!,
                  height: 190,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: InkWell(
                    onTap: () => setState(() => _selectedImagePath = null),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            InkWell(
              onTap: _showImageSourceSheet,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                child: Column(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add_a_photo_rounded,
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Recipe Photo',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Take a picture of your dish or pick from gallery',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.textSecondary : Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardBackground : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.border : const Color(0xFFEBEBEB),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_rounded, size: 18),
                    label: const Text('Camera'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_rounded, size: 18),
                    label: const Text('Gallery'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
