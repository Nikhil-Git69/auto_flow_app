import 'package:auto_flow/models/api_models/activity_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GanttChartView extends StatelessWidget {
  final List<ActivityModel> activities;
  final Function(ActivityModel) onActivityTap;

  const GanttChartView({
    super.key,
    required this.activities,
    required this.onActivityTap,
  });

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return const Center(child: Text("No activities to display"));
    }

    // 1. Calculate Date Range
    DateTime minDate = DateTime.now();
    DateTime maxDate = DateTime.now().add(const Duration(days: 7));

    if (activities.isNotEmpty) {
      final startDates = activities
          .map((e) => e.startDate ?? e.createdAt)
          .toList();
      final endDates = activities
          .map((e) => e.deadline ?? e.createdAt.add(const Duration(days: 1)))
          .toList();

      startDates.sort();
      endDates.sort();

      minDate = startDates.first.subtract(const Duration(days: 1)); // Buffer
      maxDate = endDates.last.add(const Duration(days: 7)); // Buffer
    }

    // Ensure we strip time for easier calculation
    final startOfChart = DateTime(minDate.year, minDate.month, minDate.day);
    final endOfChart = DateTime(maxDate.year, maxDate.month, maxDate.day);
    final totalDays = endOfChart.difference(startOfChart).inDays + 1;

    // Constants
    const double dayWidth = 50.0;
    const double rowHeight = 60.0;
    const double headerHeight = 40.0;
    const double nameColumnWidth = 140.0;

    return Column(
      children: [
        SizedBox(
          height: headerHeight,
          child: Row(
            children: [
              const SizedBox(
                width: nameColumnWidth,
                child: Center(
                  child: Text(
                    "Activity",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              // Expanded(
              //   child: ListView.builder(
              //     scrollDirection: Axis.horizontal,
              //     physics: const ClampingScrollPhysics(),
              //     itemBuilder: (context, index) => const SizedBox(),
              //     itemCount: 0,
              //   ),
              // ),
            ],
          ),
        ),

        // Main Content Area
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: nameColumnWidth,
                  child: Column(
                    children: [
                      // Header for Name Column (Sticky-ish if we pushed it up, but here it scrolls)
                      // Actually, let's put the header ABOVE this SingleChildScrollView if we want it sticky.
                      // Let's try the simpler approach first: Everything scrolls together vertically.
                      // Retrying structure:
                      // Column [
                      //    Row [ FixedHeaderCell, Expanded(ScrollView_H(TimelineHeader)) ]
                      //    Expanded(ScrollView_V [
                      //       Row [
                      //          Column(Names),
                      //          Expanded(ScrollView_H(Column(Bars)))  <-- Issue: H-scroll separate from header H-scroll
                      //       ]
                      //    ])
                      // ]
                      // Syncing horizontal scrolls is easier than vertical.
                      // Let's use linked controllers for Horizontal Sync.
                      // Actually, let's stick to the simplest robust layout:
                      // SingleVerticalScrollView containing:
                      //    Row [
                      //       Column(Names),
                      //       SingleHorizontalScrollView(Column(Bars))
                      //    ]
                      // Drawback: Header isn't sticky.
                      // User can live with non-sticky header for now.
                      const SizedBox(height: headerHeight),
                      ...activities.map(
                        (activity) => Container(
                          height: rowHeight,
                          padding: const EdgeInsets.all(8),
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.grey.shade200),
                            ),
                          ),
                          child: Text(
                            activity.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Scrollable Timeline Area
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Timeline Header
                        SizedBox(
                          height: headerHeight,
                          child: Row(
                            children: List.generate(totalDays, (index) {
                              final date = startOfChart.add(
                                Duration(days: index),
                              );
                              return Container(
                                width: dayWidth,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  border: Border(
                                    left: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                    bottom: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  color: Colors.grey.shade50,
                                ),
                                child: Text(
                                  DateFormat('d\nMMM').format(date),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            }),
                          ),
                        ),

                        // Timeline Bars
                        ...activities.map((activity) {
                          // Calculate Position
                          final startDate =
                              activity.startDate ?? activity.createdAt;
                          final endDate =
                              activity.deadline ??
                              startDate.add(const Duration(days: 1));

                          final startOffset =
                              startDate.difference(startOfChart).inDays *
                              dayWidth;
                          final durationDays =
                              endDate.difference(startDate).inDays +
                              1; // inclusive
                          final width =
                              (durationDays > 0 ? durationDays : 1) * dayWidth;

                          Color barColor = Colors.blue;
                          if (activity.color != null) {
                            // Parse hex if simple hex string
                            try {
                              String hex = activity.color!.replaceAll("#", "");
                              if (hex.length == 6) hex = "FF$hex";
                              barColor = Color(int.parse(hex, radix: 16));
                            } catch (_) {}
                          } else {
                            if (activity.status == 'Done')
                              barColor = Colors.green;
                          }

                          return Container(
                            height: rowHeight,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(color: Colors.grey.shade200),
                              ),
                            ),
                            child: Stack(
                              children: [
                                // Grid lines
                                Row(
                                  children: List.generate(
                                    totalDays,
                                    (index) => Container(
                                      width: dayWidth,
                                      decoration: BoxDecoration(
                                        border: Border(
                                          left: BorderSide(
                                            color: Colors.grey.shade100,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // The Bar
                                Positioned(
                                  left: startOffset < 0
                                      ? 0
                                      : startOffset.toDouble(),
                                  top: 10,
                                  bottom: 10,
                                  width: width.toDouble(),
                                  child: GestureDetector(
                                    onTap: () => onActivityTap(activity),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: barColor.withValues(alpha: 0.8),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: barColor.withValues(
                                            alpha: 1.0,
                                          ),
                                          width: 1,
                                        ),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                      ),
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        activity.title,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
