import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/enums/neumorphic_style.dart';
import '../../../theme/color_palette.dart';
import '../../providers/theme_provider.dart';

/// Base neumorphic container with convex/concave shadow effects
class NeumorphicContainer extends StatelessWidget {
  final Widget? child;
  final NeumorphicStyle style;
  final double borderRadius;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? width;
  final double? height;
  final Color? color;
  final BoxConstraints? constraints;

  const NeumorphicContainer({
    super.key,
    this.child,
    this.style = NeumorphicStyle.convex,
    this.borderRadius = 16.0,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.color,
    this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().neumorphicTheme;
    final effectiveColor = color ?? theme.surfaceColor;

    return Container(
      width: width,
      height: height,
      margin: margin,
      constraints: constraints,
      decoration: BoxDecoration(
        color: effectiveColor,
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: _buildGradient(effectiveColor),
        boxShadow: _buildShadows(theme),
      ),
      child: padding != null
          ? Padding(padding: padding!, child: child)
          : child,
    );
  }

  LinearGradient? _buildGradient(Color baseColor) {
    if (style == NeumorphicStyle.flat) return null;

    final isConvex = style == NeumorphicStyle.convex;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isConvex
          ? [baseColor.lighten(3), baseColor.darken(3)]
          : [baseColor.darken(5), baseColor.lighten(2)],
    );
  }

  List<BoxShadow> _buildShadows(dynamic theme) {
    if (style == NeumorphicStyle.flat) return [];

    if (style == NeumorphicStyle.convex) {
      return [
        BoxShadow(
          color: theme.shadowDark.withAlpha(153),
          offset: Offset(theme.shadowDistance, theme.shadowDistance),
          blurRadius: theme.shadowBlur,
          spreadRadius: theme.shadowSpread,
        ),
        BoxShadow(
          color: theme.shadowLight.withAlpha(204),
          offset: Offset(-theme.shadowDistance * 0.5, -theme.shadowDistance * 0.5),
          blurRadius: theme.shadowBlur * 0.5,
          spreadRadius: theme.shadowSpread,
        ),
      ];
    } else {
      // Concave (pressed) - inner shadow effect
      return [
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
      ];
    }
  }
}
