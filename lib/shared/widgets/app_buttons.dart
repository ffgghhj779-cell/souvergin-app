import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_constants.dart';

// ── Primary Button ────────────────────────────────────────────────────────────

/// Primary CTA button – blue rounded pill, matching web's blue-600 buttons.
/// Now with press-scale micro-animation and haptic feedback.
class PrimaryButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool iconTrailing;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.iconTrailing = false,
  });

  @override
  State<PrimaryButton> createState() => _PrimaryButtonState();
}

class _PrimaryButtonState extends State<PrimaryButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _scale;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 220),
    );
    // Presses to 96% — subtle, sophisticated
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut),
    );
    // Glow elevation reduces on press (like a physical button sinking)
    _glow = Tween<double>(begin: 1.0, end: 0.4).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    if (widget.onPressed == null || widget.isLoading) return;
    HapticFeedback.lightImpact();
    _pressCtrl.forward();
  }

  void _handleTapUp(TapUpDetails _) {
    _pressCtrl.reverse();
    if (widget.onPressed != null && !widget.isLoading) {
      widget.onPressed!();
    }
  }

  void _handleTapCancel() => _pressCtrl.reverse();

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null || widget.isLoading;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _pressCtrl,
        builder: (context, child) {
          return Transform.scale(
            scale: _scale.value,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 54,
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(AppConstants.radiusFull),
                color: isDisabled
                    ? AppConstants.colorPrimary.withValues(alpha: 0.5)
                    : AppConstants.colorPrimary,
                boxShadow: [
                  BoxShadow(
                    color: AppConstants.colorPrimary
                        .withValues(alpha: 0.35 * _glow.value),
                    blurRadius: 20 * _glow.value,
                    offset: Offset(0, 6 * _glow.value),
                  ),
                ],
              ),
              child: child,
            ),
          );
        },
        child: Center(
          child: widget.isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : _buildLabel(),
        ),
      ),
    );
  }

  Widget _buildLabel() {
    final textWidget = Text(
      widget.label,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 0.2,
      ),
    );
    if (widget.icon == null) return textWidget;
    final iconWidget = Icon(widget.icon, size: 18, color: Colors.white);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: widget.iconTrailing
          ? [textWidget, const SizedBox(width: 8), iconWidget]
          : [iconWidget, const SizedBox(width: 8), textWidget],
    );
  }
}

// ── Ghost Button ──────────────────────────────────────────────────────────────

/// Ghost / secondary button – dark border on dark bg.
/// Now with press-scale micro-animation and haptic feedback.
class GhostButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  const GhostButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
  });

  @override
  State<GhostButton> createState() => _GhostButtonState();
}

class _GhostButtonState extends State<GhostButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 220),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (widget.onPressed == null) return;
        HapticFeedback.lightImpact();
        _pressCtrl.forward();
      },
      onTapUp: (_) {
        _pressCtrl.reverse();
        widget.onPressed?.call();
      },
      onTapCancel: () => _pressCtrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: SizedBox(
          height: 54,
          child: OutlinedButton(
            onPressed: null, // gesture handled above
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white70,
              side: const BorderSide(color: AppConstants.colorBorder),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppConstants.radiusFull),
              ),
            ),
            child: widget.icon != null
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(widget.icon, size: 18),
                      const SizedBox(width: 8),
                      Text(widget.label),
                    ],
                  )
                : Text(widget.label),
          ),
        ),
      ),
    );
  }
}

// ── Status Badge ──────────────────────────────────────────────────────────────

/// Animated tag chip (mono-style, blue tinted) – mirrors web's "System Operational" badge.
class StatusBadge extends StatelessWidget {
  final String label;
  final Color dotColor;
  final bool animated;

  const StatusBadge({
    super.key,
    required this.label,
    this.dotColor = AppConstants.colorAccent,
    this.animated = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1628),
        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
        border: Border.all(color: const Color(0xFF1E3A5F)),
        boxShadow: [
          BoxShadow(
            color: AppConstants.colorAccent.withValues(alpha: 0.08),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _AnimatedDot(color: dotColor, animated: animated),
          const SizedBox(width: 8),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppConstants.colorAccent,
              letterSpacing: 1.5,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedDot extends StatelessWidget {
  final Color color;
  final bool animated;
  const _AnimatedDot({required this.color, required this.animated});

  @override
  Widget build(BuildContext context) {
    final dot = Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
    if (!animated) return dot;
    return Stack(
      alignment: Alignment.center,
      children: [
        dot
            .animate(onPlay: (c) => c.repeat())
            .scale(
              begin: const Offset(1, 1),
              end: const Offset(2.2, 2.2),
              duration: 1200.ms,
              curve: Curves.easeOut,
            )
            .fadeOut(duration: 1200.ms),
        dot,
      ],
    );
  }
}

// ── Mono Tag ──────────────────────────────────────────────────────────────────

/// Mono-style tag pill (Verified Route, Issued, etc.)
class MonoTag extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const MonoTag({
    super.key,
    required this.label,
    this.color = AppConstants.colorAccent,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 1.4,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
