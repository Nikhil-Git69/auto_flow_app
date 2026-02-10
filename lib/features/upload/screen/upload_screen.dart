import 'dart:developer';
import 'dart:io';
import 'package:auto_flow/constants/app_textstyles.dart';
import 'package:auto_flow/features/detail/screen/detail_screen.dart';
import 'package:auto_flow/features/upload/widget/guidelines_card.dart';
import 'package:auto_flow/features/upload/widget/upload_card.dart';
import 'package:auto_flow/models/request_models/guideline_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:auto_flow/core/custom_widgets/custom_button.dart';
import 'package:auto_flow/models/api_models/upload_model.dart';
import 'package:auto_flow/features/upload/service/upload_service.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  GuidelinesModel selectedGuidelines = GuidelinesModel.defaults();

  File? selectedFile;
  bool aiFeedback = true;
  bool isLoading = false;

  //file pickers func
  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'doc'],
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
    if (!mounted) return;

    if (selectedFile == null) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Error"),
          content: const Text("Please select a file first"),
          actions: [
            CustomButton(text: "Okay", onPressed: () => Navigator.pop(context)),
          ],
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    log("UploadScreen: Preparing to upload file: ${selectedFile!.path}");

    final formatRequirements = UploadService.generateRequirementsString(
      selectedGuidelines.toJson(),
    );

    final isCustom =
        selectedGuidelines.fontSize != 12 || selectedGuidelines.spacing != 1.5;
    final formatType = isCustom ? 'custom' : 'default';

    log("UploadScreen: Calling UploadService with formatType: $formatType");

    final result = await UploadService.uploadFile(
      file: selectedFile!,
      formatType: formatType,
      formatRequirements: formatRequirements,
    );

    log("UploadScreen: Service returned result: $result");

    if (!mounted) return;
    setState(() {
      isLoading = false;
    });

    if (result['success'] == true && result['data'] != null) {
      log("UploadScreen: Upload successful, navigating to details");
      final analysis = result['data'] as AnalysisModel;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DetailScreen(analysis: analysis),
        ),
      );
    } else {
      log("UploadScreen: Upload failed - ${result['message']}");
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Center(child: Text("Error")),
          content: Text(result['message'] ?? "Error Uploading the File."),
          actions: [
            CustomButton(text: "Okay", onPressed: () => Navigator.pop(context)),
          ],
        ),
      );
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

              // GuidelinesCard(
              //   onChanged: (guidelines) {
              //     setState(() {
              //       selectedGuidelines = guidelines;
              //     });

              //     debugPrint(
              //       "GUIDELINES RECEIVED IN UPLOAD: ${guidelines.toJson()}",
              //     );
              //   },
              // ),
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
            textColor: selectedFile != null && !isLoading
                ? Colors.white
                : Colors.grey,
          ),
        ),
      ),
    );
  }
}
