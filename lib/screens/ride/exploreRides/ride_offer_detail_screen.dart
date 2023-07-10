import 'package:corider/cloud_functions/firebase_function.dart';
import 'package:corider/models/types/requested_offer_status.dart';
import 'package:corider/models/user_model.dart';
import 'package:corider/providers/user_state.dart';
import 'package:corider/screens/chat/chat.dart';
import 'package:corider/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:corider/models/ride_offer_model.dart';
import 'package:provider/provider.dart';

class RideOfferDetailScreen extends StatefulWidget {
  final UserState userState;
  final RideOfferModel rideOffer;
  final GlobalKey? refreshOffersKey;

  const RideOfferDetailScreen({Key? key, required this.userState, required this.rideOffer, this.refreshOffersKey})
      : super(key: key);
  @override
  RideOfferDetailScreenState createState() => RideOfferDetailScreenState();
}

class RideOfferDetailScreenState extends State<RideOfferDetailScreen> {
  bool isRequesting = false;
  UserModel? driverUser;

  void refreshOffers() {
    if (widget.refreshOffersKey is GlobalKey<RefreshIndicatorState>) {
      GlobalKey<RefreshIndicatorState> refreshOffersIndicatorKey =
          widget.refreshOffersKey as GlobalKey<RefreshIndicatorState>;
      refreshOffersIndicatorKey.currentState?.show();
    } else {
      debugPrint('widget.refreshOffersKey is not of type GlobalKey<RefreshIndicatorState>');
    }
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      isRequesting = true;
    });
    widget.userState.getStoredUserByEmail(widget.rideOffer.driverId).then((user) => {
          setState(() {
            driverUser = user;
            isRequesting = false;
          })
        });
  }

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
              'Price: \n${widget.rideOffer.price == 0.0 ? 'Free' : widget.rideOffer.price}',
              style: const TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Additional Details: \n${widget.rideOffer.additionalDetails}',
              style: const TextStyle(fontSize: 16.0),
            ),
            if (widget.rideOffer.driverId == currentUser.email)
              Column(
                children: [
                  const SizedBox(height: 8.0),
                  const Text(
                    'Requested Users:',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  const SizedBox(height: 8.0),
                  Column(
                    children: widget.rideOffer.requestedUserIds.entries.map((entry) {
                      String userId = entry.key;
                      RequestedOfferStatus status = entry.value;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(userId.split('@')[0]),
                          Row(
                            children: [Text('${describeEnum(status)}'), Utils.requestStatusToIcon(status)],
                          ),
                          ElevatedButton(
                            onPressed: () {
                              if (status != RequestedOfferStatus.ACCEPTED) {
                                setState(() {
                                  isRequesting = true;
                                });
                                widget.userState.currentUser!
                                    .acceptRideRequest(widget.rideOffer.id, userId)
                                    .then((err) => {
                                          setState(() {
                                            isRequesting = false;
                                          }),
                                          if (err == null)
                                            {
                                              setState(() {
                                                widget.rideOffer.requestedUserIds[userId] =
                                                    RequestedOfferStatus.ACCEPTED;
                                              }),
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Ride request accepted!'),
                                                  duration: Duration(seconds: 1),
                                                ),
                                              ),
                                            }
                                          else
                                            {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Error: $err'),
                                                  duration: const Duration(seconds: 2),
                                                ),
                                              ),
                                            }
                                        });
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Ride request already accepted!'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            child: const Icon(Icons.check),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              if (status != RequestedOfferStatus.REJECTED) {
                                setState(() {
                                  isRequesting = true;
                                });
                                widget.userState.currentUser!
                                    .rejectRideRequest(widget.rideOffer.id, userId)
                                    .then((err) => {
                                          setState(() {
                                            isRequesting = false;
                                          }),
                                          if (err == null)
                                            {
                                              setState(() {
                                                widget.rideOffer.requestedUserIds[userId] =
                                                    RequestedOfferStatus.REJECTED;
                                              }),
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Ride request rejected!'),
                                                  duration: Duration(seconds: 1),
                                                ),
                                              ),
                                            }
                                          else
                                            {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Error: $err'),
                                                  duration: const Duration(seconds: 2),
                                                ),
                                              ),
                                            }
                                        });
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Ride request already rejected!'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Icon(Icons.close),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            // Add more details as needed
            const SizedBox(height: 32.0),
            Center(
              child: !isRequesting
                  ? buildRideOfferActions(context, widget.userState, currentUser)
                  : const CircularProgressIndicator(),
            )
          ],
        ),
      ),
    );
  }

  Widget buildMyRideOfferActions(BuildContext context, UserState userState, UserModel currentUser) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          isRequesting = true;
        });
        FirebaseFunctions.deleteUserRideOfferByOfferId(currentUser, widget.rideOffer.id).then((value) => {
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
        refreshOffers();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
      ),
      child: const Text('Delete Ride'),
    );
  }

  Widget chatButton(UserModel currentUser) {
    return ElevatedButton(
      onPressed: () {
        setState(() {
          isRequesting = true;
        });
        currentUser.requestChatWithUser(widget.userState, driverUser!).then((chatRoom) => {
              setState(() {
                isRequesting = false;
              }),
              if (chatRoom != null)
                {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatScreen(
                        userState: widget.userState,
                        room: chatRoom,
                      ),
                    ),
                  )
                }
              else
                {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Chat request failed!"),
                      duration: Duration(seconds: 2),
                    ),
                  )
                }
            });
      },
      child: const Text('Chat'),
    );
  }

  Widget buildOtherRideOfferActions(BuildContext context, UserState userState, UserModel currentUser) {
    final requestedOfferStatus = widget.rideOffer.requestedUserIds[currentUser.email]!;
    return currentUser.requestedOfferIds.contains(widget.rideOffer.id)
        ? Column(
            children: [
              chatButton(currentUser),
              const SizedBox(height: 8.0),
              Text('Ride ${describeEnum(requestedOfferStatus)}!',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0,
                      color: Utils.requestStatusToColor(requestedOfferStatus))),
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
                    refreshOffers();
                  },
                  child: const Text('Withdraw Request')),
            ],
          )
        : Column(
            children: [
              chatButton(currentUser),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isRequesting = true;
                  });
                  currentUser.requestRide(userState, widget.rideOffer).then((err) => {
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
                  refreshOffers();
                },
                child: const Text('Request Ride'),
              ),
            ],
          );
  }

  Widget buildRideOfferActions(BuildContext context, UserState userState, UserModel currentUser) {
    return currentUser.email != widget.rideOffer.driverId
        ? buildOtherRideOfferActions(context, userState, currentUser)
        : buildMyRideOfferActions(context, userState, currentUser);
  }
}
