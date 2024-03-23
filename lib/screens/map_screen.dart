import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  Marker? _deliveryMarker;
  CameraPosition? _initialCameraPosition;
  Position? _currentPosition;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  void _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      forceAndroidLocationManager: true,
    );
    setState(() {
      _currentPosition = position;
      _initialCameraPosition = CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 15,
      );
      _deliveryMarker = Marker(
        markerId: const MarkerId('delivery'),
        position: LatLng(position.latitude, position.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: 'Delivery Boy'),
      );
      _isLoading = false;
    });
  }

  void _updateLocation() async {
    Position newPosition =
        await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = newPosition;
      _deliveryMarker = _deliveryMarker!.copyWith(
        positionParam: LatLng(newPosition.latitude, newPosition.longitude),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              title: const Text('Delivery Tracking'),
            ),
            body: _currentPosition == null
                ? const Center(child: Text('NULLLLLL'))
                : GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition: _initialCameraPosition!,
                    markers: {_deliveryMarker!},
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                    },
                  ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                _updateLocation();
              },
              tooltip: 'Refresh Location',
              child: const Icon(Icons.refresh),
            ),
          );
  }
}
