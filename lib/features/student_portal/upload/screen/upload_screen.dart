import 'dart:io';
import 'package:auto_flow/constants/app_textstyles.dart';
import 'package:auto_flow/features/student_portal/upload/widget/guidelines_card.dart';
import 'package:auto_flow/features/student_portal/upload/widget/upload_card.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:auto_flow/core/custom_widgets/custom_button.dart';
import 'package:auto_flow/models/api_models/upload_model.dart';
import 'package:auto_flow/features/student_portal/upload/service/upload_service.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? selectedFile;  
  bool aiFeedback = false; 
  bool isLoading = false; 
  UploadModel? uploadResult;

  final api = ApiService(apiKey: 'Bearer super-secret-key');

  //file pickers func
  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
      });
    }
  }

  //extract file name from selected file
  String? get selectedFileName {
    if (selectedFile == null) return null;
    return selectedFile!.path.split(Platform.pathSeparator).last;
  }

  //uplaod file api func
  Future<void> uploadFile() async {
    if (selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a file first")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final result = await api.uploadReport(
      file: selectedFile!,
      aiFeedback: aiFeedback,
    );

    setState(() {
      isLoading = false;
      uploadResult = result;
    });

    if (result != null) {
      // Show feedback in a dialog
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          final theme = Theme.of(context);
          final colorScheme = theme.colorScheme;
          final textTheme = theme.textTheme;

          return AlertDialog(
            backgroundColor: colorScheme.surface,
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),

            title: Center(
              child: Text(
                "Upload Result",
                style: AppTextStyles.midHeader(
                  context,
                ).copyWith(color: colorScheme.primary),
              ),
            ),

            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Format Feedback",
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  result.data?.formatFeedback?.join(", ") ?? "N/A",
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),

                const SizedBox(height: 16),

                if ((result.data?.contentFeedback ?? []).isNotEmpty) ...[
                  Text(
                    "Content Feedback",
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    (result.data?.contentFeedback ?? []).join(", "),
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ],
            ),

            actionsAlignment: MainAxisAlignment.center,
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: colorScheme.primary,
                ),
                onPressed: () => Navigator.pop(context),
                child: Text(
                  "OK",
                  style: AppTextStyles.subMidHeader(context).copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight
                        .w600, // optional, override subMidHeader if you want bolder
                  ),
                ),
              ),
            ],
          );
        },
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Upload failed")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Upload',
          style: AppTextStyles.midHeader(
            context,
          ).copyWith(color: Theme.of(context).colorScheme.primary),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  pickFile();
                },
                child: UploadCard(
                  colorScheme: colorScheme,
                  fileName: selectedFileName,
                ),
              ),
              GuidelinesCard(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: CustomButton(
            text: isLoading ? "UPLOADING..." : "UPLOAD",
            onPressed: selectedFile != null && !isLoading ? uploadFile : null,
          ),
        ),
      ),
    );
  }
}
