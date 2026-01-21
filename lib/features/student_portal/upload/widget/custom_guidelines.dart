import 'package:auto_flow/features/student_portal/upload/widget/dropdown_field.dart';
import 'package:flutter/material.dart';

class CustomGuidelines extends StatelessWidget {
  final String leftmargin;
  final String rightmargin;
  final String topmargin;
  final String bottommargin;
  final String spacing;
  final String fontSize;

  final ValueChanged<String> onLeftMarginChanged;
  final ValueChanged<String> onRightMarginChanged;
  final ValueChanged<String> onTopMarginChanged;
  final ValueChanged<String> onBottomMarginChanged;
  final ValueChanged<String> onSpacingChanged;
  final ValueChanged<String> onFontSizeChanged;

  const CustomGuidelines({
    required this.leftmargin,
    required this.rightmargin,
    required this.topmargin,
    required this.bottommargin,
    required this.spacing,
    required this.fontSize,
    required this.onLeftMarginChanged,
    required this.onRightMarginChanged,
    required this.onTopMarginChanged,
    required this.onBottomMarginChanged,
    required this.onSpacingChanged,
    required this.onFontSizeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        DropdownField(
          label: "Left Margin",
          value: leftmargin,
          items: const ["1 inch", "1.25 inch", "1.5 inch"],
          onChanged: onLeftMarginChanged,
        ),
        DropdownField(
          label: "Right Margin",
          value: rightmargin,
          items: const ["1 inch", "1.25 inch", "1.5 inch"],
          onChanged: onRightMarginChanged,
        ),
        DropdownField(
          label: "Top Margin",
          value: topmargin,
          items: const ["1 inch", "1.25 inch", "1.5 inch"],
          onChanged: onTopMarginChanged,
        ),
        DropdownField(
          label: "Bottom Margin",
          value: bottommargin,
          items: const ["1 inch", "1.25 inch", "1.5 inch"],
          onChanged: onBottomMarginChanged,
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
