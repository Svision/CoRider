import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class CreateRideOfferPage extends StatefulWidget {
  const CreateRideOfferPage({Key? key}) : super(key: key);

  @override
  _CreateRideOfferPageState createState() => _CreateRideOfferPageState();
}

class _CreateRideOfferPageState extends State<CreateRideOfferPage> {
  TimeOfDay proposedTime = TimeOfDay.now();
  List<int> proposedWeekdays = [];
  String driverLocationName = '';
  LatLng? driverLocation;
  double price = 0.0;
  String additionalDetails = '';

  void _showTimePicker() async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: proposedTime,
    );

    if (selectedTime != null) {
      setState(() {
        proposedTime = selectedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Ride Offer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              ElevatedButton(
                onPressed: _showTimePicker,
                child: Text('Proposed Time: ${proposedTime.format(context)}'),
              ),
              SizedBox(height: 16.0),
              CheckboxListTile(
                title: const Text('Weekdays'),
                value: proposedWeekdays.contains(DateTime.now().weekday),
                onChanged: (bool? value) {
                  setState(() {
                    final weekday = DateTime.now().weekday;
                    if (value == true) {
                      proposedWeekdays.add(weekday);
                    } else {
                      proposedWeekdays.remove(weekday);
                    }
                  });
                },
              ),
              SizedBox(height: 16.0),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Driver Location Name',
                ),
                onChanged: (value) {
                  setState(() {
                    driverLocationName = value;
                  });
                },
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  // TODO: Implement map selection logic
                },
                child: Text('Select Driver Location'),
              ),
              SizedBox(height: 16.0),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Price',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,1,2}')),
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
