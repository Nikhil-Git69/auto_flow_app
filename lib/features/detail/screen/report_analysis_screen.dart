import 'package:auto_flow/constants/app_paddings.dart';
import 'package:auto_flow/constants/app_textstyles.dart';
import 'package:auto_flow/models/api_models/analysis_model.dart';
import 'package:auto_flow/services/analysis_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:open_filex/open_filex.dart';

class ReportAnalysisScreen extends StatefulWidget {
  final AnalysisModel analysis;

  const ReportAnalysisScreen({super.key, required this.analysis});

  @override
  State<ReportAnalysisScreen> createState() => _ReportAnalysisScreenState();
}

class _ReportAnalysisScreenState extends State<ReportAnalysisScreen> {
  bool _isDownloading = false;

  Future<void> _handleDownload({bool preview = false}) async {
    final id = widget.analysis.analysisId;
    final name = widget.analysis.fileName;
    if (id == null || name == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot download: Missing file details'),
          ),
        );
      }
      return;
    }

    setState(() => _isDownloading = true);

    try {
      final path = await AnalysisService.downloadDocument(
        id,
        name,
        isPreview: preview,
      );
      if (path != null) {
        if (preview) {
          final result = await OpenFilex.open(path);
          if (result.type != ResultType.done && mounted) {
            final msg =
                result.message.contains('No app found') ||
                    name.toLowerCase().endsWith('.docx')
                ? 'Could not preview file. You may need a Word viewer installed, or try downloading it instead.'
                : 'Could not open preview: ${result.message}';
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(msg)));
          }
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Saved successfully to Downloads folder!'),
              backgroundColor: Colors.teal.shade600,
            ),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to download document.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Report Detail',
            style: AppTextStyles.midHeader(
              context,
            ).copyWith(color: colorScheme.onPrimary),
          ),
          centerTitle: true,
          backgroundColor: colorScheme.primary,
          surfaceTintColor: Colors.transparent,
          iconTheme: IconThemeData(color: colorScheme.onPrimary),
          actions: [
            if (_isDownloading)
              const Padding(
                padding: EdgeInsets.only(right: 16),
                child: Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            else
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  if (value == 'download') _handleDownload();
                  if (value == 'preview') _handleDownload(preview: true);
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'preview',
                    child: Row(
                      children: [
                        Icon(Icons.visibility_outlined),
                        SizedBox(width: 8),
                        Text('Preview'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'download',
                    child: Row(
                      children: [
                        Icon(Icons.download_outlined),
                        SizedBox(width: 8),
                        Text('Download'),
                      ],
                    ),
                  ),
                ],
              ),
          ],
          bottom: TabBar(
            labelColor: colorScheme.onPrimary,
            unselectedLabelColor: colorScheme.onPrimary.withValues(alpha: 0.7),
            indicatorColor: colorScheme.onPrimary,
            indicatorWeight: 3,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Detailed Summary'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOverviewTab(colorScheme),
            _buildDetailedSummaryTab(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: AppPaddings.all16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.35),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.book_outlined,
                      color: colorScheme.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Project Overview',
                        style: AppTextStyles.subMidHeader(
                          context,
                        ).copyWith(color: colorScheme.primary),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: Text(
                        'REPORT',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (widget.analysis.summary.isNotEmpty)
                  Text(
                    widget.analysis.summary,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  )
                else
                  Text(
                    'No overview available.',
                    style: TextStyle(color: colorScheme.outline),
                  ),
                const SizedBox(height: 20),
                Divider(color: colorScheme.outlineVariant),
                const SizedBox(height: 12),
                Text(
                  'ANALYSIS STATS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.outline,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 12),
                _buildStatRow(
                  context,
                  icon: Icons.description_outlined,
                  label: 'Document Type',
                  value: 'Project Report',
                  colorScheme: colorScheme,
                ),
                const SizedBox(height: 8),
                _buildStatRow(
                  context,
                  icon: Icons.check_circle_outline,
                  label: 'Status',
                  value: 'Complete',
                  valueColor: Colors.teal,
                  colorScheme: colorScheme,
                ),
                const SizedBox(height: 8),
                _buildStatRow(
                  context,
                  icon: Icons.tag,
                  label: 'ID Reference',
                  value:
                      '#${(widget.analysis.analysisId ?? 'N/A').length > 6 ? (widget.analysis.analysisId!).substring((widget.analysis.analysisId!).length - 6) : (widget.analysis.analysisId ?? 'N/A')}',
                  valueColor: colorScheme.outline,
                  colorScheme: colorScheme,
                  mono: true,
                ),
                if (widget.analysis.uploadDate != null) ...[
                  const SizedBox(height: 8),
                  _buildStatRow(
                    context,
                    icon: Icons.calendar_today_outlined,
                    label: 'Analyzed',
                    value: _formatDate(widget.analysis.uploadDate!),
                    colorScheme: colorScheme,
                  ),
                ],
                const SizedBox(height: 24),

                // Action Buttons
                _isDownloading
                    ? const Center(child: CircularProgressIndicator())
                    : Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                side: BorderSide(color: colorScheme.primary),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: Icon(
                                Icons.download,
                                color: colorScheme.primary,
                              ),
                              label: Text(
                                'Download Document',
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: () => _handleDownload(preview: false),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colorScheme.primary,
                                foregroundColor: colorScheme.onPrimary,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              icon: const Icon(Icons.remove_red_eye),
                              label: const Text(
                                'Preview Document',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              onPressed: () => _handleDownload(preview: true),
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildDetailedSummaryTab(ColorScheme colorScheme) {
    return SingleChildScrollView(
      padding: AppPaddings.all16,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colorScheme.outlineVariant, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.article_outlined,
                  color: colorScheme.onSurface,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Detailed Analytical Summary',
                    style: AppTextStyles.subMidHeader(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (widget.analysis.processedContent != null &&
                widget.analysis.processedContent!.isNotEmpty)
              Html(
                data: widget.analysis.processedContent,
                style: {
                  'body': Style(
                    fontSize: FontSize(15),
                    lineHeight: LineHeight(1.65),
                    color: colorScheme.onSurface,
                  ),
                  'h1': Style(
                    color: colorScheme.primary,
                    fontSize: FontSize(20),
                    fontWeight: FontWeight.bold,
                  ),
                  'h2': Style(
                    color: colorScheme.primary,
                    fontSize: FontSize(17),
                    fontWeight: FontWeight.bold,
                  ),
                  'h3': Style(
                    color: colorScheme.onSurface,
                    fontSize: FontSize(15),
                    fontWeight: FontWeight.bold,
                  ),
                  'p': Style(margin: Margins.only(bottom: 12)),
                  'ul': Style(padding: HtmlPaddings.only(left: 20)),
                  'li': Style(margin: Margins.only(bottom: 6)),
                  'strong': Style(fontWeight: FontWeight.bold),
                  'em': Style(fontStyle: FontStyle.italic),
                  'hr': Style(
                    border: const Border(
                      bottom: BorderSide(color: Colors.grey, width: 0.5),
                    ),
                  ),
                },
              )
            else
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 40,
                        color: colorScheme.outline,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No detailed summary available.',
                        style: TextStyle(color: colorScheme.outline),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required ColorScheme colorScheme,
    Color? valueColor,
    bool mono = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: colorScheme.outline),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: valueColor ?? colorScheme.onSurface,
            fontFamily: mono ? 'monospace' : null,
          ),
        ),
      ],
    );
  }

  String _formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateStr;
    }
  }
}
