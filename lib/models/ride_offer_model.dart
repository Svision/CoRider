import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:corider/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';

class RideOfferModel {
  String id;
  String driverId;
  String vehicleId;
  TimeOfDay? proposedStartTime;
  TimeOfDay? proposedBackTime;
  String? passengerId;
  List<int> proposedWeekdays;
  String driverLocationName;
  LatLng driverLocation;
  double price;
  String additionalDetails;
  final DateTime createdAt;

  RideOfferModel({
    String? id,
    required this.driverId,
    required this.vehicleId,
    required this.proposedStartTime,
    required this.proposedBackTime,
    this.passengerId,
    required this.proposedWeekdays,
    required this.driverLocationName,
    required this.driverLocation,
    required this.price,
    required this.additionalDetails,
  })  : id = id ?? const Uuid().v4(),
        createdAt = DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'driverId': driverId,
        'vehicleId': vehicleId,
        'proposedStartTime':
            '${proposedStartTime?.hour.toString()}:${proposedStartTime?.minute.toString()}',
        'passengerId': passengerId,
        'proposedBackTime':
            '${proposedBackTime?.hour.toString()} : ${proposedBackTime?.minute.toString()}',
        'proposedWeekdays': proposedWeekdays,
        'driverLocationName': driverLocationName,
        'driverLocation': driverLocation.toJson(),
        'price': price,
        'additionalDetails': additionalDetails,
      };

  factory RideOfferModel.fromJson(Map<String, dynamic> json) {
    final driverLocationList = List<double>.from(json['driverLocation']);
    return RideOfferModel(
      id: json['id'],
      driverId: json['driverId'],
      vehicleId: json['vehicleId'],
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
      passengerId: json['passengerId'],
      proposedWeekdays: List<int>.from(json['proposedWeekdays']),
      driverLocationName: json['driverLocationName'],
      driverLocation: LatLng(
        driverLocationList[0],
        driverLocationList[1],
      ),
      price: json['price'],
      additionalDetails: json['additionalDetails'],
    );
  }

  Future<String?> saveToFirestore(UserModel user) async {
    try {
      await FirebaseFirestore.instance
          .collection('companies')
          .doc(user.companyName)
          .collection('rideOffers')
          .doc(id)
          .set(toJson());
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.email)
          .update({
        'rideOffers': FieldValue.arrayUnion([id]),
      });
      return null;
    } on FirebaseException catch (e) {
      return e.message;
    }
  }
}
