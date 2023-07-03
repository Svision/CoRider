import 'package:corider/cloud_functions/firebase_function.dart';
import 'package:corider/models/ride_offer_model.dart';
import 'package:corider/models/types/requested_offer_status.dart';
import 'package:corider/models/vehicle_model.dart';
import 'package:corider/providers/user_state.dart';
import 'package:corider/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_chat_types/flutter_chat_types.dart';

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
  List<String> chatRoomIds;

  UserModel({
    this.createdAt,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.profileImage,
    this.vehicle,
    this.myOfferIds = const [],
    this.requestedOfferIds = const [],
    this.chatRoomIds = const [],
  }) : companyName = email.split("@")[1];

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
        email: json['email'],
        firstName: json['firstName'],
        lastName: json['lastName'],
        profileImage: json['profileImage'],
        createdAt: DateTime.parse(json['createdAt']),
        vehicle: json['vehicle'] != null ? VehicleModel.fromJson(json['vehicle']) : null,
        myOfferIds: json['myOfferIds'] != null ? List<String>.from(json['myOfferIds']) : [],
        requestedOfferIds: json['requestedOfferIds'] != null ? List<String>.from(json['requestedOfferIds']) : [],
        chatRoomIds: json['chatRoomIds'] != null ? List<String>.from(json['chatRoomIds']) : []);
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
        "chatRoomIds": chatRoomIds,
      };

  String get fullName => '$firstName $lastName';

  User toChatUser() => User(
        id: email,
        firstName: firstName,
        lastName: lastName,
        imageUrl: profileImage,
      );

  String messageChannelId() => '$email-channel';

  //#region User Intents
  Future<String?> createRideOffer(UserState userState, RideOfferModel offer) async {
    final err = await FirebaseFunctions.saveRideOfferByUser(this, offer);
    if (err == null) {
      myOfferIds.add(offer.id);
      userState.setCurrentUser(this);
      return null;
    } else {
      return err;
    }
  }

  Future<String?> saveProfileImage(UserState userState, String imageUrl) async {
    final err = await FirebaseFunctions.saveProfileImageByUser(this, imageUrl);
    if (err == null) {
      profileImage = imageUrl;
      userState.setCurrentUser(this);
      return null;
    } else {
      return err;
    }
  }

  Future<String?> saveVehicle(UserState userState, VehicleModel vehicle) async {
    final err = await FirebaseFunctions.saveVehicleByUser(this, vehicle);
    if (err == null) {
      this.vehicle = vehicle;
      userState.setCurrentUser(this);
      return null;
    } else {
      return err;
    }
  }

  Future<String?> deleteVehicle(UserState userState) async {
    final err = await FirebaseFunctions.deleteVehicleByUser(this);
    if (err == null) {
      vehicle = null;
      userState.setCurrentUser(this);
      return null;
    } else {
      return err;
    }
  }

  Future<String?> requestRide(UserState userState, RideOfferModel rideOffer) async {
    final err = await FirebaseFunctions.requestRideByRideOffer(this, rideOffer);
    if (err == null) {
      requestedOfferIds.add(rideOffer.id);
      userState.setCurrentUser(this);
      return null;
    } else {
      return err;
    }
  }

  Future<String?> withdrawRequestRide(UserState userState, String rideOfferId) async {
    final err = await FirebaseFunctions.removeRideRequestByRideOfferId(this, rideOfferId);
    if (err == null) {
      requestedOfferIds.remove(rideOfferId);
      userState.setCurrentUser(this);
      return null;
    } else {
      return err;
    }
  }

  Future<types.Room?> requestChatWithUser(UserState userState, UserModel otherUser) async {
    try {
      String? roomId = Utils.getRoomIdByTwoUser(email, otherUser.email);
      if (!chatRoomIds.contains(roomId)) {
        roomId = await FirebaseFunctions.requestChatWithUser(userState, this, otherUser);
      }
      if (roomId != null) {
        if (!chatRoomIds.contains(roomId)) {
          chatRoomIds.add(roomId);
        }
        return await userState.getStoredChatRoomByRoomId(roomId, forceUpdate: true);
      } else {
        return null;
      }
    } catch (e) {
      debugPrint('requestChatWithUser: $e');
      return null;
    }
  }

  Future<String?> acceptRideRequest(String rideOfferId, String userId) async {
    final err = await FirebaseFunctions.changeRideRequestStatusWithUserId(
        this, rideOfferId, userId, RequestedOfferStatus.ACCEPTED);
    if (err == null) {
      return null;
    } else {
      return err;
    }
  }

  Future<String?> rejectRideRequest(String rideOfferId, String userId) async {
    final err = await FirebaseFunctions.changeRideRequestStatusWithUserId(
        this, rideOfferId, userId, RequestedOfferStatus.REJECTED);
    if (err == null) {
      return null;
    } else {
      return err;
    }
  }
  //#endregion
}
