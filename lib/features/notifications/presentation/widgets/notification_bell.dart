import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/notification_providers.dart';

class NotificationBell extends ConsumerStatefulWidget {
  final Color? iconColor;
  final double size;

  const NotificationBell({
    super.key,
    this.iconColor,
    this.size = 24.0,
  });

  @override
  ConsumerState<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends ConsumerState<NotificationBell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;
  double _tapScale = 1.0;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    // Damped harmonic shake animation (-0.14 -> +0.14 -> -0.08 -> +0.08 -> 0)
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -0.14).chain(CurveTween(curve: Curves.easeOut)), weight: 20),
      TweenSequenceItem(tween: Tween(begin: -0.14, end: 0.14).chain(CurveTween(curve: Curves.easeInOut)), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.14, end: -0.07).chain(CurveTween(curve: Curves.easeInOut)), weight: 25),
      TweenSequenceItem(tween: Tween(begin: -0.07, end: 0.0).chain(CurveTween(curve: Curves.easeIn)), weight: 25),
    ]).animate(_shakeController);

    // Initial subtle shake on mount if notifications exist
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final initialCount = ref.read(unreadNotificationCountProvider);
      if (initialCount > 0 && mounted) {
        _shakeController.forward(from: 0.0);
      }
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _triggerShake() {
    if (!_shakeController.isAnimating) {
      _shakeController.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen for unread count changes and shake when count increases
    ref.listen<int>(unreadNotificationCountProvider, (prev, next) {
      if (next > (prev ?? 0)) {
        _triggerShake();
      }
    });

    final unreadCount = ref.watch(unreadNotificationCountProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = widget.iconColor ?? (isDark ? Colors.white : AppColors.lightTextPrimary);

    return GestureDetector(
      onTapDown: (_) => setState(() => _tapScale = 0.88),
      onTapUp: (_) => setState(() => _tapScale = 1.0),
      onTapCancel: () => setState(() => _tapScale = 1.0),
      onTap: () {
        HapticFeedback.lightImpact();
        context.pushNamed(RouteNames.notifications);
      },
      child: AnimatedScale(
        scale: _tapScale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutQuad,
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardBackground.withOpacity(0.6) : AppColors.lightSurfaceCard,
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark ? AppColors.border.withOpacity(0.8) : AppColors.lightBorder,
              width: 1,
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Animated Shaking Bell
              AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _shakeAnimation.value * math.pi,
                    alignment: Alignment.topCenter,
                    child: child,
                  );
                },
                child: Icon(
                  unreadCount > 0 ? Icons.notifications_rounded : Icons.notifications_none_rounded,
                  color: unreadCount > 0 ? AppColors.primary : defaultColor,
                  size: widget.size,
                ),
              ),

              // Creative CookMate Red Unread Badge
              if (unreadCount > 0)
                Positioned(
                  top: -5,
                  right: -7,
                  child: AnimatedScale(
                    scale: 1.0,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.elasticOut,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark ? AppColors.background : Colors.white,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.5),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          unreadCount > 99 ? '99+' : unreadCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.2,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
