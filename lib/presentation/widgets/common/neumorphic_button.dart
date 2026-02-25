import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/enums/button_type.dart';
import '../../../theme/color_palette.dart';
import '../../../theme/typography.dart';
import '../../providers/theme_provider.dart';

/// Tactile neumorphic button with press animation
class NeumorphicButton extends StatefulWidget {
  final Widget? child;
  final String? label;
  final VoidCallback? onPressed;
  final ButtonType buttonType;
  final double borderRadius;
  final EdgeInsets? padding;
  final double? width;
  final double? height;
  final bool enabled;

  const NeumorphicButton({
    super.key,
    this.child,
    this.label,
    this.onPressed,
    this.buttonType = ButtonType.number,
    this.borderRadius = 16.0,
    this.padding,
    this.width,
    this.height,
    this.enabled = true,
  });

  @override
  State<NeumorphicButton> createState() => _NeumorphicButtonState();
}

class _NeumorphicButtonState extends State<NeumorphicButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pressAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _pressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.enabled) return;
    setState(() => _isPressed = true);
    _controller.forward();
    _triggerHaptic();
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.enabled) return;
    setState(() => _isPressed = false);
    _controller.reverse();
    widget.onPressed?.call();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _triggerHaptic() {
    switch (widget.buttonType) {
      case ButtonType.number:
        HapticFeedback.lightImpact();
      case ButtonType.operation:
      case ButtonType.function:
        HapticFeedback.mediumImpact();
      case ButtonType.equals:
        HapticFeedback.heavyImpact();
      case ButtonType.clear:
      case ButtonType.memory:
        HapticFeedback.selectionClick();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().neumorphicTheme;

    return GestureDetector(
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final pressDepth = theme.buttonPressDepth * _pressAnimation.value;

          return Transform.translate(
            offset: Offset(0, pressDepth),
            child: _buildButton(context, theme, pressDepth),
          );
        },
      ),
    );
  }

  Widget _buildButton(BuildContext context, theme, double pressDepth) {
    final buttonColor = _getButtonColor(theme);
    final textColor = _getTextColor(theme);

    return Container(
      width: widget.width,
      height: widget.height,
      padding: widget.padding ?? const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: buttonColor,
        borderRadius: BorderRadius.circular(widget.borderRadius),
        gradient: _buildGradient(buttonColor),
        boxShadow: _buildShadows(theme, pressDepth),
      ),
      child: Center(
        child: widget.child ??
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                widget.label ?? '',
                style: _getTextStyle(textColor),
                textAlign: TextAlign.center,
              ),
            ),
      ),
    );
  }

  Color _getButtonColor(dynamic theme) {
    switch (widget.buttonType) {
      case ButtonType.number:
        return theme.numberButtonColor;
      case ButtonType.operation:
      case ButtonType.equals:
        return theme.operatorButtonColor;
      case ButtonType.function:
      case ButtonType.clear:
      case ButtonType.memory:
        return theme.functionButtonColor;
    }
  }

  Color _getTextColor(dynamic theme) {
    switch (widget.buttonType) {
      case ButtonType.operation:
      case ButtonType.equals:
        return theme.textOnAccent;
      default:
        return theme.textPrimary;
    }
  }

  TextStyle _getTextStyle(Color color) {
    switch (widget.buttonType) {
      case ButtonType.number:
      case ButtonType.equals:
        return AppTypography.buttonLarge(color);
      case ButtonType.operation:
        return AppTypography.buttonLarge(color);
      case ButtonType.function:
      case ButtonType.clear:
      case ButtonType.memory:
        return AppTypography.buttonMedium(color);
    }
  }

  LinearGradient _buildGradient(Color baseColor) {
    if (_isPressed) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [baseColor.darken(5), baseColor.lighten(2)],
      );
    }
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [baseColor.lighten(3), baseColor.darken(3)],
    );
  }

  List<BoxShadow> _buildShadows(dynamic theme, double pressDepth) {
    final intensity = 1 - (pressDepth / theme.buttonPressDepth);

    if (_isPressed) {
      // Concave (pressed) shadows
      return [
        BoxShadow(
          color: theme.shadowDark.withAlpha((128 * intensity).round()),
          offset: Offset(-2 * intensity, -2 * intensity),
          blurRadius: 4,
          spreadRadius: -2,
        ),
        BoxShadow(
          color: theme.shadowLight.withAlpha((128 * intensity).round()),
          offset: Offset(2 * intensity, 2 * intensity),
          blurRadius: 4,
          spreadRadius: -2,
        ),
      ];
    }

    // Convex (unpressed) shadows
    return [
      BoxShadow(
        color: theme.shadowDark.withAlpha((153 * intensity).round()),
        offset: Offset(
          theme.shadowDistance * 0.6 * intensity,
          theme.shadowDistance * 0.6 * intensity,
        ),
        blurRadius: theme.shadowBlur * 0.6 * intensity,
      ),
      BoxShadow(
        color: theme.shadowLight.withAlpha((204 * intensity).round()),
        offset: Offset(
          -theme.shadowDistance * 0.3 * intensity,
          -theme.shadowDistance * 0.3 * intensity,
        ),
        blurRadius: theme.shadowBlur * 0.3 * intensity,
      ),
    ];
  }
}
