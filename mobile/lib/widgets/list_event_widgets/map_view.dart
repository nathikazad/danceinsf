import 'package:flutter/material.dart';
class MapViewWidget extends StatelessWidget {
  const MapViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('hidden_events'),
      height: MediaQuery.of(context).size.height * 0.3,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Events Hidden',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Click the toggle button to show events list',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}