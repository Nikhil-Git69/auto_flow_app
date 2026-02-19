import 'dart:developer';
import 'dart:io';
import 'package:auto_flow/constants/app_textstyles.dart';
import 'package:auto_flow/features/detail/screen/detail_screen.dart';
import 'package:auto_flow/features/upload/screen/concept_analysis_screen.dart';
import 'package:auto_flow/features/upload/screen/custom_analysis_screen.dart'; // Will create this next
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
  String _selectedFormatType = 'default'; // default, custom, concept
  File? selectedFile;
  File? templateFile; // For Custom Analysis
  bool isLoading = false;

  // Guidelines for Custom Analysis
  final Map<String, Map<String, String>> _customRequirements = {
    'Margins': {
      'Top': '1 in',
      'Bottom': '1 in',
      'Left': '1 in',
      'Right': '1 in',
    },
    'Typography': {
      'Font Name': 'Times New Roman',
      'Font Size': '12 pt',
      'Line Spacing': '2.0',
    },
    'Paragraph': {'Alignment': 'Left', 'Indentation': '0.5 in'},
    'Page Layout': {'Page Size': 'Letter', 'Orientation': 'Portrait'},
  };

  void _updateRequirement(String category, String key, String value) {
    setState(() {
      _customRequirements[category]?[key] = value;
    });
  }

  Future<void> pickFile({bool isTemplate = false}) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'doc'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        if (isTemplate) {
          templateFile = File(result.files.single.path!);
        } else {
          selectedFile = File(result.files.single.path!);
        }
      });
    }
  }

  String? get selectedFileName {
    if (selectedFile == null) return null;
    return selectedFile!.path.split(Platform.pathSeparator).last;
  }

  String? get templateFileName {
    if (templateFile == null) return null;
    return templateFile!.path.split(Platform.pathSeparator).last;
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
      // Generate requirements string (mock implementation or from guidelines)
      String formatRequirements = "";
      if (_selectedFormatType == 'custom') {
        // Generate formatting requirements string from map
        final buffer = StringBuffer();
        buffer.writeln("### MANDATORY FORMATTING RULES ###");

        _customRequirements.forEach((category, rules) {
          rules.forEach((key, value) {
            if (value.isNotEmpty) {
              buffer.writeln("!!! RULE: $category - $key MUST BE $value !!!");
            }
          });
        });

        formatRequirements = buffer.toString();
      }

      final result = await UploadService.uploadFile(
        file: selectedFile!,
        formatType: _selectedFormatType,
        formatRequirements: formatRequirements,
        // templateFile: templateFile, // Update UploadService to accept templateFile if needed
      );

      if (!mounted) return;
      setState(() {
        isLoading = false;
      });

      if (result['success'] == true && result['data'] != null) {
        final analysis = result['data'] as AnalysisModel;

        // Navigate based on type
        if (_selectedFormatType == 'concept') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ConceptAnalysisScreen(analysis: analysis),
            ),
          );
        } else if (_selectedFormatType == 'custom') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  CustomAnalysisScreen(analysis: analysis), // To be created
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
              // Format Type Tabs
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
                    _buildTab('Default', 'default'),
                    _buildTab('Custom', 'custom'),
                    _buildTab('Concept', 'concept'),
                  ],
                ),
              ),

              GestureDetector(
                onTap: () => pickFile(isTemplate: false),
                child: UploadCard(
                  colorScheme: colorScheme,
                  fileName: selectedFileName,
                ),
              ),

              if (_selectedFormatType == 'custom') ...[
                const SizedBox(height: 24),
                Text(
                  "Optional: Template File",
                  style: AppTextStyles.subMidHeader(context),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => pickFile(isTemplate: true),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.outlineVariant,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.upload_file, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          templateFileName ?? "Select Template (DOCX/PDF)",
                          style: TextStyle(
                            color: templateFileName != null
                                ? colorScheme.onSurface
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  "Formatting Guidelines",
                  style: AppTextStyles.subMidHeader(context),
                ),
                const SizedBox(height: 16),

                _buildGuidelineSection("Margins", [
                  "Top",
                  "Bottom",
                  "Left",
                  "Right",
                ]),
                _buildGuidelineSection("Typography", [
                  "Font Name",
                  "Font Size",
                  "Line Spacing",
                ]),
                _buildGuidelineSection("Paragraph", [
                  "Alignment",
                  "Indentation",
                ]),
                _buildGuidelineSection("Page Layout", [
                  "Page Size",
                  "Orientation",
                ]),

                const SizedBox(height: 24),
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
            textColor: selectedFile != null && !isLoading
                ? Colors.white
                : Colors.grey,
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

  // Predefined options for guidelines
  final Map<String, List<String>> _guidelineOptions = {
    // Margins
    'Top': ['0.5 in', '1 in', '1.5 in', '2 in', 'Custom...'],
    'Bottom': ['0.5 in', '1 in', '1.5 in', '2 in', 'Custom...'],
    'Left': ['0.5 in', '1 in', '1.5 in', '2 in', 'Custom...'],
    'Right': ['0.5 in', '1 in', '1.5 in', '2 in', 'Custom...'],
    // Typography
    'Font Name': [
      'Times New Roman',
      'Arial',
      'Calibri',
      'Verdana',
      'Custom...',
    ],
    'Font Size': ['10 pt', '11 pt', '12 pt', '14 pt', 'Custom...'],
    'Line Spacing': ['1.0', '1.15', '1.5', '2.0', 'Custom...'],
    // Paragraph
    'Alignment': ['Left', 'Center', 'Right', 'Justify', 'Custom...'],
    'Indentation': ['0 in', '0.5 in', '1 in', 'Custom...'],
    // Page Layout
    'Page Size': ['Letter', 'A4', 'Legal', 'Custom...'],
    'Orientation': ['Portrait', 'Landscape', 'Custom...'],
  };

  Widget _buildGuidelineSection(String title, List<String> fields) {
    final colorScheme = Theme.of(context).colorScheme;

    return ExpansionTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      collapsedBackgroundColor: colorScheme.surface,
      backgroundColor: colorScheme.surface,
      textColor: colorScheme.primary,
      iconColor: colorScheme.primary,
      childrenPadding: const EdgeInsets.all(16),
      children: fields.map((field) {
        final currentValue = _customRequirements[title]?[field] ?? '';
        // If current value is not in options, it's custom
        final options = _guidelineOptions[field] ?? [];
        final isCustom =
            !options.contains(currentValue) && currentValue.isNotEmpty;
        final dropdownValue = isCustom
            ? 'Custom...'
            : (options.contains(currentValue) ? currentValue : null);

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      "$field:",
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: SizedBox(
                      height: 40,
                      child: DropdownButtonFormField<String>(
                        value: dropdownValue,
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: colorScheme.surfaceContainerHighest
                              .withOpacity(0.3),
                        ),
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurface,
                        ),
                        items: options.map((opt) {
                          return DropdownMenuItem(value: opt, child: Text(opt));
                        }).toList(),
                        onChanged: (val) {
                          if (val == 'Custom...') {
                            // Clear value to show text field
                            _updateRequirement(title, field, '');
                          } else if (val != null) {
                            _updateRequirement(title, field, val);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              // Show text field if 'Custom...' is selected (or value is effectively custom)
              if (dropdownValue == 'Custom...' ||
                  (currentValue.isEmpty && dropdownValue == null))
                Padding(
                  padding: const EdgeInsets.only(top: 8, left: 0),
                  child: Row(
                    children: [
                      const Spacer(flex: 2),
                      Expanded(
                        flex: 3,
                        child: SizedBox(
                          height: 40,
                          child: TextField(
                            controller:
                                TextEditingController(text: currentValue)
                                  ..selection = TextSelection.fromPosition(
                                    TextPosition(offset: currentValue.length),
                                  ),
                            onChanged: (val) =>
                                _updateRequirement(title, field, val),
                            decoration: InputDecoration(
                              hintText: 'Enter custom value...',
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: colorScheme.surface,
                            ),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
