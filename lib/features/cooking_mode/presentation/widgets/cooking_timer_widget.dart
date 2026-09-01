import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/time_formatter.dart';

class CookingTimerWidget extends StatelessWidget {
  final int remainingSeconds;
  final int initialSeconds;
  final bool isRunning;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onReset;
  final Function(int) onAddSeconds;

  const CookingTimerWidget({
    super.key,
    required this.remainingSeconds,
    required this.initialSeconds,
    required this.isRunning,
    required this.onStart,
    required this.onPause,
    required this.onReset,
    required this.onAddSeconds,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isCompleted = remainingSeconds == 0 && initialSeconds > 0;
    final double progress = initialSeconds > 0 ? (remainingSeconds / initialSeconds).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isCompleted
            ? AppColors.success.withValues(alpha: 0.12)
            : (isDark ? AppColors.darkSurfaceCard : Colors.white),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCompleted
              ? AppColors.success
              : (isRunning ? AppColors.primary : (isDark ? AppColors.darkBorder : AppColors.lightBorder)),
          width: isRunning || isCompleted ? 2.0 : 1.0,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.timer_rounded,
                    size: 20,
                    color: isCompleted ? AppColors.success : AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isCompleted ? 'STEP TIMER FINISHED' : 'STEP TIMER',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: isCompleted ? AppColors.success : AppColors.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              if (isRunning)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 8,
                        height: 8,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      ),
                      SizedBox(width: 6),
                      Text(
                        'RUNNING',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Digital Timer display with linear progress
          Text(
            TimeFormatter.formatSecondsToTimer(remainingSeconds),
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              color: isCompleted
                  ? AppColors.success
                  : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightBorder,
              valueColor: AlwaysStoppedAnimation<Color>(
                isCompleted ? AppColors.success : AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Reset Button
              IconButton.filledTonal(
                onPressed: onReset,
                icon: const Icon(Icons.replay_rounded, size: 20),
                tooltip: 'Reset timer',
              ),
              const SizedBox(width: 14),

              // Play / Pause Toggle Button
              ElevatedButton.icon(
                onPressed: isCompleted ? onReset : (isRunning ? onPause : onStart),
                icon: Icon(
                  isCompleted
                      ? Icons.replay_rounded
                      : (isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded),
                  size: 22,
                ),
                label: Text(
                  isCompleted ? 'Restart' : (isRunning ? 'Pause' : 'Start'),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCompleted ? AppColors.success : AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              const SizedBox(width: 14),

              // +1 Minute Booster
              IconButton.filledTonal(
                onPressed: () => onAddSeconds(60),
                icon: const Text('+1m', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11)),
                tooltip: 'Add 1 minute',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
