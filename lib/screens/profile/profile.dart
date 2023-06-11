import 'package:corider/screens/login/user_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignOffButton extends StatelessWidget {
  final VoidCallback onPressed;

  const SignOffButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<UserState>(context).currentUser;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "User: ${currentUser?.email ?? 'Unknown'}",
          style: TextStyle(fontSize: 16),
        ),
        ElevatedButton(
          onPressed: onPressed,
          child: Text('Sign Off'),
        ),
      ],
    );
  }
}
