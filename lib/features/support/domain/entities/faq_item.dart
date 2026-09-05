class FaqItem {
  final int id;
  final String category;
  final String question;
  final String answer;
  final int sortOrder;
  final bool isPublished;
  final DateTime? updatedAt;

  const FaqItem({
    required this.id,
    required this.category,
    required this.question,
    required this.answer,
    this.sortOrder = 0,
    this.isPublished = true,
    this.updatedAt,
  });
}
