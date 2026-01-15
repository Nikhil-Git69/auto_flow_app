import 'package:auto_flow/features/student_portal/upload/widget/custom_guidelines.dart';
import 'package:auto_flow/features/student_portal/upload/widget/default_guidelines.dart';
import 'package:auto_flow/features/student_portal/upload/widget/tab_button.dart';
import 'package:flutter/material.dart';


class GuidelinesCard extends StatefulWidget {
  const GuidelinesCard({super.key});

  @override
  State<GuidelinesCard> createState() => _GuidelinesCardState();
}

class _GuidelinesCardState extends State<GuidelinesCard> {
  bool isCustom = false;

  String margin = "1 inch";
  String spacing = "1.5";
  String fontSize = "12";

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
   
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Report Format Guidelines",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),

          const SizedBox(height: 12),

          /// Tabs
          Row(
            children: [
              TabButton(
                title: "Default",
                selected: !isCustom,
                onTap: () => setState(() => isCustom = false),
              ),
              const SizedBox(width: 8),
              TabButton(
                title: "Custom",
                selected: isCustom,
                onTap: () => setState(() => isCustom = true),
              ),
            ],
          ),

          const SizedBox(height: 16),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: isCustom
                ? CustomGuidelines(
              margin: margin,
              spacing: spacing,
              fontSize: fontSize,
              onMarginChanged: (v) => setState(() => margin = v),
              onSpacingChanged: (v) => setState(() => spacing = v),
              onFontSizeChanged: (v) => setState(() => fontSize = v),
            )
                : DefaultGuidelines(),
          ),
        ],
      ),
    );
  }
}
