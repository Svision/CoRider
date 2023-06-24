import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:corider/models/ride_offer_model.dart';
import 'package:corider/models/types/requested_offer_status.dart';
import 'package:corider/models/user_model.dart';
import 'package:corider/models/vehicle_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/foundation.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class FirebaseFunctions {
  static Future<List<types.Room>> fetchChatRooms(UserModel user) async {
    List<types.Room> chatRooms = [];
    try {
      final chatRoomsCollection =
          FirebaseFirestore.instance.collection('companies').doc(user.companyName).collection("chatRooms");
      final chatRoomsSnapshot = await chatRoomsCollection.where('userIds', arrayContains: user.email).get();
      if (chatRoomsSnapshot.docs.isNotEmpty) {
        chatRooms = chatRoomsSnapshot.docs.map((room) => types.Room.fromJson(room.data())).toList();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return chatRooms;
  }

  static Future<RideOfferModel?> fetchRideOfferById(UserModel user, String offerId) async {
    try {
      final offerDoc = await FirebaseFirestore.instance
          .collection("companies")
          .doc(user.companyName)
          .collection("rideOffers")
          .doc(offerId)
          .get();
      if (offerDoc.exists) {
        final offer = RideOfferModel.fromJson(offerDoc.data()!);
        return offer;
      } else {
        debugPrint("Offer not found");
        return null;
      }
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  static Future<List<RideOfferModel>> fetchUserOffersbyUser(UserModel user) async {
    try {
      final offersCollection = FirebaseFirestore.instance
          .collection("companies")
          .doc(user.companyName)
          .collection("rideOffers")
          .where("driverId", isEqualTo: user.email);

      final offersSnapshot = await offersCollection.get();

      if (offersSnapshot.docs.isNotEmpty) {
        final offers = offersSnapshot.docs.map((offer) => RideOfferModel.fromJson(offer.data())).toList();
        return offers;
      } else {
        return [];
      }
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  static Future<String?> getProfileImageUrlByUser(UserModel user) async {
    try {
      final storage = firebase_storage.FirebaseStorage.instance;
      final storageRef = storage.ref().child('profile_images/${user.email}.jpg');
      return await storageRef.getDownloadURL();
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  static Future<String?> uploadProfileImageByUser(UserModel user, File imageFile) async {
    try {
      final storage = firebase_storage.FirebaseStorage.instance;
      final storageRef = storage.ref().child('profile_images/${user.email}.jpg');
      // Upload the image file to Firebase Storage
      await storageRef.putFile(imageFile);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  static Future<String?> saveProfileImageByUser(UserModel user, String profileImageUrl) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.email).update({
        'profileImage': profileImageUrl,
      });
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  static Future<String?> saveRideOfferByUser(UserModel user, RideOfferModel offer) async {
    try {
      await FirebaseFirestore.instance
          .collection('companies')
          .doc(user.companyName)
          .collection('rideOffers')
          .doc(offer.id)
          .set(offer.toJson());
      await FirebaseFirestore.instance.collection('users').doc(user.email).update({
        'rideOffers': FieldValue.arrayUnion([offer.id]),
      });
      return null;
    } on FirebaseException catch (e) {
      return e.message;
    }
  }

  static Future<String?> requestRideByRideOfferId(UserModel user, String rideOfferId) async {
    try {
      await FirebaseFirestore.instance
          .collection('companies')
          .doc(user.companyName)
          .collection('rideOffers')
          .doc(rideOfferId)
          .set({
        'requestedUserIds': {user.email: RequestedOfferStatus.PENDING.index},
      }, SetOptions(merge: true));
      await FirebaseFirestore.instance.collection('users').doc(user.email).update({
        'requestedOfferIds': FieldValue.arrayUnion([rideOfferId]),
      });
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  static Future<String?> removeRideRequestByRideOfferId(UserModel user, String rideOfferId) async {
    try {
      // Order is critical here
      // Because rideOffer might be deleted before user removes request
      await FirebaseFirestore.instance.collection('users').doc(user.email).update({
        'requestedOfferIds': FieldValue.arrayRemove([rideOfferId]),
      });
      await FirebaseFirestore.instance
          .collection('companies')
          .doc(user.companyName)
          .collection('rideOffers')
          .doc(rideOfferId)
          .set({
        'requestedUserIds': {user.email: FieldValue.delete()},
      }, SetOptions(merge: true));
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  static Future<String?> deleteVehicleByUser(UserModel user) async {
    try {
      user.vehicle = null;
      await FirebaseFirestore.instance.collection('users').doc(user.email).update({'vehicle': FieldValue.delete()});
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  static Future<String?> saveVehicleByUser(UserModel user, VehicleModel vehicle) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.email).update({
        'vehicle': vehicle.toJson(),
      });
      return null;
    } on FirebaseException catch (e) {
      return e.message;
    }
  }

  static Future<String?> fetchUserProfileImageByEmail(String email) async {
    try {
      final usersCollection = FirebaseFirestore.instance.collection("users");

      final userSnapshot = await usersCollection.doc(email).get();

      if (userSnapshot.exists) {
        final userData = userSnapshot.data();
        final profileImage = userData!['profileImage'];
        return profileImage;
      } else {
        debugPrint("User not found");
        return null;
      }
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  static Future<String?> deleteUserRideOfferByOfferId(UserModel user, String offerId) async {
    try {
      final offersCollection =
          FirebaseFirestore.instance.collection("companies").doc(user.companyName).collection("rideOffers");
      offersCollection.doc(offerId).delete();

      await FirebaseFirestore.instance.collection('users').doc(user.email).update({
        'rideOffers': FieldValue.arrayRemove([offerId]),
      });
      return null;
    } catch (e) {
      debugPrint(e.toString());
      return e.toString();
    }
  }

  static Future<List<RideOfferModel>> fetchAllOffersbyUser(UserModel user) async {
    try {
      final offersCollection =
          FirebaseFirestore.instance.collection("companies").doc(user.companyName).collection("rideOffers");

      final offersSnapshot = await offersCollection.get();
      debugPrint(offersSnapshot.docs.first.data().toString());

      final offers = offersSnapshot.docs.map((e) => RideOfferModel.fromJson(e.data())).toList();

      return offers;
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  static Future<VehicleModel?> fetchUserVehicleByEmail(String email) async {
    VehicleModel? vehicleModel;
    try {
      final usersCollection = FirebaseFirestore.instance.collection("users");

      final userSnapshot = await usersCollection.doc(email).get();

      if (userSnapshot.exists) {
        final userData = userSnapshot.data();
        final vehicleData = userData!['vehicle'];
        if (vehicleData == null) {
          debugPrint("Vehicle not found");
        } else {
          vehicleModel = VehicleModel.fromJson(vehicleData);
        }
      } else {
        debugPrint("User not found");
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return vehicleModel;
  }

  static Future<UserModel?> fetchUserByEmail(String email) async {
    UserModel? userModel;
    try {
      final usersCollection = FirebaseFirestore.instance.collection("users");

      final userSnapshot = await usersCollection.doc(email).get();

      if (userSnapshot.exists) {
        final userData = userSnapshot.data();
        userModel = UserModel.fromJson(userData!);
      } else {
        debugPrint("User not found");
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return userModel;
  }

  static Future<String?> authUser(LoginData data) async {
    debugPrint('Name: ${data.name}, Password: ${data.password}');
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: data.name,
        password: data.password,
      );
      // User signed in successfully
      String successMessage = 'User ${data.name} signed in successfully!';
      debugPrint(successMessage);
      return null;
    } catch (e) {
      // Error occurred while signing in
      return 'Error signing in: $e';
    }
  }

  static Future<String?> signupUser(SignupData data) async {
    debugPrint('Signup Name: ${data.name}, Password: ${data.password}');
    try {
      await Firebase.initializeApp(); // Initialize Firebase
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: data.name!,
        password: data.password!,
      );

      final db = FirebaseFirestore.instance;
      final user = UserModel(
          email: data.name!,
          firstName: data.additionalSignupData!['firstName']!,
          lastName: data.additionalSignupData!['lastName']!);
      final userJson = user.toJson();

      await db
          .collection("users")
          .doc(user.email)
          .set(userJson)
          .then((_) => debugPrint('DocumentSnapshot added with ID: ${user.email}'));

      // User added successfully
      String successMessage = 'User ${userCredential.user} signed up successfully!';
      debugPrint(successMessage);
      return null;
    } catch (e) {
      // Error occurred while adding user
      return ('Error adding user: $e');
    }
  }

  static Future<String?> recoverPassword(String name) async {
    debugPrint('Name: $name');
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: name,
      );
      // Password reset email sent successfully
      String successMessage = 'Password reset email sent to $name!';
      debugPrint(successMessage);
      return null;
    } catch (e) {
      // Error occurred while sending password reset email
      return ('Error sending password reset email: $e');
    }
  }

  static Future<String?> deleteUserAccount(UserModel user) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(user.email).delete();
      await FirebaseAuth.instance.currentUser!.delete();

      try {
        // Delete the user's profile image from Firebase Storage
        final storage = firebase_storage.FirebaseStorage.instance;
        final storageRef = storage.ref().child('profile_images/${user.email}.jpg');
        await storageRef.delete();
      } catch (e) {
        debugPrint(e.toString());
      }

      debugPrint('Deleting offer created by user ${user.email} from ${user.companyName}');
      // Delete all ride offers created by the user
      final rideOffersCollections =
          FirebaseFirestore.instance.collection('companies').doc(user.companyName).collection('rideOffers');
      final rideOffersQuerySnapshot = await rideOffersCollections.where('driverId', isEqualTo: user.email).get();
      debugPrint('Deleting ${rideOffersQuerySnapshot.docs.length} ride offers created by ${user.email}');
      for (final rideOfferSnapshot in rideOffersQuerySnapshot.docs) {
        await rideOfferSnapshot.reference.delete();
      }
      return null;
    } catch (e) {
      debugPrint(e.toString());
      return e.toString();
    }
  }
}
