import 'package:flutter/material.dart';

class SignOffButton extends StatelessWidget {
  final VoidCallback onPressed;

  const SignOffButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: const Text('Sign Off'),
    );
  }
}
