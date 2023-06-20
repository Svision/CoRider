import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:corider/models/vehicle_model.dart';

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
