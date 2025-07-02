import 'package:dance_sf/controllers/log_controller.dart';
import 'package:dance_sf/widgets/view_event_widgets/ratings_section.dart';
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
import '../widgets/view_event_widgets/previous_event_link.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ViewEventScreen extends StatefulWidget {
  final String eventInstanceId;
  final EventInstance? initialEventInstance;

  const ViewEventScreen({
    super.key,
    required this.eventInstanceId,
    this.initialEventInstance,
  });

  @override
  State<ViewEventScreen> createState() => _ViewEventScreenState();
}

class _ViewEventScreenState extends State<ViewEventScreen> {
  late Future<EventInstance?> _eventFuture;
  bool _editButtonClicked = false;

  @override
  void initState() {
    super.initState();
    _loadEventInstance();
  }

  void _loadEventInstance() {
    setState(() {
      _eventFuture = EventInstanceController.fetchEventInstance(widget.eventInstanceId)
          .then((eventInstance) {
        LogController.logNavigation('Viewing event ${eventInstance?.event.name} ${_formatDate(eventInstance?.date)}');
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
    final l10n = AppLocalizations.of(context)!;
    return FutureBuilder<EventInstance?>(
      future: _eventFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
          if (widget.initialEventInstance != null) {
            return _buildEventContent(widget.initialEventInstance!, l10n);
          }
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return Scaffold(
            body: Center(child: Text(l10n.eventNotFound)),
          );
        }
        return _buildEventContent(snapshot.data!, l10n);
      },
    );
  }

  Widget _buildEventContent(EventInstance eventInstance, AppLocalizations l10n) {
    final event = eventInstance.event;
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    
    bool isExcited = false;
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
          onPressed: () {
            if (GoRouter.of(context).canPop()) {
              GoRouter.of(context).pop(_editButtonClicked);
            } else {
              GoRouter.of(context).go('/events');
            }
          },
        ),
        actions: [
          if (currentUserId != null && 
           (currentUserId == eventInstance.event.organizerId
           || currentUserId == eventInstance.event.creatorId
           || currentUserId == 'b0ffdf47-a4e3-43e9-b85e-15c8af0a1bd6'))
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
              onPressed: () {
                setState(() {
                  _editButtonClicked = true;
                });
                _showEditOptions(context, eventInstance);
              },
            ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: Theme.of(context).colorScheme.secondaryContainer,
              ),
              child: Icon(
                Icons.ios_share,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
            ),
            onPressed: () {
              final url = 'https://sfdn.cc/${eventInstance.shortUrl.toLowerCase()}';
              if (kIsWeb) {
                Clipboard.setData(ClipboardData(text: url));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.linkCopied)),
                );
              } else {
                SharePlus.instance.share(
                  ShareParams(uri: Uri.parse(url))
                );
              }
            },
          ),
          const SizedBox(width: 10)
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TopBox(event: event, eventInstance: eventInstance),
            const SizedBox(height: 24),
            EventDetailRow(
                icon: SvgIcon(
                  icon: SvgIconData('assets/icons/calendar.svg'),
                  size: 18,
                ),
                text: _formatDate(eventInstance.date)),
            EventDetailRow(
                icon: Icon(Icons.access_time,
                    color: Theme.of(context).colorScheme.primary, size: 18),
                text: _formatTimeRange(
                    eventInstance.startTime, eventInstance.endTime)),
            EventDetailRow(
                icon: Icon(Icons.refresh,
                    color: Theme.of(context).colorScheme.primary, size: 18),
                text: _formatRecurrence(event.frequency, event.schedule, l10n)),
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
                  text: l10n.linkToEvent,
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
                  ratings: eventInstance.ratings.where((rating) => rating.eventInstanceId == widget.eventInstanceId).toList(),
                  onRatingChanged: _loadEventInstance,
                  event: event
            ),
            if (eventInstance.event.frequency == Frequency.weekly || eventInstance.event.frequency == Frequency.monthly)
            PreviousEventLink(
              eventId: event.eventId,
              currentDate: eventInstance.date,
            ),
            const SizedBox(height: 32),
            ProposalsWidget(
                eventInstance: eventInstance,
                onEditClicked: () {
                  _showEditOptions(context, eventInstance);
                }),
            const SizedBox(height: 32),
            if (eventInstance.ratings.isNotEmpty)
              RatingsSection(occurrence: eventInstance),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return '';
    }
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

  String _formatRecurrence(Frequency freq, SchedulePattern schedule, AppLocalizations l10n) {
    switch (freq) {
      case Frequency.once:
        return l10n.oneTime;
      case Frequency.weekly:
        return l10n.repeatWeekly(_getLocalizedDayName(schedule.dayOfWeek, l10n));
      case Frequency.monthly:
        final weekNumber = schedule.weeksOfMonth != null && schedule.weeksOfMonth!.isNotEmpty ? schedule.weeksOfMonth!.first : 1;
        final weekString = _getWeekOfMonthString(weekNumber, l10n).capitalize;
        return l10n.repeatMonthly(weekString, _getLocalizedDayName(schedule.dayOfWeek, l10n));
    }
  }

  String _getWeekOfMonthString(int weekOfMonth, AppLocalizations l10n) {
    switch (weekOfMonth) {
      case 1:
        return l10n.weekOfMonthFirst;
      case 2:
        return l10n.weekOfMonthSecond;
      case 3:
        return l10n.weekOfMonthThird;
      case 4:
        return l10n.weekOfMonthFourth;
      case 5:
        return l10n.weekOfMonthLast;
      default:
        return '';
    }
  }

  String _getLocalizedDayName(DayOfWeek? dayOfWeek, AppLocalizations l10n) {
    if (dayOfWeek == null) return '';
    final names = l10n.weekdayNames.split(',');
    return names[dayOfWeek.index].trim().capitalize;
  }
}
