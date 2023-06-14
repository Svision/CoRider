import 'package:corider/screens/Ride/offerRide/location_picker_map_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

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
  String driverLocationName = '';
  LatLng? driverLocation;
  double price = 0.0;
  String additionalDetails = '';

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

  @override
  Widget build(BuildContext context) {
    void selectDriverLocation() async {
      LocationData? currentLocation;
      var location = Location();

      // Check if location services are enabled
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          // Location services are not enabled, handle accordingly
          return;
        }
      }

      // Check if the app has permission to access location
      PermissionStatus permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          // Location permission not granted, handle accordingly
          return;
        }
      }

      // Get the current location
      currentLocation = await location.getLocation();

      // Launch the map screen to select a location
      LatLng? selectedLocation = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LocationPickerMapScreen(
            initialLocation:
                LatLng(currentLocation!.latitude!, currentLocation!.longitude!),
          ),
        ),
      );

      // Handle the selected location
      if (selectedLocation != null) {
        // Update the driver location based on the selected location
        setState(() {
          driverLocation = selectedLocation;
        });
      }
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
              ElevatedButton(
                onPressed: () {
                  selectDriverLocation();
                },
                child: const Text('Select your Location'),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Price',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,1}')),
                ],
                onChanged: (value) {
                  setState(() {
                    price = double.parse(value) ?? 0.0;
                  });
                },
              ),
              SizedBox(height: 16.0),
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
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  // TODO: Implement saving the ride offer logic
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
