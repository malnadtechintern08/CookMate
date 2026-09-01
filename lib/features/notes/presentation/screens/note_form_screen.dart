import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../recipes/presentation/providers/recipe_providers.dart';
import '../../domain/entities/note.dart';
import '../providers/notes_providers.dart';

class NoteFormScreen extends ConsumerStatefulWidget {
  final String? noteId;
  final Note? initialNote;

  const NoteFormScreen({
    super.key,
    this.noteId,
    this.initialNote,
  });

  @override
  ConsumerState<NoteFormScreen> createState() => _NoteFormScreenState();
}

class _NoteFormScreenState extends ConsumerState<NoteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late final TextEditingController _tagsController;

  late String _selectedCategory;
  late bool _isPinned;
  late bool _isFavorite;
  String? _selectedRecipeId;
  String? _selectedRecipeTitle;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final note = widget.initialNote;
    _titleController = TextEditingController(text: note?.title ?? '');
    _contentController = TextEditingController(text: note?.content ?? '');
    _tagsController = TextEditingController(text: note?.tags.join(', ') ?? '');
    _selectedCategory = note?.category ?? NoteCategory.recipeIdea;
    _isPinned = note?.isPinned ?? false;
    _isFavorite = note?.isFavorite ?? false;
    _selectedRecipeId = note?.relatedRecipeId;
    _selectedRecipeTitle = note?.relatedRecipeTitle;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    final l10n = AppLocalizations.of(context)!;

    final rawTags = _tagsController.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final now = DateTime.now();

    if (widget.initialNote != null) {
      // Update existing note
      final updated = widget.initialNote!.copyWith(
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        category: _selectedCategory,
        tags: rawTags,
        isPinned: _isPinned,
        isFavorite: _isFavorite,
        relatedRecipeId: _selectedRecipeId,
        relatedRecipeTitle: _selectedRecipeTitle,
        clearRelatedRecipe: _selectedRecipeId == null,
        updatedAt: now,
      );
      await ref.read(notesControllerProvider.notifier).updateNote(updated);
    } else {
      // Create new note
      final newNote = Note(
        id: const Uuid().v4(),
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        category: _selectedCategory,
        tags: rawTags,
        isPinned: _isPinned,
        isFavorite: _isFavorite,
        relatedRecipeId: _selectedRecipeId,
        relatedRecipeTitle: _selectedRecipeTitle,
        createdAt: now,
        updatedAt: now,
      );
      await ref.read(notesControllerProvider.notifier).createNote(newNote);
    }

    if (mounted) {
      setState(() => _isSaving = false);
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.noteSavedSuccess),
          backgroundColor: AppColors.vegGreen,
        ),
      );
    }
  }

  void _showRecipeSelectorModal(BuildContext context) {
    final allRecipesAsync = ref.read(allRecipesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.cardBackground : AppColors.lightSurfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        String query = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.4,
              maxChildSize: 0.9,
              expand: false,
              builder: (context, scrollController) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.border : AppColors.lightBorder,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.selectRecipe,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        autofocus: false,
                        decoration: InputDecoration(
                          hintText: l10n.searchHint,
                          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryOrange),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                        ),
                        onChanged: (val) {
                          setModalState(() {
                            query = val.trim().toLowerCase();
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        leading: const Icon(Icons.clear_rounded, color: AppColors.nonVegRed),
                        title: Text(l10n.noRecipeSelected),
                        onTap: () {
                          setState(() {
                            _selectedRecipeId = null;
                            _selectedRecipeTitle = null;
                          });
                          Navigator.of(ctx).pop();
                        },
                      ),
                      const Divider(),
                      Expanded(
                        child: allRecipesAsync.when(
                          data: (recipes) {
                            final filtered = query.isEmpty
                                ? recipes
                                : recipes.where((r) => r.title.toLowerCase().contains(query)).toList();

                            return ListView.builder(
                              controller: scrollController,
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final recipe = filtered[index];
                                final isSelected = _selectedRecipeId == recipe.id;
                                return ListTile(
                                  leading: const Icon(Icons.restaurant_menu_rounded, color: AppColors.primaryOrange),
                                  title: Text(
                                    recipe.title,
                                    style: TextStyle(
                                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                                      color: isSelected ? AppColors.primaryOrange : null,
                                    ),
                                  ),
                                  subtitle: Text('${recipe.cuisine} • ${recipe.region}'),
                                  trailing: isSelected
                                      ? const Icon(Icons.check_circle_rounded, color: AppColors.primaryOrange)
                                      : null,
                                  onTap: () {
                                    setState(() {
                                      _selectedRecipeId = recipe.id;
                                      _selectedRecipeTitle = recipe.title;
                                    });
                                    Navigator.of(ctx).pop();
                                  },
                                );
                              },
                            );
                          },
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (err, _) => Center(child: Text('Error: $err')),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialNote != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? l10n.editNote : l10n.newNote),
        actions: [
          IconButton(
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryOrange),
                  )
                : const Icon(Icons.check_rounded, color: AppColors.primaryOrange),
            tooltip: l10n.save,
            onPressed: _isSaving ? null : _saveNote,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Title input
            TextFormField(
              controller: _titleController,
              autofocus: !isEditing,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                labelText: '${l10n.noteTitle} *',
                hintText: l10n.noteTitleHint,
                prefixIcon: const Icon(Icons.edit_note_rounded, color: AppColors.primaryOrange),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.noteTitleRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Category Selection
            Text(
              l10n.category.toUpperCase(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryOrange,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: NoteCategory.allCategories.map((cat) {
                final isSelected = _selectedCategory == cat;
                final catLabel = NoteCategory.getLocalizedName(cat, l10n);
                return ChoiceChip(
                  label: Text(catLabel),
                  selected: isSelected,
                  selectedColor: AppColors.primaryOrange,
                  backgroundColor: isDark ? AppColors.cardBackground : AppColors.lightSurfaceCard,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : (isDark ? AppColors.textSecondary : AppColors.lightTextSecondary),
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.primaryOrange
                        : (isDark ? AppColors.border : AppColors.lightBorder),
                  ),
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedCategory = cat);
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Note Content
            TextFormField(
              controller: _contentController,
              maxLines: 8,
              minLines: 5,
              style: const TextStyle(fontSize: 15, height: 1.45),
              decoration: InputDecoration(
                labelText: l10n.noteContent,
                hintText: l10n.noteContentHint,
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 20),

            // Related Recipe Selector
            Text(
              l10n.relatedRecipe.toUpperCase(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryOrange,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _showRecipeSelectorModal(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardBackground : AppColors.lightSurfaceCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _selectedRecipeId != null
                        ? AppColors.primaryOrange.withValues(alpha: 0.5)
                        : (isDark ? AppColors.border : AppColors.lightBorder),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.restaurant_rounded, color: AppColors.primaryOrange, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _selectedRecipeTitle ?? l10n.selectRecipe,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: _selectedRecipeTitle != null ? FontWeight.w700 : FontWeight.w400,
                          color: _selectedRecipeTitle != null
                              ? (isDark ? AppColors.textPrimary : AppColors.lightTextPrimary)
                              : (isDark ? AppColors.textMuted : AppColors.lightTextMuted),
                        ),
                      ),
                    ),
                    if (_selectedRecipeId != null)
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () {
                          setState(() {
                            _selectedRecipeId = null;
                            _selectedRecipeTitle = null;
                          });
                        },
                      )
                    else
                      const Icon(Icons.arrow_drop_down_rounded, color: AppColors.primaryOrange),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Tags input
            TextFormField(
              controller: _tagsController,
              decoration: InputDecoration(
                labelText: l10n.tags,
                hintText: l10n.tagsHint,
                prefixIcon: const Icon(Icons.tag_rounded, color: AppColors.primaryOrange),
              ),
            ),
            const SizedBox(height: 24),

            // Switches: Pin & Favorite
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardBackground : AppColors.lightSurfaceCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? AppColors.border : AppColors.lightBorder),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: Row(
                      children: [
                        const Icon(Icons.push_pin_rounded, size: 18, color: AppColors.primaryOrange),
                        const SizedBox(width: 8),
                        Text(l10n.pinned, style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                    value: _isPinned,
                    activeThumbColor: AppColors.primaryOrange,
                    onChanged: (val) => setState(() => _isPinned = val),
                  ),
                  Divider(color: isDark ? AppColors.border : AppColors.lightBorder, height: 1),
                  SwitchListTile(
                    title: Row(
                      children: [
                        const Icon(Icons.favorite_rounded, size: 18, color: AppColors.nonVegRed),
                        const SizedBox(width: 8),
                        Text(l10n.favorite, style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                    value: _isFavorite,
                    activeThumbColor: AppColors.nonVegRed,
                    onChanged: (val) => setState(() => _isFavorite = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Save Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.save_rounded, color: Colors.white),
              label: Text(
                l10n.save,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
              ),
              onPressed: _isSaving ? null : _saveNote,
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
