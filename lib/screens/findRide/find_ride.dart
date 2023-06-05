import 'package:flutter/material.dart';
import 'package:corider/widgets/offer_ride_card.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RideOfferList extends StatefulWidget {
  const RideOfferList({super.key});

  @override
  _RideOfferListState createState() => _RideOfferListState();
}

class _RideOfferListState extends State<RideOfferList> {
  int _selectedIndex = 0;

  final List<String> rideOffers = [
    'Offer 1',
    'Offer 2',
    'Offer 3',
    'Offer 4',
    'Offer 5',
    'Offer 6',
    'Offer 7',
    'Offer 8',
    'Offer 9',
    'Offer 10',
  ];

  final LatLng _center = const LatLng(43.7720940, -79.3453741);
  final Set<Marker> _markers = {};

  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _addMarkers();
  }

  void _addMarkers() {
List<LatLng> mockLocations = [
      const LatLng(43.7728065, -79.3337945),
      const LatLng(43.7728065 + 0.045, -79.3337945 + 0.045),
      const LatLng(43.7728065 - 0.045, -79.3337945 - 0.045),
      const LatLng(43.7728065 + 0.09, -79.3337945 + 0.09),
      const LatLng(43.7728065 - 0.09, -79.3337945 - 0.09),
      const LatLng(43.7728065 + 0.135, -79.3337945 + 0.135),
      const LatLng(43.7728065 - 0.135, -79.3337945 - 0.135),
      const LatLng(43.7728065 + 0.18, -79.3337945 + 0.18),
      const LatLng(43.7728065 - 0.18, -79.3337945 - 0.18),
      const LatLng(43.7728065 + 0.225, -79.3337945 + 0.225),
    ];

    for (int i = 0; i < rideOffers.length; i++) {
      LatLng location = mockLocations[i]; // Replace with real location
      Marker marker = Marker(
        markerId: MarkerId(i.toString()),
        position: location,
        infoWindow: InfoWindow(title: 'Offer ${i + 1}'),
      );
      _markers.add(marker);
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ride Offers'),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          ListView.builder(
            itemCount: rideOffers.length,
            itemBuilder: (context, index) {
              return RideOfferCard(rideOffer: rideOffers[index]);
            },
          ),
          CustomCustomMapWidget(
            markers: _markers,
            initialCameraPosition: CameraPosition(target: _center, zoom: 12.0),
            onMapCreated: _onMapCreated,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'List View',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map View',
          ),
        ],
      ),
    );
  }
}

class CustomCustomMapWidget extends StatefulWidget {
  final Set<Marker> markers;
  final CameraPosition initialCameraPosition;
  final void Function(GoogleMapController) onMapCreated;

  const CustomCustomMapWidget({
    required this.markers,
    required this.initialCameraPosition,
    required this.onMapCreated,
    Key? key,
  }) : super(key: key);

  @override
  _CustomCustomMapWidgetState createState() => _CustomCustomMapWidgetState();
}

class _CustomCustomMapWidgetState extends State<CustomCustomMapWidget> {
  late GoogleMapController mapController;
  late CameraPosition cameraPosition;

  @override
  void initState() {
    super.initState();
    cameraPosition = widget.initialCameraPosition;
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: widget.onMapCreated,
      mapType: MapType.normal,
      initialCameraPosition: cameraPosition,
      markers: widget.markers,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
    );
  }
}
