import 'package:flutter/material.dart';
import 'package:flutter_application/widgets/add_event_widgets/repeat_section.dart';
import 'package:flutter_application/widgets/view_event_widgets/flyer_viewer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/event_controller.dart';
import '../models/event_model.dart';
import '../widgets/view_event_widgets/event_detail_row.dart';
import '../widgets/view_event_widgets/event_rating_summary.dart';
import '../widgets/view_event_widgets/top_box.dart';
import '../widgets/view_event_widgets/event_proposals/event_proposals.dart';

final eventControllerProvider = Provider<EventController>((ref) => EventController());

class ViewEventScreen extends ConsumerStatefulWidget {
  final String eventInstanceId;
  const ViewEventScreen({required this.eventInstanceId, super.key});

  @override
  ConsumerState<ViewEventScreen> createState() => _ViewEventScreenState();
}

class _ViewEventScreenState extends ConsumerState<ViewEventScreen> {
  late Future<EventInstance?> _eventFuture;

  @override
  void initState() {
    super.initState();
    final controller = ref.read(eventControllerProvider);
    _eventFuture = controller.fetchEvent(widget.eventInstanceId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: FutureBuilder<EventInstance?>(
        future: _eventFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Event not found.'));
          }
          final eventInstance = snapshot.data!;
          final event = eventInstance.event;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main Info Card
                TopBox(event: event, eventInstance: eventInstance),
                const SizedBox(height: 24),
                // Event Details
                EventDetailRow(icon: Icons.calendar_today, text: _formatDate(eventInstance.date)),
                EventDetailRow(icon: Icons.access_time, text: _formatTimeRange(eventInstance.startTime, eventInstance.endTime)),
                EventDetailRow(icon: Icons.repeat, text: _formatRecurrence(event.frequency, event.schedule)),
                EventDetailRow(icon: Icons.location_on, text: '${eventInstance.venueName}, ${eventInstance.city}', linkText: 'Directions', linkUrl: eventInstance.url),
                if (eventInstance.ticketLink != null && eventInstance.ticketLink!.isNotEmpty)
                  EventDetailRow(icon: Icons.link, text: 'Buy Tickets', linkUrl: eventInstance.ticketLink),
                if (eventInstance.flyerUrl != null && eventInstance.flyerUrl!.isNotEmpty)
                  FlyerViewer(url: eventInstance.flyerUrl!),
                const SizedBox(height: 24),
                if (eventInstance.hasStarted)
                  EventRatingSummary(date: eventInstance.date, ratings: eventInstance.ratings, submitRating: (rating) async {
                    final ret = await EventController.rateEvent(eventInstance.eventInstanceId, rating);
                    if (ret != null) {
                      setState(() {
                        final existingIndex = eventInstance.ratings.indexWhere((r) => r.userId == ret.userId);
                        if (existingIndex != -1) {
                          eventInstance.ratings[existingIndex] = ret;
                        } else {
                          eventInstance.ratings.add(ret);
                        }
                      });
                    }
                  }),
                const SizedBox(height: 32),
                ProposalsWidget(
                  eventInstance: eventInstance,
                ),
              ],
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

  String _formatRecurrence(Frequency freq, SchedulePattern schedule) {
    switch (freq) {
      case Frequency.once:
        return 'One-time';
      case Frequency.weekly:
        return 'Repeat Weekly, Every ${schedule.dayOfWeekString.capitalize()}';
      case Frequency.monthly:
        return 'Monthly, Every ${schedule.weekOfMonthString} ${schedule.dayOfWeekString.capitalize()}';
    }
  }
}