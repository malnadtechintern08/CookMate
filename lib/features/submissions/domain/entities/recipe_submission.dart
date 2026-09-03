enum SubmissionStatus {
  pending,
  underReview,
  changesRequested,
  approved,
  rejected,
  published;

  static SubmissionStatus fromString(String? val) {
    switch (val?.toLowerCase().trim()) {
      case 'under_review':
        return SubmissionStatus.underReview;
      case 'changes_requested':
        return SubmissionStatus.changesRequested;
      case 'approved':
        return SubmissionStatus.approved;
      case 'rejected':
        return SubmissionStatus.rejected;
      case 'published':
        return SubmissionStatus.published;
      case 'pending':
      default:
        return SubmissionStatus.pending;
    }
  }

  String get displayName {
    switch (this) {
      case SubmissionStatus.pending:
        return 'Pending Review';
      case SubmissionStatus.underReview:
        return 'Under Review';
      case SubmissionStatus.changesRequested:
        return 'Changes Requested';
      case SubmissionStatus.approved:
        return 'Approved';
      case SubmissionStatus.rejected:
        return 'Not Approved';
      case SubmissionStatus.published:
        return 'Approved & Published';
    }
  }

  String get dbValue {
    switch (this) {
      case SubmissionStatus.pending:
        return 'pending';
      case SubmissionStatus.underReview:
        return 'under_review';
      case SubmissionStatus.changesRequested:
        return 'changes_requested';
      case SubmissionStatus.approved:
        return 'approved';
      case SubmissionStatus.rejected:
        return 'rejected';
      case SubmissionStatus.published:
        return 'published';
    }
  }
}

class SubmissionIngredient {
  final String name;
  final String quantity;
  final String unit;
  final int position;

  const SubmissionIngredient({
    required this.name,
    this.quantity = '1',
    this.unit = '',
    this.position = 1,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'quantity': quantity,
    'unit': unit,
    'position': position,
  };

  factory SubmissionIngredient.fromJson(Map<String, dynamic> json) =>
      SubmissionIngredient(
        name: json['name']?.toString() ?? json['ingredient']?.toString() ?? '',
        quantity: json['quantity']?.toString() ?? '1',
        unit: json['unit']?.toString() ?? '',
        position: (json['position'] as num?)?.toInt() ?? 1,
      );
}

class SubmissionStep {
  final int stepNumber;
  final String instruction;
  final int timerSeconds;

  const SubmissionStep({
    required this.stepNumber,
    required this.instruction,
    this.timerSeconds = 0,
  });

  Map<String, dynamic> toJson() => {
    'step_number': stepNumber,
    'instruction': instruction,
    'timer_seconds': timerSeconds,
  };

  factory SubmissionStep.fromJson(Map<String, dynamic> json) => SubmissionStep(
    stepNumber: (json['step_number'] as num?)?.toInt() ?? 1,
    instruction: json['instruction']?.toString() ?? '',
    timerSeconds: (json['timer_seconds'] as num?)?.toInt() ?? 0,
  );
}

class RecipeSubmission {
  final int id;
  final String recipeName;
  final String description;
  final String categoryId;
  final String categoryName;
  final String categoryColor;
  final String? image;
  final int prepTime;
  final int cookTime;
  final String difficulty;
  final int servings;
  final String cuisine;
  final String foodType;
  final String? notes;
  final SubmissionStatus status;
  final bool allowPublication;
  final bool showAuthorName;
  final String? authorDisplayName;
  final String? adminNotes;
  final String? rejectionReason;
  final String? publishedRecipeId;
  final DateTime submittedAt;
  final DateTime? reviewedAt;
  final List<String> tags;
  final int ingredientCount;
  final int stepCount;
  final List<SubmissionIngredient> ingredients;
  final List<SubmissionStep> steps;

  const RecipeSubmission({
    required this.id,
    required this.recipeName,
    required this.description,
    required this.categoryId,
    this.categoryName = 'General',
    this.categoryColor = '#E50914',
    this.image,
    this.prepTime = 15,
    this.cookTime = 20,
    this.difficulty = 'Medium',
    this.servings = 4,
    this.cuisine = 'Homemade',
    this.foodType = 'Vegetarian',
    this.notes,
    this.status = SubmissionStatus.pending,
    this.allowPublication = false,
    this.showAuthorName = false,
    this.authorDisplayName,
    this.adminNotes,
    this.rejectionReason,
    this.publishedRecipeId,
    required this.submittedAt,
    this.reviewedAt,
    this.tags = const [],
    this.ingredientCount = 0,
    this.stepCount = 0,
    this.ingredients = const [],
    this.steps = const [],
  });

  int get totalTime => prepTime + cookTime;
  bool get isVegetarian =>
      foodType.toLowerCase() == 'vegetarian' || foodType.toLowerCase() == 'veg';
  bool get isPublished => status == SubmissionStatus.published;
  bool get isPending => status == SubmissionStatus.pending;
  bool get hasChangesRequested => status == SubmissionStatus.changesRequested;
  bool get isRejected => status == SubmissionStatus.rejected;
}
