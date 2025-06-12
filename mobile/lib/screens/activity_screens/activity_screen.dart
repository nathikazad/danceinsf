import 'package:dance_sf/models/log.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../controllers/log_controller.dart';
import '../../utils/app_scaffold/app_scaffold.dart';
import 'activity_by_date_screen.dart';

final logsProvider = FutureProvider<List<Log>>((ref) async {
  return await LogController.fetchLogs();
});

class ActivityChart extends StatelessWidget {
  final Map<String, List<Log>> groupedLogs;
  final List<String> sortedDates;

  const ActivityChart({
    super.key,
    required this.groupedLogs,
    required this.sortedDates,
  });

  @override
  Widget build(BuildContext context) {
    final spots = sortedDates.asMap().entries.map((entry) {
      final date = entry.key;
      final count = groupedLogs[entry.value]!.length;
      return FlSpot(date.toDouble(), count.toDouble());
    }).toList();

    // Calculate how many labels to show (approximately one label per 3 bars)
    final labelInterval = (spots.length / 8).ceil();

    return SizedBox(
      height: 200,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: spots.map((e) => e.y).reduce((a, b) => a > b ? a : b) + 1,
            barTouchData: BarTouchData(
              enabled: false,
              touchTooltipData: BarTouchTooltipData(
                tooltipBgColor: Colors.transparent,
                tooltipPadding: EdgeInsets.zero,
                tooltipMargin: 0,
                getTooltipItem: (
                  BarChartGroupData group,
                  int groupIndex,
                  BarChartRodData rod,
                  int rodIndex,
                ) {
                  return BarTooltipItem(
                    rod.toY.round().toString(),
                    const TextStyle(
                      color: Color.fromRGBO(240, 99, 20, 1),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() >= sortedDates.length) return const Text('');
                    // Only show label for every nth bar
                    if (value.toInt() % labelInterval != 0) return const Text('');
                    final date = DateTime.parse(sortedDates[value.toInt()]);
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        '${date.month}/${date.day}',
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toInt().toString(),
                      style: const TextStyle(fontSize: 10),
                    );
                  },
                ),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            gridData: FlGridData(show: false),
            barGroups: spots.map((spot) {
              return BarChartGroupData(
                x: spot.x.toInt(),
                barRods: [
                  BarChartRodData(
                    toY: spot.y,
                    color: const Color.fromRGBO(240, 99, 20, 1),
                    width: 20,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ],
                showingTooltipIndicators: [0],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class ActivityScreen extends ConsumerWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(logsProvider);

    return AppScaffold(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Activity Logs'),
        ),
        body: logsAsync.when(
          data: (logs) {
            if (logs.isEmpty) {
              return const Center(
                child: Text('No logs found'),
              );
            }

            // Group logs by date
            final Map<String, List<Log>> groupedLogs = {};
            for (var log in logs) {
              final createdAt = log.createdAt;
              final dateKey = '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}';
              groupedLogs.putIfAbsent(dateKey, () => []).add(log);
            }

            // Sort dates in descending order
            final sortedDates = groupedLogs.keys.toList()
              ..sort((a, b) => b.compareTo(a));

            return Column(
              children: [
                ActivityChart(
                  groupedLogs: groupedLogs,
                  sortedDates: sortedDates,
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: sortedDates.length,
                    itemBuilder: (context, index) {
                      final date = sortedDates[index];
                      final dateTime = DateTime.parse(date);

                      return ListTile(
                        title: Text(
                          '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        trailing: Text('${groupedLogs[date]!.length} activities'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ActivityByDateScreen(date: date),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Error: $error'),
          ),
        ),
      ),
    );
  }
} 