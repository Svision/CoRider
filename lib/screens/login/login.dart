import 'package:corider/cloud_functions/firebase_function.dart';
import 'package:corider/providers/user_state.dart';
import 'package:corider/screens/login/custom_route.dart';
import 'package:corider/screens/login/onboarding_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_login/flutter_login.dart';
import '../root.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

AndroidNotificationChannel? channel;

FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;
late FirebaseMessaging messaging;

void notificationTapBackground(NotificationResponse notificationResponse) {
  debugPrint('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    debugPrint('notification action tapped with input: ${notificationResponse.input}');
  }
}

class LoginScreen extends StatelessWidget {
  static const routeName = '/login';
  final UserState userState;
  static bool isFirstTimeLoad = false;

  const LoginScreen({super.key, required this.userState});
  Duration get loginTime => const Duration(milliseconds: 1000);

  Future<void> registerNotification() async {
    await Firebase.initializeApp();
    messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    final fcmToken = await messaging.getToken();
    debugPrint('fcmToken: $fcmToken');

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const initSettings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'), iOS: DarwinInitializationSettings());

    await flutterLocalNotificationsPlugin!.initialize(initSettings,
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
        onDidReceiveNotificationResponse: notificationTapBackground);
    await messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<String?> _handleLogin(BuildContext context, String email) async {
    try {
      await FirebaseFunctions.fetchUserByEmail(email).then((user) async {
        await userState.setCurrentUser(user!);
        await userState.loadData();
      });
      await registerNotification();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsFlutterBinding.ensureInitialized();
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
