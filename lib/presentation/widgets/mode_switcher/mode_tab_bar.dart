import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/enums/calculator_mode.dart';
import '../../../theme/typography.dart';
import '../../providers/theme_provider.dart';

/// Neumorphic tab bar for switching between Calculator, Currency, and Unit modes
class ModeTabBar extends StatelessWidget {
  final CalculatorMode selectedMode;
  final ValueChanged<CalculatorMode> onModeChanged;

  const ModeTabBar({
    super.key,
    required this.selectedMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().neumorphicTheme;

    return Container(
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.shadowDark.withAlpha(100),
            offset: Offset(-theme.innerShadowDistance, -theme.innerShadowDistance),
            blurRadius: theme.innerShadowBlur,
            spreadRadius: -2,
          ),
          BoxShadow(
            color: theme.shadowLight.withAlpha(100),
            offset: Offset(theme.innerShadowDistance, theme.innerShadowDistance),
            blurRadius: theme.innerShadowBlur,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Row(
        children: [
          _ModeTab(
            mode: CalculatorMode.basic,
            label: 'Calc',
            icon: Icons.calculate_outlined,
            isSelected: selectedMode == CalculatorMode.basic ||
                selectedMode == CalculatorMode.scientific,
            onTap: () => onModeChanged(CalculatorMode.basic),
          ),
          _ModeTab(
            mode: CalculatorMode.currency,
            label: 'Currency',
            icon: Icons.currency_exchange,
            isSelected: selectedMode == CalculatorMode.currency,
            onTap: () => onModeChanged(CalculatorMode.currency),
          ),
          _ModeTab(
            mode: CalculatorMode.unitConverter,
            label: 'Units',
            icon: Icons.straighten,
            isSelected: selectedMode == CalculatorMode.unitConverter,
            onTap: () => onModeChanged(CalculatorMode.unitConverter),
          ),
        ],
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  final CalculatorMode mode;
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeTab({
    required this.mode,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().neumorphicTheme;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isSelected ? theme.surfaceColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: theme.shadowDark.withAlpha(120),
                      offset: const Offset(2, 2),
                      blurRadius: 6,
                    ),
                    BoxShadow(
                      color: theme.shadowLight.withAlpha(150),
                      offset: const Offset(-1, -1),
                      blurRadius: 4,
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? theme.accentColor : theme.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTypography.label(
                  isSelected ? theme.accentColor : theme.textSecondary,
                ).copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
