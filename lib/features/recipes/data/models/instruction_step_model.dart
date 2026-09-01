import '../../domain/entities/instruction_step.dart';

class InstructionStepModel extends InstructionStep {
  const InstructionStepModel({
    super.id,
    required super.stepNumber,
    required super.instruction,
    super.timerSeconds,
  });

  factory InstructionStepModel.fromMap(Map<String, dynamic> map) {
    return InstructionStepModel(
      id: map['id'] as int?,
      stepNumber: (map['step_number'] as num).toInt(),
      instruction: map['instruction'] as String,
      timerSeconds: (map['timer_seconds'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> toMap(String recipeId) {
    final map = <String, dynamic>{
      'recipe_id': recipeId,
      'step_number': stepNumber,
      'instruction': instruction,
      'timer_seconds': timerSeconds,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }
}
