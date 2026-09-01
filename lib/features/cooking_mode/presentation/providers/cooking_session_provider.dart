import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cookmate/features/recipes/domain/entities/recipe.dart';

class CookingSessionState {
  final Recipe recipe;
  final int currentStepIndex;
  final Set<int> completedSteps;
  final int remainingTimerSeconds;
  final bool isTimerRunning;
  final int initialTimerSeconds;
  final bool isFinished;

  const CookingSessionState({
    required this.recipe,
    this.currentStepIndex = 0,
    this.completedSteps = const {},
    this.remainingTimerSeconds = 0,
    this.isTimerRunning = false,
    this.initialTimerSeconds = 0,
    this.isFinished = false,
  });

  CookingSessionState copyWith({
    Recipe? recipe,
    int? currentStepIndex,
    Set<int>? completedSteps,
    int? remainingTimerSeconds,
    bool? isTimerRunning,
    int? initialTimerSeconds,
    bool? isFinished,
  }) {
    return CookingSessionState(
      recipe: recipe ?? this.recipe,
      currentStepIndex: currentStepIndex ?? this.currentStepIndex,
      completedSteps: completedSteps ?? this.completedSteps,
      remainingTimerSeconds: remainingTimerSeconds ?? this.remainingTimerSeconds,
      isTimerRunning: isTimerRunning ?? this.isTimerRunning,
      initialTimerSeconds: initialTimerSeconds ?? this.initialTimerSeconds,
      isFinished: isFinished ?? this.isFinished,
    );
  }

  double get progressPercentage {
    if (recipe.instructions.isEmpty) return 1.0;
    return completedSteps.length / recipe.instructions.length;
  }
}

class CookingSessionNotifier extends StateNotifier<CookingSessionState> {
  Timer? _timer;

  CookingSessionNotifier(Recipe recipe)
      : super(CookingSessionState(
          recipe: recipe,
          remainingTimerSeconds: recipe.instructions.isNotEmpty
              ? (recipe.instructions.first.timerSeconds ?? 0)
              : 0,
          initialTimerSeconds: recipe.instructions.isNotEmpty
              ? (recipe.instructions.first.timerSeconds ?? 0)
              : 0,
        ));

  void nextStep() {
    _timer?.cancel();
    final nextIdx = state.currentStepIndex + 1;
    if (nextIdx < state.recipe.instructions.length) {
      final step = state.recipe.instructions[nextIdx];
      final duration = step.timerSeconds ?? 0;
      state = state.copyWith(
        currentStepIndex: nextIdx,
        remainingTimerSeconds: duration,
        initialTimerSeconds: duration,
        isTimerRunning: false,
      );
    } else {
      state = state.copyWith(isFinished: true, isTimerRunning: false);
    }
  }

  void previousStep() {
    _timer?.cancel();
    if (state.currentStepIndex > 0) {
      final prevIdx = state.currentStepIndex - 1;
      final step = state.recipe.instructions[prevIdx];
      final duration = step.timerSeconds ?? 0;
      state = state.copyWith(
        currentStepIndex: prevIdx,
        remainingTimerSeconds: duration,
        initialTimerSeconds: duration,
        isTimerRunning: false,
        isFinished: false,
      );
    }
  }

  void goToStep(int index) {
    if (index >= 0 && index < state.recipe.instructions.length) {
      _timer?.cancel();
      final step = state.recipe.instructions[index];
      final duration = step.timerSeconds ?? 0;
      state = state.copyWith(
        currentStepIndex: index,
        remainingTimerSeconds: duration,
        initialTimerSeconds: duration,
        isTimerRunning: false,
        isFinished: false,
      );
    }
  }

  void toggleStepCompletion(int stepIndex) {
    final updated = Set<int>.from(state.completedSteps);
    if (updated.contains(stepIndex)) {
      updated.remove(stepIndex);
    } else {
      updated.add(stepIndex);
    }
    state = state.copyWith(completedSteps: updated);
  }

  void startTimer() {
    if (state.remainingTimerSeconds <= 0) return;
    _timer?.cancel();
    state = state.copyWith(isTimerRunning: true);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingTimerSeconds > 1) {
        state = state.copyWith(remainingTimerSeconds: state.remainingTimerSeconds - 1);
      } else {
        _timer?.cancel();
        state = state.copyWith(
          remainingTimerSeconds: 0,
          isTimerRunning: false,
        );
        // Automatically mark current step completed
        final updated = Set<int>.from(state.completedSteps);
        updated.add(state.currentStepIndex);
        state = state.copyWith(completedSteps: updated);
      }
    });
  }

  void pauseTimer() {
    _timer?.cancel();
    state = state.copyWith(isTimerRunning: false);
  }

  void resetTimer() {
    _timer?.cancel();
    state = state.copyWith(
      remainingTimerSeconds: state.initialTimerSeconds,
      isTimerRunning: false,
    );
  }

  void addTimerSeconds(int seconds) {
    final newTime = state.remainingTimerSeconds + seconds;
    state = state.copyWith(
      remainingTimerSeconds: newTime,
      initialTimerSeconds: state.initialTimerSeconds + seconds,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final cookingSessionProvider = StateNotifierProvider.family.autoDispose<
    CookingSessionNotifier, CookingSessionState, Recipe>((ref, recipe) {
  return CookingSessionNotifier(recipe);
});
