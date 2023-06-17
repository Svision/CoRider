import 'package:corider/cloud_functions/firebase_function.dart';
import 'package:corider/models/ride_offer_model.dart';
import 'package:corider/models/user_model.dart';
import 'package:corider/models/user_state.dart';
import 'package:corider/models/vehicle_model.dart';
import 'package:corider/screens/Ride/offerRide/address_search_screen.dart';
import 'package:corider/screens/profile/add_vehicle_screen.dart';
import 'package:corider/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

final List<String> weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

class CreateRideOfferPage extends StatefulWidget {
  const CreateRideOfferPage({Key? key}) : super(key: key);

  @override
  _CreateRideOfferPageState createState() => _CreateRideOfferPageState();
}

class _CreateRideOfferPageState extends State<CreateRideOfferPage> {
  TimeOfDay proposedStartTime = const TimeOfDay(hour: 8, minute: 30);
  TimeOfDay proposedBackTime = const TimeOfDay(hour: 17, minute: 00);
  List<int> proposedWeekdays = [1, 2, 3, 4, 5];
  String? driverLocationName;
  LatLng? driverLocation;
  double price = 0.0;
  VehicleModel? vehicle;
  String additionalDetails = '';
  bool isSubmitting = false;

  void _showTimePicker(bool forStart) async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: forStart ? proposedStartTime : proposedBackTime,
    );

    if (selectedTime != null) {
      setState(() {
        if (forStart) {
          proposedStartTime = selectedTime;
        } else {
          proposedBackTime = selectedTime;
        }
      });
    }
  }

  Future<Tuple2<String, LatLng>?> selectDriverLocation() async {
    // Launch the map screen to select a location
    Tuple2<String, LatLng>? text2location = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddressSearchScreen()),
    );

    // Handle the selected location
    if (text2location != null) {
      // Update the driver location based on the selected location
      return text2location;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final userState = Provider.of<UserState>(context);
    final currentUser = userState.currentUser;
    try {
      FirebaseFunctions.fetchVehicleFromFirebase(currentUser!.email)
          .then((vehicle) {
        setState(() {
          this.vehicle = vehicle;
        });
      });
    } catch (e) {
      debugPrint(e.toString());
      setState(() {
        vehicle = VehicleModel();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Ride Offer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  const Text('Start:'),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showTimePicker(true),
                      child: Text(proposedStartTime.format(context)),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  const Text('Back:'),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _showTimePicker(false),
                      child: Text(proposedBackTime.format(context)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Row(
                children: [
                  for (int i = 0; i < 7; i++)
                    Expanded(
                      child: Column(
                        children: [
                          Text(weekdays[i]),
                          Checkbox(
                            value: proposedWeekdays.contains(i),
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  proposedWeekdays.add(i);
                                  debugPrint("Selected: ${weekdays[i]}");
                                } else {
                                  if (proposedWeekdays.length == 1) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                            'At least one day must be selected',
                                          ),
                                          duration: Duration(seconds: 1)),
                                    );
                                  } else {
                                    proposedWeekdays.remove(i);
                                    debugPrint("Unselected: ${weekdays[i]}");
                                  }
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16.0),
              driverLocationName == null
                  ? ElevatedButton(
                      onPressed: () {
                        selectDriverLocation().then((selectedLocation) {
                          setState(() {
                            driverLocationName =
                                selectedLocation?.item1 ?? driverLocationName;
                            driverLocation =
                                selectedLocation?.item2 ?? driverLocation;
                            debugPrint(
                                'Selected location: $driverLocationName, $driverLocation');
                          });
                        });
                      },
                      child: const Text('Select your Location'),
                    )
                  : Row(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: Text(driverLocationName!),
                        ),
                        Expanded(
                            child: ElevatedButton(
                          onPressed: () {
                            selectDriverLocation().then((selectedLocation) {
                              setState(() {
                                driverLocationName = selectedLocation?.item1 ??
                                    driverLocationName;
                                driverLocation =
                                    selectedLocation?.item2 ?? driverLocation;
                                debugPrint(
                                    'Selected location: $driverLocationName, $driverLocation');
                              });
                            });
                          },
                          child: const Text('Modify'),
                        ))
                      ],
                    ),
              const SizedBox(height: 16.0),
              if (vehicle == null)
                const CircularProgressIndicator()
              else if (vehicle!.fullName == VehicleModel().fullName)
                ElevatedButton(
                  child: const Text('Add Vehicle'),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AddVehiclePage(
                              vehicle: currentUser!.vehicle,
                            )),
                  ),
                )
              else
                Row(
                  children: [
                    Text('Vehicle Used: ${vehicle!.fullName}'),
                    const SizedBox(width: 8.0),
                    Container(
                      width: 16,
                      height: 16,
                      color: Utils.getColorFromValue(vehicle!.color!),
                      margin: const EdgeInsets.only(right: 8),
                    ),
                  ],
                ),
              const SizedBox(height: 16.0),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Price',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                onChanged: (value) {
                  setState(() {
                    price = double.tryParse(value) ?? 0.0;
                  });
                },
                // Display the formatted price in the text field
                initialValue: price != null
                    ? NumberFormat.currency().format(price)
                    : null,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Additional Details',
                ),
                onChanged: (value) {
                  setState(() {
                    additionalDetails = value;
                  });
                },
              ),
              const SizedBox(height: 16.0),
              isSubmitting
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          isSubmitting = true;
                        });
                        if (driverLocationName == null ||
                            driverLocation == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select your location'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                          setState(() {
                            isSubmitting = false;
                          });
                          return;
                        }
                        if (vehicle == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select your vehicle'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                          setState(() {
                            isSubmitting = false;
                          });
                          return;
                        }
                        final rideOffer = RideOfferModel(
                          driverId: currentUser!.email,
                          proposedStartTime: proposedStartTime,
                          proposedBackTime: proposedBackTime,
                          proposedWeekdays: proposedWeekdays,
                          driverLocationName: driverLocationName!,
                          driverLocation: driverLocation!,
                          vehicle: vehicle!,
                          price: price,
                          additionalDetails: additionalDetails,
                        );
                        await rideOffer.saveToFirestore(currentUser.email);
                        setState(() {
                          isSubmitting = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Ride offer created!'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                        Navigator.pop(context);
                      },
                      child: const Text('Create Ride Offer'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
