import 'package:flutter/material.dart';
import 'package:dance_sf/models/event_model.dart';

class MapViewWidget extends StatelessWidget {
  final List<EventInstance> events;

  const MapViewWidget({
    required this.events,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('map_view'),
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
            'Events Map',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return ListTile(
                  title: Text(event.event.name),
                  subtitle: event.event.geoPoint != null
                      ? Text('Lat: ${event.event.geoPoint!.latitude}, Lng: ${event.event.geoPoint!.longitude}')
                      : const Text('No location data'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}