class SupportPage {
  final String id;
  final String title;
  final String slug;
  final String summary;
  final String content;
  final Map<String, dynamic> meta;
  final bool isPublished;
  final DateTime? updatedAt;

  const SupportPage({
    required this.id,
    required this.title,
    required this.slug,
    required this.summary,
    required this.content,
    this.meta = const {},
    this.isPublished = true,
    this.updatedAt,
  });
}
