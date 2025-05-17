import 'package:flutter/material.dart';
import '../../models/event_model.dart';

class LocationSection extends StatefulWidget {
  final Location location;
  final Function(Location) onLocationChanged;

  const LocationSection({
    required this.location,
    required this.onLocationChanged,
    super.key,
  });

  @override
  State<LocationSection> createState() => _LocationSectionState();
}

class _LocationSectionState extends State<LocationSection> {
  final _venueController = TextEditingController();
  final _cityController = TextEditingController();
  final _mapsLinkController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _venueController.text = widget.location.venueName;
    _cityController.text = widget.location.city;
    _mapsLinkController.text = widget.location.url ?? '';
  }

  @override
  void dispose() {
    _venueController.dispose();
    _cityController.dispose();
    _mapsLinkController.dispose();
    super.dispose();
  }

  void _updateLocation() {
    widget.onLocationChanged(Location(
      venueName: _venueController.text,
      city: _cityController.text,
      url: _mapsLinkController.text,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Location', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _venueController,
          decoration: const InputDecoration(
            hintText: 'Venue Name',
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => _updateLocation(),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _cityController,
          decoration: const InputDecoration(
            hintText: 'City',
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => _updateLocation(),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _mapsLinkController,
          decoration: const InputDecoration(
            hintText: 'Google Map Link',
            border: OutlineInputBorder(),
          ),
          onChanged: (_) => _updateLocation(),
        ),
      ],
    );
  }
} 