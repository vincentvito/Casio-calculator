import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/theme_provider.dart';

/// Modal bottom sheet with an HSV color wheel for picking a color.
class ColorPickerSheet extends StatefulWidget {
  final Color initialColor;
  final ValueChanged<Color> onColorChanged;
  final String title;

  const ColorPickerSheet({
    super.key,
    required this.initialColor,
    required this.onColorChanged,
    required this.title,
  });

  /// Show the picker as a modal bottom sheet and return the picked color.
  static Future<void> show({
    required BuildContext context,
    required Color initialColor,
    required ValueChanged<Color> onColorChanged,
    required String title,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ColorPickerSheet(
        initialColor: initialColor,
        onColorChanged: onColorChanged,
        title: title,
      ),
    );
  }

  @override
  State<ColorPickerSheet> createState() => _ColorPickerSheetState();
}

class _ColorPickerSheetState extends State<ColorPickerSheet> {
  late Color _currentColor;

  @override
  void initState() {
    super.initState();
    _currentColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>().neumorphicTheme;

    return Container(
      decoration: BoxDecoration(
        color: theme.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: theme.shadowDark.withAlpha(80),
            offset: const Offset(0, -4),
            blurRadius: 16,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.textSecondary.withAlpha(80),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              // Color wheel picker
              ColorPicker(
                color: _currentColor,
                onColorChanged: (Color color) {
                  setState(() => _currentColor = color);
                  widget.onColorChanged(color);
                },
                pickersEnabled: const <ColorPickerType, bool>{
                  ColorPickerType.wheel: true,
                  ColorPickerType.primary: false,
                  ColorPickerType.accent: false,
                  ColorPickerType.custom: false,
                },
                enableShadesSelection: true,
                wheelDiameter: 220,
                wheelWidth: 20,
                wheelSquarePadding: 10,
                wheelSquareBorderRadius: 6,
                wheelHasBorder: false,
                heading: null,
                subheading: null,
                wheelSubheading: null,
                showColorCode: true,
                colorCodeHasColor: true,
                colorCodeReadOnly: false,
                showColorName: false,
                showRecentColors: false,
                enableOpacity: false,
                copyPasteBehavior: const ColorPickerCopyPasteBehavior(
                  copyFormat: ColorPickerCopyFormat.hexRRGGBB,
                ),
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
