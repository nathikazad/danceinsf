import 'package:flutter/material.dart';
import 'package:dance_sf/models/event_model.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:go_router/go_router.dart';
import 'package:collection/collection.dart';

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
  late MapController controller;
  final List<GeoPoint> _markers = [];
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    controller = MapController.withPosition(
      initPosition: GeoPoint(
        latitude: 37.7749,
        longitude: -122.4194,
      ),
    );
  }

  @override
  void didUpdateWidget(MapViewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.events != widget.events) {
      _updateMarkers();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _clearMarkers() async {
    if (!_isMapReady) return;
    try {
      for (final marker in _markers) {
        try {
          await controller.removeMarker(marker);
        } catch (e) {
          print('Error removing marker: $e');
        }
      }
      _markers.clear();
    } catch (e) {
      print('Error in _clearMarkers: $e');
    }
  }

  Future<void> _updateMarkers() async {
    if (!_isMapReady) return;
    
    final newMarkers = widget.events
        .where((event) => event.event.geoPoint != null)
        .map((event) => GeoPoint(
              latitude: event.event.geoPoint!.latitude,
              longitude: event.event.geoPoint!.longitude,
            ))
        .toList();

    final markersChanged = _markers.length != newMarkers.length ||
        !ListEquality().equals(_markers, newMarkers);

    if (markersChanged) {
      await _clearMarkers();
      _markers.addAll(newMarkers);
      await _addEventMarkers();
    }
  }

  Future<void> _addEventMarkers() async {
    if (!_isMapReady) return;
    
    for (final event in widget.events) {
      if (event.event.geoPoint != null) {
        final geoPoint = GeoPoint(
          latitude: event.event.geoPoint!.latitude,
          longitude: event.event.geoPoint!.longitude,
        );
        await controller.addMarker(
          geoPoint,
          markerIcon: MarkerIcon(
            icon: Icon(
              Icons.location_on,
              color: Colors.orange,
              size: 48,
            ),
          ),
        );
      }
    }

    if (_markers.isNotEmpty) {
      await controller.moveTo(_markers.first);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.3,
      child: OSMFlutter(
        key: const ValueKey('osm_map'),
        controller: controller,
        osmOption: OSMOption(
          zoomOption: const ZoomOption(
            initZoom: 12,
            minZoomLevel: 3,
            maxZoomLevel: 19,
            stepZoom: 1.0,
          ),
          showDefaultInfoWindow: true,
        ),
        onMapIsReady: (isReady) {
          if (isReady && !_isMapReady) {
            _isMapReady = true;
            _addEventMarkers();
          }
        },
        onGeoPointClicked: (geoPoint) {
          final eventIndex = _markers.indexWhere(
            (marker) => marker.latitude == geoPoint.latitude && marker.longitude == geoPoint.longitude,
          );
          if (eventIndex != -1) {
            final event = widget.events[eventIndex];
            context.push('/event/${event.eventInstanceId}', extra: event);
          }
        },
      ),
    );
  }
} 