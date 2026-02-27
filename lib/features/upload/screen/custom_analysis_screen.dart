// import 'package:auto_flow/constants/app_paddings.dart';
// import 'package:auto_flow/constants/app_textstyles.dart';
// import 'package:auto_flow/features/upload/widget/issue_card.dart';
// import 'package:auto_flow/models/api_models/analysis_model.dart';
// import 'package:flutter/material.dart';

// class CustomAnalysisScreen extends StatefulWidget {
//   final AnalysisModel analysis;

//   const CustomAnalysisScreen({super.key, required this.analysis});

//   @override
//   State<CustomAnalysisScreen> createState() => _CustomAnalysisScreenState();
// }

// class _CustomAnalysisScreenState extends State<CustomAnalysisScreen> {
//   String _selectedFilter = 'All'; // All, Critical, Major, Minor

//   @override
//   Widget build(BuildContext context) {
//     final colorScheme = Theme.of(context).colorScheme;
//     final analysis = widget.analysis;
//     final issues = _filterIssues(analysis.issues);

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           "Custom Format Audit",
//           style: AppTextStyles.midHeader(
//             context,
//           ).copyWith(color: colorScheme.onPrimary),
//         ),
//         centerTitle: true,
//         backgroundColor: colorScheme.primary,
//         iconTheme: IconThemeData(color: colorScheme.onPrimary),
//       ),
//       body: SingleChildScrollView(
//         padding: AppPaddings.all16,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: _getComplianceColor(
//                   analysis.totalScore,
//                 ).withValues(alpha: 0.1),
//                 borderRadius: BorderRadius.circular(20),
//                 border: Border.all(
//                   color: _getComplianceColor(
//                     analysis.totalScore,
//                   ).withValues(alpha: 0.3),
//                   width: 1.5,
//                 ),
//               ),
//               child: Column(
//                 children: [
//                   Text(
//                     _getComplianceStatus(analysis.totalScore),
//                     style: AppTextStyles.largeHeader(context).copyWith(
//                       color: _getComplianceColor(analysis.totalScore),
//                       fontSize: 24,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     "Compliance Score: ${analysis.totalScore}/100",
//                     style: TextStyle(
//                       color: colorScheme.onSurfaceVariant,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 24),

//             // Requirements List (Mocked or from analysis.formatRequirements)
//             if (analysis.formatRequirements != null &&
//                 analysis.formatRequirements!.isNotEmpty) ...[
//               Text(
//                 "Format Requirements Check",
//                 style: AppTextStyles.midHeader(context),
//               ),
//               const SizedBox(height: 12),
//               Container(
//                 width: double.infinity,
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.purple.withValues(alpha: 0.05),
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(
//                     color: Colors.purple.withValues(alpha: 0.2),
//                   ),
//                 ),
//                 child: Text(
//                   analysis.formatRequirements!,
//                   style: const TextStyle(fontSize: 14, height: 1.5),
//                 ),
//               ),
//               const SizedBox(height: 24),
//             ],

//             // Issues List Header & Filter
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   "Issues Found (${issues.length})",
//                   style: AppTextStyles.midHeader(context),
//                 ),
//                 // Simple Filter Dropdown
//                 DropdownButton<String>(
//                   value: _selectedFilter,
//                   items: ['All', 'Critical', 'Major', 'Minor'].map((
//                     String value,
//                   ) {
//                     return DropdownMenuItem<String>(
//                       value: value,
//                       child: Text(value),
//                     );
//                   }).toList(),
//                   onChanged: (newValue) {
//                     setState(() {
//                       _selectedFilter = newValue!;
//                     });
//                   },
//                   underline: Container(), // Remove underline
//                   style: TextStyle(
//                     color: colorScheme.primary,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   icon: Icon(Icons.filter_list, color: colorScheme.primary),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),

//             if (issues.isEmpty)
//               const Center(
//                 child: Padding(
//                   padding: EdgeInsets.all(32.0),
//                   child: Text("No issues found matching criteria."),
//                 ),
//               )
//             else
//               ListView.builder(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 itemCount: issues.length,
//                 itemBuilder: (context, index) {
//                   return IssueCard(issue: issues[index]);
//                 },
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   List<AnalysisIssue> _filterIssues(List<AnalysisIssue> allIssues) {
//     if (_selectedFilter == 'All') return allIssues;
//     return allIssues
//         .where((issue) => issue.severity == _selectedFilter)
//         .toList();
//   }

//   Color _getComplianceColor(int score) {
//     if (score >= 80) return Colors.green;
//     if (score >= 60) return Colors.orange;
//     return Colors.red;
//   }

//   String _getComplianceStatus(int score) {
//     if (score >= 80) return "COMPLIANT";
//     if (score >= 60) return "PARTIALLY COMPLIANT";
//     return "NON-COMPLIANT";
//   }
// }
