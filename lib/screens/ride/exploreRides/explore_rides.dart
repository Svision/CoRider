import 'package:corider/models/ride_offer_model.dart';
import 'package:corider/models/user_model.dart';
import 'package:corider/providers/user_state.dart';
import 'package:corider/screens/ride/createRideOffer/create_ride_offer_screen.dart';
import 'package:corider/screens/ride/exploreRides/ride_offer_detail_screen.dart';
import 'package:corider/screens/ride/exploreRides/rides_filter/filter_sort_enum.dart';
import 'package:corider/screens/ride/exploreRides/rides_filter/rides_filter.dart';
import 'package:flutter/material.dart';
import 'package:corider/widgets/offer_ride_card.dart';
import 'package:geolocator/geolocator.dart';
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
  List<RideOfferCard>? rideOfferCards;

  LatLng? currentLocation;
  final Set<Marker> _markers = {};
  GlobalKey<RefreshIndicatorState> refreshOffersIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    currentLocation = widget.userState.currentLocation;
    if (widget.userState.storedOffers.isEmpty) {
      _handleRefresh(widget.userState.currentUser!);
    } else {
      offers = widget.userState.storedOffers.values.toList();
      rideOfferCards = offers
          .map((offer) => RideOfferCard(
                userState: widget.userState,
                rideOffer: offer,
                currentLocation: currentLocation,
                refreshOffersIndicatorKey: refreshOffersIndicatorKey,
              ))
          .toList();
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
      currentLocation = await widget.userState.getCurrentLocation();
      setState(() {
        offers = widget.userState.storedOffers.values.toList();
        rideOfferCards = offers
            .map((offer) => RideOfferCard(
                  userState: widget.userState,
                  rideOffer: offer,
                  currentLocation: currentLocation,
                  refreshOffersIndicatorKey: refreshOffersIndicatorKey,
                ))
            .toList();
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
      body: rideOfferCards == null
          ? const Center(child: CircularProgressIndicator())
          : IndexedStack(
              index: _selectedIndex,
              children: [
                RefreshIndicator(
                    key: refreshOffersIndicatorKey,
                    onRefresh: () => _handleRefresh(currentUser),
                    child: RideOfferList(
                      userState: userState,
                      rideOfferCards: rideOfferCards!,
                      refreshOffersIndicatorKey: refreshOffersIndicatorKey,
                      currentLocation: currentLocation,
                    )),
                CustomCustomMapWidget(
                  markers: _markers,
                  initialCameraPosition: CameraPosition(
                      target: currentLocation ?? const LatLng(43.7720940, -79.3453741),
                      zoom: currentLocation != null ? 12.0 : 20.0),
                  onMapCreated: _onMapCreated,
                ),
              ],
            ),
    );
  }
}

class RideOfferList extends StatefulWidget {
  final UserState userState;
  final List<RideOfferCard> rideOfferCards;
  final GlobalKey<RefreshIndicatorState> refreshOffersIndicatorKey;
  final LatLng? currentLocation;
  const RideOfferList({
    Key? key,
    required this.userState,
    required this.rideOfferCards,
    required this.refreshOffersIndicatorKey,
    required this.currentLocation,
  }) : super(key: key);

  @override
  State<RideOfferList> createState() => _RideOfferListState();
}

class _RideOfferListState extends State<RideOfferList> {
  RideOfferFilter? _selectedFilter;
  RideOfferSortBy? _selectedSort;

  late List<RideOfferCard> displayOffers;

  void _handleFilterChanged(RideOfferFilter value) {
    if (_selectedFilter == value) {
      return;
    }
    setState(() {
      _selectedFilter = value;
      debugPrint(_selectedFilter.toString());
    });
  }

  void _handleSortChanged(RideOfferSortBy value) {
    if (_selectedSort == value) {
      return;
    }
    setState(() {
      _selectedSort = value;
    });
    switch (value) {
      case RideOfferSortBy.distance:
        _sortOffersByDistance();
        break;
      default:
        _rebuildOffers(List.from(widget.rideOfferCards));
        break;
    }
  }

  void _sortOffersByDistance() {
    if (widget.currentLocation == null) {
      return;
    }
    List<RideOfferCard> sortedOffers = List.from(widget.rideOfferCards);
    sortedOffers.sort((a, b) {
      double distanceA = Geolocator.distanceBetween(widget.currentLocation!.latitude, widget.currentLocation!.longitude,
          a.rideOffer.driverLocation.latitude, a.rideOffer.driverLocation.longitude);
      double distanceB = Geolocator.distanceBetween(widget.currentLocation!.latitude, widget.currentLocation!.longitude,
          b.rideOffer.driverLocation.latitude, b.rideOffer.driverLocation.longitude);
      return distanceA.compareTo(distanceB);
    });
    _rebuildOffers(sortedOffers);
  }

  void _rebuildOffers(List<RideOfferCard> offers) {
    setState(() {
      displayOffers = [];
      Future.delayed(const Duration(milliseconds: 50), () {
        setState(() {
          displayOffers = offers;
        });
      });
    });
  }

  @override
  void initState() {
    super.initState();
    displayOffers = List.from(widget.rideOfferCards);
  }

  @override
  Widget build(BuildContext context) {
    return widget.rideOfferCards.isEmpty
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
        : Column(
            children: [
              RidesFilter(
                onFilterChanged: _handleFilterChanged,
                onSortChanged: _handleSortChanged,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: displayOffers.length + 1,
                  itemBuilder: (context, index) {
                    if (index < displayOffers.length) {
                      if (_selectedFilter == RideOfferFilter.byMe &&
                              displayOffers[index].rideOffer.driverId != widget.userState.currentUser!.email ||
                          _selectedFilter == RideOfferFilter.others &&
                              displayOffers[index].rideOffer.driverId == widget.userState.currentUser!.email) {
                        return Container();
                      }
                      return displayOffers[index];
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
                ),
              )
            ],
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
