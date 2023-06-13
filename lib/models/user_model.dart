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
      createdAt: json['createdAt'].toDate(),
      vehicle: json['vehicle'] != null
          ? VehicleModel.fromJson(json['vehicle'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'profileImage': profileImage,
      'createdAt': createdAt,
    };
  }

  setProfileImage(String? imageUrl) {
    profileImage = imageUrl;
  }

  String get fullName => '$firstName $lastName';

  setVehicle(VehicleModel vehicle) {
    this.vehicle = vehicle;
  }
}
