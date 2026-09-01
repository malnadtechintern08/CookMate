import 'dart:convert';
import '../../domain/entities/note.dart';

class NoteModel extends Note {
  const NoteModel({
    required super.id,
    required super.title,
    required super.content,
    required super.category,
    super.tags,
    super.isPinned,
    super.isFavorite,
    super.relatedRecipeId,
    super.relatedRecipeTitle,
    required super.createdAt,
    required super.updatedAt,
  });

  factory NoteModel.fromEntity(Note note) {
    return NoteModel(
      id: note.id,
      title: note.title,
      content: note.content,
      category: note.category,
      tags: note.tags,
      isPinned: note.isPinned,
      isFavorite: note.isFavorite,
      relatedRecipeId: note.relatedRecipeId,
      relatedRecipeTitle: note.relatedRecipeTitle,
      createdAt: note.createdAt,
      updatedAt: note.updatedAt,
    );
  }

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    List<String> parsedTags = [];
    if (map['tags'] != null && map['tags'] is String && (map['tags'] as String).isNotEmpty) {
      try {
        final decoded = jsonDecode(map['tags'] as String);
        if (decoded is List) {
          parsedTags = decoded.map((e) => e.toString()).toList();
        }
      } catch (_) {
        // Fallback for comma separated string
        parsedTags = (map['tags'] as String)
            .split(',')
            .map((t) => t.trim())
            .where((t) => t.isNotEmpty)
            .toList();
      }
    }

    return NoteModel(
      id: map['id'] as String,
      title: map['title'] as String? ?? '',
      content: map['content'] as String? ?? '',
      category: map['category'] as String? ?? NoteCategory.other,
      tags: parsedTags,
      isPinned: (map['is_pinned'] as int? ?? 0) == 1,
      isFavorite: (map['is_favorite'] as int? ?? 0) == 1,
      relatedRecipeId: map['related_recipe_id'] as String?,
      relatedRecipeTitle: map['related_recipe_title'] as String?,
      createdAt: DateTime.tryParse(map['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'tags': jsonEncode(tags),
      'is_pinned': isPinned ? 1 : 0,
      'is_favorite': isFavorite ? 1 : 0,
      'related_recipe_id': relatedRecipeId,
      'related_recipe_title': relatedRecipeTitle,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Note toEntity() {
    return Note(
      id: id,
      title: title,
      content: content,
      category: category,
      tags: tags,
      isPinned: isPinned,
      isFavorite: isFavorite,
      relatedRecipeId: relatedRecipeId,
      relatedRecipeTitle: relatedRecipeTitle,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
