import 'package:flutter/material.dart';
import '../../models/event_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EventRatingSummary extends StatefulWidget {
  final DateTime date;
  final List<EventRating> ratings;
  final Function(int) submitRating;
  const EventRatingSummary(
      {required this.date,
      required this.ratings,
      required this.submitRating,
      super.key});

  @override
  State<EventRatingSummary> createState() => _EventRatingSummaryState();
}

class _EventRatingSummaryState extends State<EventRatingSummary> {
  int selectedRating = 0;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Find user's rating if it exists
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    if (currentUserId != null) {
      final userRating = widget.ratings.firstWhere(
        (rating) => rating.userId == currentUserId,
        orElse: () => EventRating(
          rating: 0,
          createdAt: DateTime.now(),
          userId: '',
        ),
      );
      selectedRating = userRating.rating.toInt();
    }
  }

  String _formatDate(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[(date.weekday - 1) % 7]}, ${date.month}/${date.day}';
  }

  void _handleRating(int rating) {
    setState(() {
      selectedRating = rating;
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final brightness = Theme.of(context).brightness;
    final hasUserRated = currentUserId != null &&
        widget.ratings.any((rating) => rating.userId == currentUserId);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      elevation: 0,
      color: brightness == Brightness.light
          ? Colors.white
          : Color.fromRGBO(43, 33, 28, 1),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Center(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (widget.ratings.isEmpty)
                    Text(
                        'This rating is for event on ${_formatDate(widget.date)}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 14,
                            color: brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black)),
                  if (widget.ratings.isNotEmpty)
                    Text('The event on ${_formatDate(widget.date)} got',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 14,
                            color: brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black)),
                  const SizedBox(width: 8),
                  if (widget.ratings.isNotEmpty)
                    Icon(Icons.favorite,
                        color: Theme.of(context).colorScheme.primary, size: 18),
                  if (widget.ratings.isNotEmpty)
                    Text(
                      widget.ratings.isNotEmpty
                          ? widget.ratings.first.rating.toStringAsFixed(1)
                          : '-',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                              color: Theme.of(context).colorScheme.onTertiary,
                              fontSize: 18),
                    ),
                  if (widget.ratings.isNotEmpty)
                    Text(
                      ' (${widget.ratings.length})',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                              fontWeight: FontWeight.w400,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onTertiary
                                  .withOpacity(0.5),
                              fontSize: 14),
                    ),
                ],
              ),
              const SizedBox(height: 15),
              Text(
                hasUserRated ? 'Your Rating' : 'Rate this Event',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 16),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (i) => GestureDetector(
                    onTap: () {
                      _handleRating(i + 1);
                      widget.submitRating(i + 1);
                    },
                    child: Icon(
                      i < selectedRating ? Icons.favorite : Icons.favorite,
                      color: i < selectedRating
                          ? Colors.orange
                          : brightness == Brightness.light
                              ? Color.fromRGBO(218, 218, 218, 1)
                              : Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
