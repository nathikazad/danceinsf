import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../controllers/log_controller.dart';
import '../../models/log.dart';
import '../../utils/app_scaffold/app_scaffold.dart';

final userOrSessionLogsProvider = FutureProvider.family<List<Log>, ({String id, bool isUserId})>((ref, params) async {
  final logs = await LogController.fetchLogsByUserOrSession(params.id, isUserId: params.isUserId);
  // Sort by most recent first
  logs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return logs;
});

class ActivityByUserOrSessionScreen extends ConsumerStatefulWidget {
  final String id;
  final bool isUserId;

  const ActivityByUserOrSessionScreen({
    required this.id,
    required this.isUserId,
    super.key,
  });

  @override
  ConsumerState<ActivityByUserOrSessionScreen> createState() => _ActivityByUserOrSessionScreenState();
}

class _ActivityByUserOrSessionScreenState extends ConsumerState<ActivityByUserOrSessionScreen> {
  int? expandedIndex;

  @override
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(userOrSessionLogsProvider((id: widget.id, isUserId: widget.isUserId)));

    return AppScaffold(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Activities for ${widget.isUserId ? 'User' : 'Session'} ${widget.id}'),
        ),
        body: logsAsync.when(
          data: (logs) {
            if (logs.isEmpty) {
              return const Center(
                child: Text('No activities found'),
              );
            }

            return ListView.builder(
              itemCount: logs.length,
              itemBuilder: (context, index) {
                final log = logs[index];
                final createdAt = log.createdAt;

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date: ${createdAt.toLocal().toString().split('.')[0].split(' ')[0]}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          'Time: ${createdAt.toLocal().toString().split('.')[0].split(' ')[1]}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (log.device != null) Text('Device: ${log.device}'),
                        if (log.userId != null && !widget.isUserId) ...[
                          const SizedBox(height: 4),
                          InkWell(
                            onTap: () => context.push('/activity/user/${log.userId}'),
                            child: Text(
                              'User ID: ${log.userId}',
                              style: const TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        InkWell(
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