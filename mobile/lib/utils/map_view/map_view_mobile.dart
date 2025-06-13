import 'package:flutter/material.dart';
import 'package:dance_sf/models/event_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:go_router/go_router.dart';

class MapViewWidget extends StatefulWidget {
  final List<EventInstance> events;

  const MapViewWidget({
    required this.events,
    super.key,
  });

  @override
  State<MapViewWidget> createState() => _MapViewWidgetState();
}

class _MapViewWidgetState extends State<MapViewWidget> {
  late GoogleMapController _controller;
  final Set<Marker> _markers = {};
  bool _isMapReady = false;

  // Center of Bay Area
  final LatLng _bayAreaCenter = const LatLng(37.575431, -122.161285);

  @override
  void didUpdateWidget(MapViewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Compare event instance IDs
    final oldIds = oldWidget.events.map((e) => e.eventInstanceId).toSet();
    final newIds = widget.events.map((e) => e.eventInstanceId).toSet();
    
    // Only update if there are actual changes in the events
    if (oldIds.length != newIds.length || !oldIds.every((id) => newIds.contains(id))) {
      _updateMarkers();
    }
  }

  Future<void> _updateMarkers() async {
    if (!_isMapReady) return;

    final newMarkers = widget.events
        .where((event) => event.event.location.gpsPoint != null)
        .map((event) {
          print("${event.event.name} ${event.event.location.gpsPoint?.latitude} ${event.event.location.gpsPoint?.longitude}");
          var position = LatLng(
            event.event.location.gpsPoint!.latitude,
            event.event.location.gpsPoint!.longitude,
          );
          final name = event.event.name;
          return Marker(
            markerId: MarkerId(event.eventInstanceId),
            position: position,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
            infoWindow: InfoWindow(
              title: name,
              snippet: 'Tap to view details',
              onTap: () {
                context.push('/event/${event.eventInstanceId}', extra: event);
              },
            ),
          );
        })
        .toSet();

    setState(() {
      _markers.clear();
      _markers.addAll(newMarkers);
    });


    _controller.animateCamera(
      CameraUpdate.newLatLngZoom(_bayAreaCenter, 8.0),
    );

  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.3,
      child: GoogleMap(
        key: const ValueKey('google_map'),
        initialCameraPosition: const CameraPosition(
          target: LatLng(37.575431, -122.161285), // Center of Bay Area
          zoom: 8,
        ),
        markers: _markers,
        onMapCreated: (GoogleMapController controller) {
          _controller = controller;
          _isMapReady = true;
          _updateMarkers();
        },
        myLocationEnabled: false,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: true,
        mapToolbarEnabled: false,
        mapType: MapType.normal,
        compassEnabled: true,
        rotateGesturesEnabled: true,
        tiltGesturesEnabled: true,
        zoomGesturesEnabled: true,
        scrollGesturesEnabled: true,
      ),
    );
  }
} 