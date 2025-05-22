import 'package:dance_sf/controllers/event_instance_controller.dart';
import 'package:dance_sf/widgets/verify_event_widgets/verify_user.dart';
import 'package:flutter/material.dart';
import '../../models/event_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class EventRatingSummary extends StatefulWidget {
  final DateTime date;
  final List<EventRating> ratings;
  final String eventInstanceId;
  final Function() onRatingChanged;
  final Event event;
  const EventRatingSummary(
      {required this.date,
      required this.ratings,
      required this.event,
      required this.eventInstanceId,
      required this.onRatingChanged,
      super.key});

  @override
  State<EventRatingSummary> createState() => _EventRatingSummaryState();
}

class _EventRatingSummaryState extends State<EventRatingSummary> {
  int selectedRating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _showCommentBox = false;

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
          eventInstanceId: widget.eventInstanceId,
        ),
      );
      selectedRating = userRating.rating.toInt();
      _commentController.text = userRating.comment ?? '';
    }
  }

  String _formatDate(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[(date.weekday - 1) % 7]}, ${date.month}/${date.day}';
  }

  void _handleRating(int rating) {
    setState(() {
      selectedRating = rating;
      _showCommentBox = true;
    });
  }

  Future<void> _submitRating() async {
    final isVerified = await handleRatingVerification(context);
    if (!isVerified) return;
    
    await EventInstanceController.rateEvent(
      widget.eventInstanceId, 
      selectedRating,
      widget.date,
      comment: _commentController.text.trim(),
    );
    widget.onRatingChanged();
    setState(() {
      _showCommentBox = false;
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
                  if (widget.ratings.isNotEmpty)...[
                    Icon(Icons.favorite,
                        color: Theme.of(context).colorScheme.primary, size: 18),
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
                  ]
                ],
              ),
              if (widget.event.ratingCount != null && widget.event.ratingCount! > 0) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'All ${widget.event.name} events got',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 14,
                          color: brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.favorite,
                        color: Theme.of(context).colorScheme.primary, size: 18),
                    Text(
                      widget.event.rating?.toStringAsFixed(1) ?? '-',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                              color: Theme.of(context).colorScheme.onTertiary,
                              fontSize: 18),
                    ),
                    Text(
                      ' (${widget.event.ratingCount ?? 0})',
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
              ],
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
                    onTap: () => _handleRating(i + 1),
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
              if (_showCommentBox) ...[
                const SizedBox(height: 15),
                TextField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: 'Add a comment (optional)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _submitRating,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('Submit Rating'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
