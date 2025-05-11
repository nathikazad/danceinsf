import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../auth.dart';
import '../models/event.dart';
import 'package:intl/intl.dart';

class EventsScreen extends ConsumerWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = Event.generateEvents(10);
    final startDate = DateTime.now();
    final endDate = DateTime.now().add(const Duration(days: 7));
    final occurrences = Event.expandEvents(events, startDate, endDate);
    final grouped = Event.groupOccurrencesByDate(occurrences);
    final dateFormat = DateFormat('EEEE, MMM d');
    final timeFormat = DateFormat('h:mma');

    final dateKeys = grouped.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dance Events'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authProvider).signOut(),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: dateKeys.length,
        itemBuilder: (context, dateIndex) {
          final date = dateKeys[dateIndex];
          final occs = grouped[date]!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  dateFormat.format(date),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              ...occs.map((occurrence) {
                final event = occurrence.event;
                final start = event.startTime;
                final end = event.endTime;
                final location = event.location;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: occs.first == occurrence ? Colors.blue : Colors.transparent,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                event.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, size: 18),
                                  const SizedBox(width: 4),
                                  Text(location.address, style: const TextStyle(fontSize: 15)),
                                ],
                              ),
                              Text(
                                'San Francisco', // Placeholder for city
                                style: const TextStyle(fontSize: 13, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${start.format(context)} to ${end.format(context)}',
                              style: const TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '2415', // Placeholder for price
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              if (dateIndex != dateKeys.length - 1)
                const Divider(height: 32, thickness: 3, color: Colors.grey),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-event'),
        child: const Icon(Icons.add),
      ),
    );
  }
} 