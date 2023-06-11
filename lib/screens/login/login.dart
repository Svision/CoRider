import 'package:corider/models/user_model.dart';
import 'package:corider/screens/login/user_state.dart';
import 'package:corider/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import '../dashboard.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  static bool isFirstTimeLoad = false;

  const LoginScreen({super.key});
  Duration get loginTime => const Duration(milliseconds: 1000);

  void _handleLogin(BuildContext context, LoginData data) {
    // TODO: Get user data from Firebase
    UserModel user = UserModel(
      email: data.name,
      name: 'User',
      age: 24,
    );
    Provider.of<UserState>(context, listen: false).setUser(user);
  }

  void _handleSignup(BuildContext context, SignupData data) {
    // TODO: Get user data from Firebase
    UserModel user = UserModel(
      email: data.name!,
      name: 'User',
      age: 24,
    );
    Provider.of<UserState>(context, listen: false).setUser(user);
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
      // logo: const AssetImage('assets/images/logo.png'),
      onLogin: (data) async {
        final err = await _authUser(data);
        if (err == null) {
          _handleLogin(context, data);
        } else {
          // Handle the error returned from _authUser
          return err;
        }
      },
      onSignup: (data) async {
        final err = await _signupUser(data);
        if (err == null) {
          _handleSignup(context, data);
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
    );
  }
}
