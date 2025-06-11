import 'package:dance_sf/screens/activity_screens/activity_by_user_or_session_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../controllers/log_controller.dart';
import '../../models/log.dart';
import '../../utils/app_scaffold/app_scaffold.dart';

final dateLogsProvider = FutureProvider.family<({
  List<Log> logs,
  Map<String, int> userIdCounts,
  Map<String, int> sessionIdCounts
}), String>((ref, date) async {
  final result = await LogController.fetchByDate(date);
  // Sort by most recent last
  result.logs.sort((a, b) => a.createdAt.compareTo(b.createdAt));
  return result;
});

class ActivityByDateScreen extends ConsumerStatefulWidget {
  final String date;

  const ActivityByDateScreen({
    required this.date,
    super.key,
  });

  @override
  ConsumerState<ActivityByDateScreen> createState() => _ActivityByDateScreenState();
}

class _ActivityByDateScreenState extends ConsumerState<ActivityByDateScreen> {
  int? expandedIndex;

  @override
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(dateLogsProvider(widget.date));

    return AppScaffold(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Activities for ${widget.date}'),
        ),
        body: logsAsync.when(
          data: (data) {
            if (data.logs.isEmpty) {
              return const Center(
                child: Text('No activities found for this date'),
              );
            }

            return ListView.builder(
              itemCount: data.logs.length,
              itemBuilder: (context, index) {
                final log = data.logs[index];
                final createdAt = log.createdAt;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Time: ${createdAt.toLocal().toString().split('.')[0].split(' ')[1]}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (log.device != null) Text('Device: ${log.device}'),
                        if (log.userId != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ActivityByUserOrSessionScreen(
                                        id: log.userId!,
                                        isUserId: true,
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    'User ID: ${log.userId}',
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                '(${data.userIdCounts[log.userId]} activities)',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ActivityByUserOrSessionScreen(
                                      id: log.sessionId,
                                      isUserId: false,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'Session ID: ${log.sessionId}',
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              '(${data.sessionIdCounts[log.sessionId]} activities)',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                        if (log.actions.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () {
                              setState(() {
                                expandedIndex = expandedIndex == index ? null : index;
                              });
                            },
                            child: Row(
                              children: [
                                const Text('Actions:', style: TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(width: 8),
                                Icon(
                                  expandedIndex == index ? Icons.expand_less : Icons.expand_more,
                                ),
                              ],
                            ),
                          ),
                          if (expandedIndex == index) ...[
                            const SizedBox(height: 8),
                            ...log.actions.entries.map((entry) => Padding(
                              padding: const EdgeInsets.only(left: 16, top: 4),
                              child: Text('${entry.key}: ${entry.value}'),
                            )),
                          ],
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