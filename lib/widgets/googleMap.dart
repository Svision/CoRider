import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapWidget extends StatefulWidget {
  const MapWidget({Key? key}) : super(key: key);

  @override
  State<MapWidget> createState() => MapWidgetState();
}

class MapWidgetState extends State<MapWidget> {
  late GoogleMapController mapController;
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    _checkLocationPermissions();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  Future<void> _checkLocationPermissions() async {
    try {
      LocationData? currentLocation; // Changed LocationData to nullable type
      var location = Location();

      final hasPermission = await location.hasPermission();
      if (hasPermission == PermissionStatus.granted) {
        final serviceEnabled = await location.serviceEnabled();
        if (serviceEnabled) {
          location.onLocationChanged.listen((LocationData newLocation) {
            setState(() {
              currentLocation = newLocation;
              _currentLocation = LatLng(
                currentLocation!.latitude!,
                currentLocation!.longitude!,
              );
            });
          });
        } else {
          debugPrint('Location service is disabled.');
        }
      } else {
        debugPrint('Location permission is not granted.');
      }
    } catch (e) {
      debugPrint('Error while checking location permissions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentLocation == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Stack(
              children: [
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  mapType: MapType.normal,
                  initialCameraPosition: CameraPosition(
                    target: _currentLocation!,
                    zoom: 16.0,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                ),
              ],
            ),
    );
  }
}
