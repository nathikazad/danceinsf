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

  @override
  void didUpdateWidget(MapViewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.events != widget.events) {
      _updateMarkers();
    }
  }

  Future<void> _updateMarkers() async {
    if (!_isMapReady) return;

    final newMarkers = widget.events
        .where((event) => event.event.geoPoint != null)
        .map((event) {
          final position = LatLng(
            event.event.geoPoint!.latitude,
            event.event.geoPoint!.longitude,
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

    if (_markers.isNotEmpty) {
      final firstMarker = _markers.first;
      _controller.animateCamera(
        CameraUpdate.newLatLngZoom(firstMarker.position, 12),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.3,
      child: GoogleMap(
        key: const ValueKey('google_map'),
        initialCameraPosition: const CameraPosition(
          target: LatLng(37.7749, -122.4194), // San Francisco
          zoom: 12,
        ),
        markers: _markers,
        onMapCreated: (GoogleMapController controller) {
          _controller = controller;
          _isMapReady = true;
          _updateMarkers();
        },
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
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