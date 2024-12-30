import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PolygonMapTry extends StatefulWidget {
  const PolygonMapTry({super.key});

  @override
  State<PolygonMapTry> createState() => _PolygonMapTryState();
}

class _PolygonMapTryState extends State<PolygonMapTry> {
  late GoogleMapController mapController;
  bool _isLoading = true;
  LatLng _initialPosition = const LatLng(26.8206, 30.8025);
  Circle _circle = const Circle(circleId: CircleId('dottedCircle'));
  Polyline _polyline = const Polyline(polylineId: PolylineId('dottedPolyLine'));
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
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
    _createPolygon(center: _initialPosition);
    _addMarker(position: _initialPosition, title: 'Current Location');
  }

  void _createPolygon({required LatLng center}) {
    _circle = Circle(
      circleId: const CircleId('dottedCircle'),
      center: center,
      radius: 250,
      strokeWidth: 0,
      fillColor: Colors.orangeAccent.withOpacity(.25),
    );

    _polyline = Polyline(
      polylineId: const PolylineId('dottedCircle'),
      color: Colors.deepOrange,
      width: 2,
      patterns: [
        PatternItem.dash(20),
        PatternItem.gap(20),
      ],
      points: List<LatLng>.generate(
        360,
        (index) {
          return calculateNewCoordinates(center.latitude, center.longitude, 250,
              double.parse(index.toString()));
        },
      ),
    );

    setState(() {});
  }

  LatLng calculateNewCoordinates(
      double lat, double lon, double radiusInMeters, double angleInDegrees) {
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

  void _addMarker({required LatLng position, String? title}) {
    final markerId = MarkerId(position.toString());
    setState(() {
      _markers.add(Marker(
        markerId: markerId,
        position: position,
        infoWindow: InfoWindow(title: title ?? 'New Marker'),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Map with Polygon'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              onMapCreated: _onMapCreated,
              polylines: {_polyline},
              circles: {_circle},
              markers: _markers,
              // onTap: (LatLng position) {
              //   _createPolygon(center: position);
              // },
              // onLongPress: (LatLng position) {
              //   _addMarker(
              //     position: position,
              //   );
              // },
              initialCameraPosition: CameraPosition(
                target: _initialPosition,
                zoom: 15.0,
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
    );
  }
}
