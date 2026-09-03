import '../../domain/entities/tag.dart';

class TagModel extends Tag {
  const TagModel({
    required super.id,
    required super.name,
    required super.slug,
    super.usageCount = 0,
  });

  factory TagModel.fromMap(Map<String, dynamic> map) {
    int parseInt(dynamic val, [int fallback = 0]) {
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? fallback;
      return fallback;
    }

    return TagModel(
      id: parseInt(map['id'], 0),
      name: (map['name'] as String?)?.trim() ?? '',
      slug: (map['slug'] as String?)?.trim() ?? '',
      usageCount: parseInt(map['usage_count'], 0),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'usage_count': usageCount,
    };
  }
}
