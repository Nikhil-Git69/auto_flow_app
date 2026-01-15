import 'package:auto_flow/features/student_portal/upload/widget/guidelines_row.dart';
import 'package:flutter/material.dart';

class DefaultGuidelines extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        GuidelineRow(label: "Margin", value: "1 inch"),
        GuidelineRow(label: "Line Spacing", value: "1.5"),
        GuidelineRow(label: "Font", value: "Times New Roman"),
        GuidelineRow(label: "Font Size", value: "12"),
      ],
    );
  }
}

