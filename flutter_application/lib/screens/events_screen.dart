import 'package:flutter/material.dart';
import 'package:flutter_application/widget/event_card.dart';
import 'package:flutter_application/widget/week_navigator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../auth.dart';
import '../models/event.dart';
import '../controllers/event_controller.dart';
import 'package:intl/intl.dart';

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  DateTime? _weekStart;
  int _selectedWeekday = DateTime.now().weekday;
  final ScrollController _scrollController = ScrollController();
  final Map<DateTime, GlobalKey> _dateKeys = {};

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _updateVisibleDate() {
    if (!_scrollController.hasClients) return;

    DateTime? closestDate;

    for (final entry in _dateKeys.entries) {
      final key = entry.value;
      final context = key.currentContext;
      if (context == null) continue;

      final RenderBox box = context.findRenderObject() as RenderBox;
      final position = box.localToGlobal(Offset.zero);
      final startY = position.dy;
      
      // Check if our reference point (topThreshold) falls within this card's bounds
      if (startY > 0) {
        closestDate = entry.key;
        break;
      }
    }

    if (closestDate != null) {
      setState(() {
        _selectedWeekday = closestDate!.weekday;
        _weekStart = closestDate.subtract(Duration(days: (closestDate.weekday - 1) % 7));
      });
    }
  }

  void _scrollToClosestDate(DateTime targetDate) {
    if (!_scrollController.hasClients) return;

    // Find the closest date key
    DateTime? closestDate;
    int? minDistance;

    for (final entry in _dateKeys.entries) {
      final key = entry.value;
      final context = key.currentContext;
      if (context == null) continue;

      // final RenderBox box = context.findRenderObject() as RenderBox;
      // final position = box.localToGlobal(Offset.zero);
      // final startY = position.dy;
      
      // Calculate distance from target date
      final daysDifference = entry.key.difference(targetDate).inDays.abs();
      
      if (minDistance == null || daysDifference < minDistance) {
        minDistance = daysDifference;
        closestDate = entry.key;
      }
    }

    if (closestDate != null) {
      final key = _dateKeys[closestDate]!;
      final context = key.currentContext;
      if (context != null) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(eventControllerProvider);
    final dateFormat = DateFormat('EEEE, MMM d');

    final weekStart = _weekStart ?? DateTime.now().subtract(Duration(days: (DateTime.now().weekday - 1) % 7));

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
      body: Column(
        children: [
          WeekNavigator(
            weekStart: weekStart,
            selectedWeekday: _selectedWeekday,
            onWeekChanged: (newWeekStart) {
              setState(() {
                _weekStart = newWeekStart;
                _selectedWeekday = 1; // Set to Monday
              });
              // Find the closest date key to scroll to
              final targetDate = newWeekStart; // Since we're going to Monday, we can use weekStart directly
              _scrollToClosestDate(targetDate);
            },
            onDaySelected: (weekday) {
              setState(() {
                _selectedWeekday = weekday;
              });
              // Find the closest date key to scroll to
              final targetDate = _weekStart!.add(Duration(days: weekday - 1));
              _scrollToClosestDate(targetDate);
            },
          ),
          const Divider(height: 1, thickness: 1),
          Expanded(
            child: eventsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: Text('Error: ${error.toString()}'),
              ),
              data: (occurrences) {
                final startDate = DateTime.now();
                final endDate = DateTime.now().add(const Duration(days: 30));
                
                final filteredOccurrences = occurrences.where((occ) =>
                  occ.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
                  occ.date.isBefore(endDate.add(const Duration(days: 1)))
                ).toList();
                
                final grouped = Event.groupOccurrencesByDate(filteredOccurrences);
                final dateKeys = grouped.keys.toList()..sort();

                if (dateKeys.isEmpty) {
                  return const Center(
                    child: Text('No events found in the next 7 days'),
                  );
                }

                return NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification is ScrollUpdateNotification) {
                      _updateVisibleDate();
                    }
                    return true;
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: dateKeys.length,
                    itemBuilder: (context, dateIndex) {
                      final date = dateKeys[dateIndex];
                      final occs = grouped[date]!;
                      
                      // Create or get key for this date
                      _dateKeys[date] = _dateKeys[date] ?? GlobalKey();
                      
                      return Column(
                        key: _dateKeys[date],
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
                            return EventCard(
                              event: event,
                              isFirst: occs.first == occurrence,
                            );
                          }).toList(),
                          if (dateIndex != dateKeys.length - 1)
                            const Divider(height: 32, thickness: 3, color: Colors.grey),
                        ],
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-event'),
        child: const Icon(Icons.add),
      ),
    );
  }
} 