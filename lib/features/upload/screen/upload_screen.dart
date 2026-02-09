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
  AnalysisModel? uploadResult;

  final api = AnalysisApiService(apiKey: 'Bearer NikhilDai123');

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
    if(!mounted) return;

    if (selectedFile == null) {
      showDialog(context: context, builder: (_) => AlertDialog(
        title: Text("Error"),
        content: Text("Please select a file first"),
        actions: [
          CustomButton(text: "Okay", onPressed: ()
          {
            Navigator.pop(context);
          },)
        ],
      ));
      return;
    }

    if (selectedGuidelines == null) {
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text("Error"),
          content: Text("Please set report guidelines first."),
        ),
      );
      setState(() => isLoading = false);
      return;
    }


    setState(() {
      isLoading = true;
    });

    final result = await api.uploadReport(
      file: selectedFile!,
      aiFeedback: aiFeedback,
      guidelines: selectedGuidelines,
    );

    if (result == null) {
      setState(() {
        isLoading = false;
      });

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Error"),
          content: const Text("Network error. Please try again."),
          actions: [
            CustomButton(
              text: "Okay",
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );

      return;
    }

    setState(() {
      isLoading = false;
      uploadResult = result;
    });



    final success = result.code == 200;

      if (success) {
        if (!mounted) return;

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(
              file: result.data!.file,
              formatFeedback: result.data!.formatFeedback,
              contentFeedback: result.data!.contentFeedback ?? [],
            ),
          ),
        );
      } else {
        if (!mounted) return;


      showDialog(context: context, builder: (_) =>AlertDialog(
       title: Center(child: Text("Error")),
        content: SizedBox(
          height: 50,
        child: Text(result.message.isNotEmpty
            ? result.message
            : "Error Uploading the File. Please try again later."),
        ),
        actions: [
          CustomButton(text: "Okay", onPressed: () {
            Navigator.pop(context);
          },)
        ],
      )
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
              GuidelinesCard(
                onChanged: (guidelines) {
                  setState(() {
                    selectedGuidelines = guidelines;
                  });

                  debugPrint(
                    "GUIDELINES RECEIVED IN UPLOAD: ${guidelines.toJson()}",
                  );
                },
              ),
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
