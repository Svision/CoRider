import 'package:corider/models/user_model.dart';
import 'package:corider/models/user_state.dart';
import 'package:corider/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import '../dashboard.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  static bool isFirstTimeLoad = false;

  const LoginScreen({super.key});
  Duration get loginTime => const Duration(milliseconds: 1000);

  Future<UserModel> _fetchUserFromFirebase(String email) async {
    final usersCollection = FirebaseFirestore.instance.collection("users");

    final docSnapshot = await usersCollection.doc(email).get();

    if (docSnapshot.exists) {
      final userData = docSnapshot.data();
      final userModel = UserModel.fromJson(userData!);
      return userModel;
    } else {
      throw Exception("User not found");
    }
  }

  Future<String?> _handleLogin(BuildContext context, String email) async {
    try {
      await _fetchUserFromFirebase(email).then((user) async {
        Provider.of<UserState>(context, listen: false).setUser(user);
      });
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> _authUser(LoginData data) async {
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
      return ('Error signing in: $e');
    }
  }

  Future<String?> _signupUser(SignupData data) async {
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

  Future<String?> _recoverPassword(String name) async {
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

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: "CoRider",
      userType: LoginUserType.email,
      savedEmail: "user@user.com", // TODO: Remove this line
      savedPassword: "123456", // TODO: Remove this line
      // logo: const AssetImage('assets/images/logo.png'),
      onLogin: (data) async {
        final err = await _authUser(data);
        if (err == null) {
          return await _handleLogin(context, data.name);
        } else {
          // Handle the error returned from _authUser
          return err;
        }
      },
      onSignup: (data) async {
        final err = await _signupUser(data);
        if (err == null) {
          return await _handleLogin(context, data.name!);
        } else {
          // Handle the error returned from _authUser
          return err;
        }
      },
      onSubmitAnimationCompleted: () {
        if (isFirstTimeLoad) {
          isFirstTimeLoad = false;
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => const OnboardingScreen(),
          ));
        } else {
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => const NavigationView(),
          ));
        }
      },
      userValidator: (value) => null,
      passwordValidator: (value) => null,
      onRecoverPassword: _recoverPassword,
      messages: LoginMessages(
        userHint: 'Company Email',
      ),
      // onConfirmSignup: (String key, LoginData loginData) async {
      //   bool isEmailVerified = false;
      //   try {
      //     await FirebaseAuth.instance.createUserWithEmailAndPassword(
      //       email: loginData.name,
      //       password: loginData.password,
      //     );

      //     // Send verification email
      //     await FirebaseAuth.instance.currentUser?.sendEmailVerification();

      //     // Wait for user to verify email
      //     await FirebaseAuth.instance.currentUser?.reload();
      //     isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
      //     if (isEmailVerified) {
      //       // User signed up successfully
      //       String successMessage =
      //           'User ${loginData.name} signed up successfully!';
      //       debugPrint(successMessage);
      //     } else {
      //       // Error occurred while signing up
      //       return 'Error signing up: Email not verified';
      //     }
      //     // Return null to indicate successful signup
      //     return null;
      //   } catch (e) {
      //     // Return the error message to display in the UI
      //     return 'Error signing up: $e';
      //   }
      // },
      // confirmSignupKeyboardType: TextInputType.number,
      loginAfterSignUp: true,
      additionalSignupFields: [
        UserFormField(
            keyName: "firstName",
            displayName: "First Name",
            fieldValidator: (value) =>
                value!.isEmpty ? 'First Name is required' : null),
        UserFormField(
            keyName: "lastName",
            displayName: "Last Name",
            fieldValidator: (value) =>
                value!.isEmpty ? 'Last Name is required' : null),
      ],
    );
  }
}
