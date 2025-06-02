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
        Text('Location',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontSize: 14, color: Theme.of(context).colorScheme.secondary)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _venueController,
          decoration: InputDecoration(
              hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 12, color: Theme.of(context).colorScheme.tertiary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              hintText: 'Venue Name',
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                    width: 1,
                  ))),
          onChanged: (_) => _updateLocation(),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _cityController,
          decoration: InputDecoration(
              hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 12, color: Theme.of(context).colorScheme.tertiary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              hintText: 'City',
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                    width: 1,
                  ))),
          onChanged: (_) => _updateLocation(),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _mapsLinkController,
          decoration: InputDecoration(
              hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 12, color: Theme.of(context).colorScheme.tertiary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              hintText: 'Google Map Link',
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                    width: 1,
                  ))),
          onChanged: (_) => _updateLocation(),
        ),
      ],
    );
  }
}
