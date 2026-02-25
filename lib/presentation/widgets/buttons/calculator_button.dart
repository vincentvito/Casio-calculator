import 'package:flutter/material.dart';
import '../../../core/enums/button_type.dart';
import '../common/neumorphic_button.dart';

/// Calculator button wrapper for standardized sizing
class CalculatorButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ButtonType buttonType;
  final int flex;

  const CalculatorButton({
    super.key,
    required this.label,
    this.onPressed,
    this.buttonType = ButtonType.number,
    this.flex = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: AspectRatio(
          aspectRatio: flex > 1 ? 2.2 : 1.0,
          child: NeumorphicButton(
            label: label,
            onPressed: onPressed,
            buttonType: buttonType,
            borderRadius: 16,
          ),
        ),
      ),
    );
  }
}
