import 'package:corider/screens/onboardingScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import '../dashboard.dart';

const users = const {
  'user': 'user',
  '': '',
};

class LoginScreen extends StatelessWidget {
  static bool isFirstTimeLoad = true;
  Duration get loginTime => Duration(milliseconds: 1000);

  Future<String?> _authUser(LoginData data) {
    debugPrint('Name: ${data.name}, Password: ${data.password}');
    return Future.delayed(loginTime).then((_) {
      if (!users.containsKey(data.name)) {
        return 'User not exists';
      }
      if (users[data.name] != data.password) {
        return 'Password does not match';
      }
      return null;
    });
  }

  Future<String?> _signupUser(SignupData data) {
    debugPrint('Signup Name: ${data.name}, Password: ${data.password}');
    return Future.delayed(loginTime).then((_) {
      return null;
    });
  }

  Future<String?> _recoverPassword(String name) {
    debugPrint('Name: $name');
    return Future.delayed(loginTime).then((_) {
      if (!users.containsKey(name)) {
        return 'User not exists';
      }
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      title: "CoRider",
      // logo: const AssetImage('assets/images/logo.png'),
      onLogin: _authUser,
      onSignup: _signupUser,
      onSubmitAnimationCompleted: () {
        if (isFirstTimeLoad) {
          isFirstTimeLoad = false;
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => OnboardingScreen(),
          ));
        }
        else {
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