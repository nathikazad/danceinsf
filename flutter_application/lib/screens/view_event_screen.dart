import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/event_controller.dart';
import '../models/event.dart';

final eventControllerProvider = Provider<EventController>((ref) => EventController());

class ViewEventScreen extends ConsumerStatefulWidget {
  final String eventId;
  const ViewEventScreen({required this.eventId, super.key});

  @override
  ConsumerState<ViewEventScreen> createState() => _ViewEventScreenState();
}

class _ViewEventScreenState extends ConsumerState<ViewEventScreen> {
  late Future<EventOccurrence?> _eventFuture;

  @override
  void initState() {
    super.initState();
    final controller = ref.read(eventControllerProvider);
    _eventFuture = controller.fetchEvent(widget.eventId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bachata Fusion'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: FutureBuilder<EventOccurrence?>(
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
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main Info Card
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              event.name,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              event.type == EventType.social ? 'Social' : 'Class and Social',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '\$${occurrence.cost.toStringAsFixed(0)}',
                                style: const TextStyle(fontSize: 20, color: Colors.orange, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.favorite, color: Colors.orange, size: 18),
                                const SizedBox(width: 4),
                                Text(
                                  event.rating?.toStringAsFixed(1) ?? '-',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  ' (${event.ratingCount ?? 0})',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                            const Text('Cumulative', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Event Details
                _EventDetailRow(icon: Icons.calendar_today, text: _formatDate(occurrence.date)),
                _EventDetailRow(icon: Icons.access_time, text: _formatTimeRange(occurrence.startTime, occurrence.endTime)),
                _EventDetailRow(icon: Icons.repeat, text: _formatRecurrence(event.frequency)),
                _EventDetailRow(icon: Icons.location_on, text: '${occurrence.venueName}, ${occurrence.city}', linkText: 'Directions', linkUrl: occurrence.url),
                if (occurrence.ticketLink != null && occurrence.ticketLink!.isNotEmpty)
                  _EventDetailRow(icon: Icons.link, text: 'Buy Tickets', linkUrl: occurrence.ticketLink),
                if (event.linkToEvent != null && event.linkToEvent!.isNotEmpty)
                  _EventDetailRow(icon: Icons.link, text: 'Flyer', linkUrl: event.linkToEvent),
                const SizedBox(height: 24),
                // Ratings Section
                if (occurrence.ratings.isNotEmpty)
                  _RatingsSection(occurrence: occurrence),
                // Rate this Event (placeholder)
                const SizedBox(height: 24),
                Center(
                  child: Column(
                    children: [
                      Text('This event on ${_formatDate(occurrence.date)} got', style: const TextStyle(fontSize: 16)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.favorite, color: Colors.orange, size: 20),
                          Text(
                            occurrence.ratings.isNotEmpty
                              ? occurrence.ratings.first.rating.toStringAsFixed(1)
                              : '-',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          Text(' (${occurrence.ratings.length})'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text('Rate this Event', style: TextStyle(fontWeight: FontWeight.bold)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (i) => Icon(Icons.favorite_border, color: Colors.grey.shade400)),
                      ),
                    ],
                  ),
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

class _EventDetailRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final String? linkText;
  final String? linkUrl;
  const _EventDetailRow({required this.icon, required this.text, this.linkText, this.linkUrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.orange, size: 22),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16))),
          if (linkText != null && linkUrl != null)
            GestureDetector(
              onTap: () => _launchUrl(context, linkUrl!),
              child: Text(linkText!, style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  void _launchUrl(BuildContext context, String url) {
    // TODO: Implement url_launcher logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Open link: $url')),
    );
  }
}

class _RatingsSection extends StatelessWidget {
  final EventOccurrence occurrence;
  const _RatingsSection({required this.occurrence});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recent Ratings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ...occurrence.ratings.take(3).map((r) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              const Icon(Icons.favorite, color: Colors.orange, size: 16),
              const SizedBox(width: 4),
              Text(r.rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              if (r.comment != null && r.comment!.isNotEmpty)
                Expanded(child: Text('"${r.comment!}"', style: const TextStyle(fontStyle: FontStyle.italic))),
              const SizedBox(width: 8),
              Text(_formatDate(r.createdAt), style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        )),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }
}
