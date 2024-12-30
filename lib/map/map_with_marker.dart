import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapWithMarker extends StatefulWidget {
  const MapWithMarker({super.key});

  @override
  State<MapWithMarker> createState() => _MapWithMarkerState();
}

class _MapWithMarkerState extends State<MapWithMarker> {
  late GoogleMapController _mapController;
  final List<LatLng> _markerPositions = [];
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  double _totalDistance = 0.0;

  // Add a marker on the map
  void _addMarker(LatLng position) {
    if (_markerPositions.length >= 2) {
      // Clear previous markers and polylines if the user adds more than 2 points
      _markers.clear();
      _polylines.clear();
      _markerPositions.clear();
      _totalDistance = 0.0;
    }

    // Add the new marker
    _markerPositions.add(position);
    _markers.add(
      Marker(
        markerId: MarkerId(position.toString()),
        position: position,
        infoWindow: InfoWindow(title: 'Point ${_markerPositions.length}'),
      ),
    );

    // If there are two markers, calculate the distance and draw a line
    if (_markerPositions.length == 2) {
      _calculateDistance();
      _drawPolyline();
    }

    setState(() {});
  }

  // Calculate the distance between two markers
  void _calculateDistance() {
    if (_markerPositions.length < 2) return;

    final LatLng point1 = _markerPositions[0];
    final LatLng point2 = _markerPositions[1];
    const double earthRadius = 6371; // Earth's radius in kilometers

    final double dLat = _toRadians(point2.latitude - point1.latitude);
    final double dLng = _toRadians(point2.longitude - point1.longitude);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(point1.latitude)) *
            cos(_toRadians(point2.latitude)) *
            sin(dLng / 2) *
            sin(dLng / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    _totalDistance = earthRadius * c; // Distance in kilometers
  }

  // Draw a polyline between the markers
  void _drawPolyline() {
    _polylines.add(
      Polyline(
        polylineId: const PolylineId('line_between_points'),
        points: _markerPositions,
        color: Colors.red,
        width: 3,
      ),
    );
  }

  // Convert degrees to radians
  double _toRadians(double degree) => degree * pi / 180;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Distance Calculator Map'),
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target:
                  LatLng(26.8206, 30.8025), // Default position (e.g., Egypt)
              zoom: 6.0,
            ),
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
            markers: _markers,
            polylines: _polylines,
            onTap: _addMarker, // Add marker when user taps on the map
            myLocationEnabled: true,
          ),
          if (_totalDistance > 0)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Text(
                  'Distance: ${_totalDistance.toStringAsFixed(2)} km',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
