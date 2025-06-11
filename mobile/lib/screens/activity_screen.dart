import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/log_controller.dart';
import '../utils/app_scaffold/app_scaffold.dart';

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

            return ListView.builder(
              itemCount: logs.length,
              itemBuilder: (context, index) {
                final log = logs[index];
                final actions = log['actions'] as Map<String, dynamic>?;
                final createdAt = DateTime.parse(log['created_at']);
                final device = log['device'] as String?;
                final userId = log['user_id'] as String?;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date: ${createdAt.toLocal().toString().split('.')[0]}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (device != null) Text('Device: $device'),
                        if (userId != null) Text('User ID: $userId'),
                        if (actions != null) ...[
                          const SizedBox(height: 8),
                          const Text('Actions:', style: TextStyle(fontWeight: FontWeight.bold)),
                          ...actions.entries.map((entry) => Padding(
                            padding: const EdgeInsets.only(left: 16, top: 4),
                            child: Text('${entry.key}: ${entry.value}'),
                          )),
                        ],
                      ],
                    ),
                  ),
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