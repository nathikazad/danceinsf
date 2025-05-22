import 'package:flutter/material.dart';
import '../../models/event_model.dart';

class RatingsSection extends StatelessWidget {
  final EventInstance occurrence;
  const RatingsSection({required this.occurrence, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Reviews', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ...(occurrence.ratings
          .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt)))
          .take(10)
          .map((r) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.favorite, color: Colors.orange, size: 16),
                const SizedBox(width: 4),
                Text(r.rating.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Expanded(
                  child: r.comment != null && r.comment!.isNotEmpty
                    ? Text('"${r.comment!}"', style: const TextStyle(fontStyle: FontStyle.italic))
                    : const SizedBox(),
                ),
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