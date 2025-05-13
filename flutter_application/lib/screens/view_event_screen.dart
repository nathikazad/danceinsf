import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/event_controller.dart';
import '../models/event.dart';
import '../widgets/view_event_widgets/event_detail_row.dart';
import '../widgets/view_event_widgets/event_rating_summary.dart';
import '../widgets/view_event_widgets/top_box.dart';

final eventControllerProvider = Provider<EventController>((ref) => EventController());

class ViewEventScreen extends ConsumerStatefulWidget {
  final String eventId;
  const ViewEventScreen({required this.eventId, super.key});

  @override
  ConsumerState<ViewEventScreen> createState() => _ViewEventScreenState();
}

class _ViewEventScreenState extends ConsumerState<ViewEventScreen> {
  late Future<EventInstance?> _eventFuture;

  @override
  void initState() {
    super.initState();
    final controller = ref.read(eventControllerProvider);
    _eventFuture = controller.fetchEvent(widget.eventId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<EventInstance?>(
        future: _eventFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Event not found.'));
          }
          final occurrence = snapshot.data!;
          final event = occurrence.event;
          return Scaffold(
            appBar: AppBar(
              title: Text(event.name),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Main Info Card
                  TopBox(event: event, occurrence: occurrence),
                  const SizedBox(height: 24),
                  // Event Details
                  EventDetailRow(icon: Icons.calendar_today, text: _formatDate(occurrence.date)),
                  EventDetailRow(icon: Icons.access_time, text: _formatTimeRange(occurrence.startTime, occurrence.endTime)),
                  EventDetailRow(icon: Icons.repeat, text: _formatRecurrence(event.frequency)),
                  EventDetailRow(icon: Icons.location_on, text: '${occurrence.venueName}, ${occurrence.city}', linkText: 'Directions', linkUrl: occurrence.url),
                  if (occurrence.ticketLink != null && occurrence.ticketLink!.isNotEmpty)
                    EventDetailRow(icon: Icons.link, text: 'Buy Tickets', linkUrl: occurrence.ticketLink),
                  if (event.linkToEvent != null && event.linkToEvent!.isNotEmpty)
                    EventDetailRow(icon: Icons.link, text: 'Flyer', linkUrl: event.linkToEvent),
                  const SizedBox(height: 24),
                  // Ratings Section
                  // if (occurrence.ratings.isNotEmpty)
                  //   RatingsSection(occurrence: occurrence),
                  // // Rate this Event (placeholder)
                  // const SizedBox(height: 24),
                  EventRatingSummary(date: occurrence.date, ratings: occurrence.ratings),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${_weekdayString(date.weekday)}, ${date.month}/${date.day}';
  }

  String _weekdayString(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[(weekday - 1) % 7];
  }

  String _formatTimeRange(TimeOfDay start, TimeOfDay end) {
    String format(TimeOfDay t) => t.format(context);
    return '${format(start)} - ${format(end)}';
  }

  String _formatRecurrence(Frequency freq) {
    switch (freq) {
      case Frequency.once:
        return 'One-time';
      case Frequency.weekly:
        return 'Repeat Weekly, Every Thursday';
      case Frequency.monthly:
        return 'Monthly';
    }
  }
}
