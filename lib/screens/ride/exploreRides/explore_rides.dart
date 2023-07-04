import 'package:corider/models/ride_offer_model.dart';
import 'package:corider/models/user_model.dart';
import 'package:corider/providers/user_state.dart';
import 'package:corider/screens/ride/createRideOffer/create_ride_offer_screen.dart';
import 'package:corider/screens/ride/exploreRides/ride_offer_detail_screen.dart';
import 'package:corider/screens/ride/exploreRides/rides_filter/filter_sort_enum.dart';
import 'package:corider/screens/ride/exploreRides/rides_filter/rides_filter.dart';
import 'package:flutter/material.dart';
import 'package:corider/widgets/offer_ride_card.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class ExploreRidesScreen extends StatefulWidget {
  final UserState userState;
  const ExploreRidesScreen({Key? key, required this.userState}) : super(key: key);

  @override
  State<ExploreRidesScreen> createState() => _ExploreRidesScreenState();
}

class _ExploreRidesScreenState extends State<ExploreRidesScreen> {
  int _selectedIndex = 0;
  List<RideOfferModel> offers = [];

  final LatLng _center = const LatLng(43.7720940, -79.3453741);
  final Set<Marker> _markers = {};
  GlobalKey<RefreshIndicatorState> refreshOffersIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    if (widget.userState.storedOffers.isEmpty) {
      _handleRefresh(widget.userState.currentUser!);
    } else {
      offers = [];
    }
  }

  void _addMarkers() {
    for (int i = 0; i < offers.length; i++) {
      LatLng location = offers[i].driverLocation; // Replace with real location
      Marker marker = Marker(
        markerId: MarkerId(i.toString()),
        position: location,
        infoWindow: InfoWindow(title: offers[i].driverId),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RideOfferDetailScreen(
                userState: widget.userState,
                rideOffer: offers[i],
              ),
            ),
          );
        },
      );
      _markers.add(marker);
    }
  }

  void _onMapCreated(GoogleMapController controller) {}

  Future<void> _handleRefresh(UserModel user) async {
    try {
      await widget.userState.fetchAllOffers();
      setState(() {
        offers = widget.userState.storedOffers.values.toList();
      });
      _addMarkers();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final userState = Provider.of<UserState>(context);
    final UserModel currentUser = userState.currentUser!;
    offers = userState.storedOffers.values.toList();
    _addMarkers();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rides'),
        leading: IconButton(
          onPressed: () {
            setState(() {
              _selectedIndex = _selectedIndex == 0 ? 1 : 0;
            });
          },
          icon: Icon(
            _selectedIndex == 0 ? Icons.map : Icons.list,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => CreateRideOfferScreen(
                          refreshOffersIndicatorKey: refreshOffersIndicatorKey,
                        )),
              );
            },
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          RefreshIndicator(
              key: refreshOffersIndicatorKey,
              onRefresh: () => _handleRefresh(currentUser),
              child: RideOfferList(
                userState: userState,
                offers: offers,
                refreshOffersIndicatorKey: refreshOffersIndicatorKey,
              )),
          CustomCustomMapWidget(
            markers: _markers,
            initialCameraPosition: CameraPosition(target: _center, zoom: 12.0),
            onMapCreated: _onMapCreated,
          ),
        ],
      ),
    );
  }
}

class RideOfferList extends StatefulWidget {
  final UserState userState;
  final List<RideOfferModel> offers;
  final GlobalKey<RefreshIndicatorState> refreshOffersIndicatorKey;
  const RideOfferList({
    Key? key,
    required this.userState,
    required this.offers,
    required this.refreshOffersIndicatorKey,
  }) : super(key: key);

  @override
  State<RideOfferList> createState() => _RideOfferListState();
}

class _RideOfferListState extends State<RideOfferList> {
  RideOfferFilter? _selectedFilter;
  RideOfferSortBy? _selectedSort;

  void _handleFilterChanged(RideOfferFilter value) {
    if (_selectedFilter == value) {
      return;
    }
    setState(() {
      _selectedFilter = value;
      debugPrint(_selectedFilter.toString());
      // Apply the filter logic based on the selected value
      // Update the filtered offers accordingly
    });
  }

  void _handleSortChanged(RideOfferSortBy value) {
    if (_selectedSort == value) {
      return;
    }
    setState(() {
      _selectedSort = value;
      debugPrint(_selectedSort.toString());
      // Apply the sort logic based on the selected value
      // Update the sorted offers accordingly
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.offers.isEmpty
        ? // If there are no offers, show refresh button
        Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'No offers found',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                IconButton(
                  onPressed: () {
                    widget.refreshOffersIndicatorKey.currentState!.show();
                  },
                  icon: const Icon(
                    Icons.refresh,
                    color: Colors.blue,
                  ),
                  iconSize: 48,
                ),
              ],
            ),
          )
        : ListView.builder(
            itemCount: widget.offers.length + 2,
            itemBuilder: (context, index) {
              // header
              if (index == 0) {
                return RidesFilter(
                  onFilterChanged: _handleFilterChanged,
                  onSortChanged: _handleSortChanged,
                );
              }
              // body
              index -= 1;
              if (index < widget.offers.length) {
                if (_selectedFilter == RideOfferFilter.byMe &&
                        widget.offers[index].driverId != widget.userState.currentUser!.email ||
                    _selectedFilter == RideOfferFilter.others &&
                        widget.offers[index].driverId == widget.userState.currentUser!.email) {
                  return Container();
                }
                return RideOfferCard(
                    userState: widget.userState,
                    rideOffer: widget.offers[index],
                    refreshOffersIndicatorKey: widget.refreshOffersIndicatorKey);
              }
              // footer
              return Container(
                padding: const EdgeInsets.all(16.0),
                alignment: Alignment.center,
                child: const Text(
                  'END\nPull down to refresh',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              );
            },
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
  State<CustomCustomMapWidget> createState() => _CustomCustomMapWidgetState();
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
