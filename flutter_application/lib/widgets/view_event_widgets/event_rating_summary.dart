import 'package:flutter/material.dart';
import '../../models/event.dart';

class EventRatingSummary extends StatelessWidget {
  final DateTime date;
  final List<EventRating> ratings;
  const EventRatingSummary({required this.date, required this.ratings, super.key});

  String _formatDate(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[(date.weekday - 1) % 7]}, ${date.month}/${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('This event on ${_formatDate(date)} got', style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              const Icon(Icons.favorite, color: Colors.orange, size: 20),
              Text(
                ratings.isNotEmpty
                  ? ratings.first.rating.toStringAsFixed(1)
                  : '-',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Text(' (${ratings.length})'),
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
    );
  }
} 