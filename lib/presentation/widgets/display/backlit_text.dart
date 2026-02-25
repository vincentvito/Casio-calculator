import 'package:flutter/material.dart';

/// Text with backlit glow effect for LCD-style display
class BacklitText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color glowColor;
  final double glowIntensity;
  final double glowRadius;
  final TextAlign textAlign;

  const BacklitText({
    super.key,
    required this.text,
    required this.style,
    required this.glowColor,
    this.glowIntensity = 0.5,
    this.glowRadius = 8.0,
    this.textAlign = TextAlign.right,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Glow layer (blurred shadow)
        Text(
          text,
          textAlign: textAlign,
          style: style.copyWith(
            foreground: Paint()
              ..color = glowColor.withAlpha((255 * glowIntensity).round())
              ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowRadius),
          ),
        ),
        // Main text
        Text(
          text,
          textAlign: textAlign,
          style: style,
        ),
      ],
    );
  }
}

/// Animated version with pulsing glow effect
class AnimatedBacklitText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final Color glowColor;
  final bool animate;
  final Duration animationDuration;
  final TextAlign textAlign;

  const AnimatedBacklitText({
    super.key,
    required this.text,
    required this.style,
    required this.glowColor,
    this.animate = false,
    this.animationDuration = const Duration(milliseconds: 2000),
    this.textAlign = TextAlign.right,
  });

  @override
  State<AnimatedBacklitText> createState() => _AnimatedBacklitTextState();
}

class _AnimatedBacklitTextState extends State<AnimatedBacklitText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.4, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.animate) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(AnimatedBacklitText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.animate && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 0.5;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return BacklitText(
          text: widget.text,
          style: widget.style,
          glowColor: widget.glowColor,
          glowIntensity: widget.animate ? _pulseAnimation.value : 0.5,
          textAlign: widget.textAlign,
        );
      },
    );
  }
}
