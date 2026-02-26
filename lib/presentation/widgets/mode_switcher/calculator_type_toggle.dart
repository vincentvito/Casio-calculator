import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../theme/typography.dart';
import '../../../theme/color_palette.dart';
import '../../providers/feedback_provider.dart';
import '../../providers/theme_provider.dart';

/// Toggle switch for Basic/Scientific calculator modes
class CalculatorTypeToggle extends StatefulWidget {
  final bool isScientific;
  final ValueChanged<bool> onChanged;

  const CalculatorTypeToggle({
    super.key,
    required this.isScientific,
    required this.onChanged,
  });

  @override
  State<CalculatorTypeToggle> createState() => _CalculatorTypeToggleState();
}

class _CalculatorTypeToggleState extends State<CalculatorTypeToggle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
      value: widget.isScientific ? 1.0 : 0.0,
    );

    _slideAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void didUpdateWidget(CalculatorTypeToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isScientific != widget.isScientific) {
      if (widget.isScientific) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().neumorphicTheme;

    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: theme.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: theme.shadowDark.withAlpha(80),
            offset: Offset(-theme.innerShadowDistance * 0.5, -theme.innerShadowDistance * 0.5),
            blurRadius: theme.innerShadowBlur * 0.5,
            spreadRadius: -1,
          ),
          BoxShadow(
            color: theme.shadowLight.withAlpha(80),
            offset: Offset(theme.innerShadowDistance * 0.5, theme.innerShadowDistance * 0.5),
            blurRadius: theme.innerShadowBlur * 0.5,
            spreadRadius: -1,
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final halfWidth = constraints.maxWidth / 2;

          return Stack(
            children: [
              // Sliding indicator
              AnimatedBuilder(
                animation: _slideAnimation,
                builder: (context, child) {
                  return Positioned(
                    left: 3 + (_slideAnimation.value * (halfWidth - 3)),
                    top: 3,
                    bottom: 3,
                    width: halfWidth - 3,
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.surfaceColor,
                        borderRadius: BorderRadius.circular(8),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.surfaceColor.lighten(3),
                            theme.surfaceColor.darken(2),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.shadowDark.withAlpha(100),
                            offset: const Offset(2, 2),
                            blurRadius: 4,
                          ),
                          BoxShadow(
                            color: theme.shadowLight.withAlpha(120),
                            offset: const Offset(-1, -1),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // Labels
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        context.read<FeedbackProvider>().selectionClick();
                        widget.onChanged(false);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Center(
                        child: AnimatedBuilder(
                          animation: _slideAnimation,
                          builder: (context, child) {
                            return Text(
                              'Basic',
                              style: AppTypography.label(
                                Color.lerp(
                                  theme.textPrimary,
                                  theme.textSecondary,
                                  _slideAnimation.value,
                                )!,
                              ).copyWith(
                                fontWeight: widget.isScientific
                                    ? FontWeight.w500
                                    : FontWeight.w600,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        context.read<FeedbackProvider>().selectionClick();
                        widget.onChanged(true);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Center(
                        child: AnimatedBuilder(
                          animation: _slideAnimation,
                          builder: (context, child) {
                            return Text(
                              'Scientific',
                              style: AppTypography.label(
                                Color.lerp(
                                  theme.textSecondary,
                                  theme.textPrimary,
                                  _slideAnimation.value,
                                )!,
                              ).copyWith(
                                fontWeight: widget.isScientific
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
