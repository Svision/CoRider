import 'package:corider/cloud_functions/firebase_function.dart';
import 'package:corider/providers/user_state.dart';
import 'package:corider/screens/login/custom_route.dart';
import 'package:corider/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import '../root.dart';

class LoginScreen extends StatelessWidget {
  static const routeName = '/login';
  final UserState userState;
  static bool isFirstTimeLoad = false;

  const LoginScreen({super.key, required this.userState});
  Duration get loginTime => const Duration(milliseconds: 1000);

  Future<String?> _handleLogin(BuildContext context, String email) async {
    try {
      await FirebaseFunctions.fetchUserByEmail(email).then((user) async {
        await userState.setCurrentUser(user!);
        await userState.loadData();
      });
      return null;
    } catch (e) {
      return e.toString();
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
        final err = await FirebaseFunctions.authUser(data);
        if (err == null) {
          return await _handleLogin(context, data.name);
        } else {
          // Handle the error returned from _authUser
          return err;
        }
      },
      onSignup: (data) async {
        final err = await FirebaseFunctions.signupUser(data);
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
          Navigator.of(context).pushAndRemoveUntil(
              FadePageRoute(
                builder: (context) => OnboardingScreen(
                  userState: userState,
                ),
              ),
              (route) => false);
        } else {
          Navigator.of(context).pushAndRemoveUntil(
              FadePageRoute(
                builder: (context) => RootNavigationView(
                  userState: userState,
                ),
              ),
              (route) => false);
        }
      },
      userValidator: (value) => null,
      passwordValidator: (value) => null,
      onRecoverPassword: FirebaseFunctions.recoverPassword,
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
            fieldValidator: (value) => value!.isEmpty ? 'First Name is required' : null),
        UserFormField(
            keyName: "lastName",
            displayName: "Last Name",
            fieldValidator: (value) => value!.isEmpty ? 'Last Name is required' : null),
      ],
    );
  }
}
