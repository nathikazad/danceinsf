import 'package:flutter/material.dart';
import '../../models/event_model.dart';

class EventRatingSummary extends StatefulWidget {
  final DateTime date;
  final List<EventRating> ratings;
  const EventRatingSummary({required this.date, required this.ratings, super.key});

  @override
  State<EventRatingSummary> createState() => _EventRatingSummaryState();
}

class _EventRatingSummaryState extends State<EventRatingSummary> {
  int selectedRating = 0;
  final TextEditingController _commentController = TextEditingController();

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
    return Center(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.ratings.isEmpty)
                Text('This rating is for event on ${_formatDate(widget.date)}', style: const TextStyle(fontSize: 16)),
              if (widget.ratings.isNotEmpty)
                Text('The event on ${_formatDate(widget.date)} got', style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              if (widget.ratings.isNotEmpty)
                const Icon(Icons.favorite, color: Colors.orange, size: 20),
              if (widget.ratings.isNotEmpty)
                Text(
                  widget.ratings.isNotEmpty
                      ? widget.ratings.first.rating.toStringAsFixed(1)
                      : '-',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              if (widget.ratings.isNotEmpty)
                Text(' (${widget.ratings.length})'),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Rate this Event', style: TextStyle(fontWeight: FontWeight.bold)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (i) => GestureDetector(
                onTap: () => _handleRating(i + 1),
                child: Icon(
                  i < selectedRating ? Icons.favorite : Icons.favorite_border,
                  color: i < selectedRating ? Colors.orange : Colors.grey.shade400,
                  size: 30,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
} 