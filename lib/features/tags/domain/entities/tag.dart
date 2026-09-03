class Tag {
  final int id;
  final String name;
  final String slug;
  final int usageCount;

  const Tag({
    required this.id,
    required this.name,
    required this.slug,
    this.usageCount = 0,
  });

  String get displayName => '#$name';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tag &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}
