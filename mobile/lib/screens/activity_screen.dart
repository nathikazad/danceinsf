import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/log_controller.dart';
import '../utils/app_scaffold/app_scaffold.dart';
import 'activity_by_date_screen.dart';

final logsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return await LogController.fetchLogs();
});

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
            final Map<String, List<Map<String, dynamic>>> groupedLogs = {};
            for (var log in logs) {
              final createdAt = DateTime.parse(log['created_at']);
              final dateKey = '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}';
              groupedLogs.putIfAbsent(dateKey, () => []).add(log);
            }

            // Sort dates in descending order
            final sortedDates = groupedLogs.keys.toList()
              ..sort((a, b) => b.compareTo(a));

            return ListView.builder(
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