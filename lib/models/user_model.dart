import 'package:corider/cloud_functions/firebase_function.dart';
import 'package:corider/models/ride_offer_model.dart';
import 'package:corider/models/vehicle_model.dart';
import 'package:corider/providers/user_state.dart';

class UserModel {
  final String email;
  String firstName;
  String lastName;
  late final String companyName;
  String? profileImage;
  final DateTime? createdAt;
  VehicleModel? vehicle;
  List<String> myOfferIds;
  List<String> requestedOfferIds;

  UserModel({
    DateTime? createdAt,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.profileImage,
    this.vehicle,
    this.myOfferIds = const [],
    this.requestedOfferIds = const [],
  })  : companyName = email.split("@")[1],
        createdAt = DateTime.now();

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
        myOfferIds: json['myOfferIds'] != null
            ? List<String>.from(json['myOfferIds'])
            : [],
        requestedOfferIds: json['requestedOfferIds'] != null
            ? List<String>.from(json['requestedOfferIds'])
            : []);
  }

  Map<String, dynamic> toJson() => {
        "email": email,
        "firstName": firstName,
        "lastName": lastName,
        "profileImage": profileImage,
        "createdAt": createdAt!.toIso8601String(),
        "vehicle": vehicle?.toJson(),
        "myOfferIds": myOfferIds,
        "requestedOfferIds": requestedOfferIds,
      };

  String get fullName => '$firstName $lastName';

  //#region User Intents
  Future<String?> createRideOffer(
      UserState userState, RideOfferModel offer) async {
    final err = await FirebaseFunctions.saveRideOfferByUser(this, offer);
    if (err == null) {
      myOfferIds.add(offer.id);
      userState.setUser(this);
      return null;
    } else {
      return err;
    }
  }

  Future<String?> saveProfileImage(UserState userState, String imageUrl) async {
    final err = await FirebaseFunctions.saveProfileImageByUser(this, imageUrl);
    if (err == null) {
      profileImage = imageUrl;
      userState.setUser(this);
      return null;
    } else {
      return err;
    }
  }

  Future<String?> saveVehicle(UserState userState, VehicleModel vehicle) async {
    final err = await FirebaseFunctions.saveVehicleByUser(this, vehicle);
    if (err == null) {
      this.vehicle = vehicle;
      userState.setUser(this);
      return null;
    } else {
      return err;
    }
  }

  Future<String?> deleteVehicle(UserState userState) async {
    final err = await FirebaseFunctions.deleteVehicleByUser(this);
    if (err == null) {
      vehicle = null;
      userState.setUser(this);
      return null;
    } else {
      return err;
    }
  }

  Future<String?> requestRide(UserState userState, String rideOfferId) async {
    final err =
        await FirebaseFunctions.requestRideByRideOfferId(this, rideOfferId);
    if (err == null) {
      requestedOfferIds.add(rideOfferId);
      userState.setUser(this);
      return null;
    } else {
      return err;
    }
  }

  Future<String?> withdrawRequestRide(
      UserState userState, String rideOfferId) async {
    final err = await FirebaseFunctions.removeRideRequestByRideOfferId(
        this, rideOfferId);
    if (err == null) {
      requestedOfferIds.remove(rideOfferId);
      userState.setUser(this);
      return null;
    } else {
      return err;
    }
  }
  //#endregion
}
