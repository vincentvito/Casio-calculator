import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../theme/color_palette.dart';
import '../../providers/theme_provider.dart';

/// Physical toggle switch with neumorphic styling
class NeumorphicToggle extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final double width;
  final double height;

  const NeumorphicToggle({
    super.key,
    required this.value,
    this.onChanged,
    this.width = 60,
    this.height = 32,
  });

  @override
  State<NeumorphicToggle> createState() => _NeumorphicToggleState();
}

class _NeumorphicToggleState extends State<NeumorphicToggle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
      value: widget.value ? 1.0 : 0.0,
    );

    _slideAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void didUpdateWidget(NeumorphicToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      if (widget.value) {
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

  void _handleTap() {
    HapticFeedback.mediumImpact();
    widget.onChanged?.call(!widget.value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().neumorphicTheme;
    final thumbSize = widget.height - 8;
    final trackWidth = widget.width - thumbSize - 8;

    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _slideAnimation,
        builder: (context, child) {
          return Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: theme.surfaceVariant,
              borderRadius: BorderRadius.circular(widget.height / 2),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowDark.withAlpha(128),
                  offset: Offset(-theme.innerShadowDistance, -theme.innerShadowDistance),
                  blurRadius: theme.innerShadowBlur,
                  spreadRadius: -2,
                ),
                BoxShadow(
                  color: theme.shadowLight.withAlpha(128),
                  offset: Offset(theme.innerShadowDistance, theme.innerShadowDistance),
                  blurRadius: theme.innerShadowBlur,
                  spreadRadius: -2,
                ),
              ],
            ),
            child: Stack(
              children: [
                // Active track highlight
                Positioned(
                  left: 4,
                  top: 4,
                  child: Container(
                    width: (trackWidth * _slideAnimation.value) + thumbSize,
                    height: thumbSize,
                    decoration: BoxDecoration(
                      color: Color.lerp(
                        theme.surfaceVariant,
                        theme.accentColor.withAlpha(100),
                        _slideAnimation.value,
                      ),
                      borderRadius: BorderRadius.circular(thumbSize / 2),
                    ),
                  ),
                ),
                // Thumb
                Positioned(
                  left: 4 + (trackWidth * _slideAnimation.value),
                  top: 4,
                  child: Container(
                    width: thumbSize,
                    height: thumbSize,
                    decoration: BoxDecoration(
                      color: Color.lerp(
                        theme.surfaceColor,
                        theme.accentColor,
                        _slideAnimation.value,
                      ),
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color.lerp(
                            theme.surfaceColor.lighten(5),
                            theme.accentLight,
                            _slideAnimation.value,
                          )!,
                          Color.lerp(
                            theme.surfaceColor.darken(5),
                            theme.accentDark,
                            _slideAnimation.value,
                          )!,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.shadowDark.withAlpha(153),
                          offset: Offset(
                            theme.shadowDistance * 0.3,
                            theme.shadowDistance * 0.3,
                          ),
                          blurRadius: theme.shadowBlur * 0.3,
                        ),
                        BoxShadow(
                          color: theme.shadowLight.withAlpha(179),
                          offset: Offset(
                            -theme.shadowDistance * 0.15,
                            -theme.shadowDistance * 0.15,
                          ),
                          blurRadius: theme.shadowBlur * 0.15,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
