import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:corider/models/ride_offer_model.dart';
import 'package:corider/models/vehicle_model.dart';

class UserModel {
  final String email;
  String firstName;
  String lastName;
  String? profileImage;
  final DateTime createdAt;
  VehicleModel? vehicle;
  List<RideOfferModel> rideOffers;

  UserModel({
    required this.email,
    required this.firstName,
    required this.lastName,
    this.profileImage,
    required this.createdAt,
    this.vehicle,
    this.rideOffers = const [],
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
        email: json['email'],
        firstName: json['firstName'],
        lastName: json['lastName'],
        profileImage: json['profileImage'],
        createdAt: DateTime.parse(json['createdAt']),
        vehicle: json['vehicle'] != null
            ? VehicleModel.fromJson(json['vehicle'])
            : null,
        rideOffers: json['vehicle'] != null
            ? List<RideOfferModel>.from(
                json['rideOffers'].map((e) => RideOfferModel.fromJson(e)))
            : []);
  }

  Map<String, dynamic> toJson() => {
        "email": email,
        "firstName": firstName,
        "lastName": lastName,
        "profileImage": profileImage,
        "createdAt": createdAt.toIso8601String(),
        "vehicle": vehicle?.toJson(),
        "rideOffers": rideOffers.map((e) => e.toJson()).toList(),
      };

  setProfileImage(String? imageUrl) {
    profileImage = imageUrl;
  }

  String get fullName => '$firstName $lastName';

  setVehicle(VehicleModel? vehicle) {
    this.vehicle = vehicle;
  }

  Future<String?> deleteVehicle() async {
    try {
      vehicle = null;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(email)
          .update({'vehicle': FieldValue.delete()});
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
