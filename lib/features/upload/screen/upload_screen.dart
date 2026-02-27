import 'dart:developer';
import 'dart:io';
import 'package:auto_flow/constants/app_textstyles.dart';
import 'package:auto_flow/features/detail/screen/detail_screen.dart';
import 'package:auto_flow/features/detail/screen/report_analysis_screen.dart';
import 'package:auto_flow/features/upload/widget/upload_card.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:auto_flow/core/custom_widgets/custom_button.dart';
import 'package:auto_flow/models/api_models/analysis_model.dart';
import 'package:auto_flow/features/upload/service/upload_service.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  String _selectedFormatType = 'default'; // default | report
  File? selectedFile;
  bool isLoading = false;

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

  String? get selectedFileName {
    if (selectedFile == null) return null;
    return selectedFile!.path.split(Platform.pathSeparator).last;
  }

  Future<void> uploadFile() async {
    if (!mounted) return;

    if (selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a file to analyze")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final result = await UploadService.uploadFile(
        file: selectedFile!,
        formatType: _selectedFormatType,
      );

      if (!mounted) return;
      setState(() {
        isLoading = false;
      });

      if (result['success'] == true && result['data'] != null) {
        final analysis = result['data'] as AnalysisModel;

        if (_selectedFormatType == 'report') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReportAnalysisScreen(analysis: analysis),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailScreen(analysis: analysis),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? "Upload failed")),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      log("Upload Error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("An error occurred: $e")));
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Format Type Tabs: DEFAULT | REPORT
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                padding: const EdgeInsets.all(4),
                margin: const EdgeInsets.only(bottom: 24),
                child: Row(
                  children: [
                    _buildTab('DEFAULT', 'default'),
                    _buildTab('REPORT', 'report'),
                  ],
                ),
              ),

              // File picker
              GestureDetector(
                onTap: pickFile,
                child: UploadCard(
                  colorScheme: colorScheme,
                  fileName: selectedFileName,
                ),
              ),

              // Report hint
              if (_selectedFormatType == 'report') ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.book_outlined,
                        color: Colors.amber.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Report mode generates a detailed analytical summary '
                          'and overview of your document.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.amber.shade900,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: CustomButton(
            text: isLoading ? "ANALYZING..." : "ANALYZE DOCUMENT",
            onPressed: selectedFile != null && !isLoading ? uploadFile : null,
            textColor:
                selectedFile != null && !isLoading ? Colors.white : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildTab(String label, String value) {
    final isSelected = _selectedFormatType == value;
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFormatType = value;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
