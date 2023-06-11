import 'package:corider/screens/login/user_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignOffButton extends StatelessWidget {
  final VoidCallback onPressed;

  const SignOffButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final userState = Provider.of<UserState>(context);
    final currentUser = userState.currentUser;

    void handleSignOff() {
      userState.signOff();
      onPressed();
    }

    void handleDeleteAccount(BuildContext context) async {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        showDialog(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: Text('Confirm Delete'),
              content: Text(
                  'Are you sure you want to delete your account? This action cannot be undone.'),
              actions: [
                TextButton(
                  onPressed: () async {
                    Navigator.of(dialogContext).pop(); // Close the dialog
                    try {
                      await user.delete();
                      // Account deleted successfully
                      print('Account deleted successfully!');
                      // Perform any additional actions after account deletion
                      handleSignOff();
                    } catch (e) {
                      // Error occurred while deleting the account
                      print('Error deleting account: $e');
                    }
                  },
                  child: Text('Delete', style: TextStyle(color: Colors.red)),
                ),
                SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(); // Close the dialog
                  },
                  child: Text('Cancel'),
                ),
              ],
            );
          },
        );
      }
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "User: ${currentUser?.email ?? 'Unknown'}",
          style: TextStyle(fontSize: 16),
        ),
        ElevatedButton(
          onPressed: handleSignOff,
          child: Text('Sign Off'),
        ),
        ElevatedButton(
          onPressed: () => handleDeleteAccount(context),
          child: Text('DELETE ACCOUNT'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red, // Set the background color to red
          ),
        ),
      ],
    );
  }
}
