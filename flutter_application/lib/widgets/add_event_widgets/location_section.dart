import 'package:flutter/material.dart';

class LocationSection extends StatefulWidget {
  const LocationSection({super.key});

  @override
  State<LocationSection> createState() => _LocationSectionState();
}

class _LocationSectionState extends State<LocationSection> {
  final _venueController = TextEditingController();
  final _cityController = TextEditingController();
  final _mapsLinkController = TextEditingController();

  @override
  void dispose() {
    _venueController.dispose();
    _cityController.dispose();
    _mapsLinkController.dispose();
    super.dispose();
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
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _cityController,
          decoration: const InputDecoration(
            hintText: 'City',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _mapsLinkController,
          decoration: const InputDecoration(
            hintText: 'Google Map Link',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }
} 