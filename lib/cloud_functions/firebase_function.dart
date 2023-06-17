import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:corider/models/user_model.dart';
import 'package:corider/models/vehicle_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_login/flutter_login.dart';

class FirebaseFunctions {
  static Future<VehicleModel> fetchVehicleFromFirebase(String email) async {
    final usersCollection = FirebaseFirestore.instance.collection("users");

    final userSnapshot = await usersCollection.doc(email).get();

    if (userSnapshot.exists) {
      final userData = userSnapshot.data();
      final vehicleData = userData!['vehicle'];
      if (vehicleData == null) {
        throw Exception("Vehicle not found");
      }
      final vehicleModel = VehicleModel.fromJson(vehicleData);
      return vehicleModel;
    } else {
      throw Exception("User not found");
    }
  }

  static Future<UserModel> fetchUserFromFirebase(String email) async {
    final usersCollection = FirebaseFirestore.instance.collection("users");

    final userSnapshot = await usersCollection.doc(email).get();

    if (userSnapshot.exists) {
      final userData = userSnapshot.data();
      final userModel = UserModel.fromJson(userData!);
      return userModel;
    } else {
      throw Exception("User not found");
    }
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
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: data.name!,
        password: data.password!,
      );

      final db = FirebaseFirestore.instance;
      final user = <String, dynamic>{
        'email': data.name,
        'firstName': data.additionalSignupData!['firstName'],
        'lastName': data.additionalSignupData!['lastName'],
        'createdAt': DateTime.now().toIso8601String(),
      };

      await db.collection("users").doc(user['email']).set(user).then((_) =>
          debugPrint('DocumentSnapshot added with ID: ${user['email']}'));

      // User added successfully
      String successMessage =
          'User ${userCredential.user} signed up successfully!';
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
}
