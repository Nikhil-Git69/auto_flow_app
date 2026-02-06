import 'package:auto_flow/constants/app_textstyles.dart';
import 'package:auto_flow/core/custom_widgets/custom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:auto_flow/features/history/widgets/file_tiles.dart';
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int selectedTab = 0;

  final tabs = ['All', 'PDF', 'Docx'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title:  Text('Evaluation History', style: AppTextStyles.midHeader(context).copyWith(
          color: Theme.of(context).colorScheme.primary,
        )),
          

      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search documents...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: colors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          SizedBox(
            height: 42,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: tabs.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final isSelected = selectedTab == index;

                return GestureDetector(
                  onTap: () => setState(() => selectedTab = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colors.primary
                          : colors.surface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      tabs[index],
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isSelected
                            ? colors.onPrimary
                            : colors.onSurface.withOpacity(0.7),
                        fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 4,
              itemBuilder: (context, index) {
                return ReviewFileTile(
                  fileName: 'AutoFlow Reports.docx',
                  submittedAt: DateTime(2025, 8, 4),
                  score: 82,
                  fileType: FileType.word,
                  status: ReviewStatus.warning,
                  onTap: () {
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
