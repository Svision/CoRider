import 'package:corider/cloud_functions/firebase_function.dart';
import 'package:corider/models/user_model.dart';
import 'package:corider/providers/user_state.dart';
import 'package:flutter/material.dart';
import 'package:corider/models/ride_offer_model.dart';
import 'package:provider/provider.dart';

class RideOfferDetailScreen extends StatefulWidget {
  final RideOfferModel rideOffer;
  final GlobalKey? refreshOffersKey;

  const RideOfferDetailScreen({Key? key, required this.rideOffer, this.refreshOffersKey}) : super(key: key);
  @override
  RideOfferDetailScreenState createState() => RideOfferDetailScreenState();
}

class RideOfferDetailScreenState extends State<RideOfferDetailScreen> {
  bool isRequesting = false;

  @override
  Widget build(BuildContext context) {
    final userState = Provider.of<UserState>(context);
    final UserModel currentUser = userState.currentUser!;
    const weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ride Offer Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Driver Details:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Driver Id: ${widget.rideOffer.driverId}',
              style: const TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Ride Offer Details:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Proposed Leave Time: \n${widget.rideOffer.proposedLeaveTime!.format(context)}',
              style: const TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Proposed Back Time: \n${widget.rideOffer.proposedBackTime!.format(context)}',
              style: const TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Availibility: \n${widget.rideOffer.proposedWeekdays.map((i) => weekdays[i]).join(', ')}',
              style: const TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Driver Location Name: \n${widget.rideOffer.driverLocationName}',
              style: const TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Driver Location: \n(${widget.rideOffer.driverLocation.latitude}, ${widget.rideOffer.driverLocation.longitude})',
              style: const TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Price: \n${widget.rideOffer.price}',
              style: const TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Additional Details: \n${widget.rideOffer.additionalDetails}',
              style: const TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 8.0),
            Text(
              'PassengerIds: \n${widget.rideOffer.requestedUserIds.toString()}',
              style: const TextStyle(fontSize: 16.0),
            ),
            // Add more details as needed
            const SizedBox(height: 32.0),
            Center(
              child: !isRequesting
                  ? currentUser.email != widget.rideOffer.driverId
                      ? currentUser.requestedOfferIds.contains(widget.rideOffer.id)
                          ? Column(
                              children: [
                                const Text(
                                  'Ride requested!',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
                                ),
                                const SizedBox(height: 8.0),
                                ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        isRequesting = true;
                                      });
                                      currentUser.withdrawRequestRide(userState, widget.rideOffer.id).then((err) => {
                                            setState(() {
                                              isRequesting = false;
                                            }),
                                            if (err == null)
                                              {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(
                                                    content: Text('Ride request withdrawn!'),
                                                    duration: Duration(seconds: 1),
                                                  ),
                                                ),
                                                Navigator.of(context).pop(),
                                              }
                                            else
                                              {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text("Ride request withdraw failed! $err"),
                                                    duration: const Duration(seconds: 2),
                                                  ),
                                                )
                                              },
                                          });
                                      if (widget.refreshOffersKey is GlobalKey<RefreshIndicatorState>) {
                                        GlobalKey<RefreshIndicatorState> refreshOffersIndicatorKey =
                                            widget.refreshOffersKey as GlobalKey<RefreshIndicatorState>;
                                        refreshOffersIndicatorKey.currentState?.show();
                                      } else {
                                        debugPrint(
                                            'widget.refreshOffersKey is not of type GlobalKey<RefreshIndicatorState>');
                                      }
                                    },
                                    child: const Text('Withdraw Request')),
                              ],
                            )
                          : ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isRequesting = true;
                                });
                                currentUser.requestRide(userState, widget.rideOffer.id).then((err) => {
                                      setState(() {
                                        isRequesting = false;
                                      }),
                                      if (err == null)
                                        {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Ride request sent!'),
                                              duration: Duration(seconds: 1),
                                            ),
                                          ),
                                          Navigator.of(context).pop(),
                                        }
                                      else
                                        {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text("Ride request failed! $err"),
                                              duration: const Duration(seconds: 2),
                                            ),
                                          )
                                        }
                                    });
                                if (widget.refreshOffersKey is GlobalKey<RefreshIndicatorState>) {
                                  GlobalKey<RefreshIndicatorState> refreshOffersIndicatorKey =
                                      widget.refreshOffersKey as GlobalKey<RefreshIndicatorState>;
                                  refreshOffersIndicatorKey.currentState?.show();
                                } else {
                                  debugPrint('widget.refreshOffersKey is not of type GlobalKey<RefreshIndicatorState>');
                                }
                              },
                              child: const Text('Request Ride'),
                            )
                      : ElevatedButton(
                          onPressed: () {
                            setState(() {
                              isRequesting = true;
                            });
                            FirebaseFunctions.deleteUserRideOfferByOfferId(currentUser, widget.rideOffer.id)
                                .then((value) => {
                                      setState(() {
                                        isRequesting = false;
                                      }),
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Ride offer deleted!'),
                                          duration: Duration(seconds: 1),
                                        ),
                                      )
                                    });
                            Navigator.of(context).pop();
                            if (widget.refreshOffersKey is GlobalKey<RefreshIndicatorState>) {
                              GlobalKey<RefreshIndicatorState> refreshOffersIndicatorKey =
                                  widget.refreshOffersKey as GlobalKey<RefreshIndicatorState>;
                              refreshOffersIndicatorKey.currentState?.show();
                            } else {
                              debugPrint('widget.refreshOffersKey is not of type GlobalKey<RefreshIndicatorState>');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text('Delete Ride'),
                        )
                  : const CircularProgressIndicator(),
            )
          ],
        ),
      ),
    );
  }
}
