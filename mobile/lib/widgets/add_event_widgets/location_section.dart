import 'package:dance_sf/utils/app_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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
  final _searchController = TextEditingController();
  Location _currentLocation = Location(venueName: '', city: '', url: '');
  List<Map<String, dynamic>> _predictions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _currentLocation = widget.location;
    _searchController.text = widget.location.venueName;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchPlaces(String query) async {
    print('Searching for: $query');
    if (query.length < 3) {
      setState(() {
        _predictions = [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/autocomplete/json'
      '?input=${Uri.encodeComponent(query)}'
      '&location=${AppStorage.defaultMapCenter.latitude},${AppStorage.defaultMapCenter.longitude}'
      '&radius=50000' // 50km radius
      '&key=AIzaSyAYc3SKKnIrnvetF3e_sVIgvPw680wi2_4',
    );
    
    print('Request URL: $url');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          setState(() {
            _predictions = List<Map<String, dynamic>>.from(data['predictions']);
          });
        } else {
          print('API Error: ${data['status']} - ${data['error_message'] ?? 'No error message'}');
        }
      } else {
        print('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching places: $e');
      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error searching for places: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _getPlaceDetails(String placeId) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://maps.googleapis.com/maps/api/place/details/json'
          '?place_id=$placeId'
          '&fields=name,formatted_address,geometry'
          '&key=AIzaSyAYc3SKKnIrnvetF3e_sVIgvPw680wi2_4',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK') {
          final result = data['result'];
          final addressComponents = result['formatted_address'].split(',');
          print(addressComponents);
          final locationComponentIndex = AppStorage.zone == 'San Francisco' ? addressComponents.length - 3 : 2;
          final city = addressComponents.length >= 2 
              ? addressComponents[locationComponentIndex].trim()
              : 'San Francisco';

          final geometry = result['geometry'];
          final location = geometry['location'];
          final gpsPoint = GPSPoint(
            latitude: location['lat'].toDouble(),
            longitude: location['lng'].toDouble(),
          );
          print(gpsPoint.latitude);
          print(gpsPoint.longitude);

          final newLocation = Location(
            venueName: result['name'],
            city: city,
            url: 'https://www.google.com/maps/place/?q=place_id:$placeId',
            gpsPoint: gpsPoint,
          );

          setState(() {
            _currentLocation = newLocation;
            _searchController.text = newLocation.venueName;
            _predictions = [];
          });

          widget.onLocationChanged(newLocation);
        }
      }
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontSize: 14,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: "Search for a venue in ${AppStorage.zone}",
            hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: 12,
              color: Theme.of(context).colorScheme.tertiary,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
                width: 1,
              ),
            ),
            suffixIcon: _isLoading
                ? const SizedBox(
                    width: 5,
                    height: 5,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
          ),
          onChanged: _searchPlaces,
        ),
        if (_predictions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: _predictions.length,
              itemBuilder: (context, index) {
                final prediction = _predictions[index];
                return ListTile(
                  title: Text(prediction['structured_formatting']['main_text']),
                  subtitle: Text(prediction['structured_formatting']['secondary_text']),
                  onTap: () => _getPlaceDetails(prediction['place_id']),
                );
              },
            ),
          ),
        if (_currentLocation.venueName.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'Selected Location:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_currentLocation.venueName}, ${_currentLocation.city}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ],
    );
  }
}
