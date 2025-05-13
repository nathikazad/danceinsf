import 'package:flutter/material.dart';
import '../../models/event.dart';

class TopBox extends StatelessWidget {
  final Event event;
  final EventInstance eventInstance;
  const TopBox({required this.event, required this.eventInstance, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
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
                  event.style == DanceStyle.bachata ? 'Bachata' : 'Salsa',
                  style: const TextStyle(fontSize: 16),
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
                    '\$${eventInstance.cost.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 20, color: Colors.orange, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                if (event.ratingCount != null && event.ratingCount! > 0)
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
                if (event.ratingCount != null && event.ratingCount! > 0)
                const Text('Cumulative', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 