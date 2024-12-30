import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPolygonScreen extends StatefulWidget {
  const MapPolygonScreen({super.key});

  @override
  State<MapPolygonScreen> createState() => _MapPolygonScreenState();
}

class _MapPolygonScreenState extends State<MapPolygonScreen> {
  late GoogleMapController _mapController;
  bool _isLoading = true;
  LatLng _initialPosition = const LatLng(26.8206, 30.8025);
  Circle _circle = const Circle(circleId: CircleId('dottedCircle'));
  Polyline _polyline = const Polyline(polylineId: PolylineId('dottedPolyLine'));
  final Set<Marker> _markers = {};

  late LatLng _currentDragPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    debugPrint("Map created");
  }

  Future<void> _getCurrentLocation() async {
    debugPrint("Fetching current location...");
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      debugPrint("Location services are disabled.");
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        debugPrint("Location permissions are denied.");
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint(
          "Location permissions are permanently denied. Cannot request permissions.");
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
      _isLoading = false;
    });

    debugPrint("Initial position: $_initialPosition");
    _polygonWithMarker(position: _initialPosition, title: 'Current Location');
  }

  void _polygonWithMarker({required LatLng position, String? title}) {
    final points = List.generate(360, (index) {
      return calculateNewCoordinates(
        lat: position.latitude,
        lon: position.longitude,
        radiusInMeters: 250,
        angleInDegrees: index.toDouble(),
      );
    });

    setState(() {
      _circle = Circle(
        circleId: const CircleId('dottedCircle'),
        center: position,
        radius: 250,
        fillColor: Colors.orangeAccent.withOpacity(.25),
        strokeWidth: 0,
      );

      _polyline = Polyline(
        polylineId: const PolylineId('dottedPolyLine'),
        points: points,
        color: Colors.deepOrange,
        width: 2,
        patterns: [
          PatternItem.dash(20),
          PatternItem.gap(20),
        ],
      );

      _markers.clear();
      _markers.add(Marker(
        markerId: MarkerId(position.toString()),
        position: position,
        infoWindow: InfoWindow(title: title ?? 'New Marker'),
      ));
    });

    debugPrint("Circle center: ${_circle.center}, radius: ${_circle.radius}");
    debugPrint("Polyline points count: ${_polyline.points.length}");
    debugPrint("Marker count: ${_markers.length}");
  }

  LatLng calculateNewCoordinates(
      {required double lat,
      required double lon,
      required double radiusInMeters,
      required double angleInDegrees}) {
    double angleInRadians = angleInDegrees * pi / 180;

    // Constants for Earth's radius and degrees per meter
    const earthRadiusInMeters = 6371000; // Approximate Earth radius in meters
    const degreesPerMeterLatitude = 1 / earthRadiusInMeters * 180 / pi;
    final degreesPerMeterLongitude =
        1 / (earthRadiusInMeters * cos(lat * pi / 180)) * 180 / pi;

    // Calculate the change in latitude and longitude in degrees
    double degreesOfLatitude = radiusInMeters * degreesPerMeterLatitude;
    double degreesOfLongitude = radiusInMeters * degreesPerMeterLongitude;

    // Calculate the new latitude and longitude
    double newLat = lat + degreesOfLatitude * sin(angleInRadians);
    double newLon = lon + degreesOfLongitude * cos(angleInRadians);

    return LatLng(newLat, newLon);
  }

  void _convertScreenToLatLng(Offset screenPosition) async {
    final LatLng position = await _mapController.getLatLng(ScreenCoordinate(
      x: screenPosition.dx.toInt(),
      y: screenPosition.dy.toInt(),
    ));

    setState(() {
      _currentDragPosition = position;
      _polygonWithMarker(
        position: _currentDragPosition,
        title: 'Dragged Location',
      );
    });

    debugPrint("Converted screen position to LatLng: $_currentDragPosition");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Map with Polygon'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GestureDetector(
              onPanStart: (details) {
                final RenderBox box = context.findRenderObject() as RenderBox;
                final Offset localPosition =
                    box.globalToLocal(details.globalPosition);

                _convertScreenToLatLng(localPosition);
              },
              onPanUpdate: (details) {
                final RenderBox box = context.findRenderObject() as RenderBox;
                final Offset localPosition =
                    box.globalToLocal(details.globalPosition);

                _convertScreenToLatLng(localPosition);
              },
              child: GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: CameraPosition(
                  target: _initialPosition,
                  zoom: 14,
                ),
                markers: _markers,
                polylines: {_polyline},
                circles: {_circle},
                //  scrollGesturesEnabled: false,
              ),
            ),
    );
  }
}
