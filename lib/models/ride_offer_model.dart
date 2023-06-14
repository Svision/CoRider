import 'package:corider/models/user_model.dart';
import 'package:corider/models/vehicle_model.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RideOfferModel {
  UserModel driver;
  VehicleModel vehicle;
  TimeOfDay? proposedStartTime;
  TimeOfDay? proposedBackTime;
  List<int> proposedWeekdays;
  String driverLocationName;
  LatLng driverLocation;
  double price;
  String additionalDetails;

  RideOfferModel({
    required this.driver,
    required this.vehicle,
    this.proposedStartTime,
    this.proposedBackTime,
    required this.proposedWeekdays,
    required this.driverLocationName,
    required this.driverLocation,
    required this.price,
    required this.additionalDetails,
  });
}
