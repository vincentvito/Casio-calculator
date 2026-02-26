import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../theme/theme_definitions.dart';
import '../../theme/theme_palette.dart';
import '../../theme/typography.dart';
import '../providers/theme_provider.dart';
import '../providers/settings_provider.dart';

/// Full-screen theme picker with large preview cards.
class ThemePickerScreen extends StatelessWidget {
  const ThemePickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final theme = themeProvider.neumorphicTheme;
    final settings = context.read<SettingsProvider>();
    final activeId = themeProvider.activeThemeId;

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
                      HapticFeedback.lightImpact();
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
                    'Themes',
                    style: AppTypography.settingsTitle(theme.textPrimary),
                  ),
                ],
              ),
            ),

            // Theme cards
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: ThemeRegistry.all.length,
                itemBuilder: (context, index) {
                  final def = ThemeRegistry.all[index];
                  final isActive = def.id == activeId;
                  return _ThemePreviewCard(
                    definition: def,
                    isActive: isActive,
                    isDarkMode: themeProvider.isDarkMode,
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      settings.updateThemeId(def.id);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThemePreviewCard extends StatelessWidget {
  final ThemeDefinition definition;
  final bool isActive;
  final bool isDarkMode;
  final VoidCallback onTap;

  const _ThemePreviewCard({
    required this.definition,
    required this.isActive,
    required this.isDarkMode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().neumorphicTheme;
    final previewPalette =
        isDarkMode ? definition.darkPalette : definition.lightPalette;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Container(
          decoration: BoxDecoration(
            color: theme.surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: isActive
                ? Border.all(color: theme.accentColor, width: 2)
                : null,
            boxShadow: [
              BoxShadow(
                color: theme.shadowDark.withAlpha(100),
                offset: const Offset(4, 4),
                blurRadius: 12,
              ),
              BoxShadow(
                color: theme.shadowLight.withAlpha(120),
                offset: const Offset(-2, -2),
                blurRadius: 8,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mini calculator preview
                Container(
                  height: 160,
                  decoration: BoxDecoration(
                    color: previewPalette.background,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: _MiniCalculatorPreview(palette: previewPalette),
                ),

                const SizedBox(height: 12),

                // Theme name + active indicator
                Row(
                  children: [
                    Icon(definition.icon, color: theme.textPrimary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      definition.displayName,
                      style: AppTypography.settingsTitle(theme.textPrimary),
                    ),
                    const Spacer(),
                    if (isActive)
                      Icon(Icons.check_circle,
                          color: theme.accentColor, size: 22),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  definition.description,
                  style: AppTypography.settingsSubtitle(theme.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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
