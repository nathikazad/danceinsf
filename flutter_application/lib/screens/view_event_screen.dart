import 'package:flutter/material.dart';
import 'package:dance_sf/controllers/event_instance_controller.dart';
import 'package:dance_sf/utils/string.dart';
import 'package:dance_sf/widgets/view_event_widgets/flyer_viewer.dart';
import 'package:dance_sf/widgets/view_event_widgets/edit_event_modal.dart';
import 'package:flutter_svg_icons/flutter_svg_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/event_model.dart';
import '../widgets/view_event_widgets/event_detail_row.dart';
import '../widgets/view_event_widgets/event_rating_summary.dart';
import '../widgets/view_event_widgets/top_box.dart';
import '../widgets/view_event_widgets/event_proposals/event_proposals.dart';
import '../widgets/view_event_widgets/excitement_widget.dart';

class ViewEventScreen extends StatefulWidget {
  final String eventInstanceId;

  const ViewEventScreen({
    super.key,
    required this.eventInstanceId,
  });

  @override
  State<ViewEventScreen> createState() => _ViewEventScreenState();
}

class _ViewEventScreenState extends State<ViewEventScreen> {
  late Future<EventInstance?> _eventFuture;

  @override
  void initState() {
    super.initState();
    _loadEventInstance();
  }

  void _loadEventInstance() {
    setState(() {
      _eventFuture = EventInstanceController.fetchEventInstance(widget.eventInstanceId)
          .then((eventInstance) {
        if (eventInstance != null) {
          print('Number of flames inside loadEventInstance: ${eventInstance.excitedUsers.length}');
        }
        return eventInstance;
      });
    });
  }

  void _showEditOptions(BuildContext context, EventInstance eventInstance) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return EditEventModal(
          eventInstance: eventInstance,
          formatDate: _formatDate,
          onEditComplete: () {
            setState(() {
              _eventFuture = EventInstanceController.fetchEventInstance(widget.eventInstanceId);
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<EventInstance?>(
      future: _eventFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const Scaffold(
            body: Center(child: Text('Event not found.')),
          );
        }
        final eventInstance = snapshot.data!;
        final event = eventInstance.event;
        final currentUserId = Supabase.instance.client.auth.currentUser?.id;
        
        bool isExcited = false;
        // Update isExcited based on current data
        if (currentUserId != null) {
          isExcited = eventInstance.excitedUsers.contains(currentUserId);
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(
              '${event.name} on ${_formatDate(eventInstance.date)}',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSecondary, fontSize: 18),
            ),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.only(left: 6),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: Theme.of(context).colorScheme.secondaryContainer),
                child: Icon(
                  Icons.arrow_back_ios,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
              onPressed: () => context.pop(),
            ),
            actions: [
              if (currentUserId != null && currentUserId == eventInstance.event.organizerId)
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Theme.of(context).colorScheme.secondaryContainer),
                    child: Icon(
                      Icons.edit,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                  ),
                  onPressed: () => _showEditOptions(context, eventInstance),
                ),
              SizedBox(
                width: 10,
              )
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main Info Card
                TopBox(event: event, eventInstance: eventInstance),
                const SizedBox(height: 24),
                // Event Details
                EventDetailRow(
                    icon: SvgIcon(
                      icon: SvgIconData('assets/icons/calendar.svg'),
                      size: 18,
                    ),
                    // icon: Icon(Icons.calendar_today,
                    //     color: Theme.of(context).colorScheme.primary, size: 18),
                    text: _formatDate(eventInstance.date)),
                EventDetailRow(
                    icon: Icon(Icons.access_time,
                        color: Theme.of(context).colorScheme.primary, size: 18),
                    text: _formatTimeRange(
                        eventInstance.startTime, eventInstance.endTime)),
                EventDetailRow(
                    icon: Icon(Icons.refresh,
                        color: Theme.of(context).colorScheme.primary, size: 18),
                    text: _formatRecurrence(event.frequency, event.schedule)),
                EventDetailRow(
                    icon: Icon(Icons.location_on,
                        color: Theme.of(context).colorScheme.primary, size: 18),
                    text: '${eventInstance.venueName}, ${eventInstance.city}',
                    linkUrl: eventInstance.url),
                if (eventInstance.ticketLink != null &&
                    eventInstance.ticketLink!.isNotEmpty)
                  EventDetailRow(
                      icon: SvgIcon(
                        icon: SvgIconData("assets/icons/line-md_link.svg"),
                        size: 18,
                      ),
                      text: 'Link to Event',
                      linkUrl: eventInstance.ticketLink),
                if (eventInstance.flyerUrl != null &&
                    eventInstance.flyerUrl!.isNotEmpty)
                  FlyerViewer(url: eventInstance.flyerUrl!),
                if (!eventInstance.hasStarted) ...[ 
                  const SizedBox(height: 16),
                  ExcitementWidget(
                    eventInstanceId: widget.eventInstanceId,
                    initialIsExcited: isExcited,
                    onExcitementChanged: _loadEventInstance
                  ),
                ],
                const SizedBox(height: 24),
                if (eventInstance.hasStarted)
                  EventRatingSummary(
                      eventInstanceId: widget.eventInstanceId,
                      date: eventInstance.date,
                      ratings: eventInstance.ratings,
                      onRatingChanged: _loadEventInstance,
                      event: event
                ),
                const SizedBox(height: 32),
                ProposalsWidget(
                    eventInstance: eventInstance,
                    onEditClicked: () {
                      _showEditOptions(context, snapshot.data!);
                    }),
              ],
            ),
          ),
        );
      },
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
