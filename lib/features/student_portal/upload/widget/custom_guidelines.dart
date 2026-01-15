import 'package:auto_flow/features/student_portal/upload/widget/dropdown_field.dart';
import 'package:flutter/material.dart';

class CustomGuidelines extends StatelessWidget {
  final String margin;
  final String spacing;
  final String fontSize;

  final ValueChanged<String> onMarginChanged;
  final ValueChanged<String> onSpacingChanged;
  final ValueChanged<String> onFontSizeChanged;

  const CustomGuidelines({
    required this.margin,
    required this.spacing,
    required this.fontSize,
    required this.onMarginChanged,
    required this.onSpacingChanged,
    required this.onFontSizeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        DropdownField(
          label: "Margin",
          value: margin,
          items: const ["1 inch", "1.25 inch", "1.5 inch"],
          onChanged: onMarginChanged,
        ),
        DropdownField(
          label: "Line Spacing",
          value: spacing,
          items: const ["1.0", "1.5", "2.0"],
          onChanged: onSpacingChanged,
        ),
        DropdownField(
          label: "Font Size",
          value: fontSize,
          items: const ["10", "11", "12", "14"],
          onChanged: onFontSizeChanged,
        ),
      ],
    );
  }
}
