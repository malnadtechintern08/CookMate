import '../../domain/entities/instruction_step.dart';

class InstructionStepModel extends InstructionStep {
  const InstructionStepModel({
    super.id,
    required super.stepNumber,
    required super.instruction,
    super.timerSeconds,
  });

  factory InstructionStepModel.fromMap(Map<String, dynamic> map) {
    final rawStep = map['step_number'];
    int step = 1;
    if (rawStep is num) {
      step = rawStep.toInt();
    } else if (rawStep != null) {
      step = int.tryParse(rawStep.toString()) ?? 1;
    }

    final rawTimer = map['timer_seconds'];
    int? timer;
    if (rawTimer is num) {
      timer = rawTimer.toInt();
    } else if (rawTimer != null) {
      timer = int.tryParse(rawTimer.toString());
    }

    final rawId = map['id'];
    int? parsedId;
    if (rawId is int) {
      parsedId = rawId;
    } else if (rawId != null) {
      parsedId = int.tryParse(rawId.toString());
    }

    return InstructionStepModel(
      id: parsedId,
      stepNumber: step,
      instruction: (map['instruction'] as String?) ?? '',
      timerSeconds: timer,
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
