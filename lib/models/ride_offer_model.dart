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

  Map<String, dynamic> toJson() => {
        'driver': driver.toJson(),
        'vehicle': vehicle.toJson(),
        'proposedStartTime': proposedStartTime?.toString(),
        'proposedBackTime': proposedBackTime?.toString(),
        'proposedWeekdays': proposedWeekdays,
        'driverLocationName': driverLocationName,
        'driverLocation': driverLocation.toJson(),
        'price': price,
        'additionalDetails': additionalDetails,
      };

  factory RideOfferModel.fromJson(Map<String, dynamic> json) {
    return RideOfferModel(
      driver: UserModel.fromJson(json['driver']),
      vehicle: VehicleModel.fromJson(json['vehicle']),
      proposedStartTime: json['proposedStartTime'] != null
          ? TimeOfDay(
              hour: int.parse(json['proposedStartTime'].split(':')[0]),
              minute: int.parse(json['proposedStartTime'].split(':')[1]),
            )
          : null,
      proposedBackTime: json['proposedBackTime'] != null
          ? TimeOfDay(
              hour: int.parse(json['proposedBackTime'].split(':')[0]),
              minute: int.parse(json['proposedBackTime'].split(':')[1]),
            )
          : null,
      proposedWeekdays: List<int>.from(json['proposedWeekdays']),
      driverLocationName: json['driverLocationName'],
      driverLocation: LatLng(
        json['driverLocation']['latitude'],
        json['driverLocation']['longitude'],
      ),
      price: json['price'],
      additionalDetails: json['additionalDetails'],
    );
  }
}
