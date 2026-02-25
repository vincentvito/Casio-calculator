import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/enums/neumorphic_style.dart';
import '../../../theme/typography.dart';
import '../../providers/theme_provider.dart';
import '../../providers/calculator_provider.dart';
import '../common/neumorphic_container.dart';
import 'backlit_text.dart';

/// Main calculator display with LCD-style appearance
class CalculatorDisplay extends StatelessWidget {
  const CalculatorDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().neumorphicTheme;
    final calculator = context.watch<CalculatorProvider>();

    // Build the main display text: show expression being built or current value
    final mainDisplayText = _buildMainDisplay(calculator);
    // Show completed expression only after result (when it ends with "=")
    final topExpression = calculator.expressionDisplay.endsWith('=')
        ? calculator.expressionDisplay
        : '';

    return NeumorphicContainer(
      style: NeumorphicStyle.concave,
      borderRadius: theme.displayBorderRadius,
      color: theme.displayBackground,
      padding: EdgeInsets.all(theme.displayPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top row: Memory indicator and completed expression (small, dimmed)
          SizedBox(
            height: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Memory indicator
                if (calculator.hasMemory)
                  Text(
                    'M',
                    style: AppTypography.labelSmall(theme.memoryIndicator),
                  )
                else
                  const SizedBox.shrink(),
                // Completed expression (shown small on top after result)
                Expanded(
                  child: Text(
                    topExpression,
                    style: AppTypography.expression(theme.displayTextDim),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Main display - shows current expression being built
          Expanded(
            child: Align(
              alignment: Alignment.bottomRight,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                child: BacklitText(
                  text: mainDisplayText,
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 36,
                    fontWeight: FontWeight.w500,
                    color: theme.displayText,
                    letterSpacing: 2,
                  ),
                  glowColor: theme.displayGlow,
                  glowIntensity: calculator.isError ? 0.8 : 0.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build the main display text showing the current expression being built
  String _buildMainDisplay(CalculatorProvider calculator) {
    final expression = calculator.expressionDisplay;
    final displayValue = calculator.displayValue;

    // If there's an active expression (like "5 +"), show it
    if (expression.isNotEmpty && !expression.endsWith('=')) {
      // If waiting for second operand (just pressed operator), only show expression
      if (calculator.isWaitingForOperand2) {
        return expression;
      }
      // User is entering second operand, show full expression with current input
      return '$expression $displayValue';
    }

    // Otherwise just show the current value
    return displayValue;
  }
}
