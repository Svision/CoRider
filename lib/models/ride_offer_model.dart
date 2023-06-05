import 'package:corider/models/user_model.dart';
import 'package:corider/models/vehicle_model.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RideOfferModel {
  final UserModel driver;
  final VehicleModel vehicle;
  final TimeOfDay proposedTime;
  final List<int> proposedWeekdays;
  final String driverLocationName;
  final LatLng driverLocation;
  final double price;
  final String additionalDetails;

  RideOfferModel({
    required this.driver,
    required this.vehicle,
    required this.proposedTime,
    required this.proposedWeekdays,
    required this.driverLocationName,
    required this.driverLocation,
    required this.price,
    required this.additionalDetails,
  });
}
