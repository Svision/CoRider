import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class LocationPickerMapScreen extends StatefulWidget {
  final LatLng initialLocation;

  LocationPickerMapScreen({required this.initialLocation});

  @override
  _LocationPickerMapScreenState createState() => _LocationPickerMapScreenState();
}

class _LocationPickerMapScreenState extends State<LocationPickerMapScreen> {
  GoogleMapController? _controller;
  LatLng? _selectedLocation;
  String _searchQuery = '';
  List<Location> _searchResults = [];

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
  }

  void _onMapTapped(LatLng location) {
    setState(() {
      _selectedLocation = location;
    });
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchQuery = '';
        _searchResults.clear();
      });
      return;
    }

    setState(() {
      _searchQuery = query;
    });

    try {
      List<Location> locations = await locationFromAddress(query);
      setState(() {
        _searchResults = locations;
      });
    } catch (e) {
      print('Error searching for location: $e');
    }
  }

  void _selectSearchResult(Location location) {
    setState(() {
      _selectedLocation = LatLng(location.latitude, location.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Location'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _searchLocation,
              decoration: InputDecoration(
                labelText: 'Search Location',
              ),
            ),
          ),
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: widget.initialLocation,
                zoom: 14.0,
              ),
              onTap: _onMapTapped,
              markers: _selectedLocation != null
                  ? {
                      Marker(
                        markerId: MarkerId('selectedLocation'),
                        position: _selectedLocation!,
                      ),
                    }
                  : {},
            ),
          ),
          if (_searchResults.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  Location location = _searchResults[index];
                  return ListTile(
                    title: Text(location.toString() ?? ''),
                    onTap: () {
                      _selectSearchResult(location);
                    },
                  );
                },
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Return the selected location to the previous screen
          Navigator.pop(context, _selectedLocation);
        },
        child: Icon(Icons.check),
      ),
    );
  }
}
