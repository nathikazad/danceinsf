import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/log_controller.dart';
import '../utils/app_scaffold/app_scaffold.dart';

final userOrSessionLogsProvider = FutureProvider.family<List<Map<String, dynamic>>, ({String id, bool isUserId})>((ref, params) async {
  return LogController.fetchLogsByUserOrSession(params.id, isUserId: params.isUserId);
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
                final actions = log['actions'] as Map<String, dynamic>?;
                final createdAt = DateTime.parse(log['created_at']);
                final device = log['device'] as String?;
                final userId = log['user_id'] as String?;
                final sessionId = log['session_id'] as String?;

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
                        if (device != null) Text('Device: $device'),
                        if (userId != null && !widget.isUserId) ...[
                          const SizedBox(height: 4),
                          InkWell(
                            onTap: () => context.push('/activity/user/$userId'),
                            child: Text(
                              'User ID: $userId',
                              style: const TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                        if (sessionId != null && widget.isUserId) ...[
                          const SizedBox(height: 4),
                          InkWell(
                            onTap: () => context.push('/activity/session/$sessionId'),
                            child: Text(
                              'Session ID: $sessionId',
                              style: const TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                        if (actions != null) ...[
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
                            ...actions.entries.map((entry) => Padding(
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