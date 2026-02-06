import 'package:auto_flow/features/upload/widget/custom_guidelines.dart';
import 'package:auto_flow/models/request_models/guideline_model.dart';
import 'package:flutter/material.dart';


class GuidelinesCard extends StatefulWidget {
  final ValueChanged<GuidelinesModel> onChanged;

  const GuidelinesCard({super.key,
    required this.onChanged,

  });

  @override
  State<GuidelinesCard> createState() => _GuidelinesCardState();
}

class _GuidelinesCardState extends State<GuidelinesCard> {
  bool isCustom = false;

  String leftmargin = "1 inch";
  String rightmargin = "1 inch";
  String topmargin = "1 inch";
  String bottommargin = "1 inch";
  String spacing = "1.5";
  String fontSize = "12";



  void _emitGuidelines() {
    final guidelines = GuidelinesModel(
      leftMargin: double.tryParse(leftmargin.replaceAll(" inch", "")) ?? 1.0,
      rightMargin: double.tryParse(rightmargin.replaceAll(" inch", "")) ?? 1.0,
      topMargin: double.tryParse(topmargin.replaceAll(" inch", "")) ?? 1.0,
      bottomMargin: double.tryParse(bottommargin.replaceAll(" inch", "")) ?? 1.0,
      spacing: double.tryParse(spacing) ?? 1.5,
      fontSize: int.tryParse(fontSize) ?? 12,
    );

    debugPrint("GUIDELINES EMITTED: ${guidelines.toJson()}");

    widget.onChanged(guidelines);
  }


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

          // Row(
          //   children: [
          //     TabButton(
          //       title: "Default",
          //       selected: !isCustom,
          //       onTap: () => setState(() => isCustom = false),
          //     ),
          //     const SizedBox(width: 8),
          //     TabButton(
          //       title: "Custom",
          //       selected: isCustom,
          //       onTap: () => setState(() => isCustom = true),
          //     ),
          //   ],
          // ),

          const SizedBox(height: 16),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child:  CustomGuidelines(
              leftmargin: leftmargin,
              rightmargin: rightmargin,
              topmargin: topmargin,
              bottommargin: bottommargin,
              spacing: spacing,
              fontSize: fontSize,
              onLeftMarginChanged: (v)
              {
                setState(() => leftmargin = v);
                _emitGuidelines();
              },
              onRightMarginChanged: (v)
              {
                setState(() => rightmargin = v);
                _emitGuidelines();
              },

              onTopMarginChanged: (v)
              {
                setState(() => topmargin = v);
                _emitGuidelines();
              },
              onBottomMarginChanged: (v)
              {
                setState(() => bottommargin = v);
                _emitGuidelines();
              },
              onSpacingChanged: (v)
              {
                setState(() => spacing = v);
                _emitGuidelines();
              },
              onFontSizeChanged: (v)
              {
                setState(() => fontSize = v);
                _emitGuidelines();
              },
            )
                // : DefaultGuidelines(),
          ),
        ],
      ),
    );
  }
}
