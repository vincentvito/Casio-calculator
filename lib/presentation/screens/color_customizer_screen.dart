import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme/color_derivation.dart';
import '../../theme/theme_definitions.dart';
import '../../theme/theme_palette.dart';
import '../../theme/typography.dart';
import '../providers/feedback_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/common/color_picker_sheet.dart';

/// Defines a customizable color slot.
class _ColorSlot {
  final String key;
  final String label;
  final IconData icon;

  const _ColorSlot(this.key, this.label, this.icon);
}

const _slots = [
  _ColorSlot('numberButton', 'Number Keys', Icons.dialpad),
  _ColorSlot('operatorButton', 'Operator Keys', Icons.calculate),
  _ColorSlot('functionButton', 'Function Keys', Icons.functions),
  _ColorSlot('displayBackground', 'Display Background', Icons.desktop_windows),
  _ColorSlot('displayText', 'Display Text', Icons.text_fields),
];

/// Screen for customizing individual theme colors via a color wheel.
class ColorCustomizerScreen extends StatelessWidget {
  const ColorCustomizerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final theme = themeProvider.neumorphicTheme;
    final settings = context.watch<SettingsProvider>();
    final overrides = settings.colorOverrides;

    // Build the effective palette for the preview
    final definition = ThemeRegistry.getById(settings.themeId);
    final basePalette = settings.isDarkMode
        ? definition.darkPalette
        : definition.lightPalette;
    final effectivePalette = overrides.isNotEmpty
        ? ColorDerivation.applyAll(basePalette, overrides)
        : basePalette;

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      context.read<FeedbackProvider>().lightTap();
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: theme.textSecondary,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Customize Colors',
                    style: AppTypography.settingsTitle(theme.textPrimary),
                  ),
                  const Spacer(),
                  if (overrides.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        context.read<FeedbackProvider>().mediumTap();
                        settings.resetColorOverrides();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: theme.surfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Reset All',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: theme.errorColor,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Live preview
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Container(
                height: 160,
                decoration: BoxDecoration(
                  color: effectivePalette.background,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowDark.withAlpha(80),
                      offset: const Offset(3, 3),
                      blurRadius: 10,
                    ),
                    BoxShadow(
                      color: theme.shadowLight.withAlpha(80),
                      offset: const Offset(-2, -2),
                      blurRadius: 6,
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: _MiniCalculatorPreview(palette: effectivePalette),
              ),
            ),

            // Color slot list
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _slots.length,
                separatorBuilder: (_, _) => const SizedBox(height: 2),
                itemBuilder: (context, index) {
                  final slot = _slots[index];
                  final currentColor =
                      _getColorForSlot(effectivePalette, slot.key);
                  final hasOverride = overrides.hasOverride(slot.key);

                  return _ColorSlotRow(
                    slot: slot,
                    currentColor: currentColor,
                    hasOverride: hasOverride,
                    onTap: () => _openPicker(
                        context, settings, slot, currentColor),
                    onReset: hasOverride
                        ? () {
                            context.read<FeedbackProvider>().lightTap();
                            settings.updateColorOverride(slot.key, null);
                          }
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForSlot(ThemePalette palette, String key) {
    switch (key) {
      case 'numberButton':
        return palette.numberButton;
      case 'functionButton':
        return palette.functionButton;
      case 'operatorButton':
        return palette.operatorButton;
      case 'displayBackground':
        return palette.displayBackground;
      case 'displayText':
        return palette.displayText;
      default:
        return Colors.grey;
    }
  }

  void _openPicker(
    BuildContext context,
    SettingsProvider settings,
    _ColorSlot slot,
    Color currentColor,
  ) {
    context.read<FeedbackProvider>().mediumTap();
    ColorPickerSheet.show(
      context: context,
      initialColor: currentColor,
      title: slot.label,
      onColorChanged: (color) {
        settings.updateColorOverride(slot.key, color);
      },
    );
  }
}

class _ColorSlotRow extends StatelessWidget {
  final _ColorSlot slot;
  final Color currentColor;
  final bool hasOverride;
  final VoidCallback onTap;
  final VoidCallback? onReset;

  const _ColorSlotRow({
    required this.slot,
    required this.currentColor,
    required this.hasOverride,
    required this.onTap,
    this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().neumorphicTheme;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: theme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: theme.shadowDark.withAlpha(40),
              offset: const Offset(2, 2),
              blurRadius: 6,
            ),
            BoxShadow(
              color: theme.shadowLight.withAlpha(50),
              offset: const Offset(-1, -1),
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(slot.icon, color: theme.textSecondary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    slot.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: theme.textPrimary,
                    ),
                  ),
                  if (hasOverride)
                    Text(
                      'Custom',
                      style: TextStyle(
                        fontSize: 11,
                        color: theme.accentColor,
                      ),
                    ),
                ],
              ),
            ),
            // Color swatch
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: currentColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.textSecondary.withAlpha(60),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: currentColor.withAlpha(60),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            if (hasOverride) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onReset,
                child: Icon(
                  Icons.refresh,
                  color: theme.textSecondary,
                  size: 18,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Mini calculator preview showing the effective palette colors.
class _MiniCalculatorPreview extends StatelessWidget {
  final ThemePalette palette;

  const _MiniCalculatorPreview({required this.palette});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Mini display
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: palette.displayBackground,
              borderRadius: BorderRadius.circular(6),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '42.0',
              style: TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 18,
                color: palette.displayText,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Button rows
          Expanded(
            child: Row(
              children: [
                _miniButton(palette.numberButton, palette.textPrimary, '7'),
                _miniButton(palette.numberButton, palette.textPrimary, '8'),
                _miniButton(palette.numberButton, palette.textPrimary, '9'),
                _miniButton(
                    palette.operatorButton, palette.textOnAccent, '+'),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Row(
              children: [
                _miniButton(
                    palette.functionButton, palette.textOnFunction, 'C'),
                _miniButton(palette.numberButton, palette.textPrimary, '0'),
                _miniButton(palette.numberButton, palette.textPrimary, '.'),
                _miniButton(
                    palette.operatorButton, palette.textOnAccent, '='),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniButton(Color bg, Color fg, String label) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: fg,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
