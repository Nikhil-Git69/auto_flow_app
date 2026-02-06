import 'package:auto_flow/constants/app_paddings.dart';
import 'package:auto_flow/constants/app_textstyles.dart';
import 'package:auto_flow/models/api_models/upload_model.dart';
import 'package:flutter/material.dart';

class DetailScreen extends StatefulWidget {
  final FileInfo file;
  final FormatFeedback formatFeedback;
  final List<String> contentFeedback;

  const DetailScreen({Key? key,required this.contentFeedback,required this.formatFeedback, required this.file})
    : super(key: key);

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
           widget.file.name,
          style: AppTextStyles.midHeader(context).copyWith(color:colorScheme.onPrimary),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        surfaceTintColor: Colors.transparent,
        iconTheme: IconThemeData(color: colorScheme.onPrimary),

      ),
      body: Padding(
        padding: AppPaddings.all16,
        child: SingleChildScrollView(
          child: Column(
            children: [

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Format Feedback",
                      style: AppTextStyles.midHeader(context),
                    ),
                    const SizedBox(height: 10),

                     ...[
                      Text(
                        widget.formatFeedback.analysisMessage,
                        style: AppTextStyles.subMidHeader(context),
                      ),
                      const SizedBox(height: 10),

                      if (widget.formatFeedback.issues.isEmpty)
                        const Text("No formatting issues found")
                      else
                        ...widget.formatFeedback.issues.map(
                              (issue) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text("• $issue"),
                          ),
                        ),
                    ],
                  ],
                ),
              ),

              if (widget.contentFeedback.isNotEmpty)
                Padding(
                  padding: AppPaddings.top10,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Content Feedback",
                          style: AppTextStyles.subMidHeader(context),
                        ),
                        const SizedBox(height: 10),

                        ...widget.contentFeedback.map(
                              (feedback) => Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text("• $feedback"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),

    );
  }
}   
