import 'package:corider/models/types/requested_offer_status.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';

class RideOfferModel {
  String id;
  String driverId;
  String vehicleId;
  TimeOfDay? proposedLeaveTime;
  TimeOfDay? proposedBackTime;
  Map<String, RequestedOfferStatus> requestedUserIds;
  List<int> proposedWeekdays;
  String driverLocationName;
  LatLng driverLocation;
  double price;
  String additionalDetails;
  final DateTime? createdAt;

  RideOfferModel({
    String? id,
    required this.createdAt,
    required this.driverId,
    required this.vehicleId,
    required this.proposedLeaveTime,
    required this.proposedBackTime,
    this.requestedUserIds = const {},
    required this.proposedWeekdays,
    required this.driverLocationName,
    required this.driverLocation,
    required this.price,
    required this.additionalDetails,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
        'id': id,
        'driverId': driverId,
        'vehicleId': vehicleId,
        'proposedLeaveTime': '${proposedLeaveTime?.hour.toString()}:${proposedLeaveTime?.minute.toString()}',
        'requestedUserIds': requestedUserIds.map((key, value) => MapEntry(key, value.index)),
        'proposedBackTime': '${proposedBackTime?.hour.toString()}:${proposedBackTime?.minute.toString()}',
        'proposedWeekdays': proposedWeekdays,
        'driverLocationName': driverLocationName,
        'driverLocation': {
          'latitude': driverLocation.latitude,
          'longitude': driverLocation.longitude,
        },
        'price': price,
        'additionalDetails': additionalDetails,
        'createdAt': createdAt!.toIso8601String(),
      };

  factory RideOfferModel.generateUnknown() {
    return RideOfferModel(
      createdAt: null,
      driverId: '',
      vehicleId: '',
      proposedLeaveTime: null,
      proposedBackTime: null,
      requestedUserIds: {},
      proposedWeekdays: [],
      driverLocationName: '',
      driverLocation: const LatLng(0, 0),
      price: 0,
      additionalDetails: '',
    );
  }

  factory RideOfferModel.fromJson(Map<String, dynamic> json) {
    return RideOfferModel(
      id: json['id'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      driverId: json['driverId'],
      vehicleId: json['vehicleId'],
      proposedLeaveTime: json['proposedLeaveTime'] != null
          ? TimeOfDay(
              hour: int.parse(json['proposedLeaveTime'].split(':')[0]),
              minute: int.parse(json['proposedLeaveTime'].split(':')[1]),
            )
          : null,
      proposedBackTime: json['proposedBackTime'] != null
          ? TimeOfDay(
              hour: int.parse(json['proposedBackTime'].split(':')[0]),
              minute: int.parse(json['proposedBackTime'].split(':')[1]),
            )
          : null,
      requestedUserIds: json['requestedUserIds'] != null
          ? (json['requestedUserIds'] as Map<String, dynamic>)
              .map((key, value) => MapEntry(key, RequestedOfferStatus.values[value]))
          : {},
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
