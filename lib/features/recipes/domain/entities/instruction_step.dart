class InstructionStep {
  final int? id;
  final int stepNumber;
  final String instruction;
  final int? timerSeconds;

  const InstructionStep({
    this.id,
    required this.stepNumber,
    required this.instruction,
    this.timerSeconds,
  });

  InstructionStep copyWith({
    int? id,
    int? stepNumber,
    String? instruction,
    int? timerSeconds,
  }) {
    return InstructionStep(
      id: id ?? this.id,
      stepNumber: stepNumber ?? this.stepNumber,
      instruction: instruction ?? this.instruction,
      timerSeconds: timerSeconds ?? this.timerSeconds,
    );
  }

  bool get hasTimer => timerSeconds != null && timerSeconds! > 0;
}
