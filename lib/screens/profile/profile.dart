import 'package:corider/models/user_state.dart';
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
              title: const Text('Confirm Delete'),
              content: const Text(
                  'Are you sure you want to delete your account? This action cannot be undone.'),
              actions: [
                TextButton(
                  onPressed: () async {
                    Navigator.of(dialogContext).pop(); // Close the dialog
                    try {
                      await user.delete();
                      // Account deleted successfully
                      debugPrint('Account deleted successfully!');
                      // Perform any additional actions after account deletion
                      handleSignOff();
                    } catch (e) {
                      // Error occurred while deleting the account
                      debugPrint('Error deleting account: $e');
                    }
                  },
                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(); // Close the dialog
                  },
                  child: const Text('Cancel'),
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
          currentUser?.email ?? 'Unknown',
          style: const TextStyle(fontSize: 16),
        ),
        Text(
          currentUser?.fullName ?? 'Unknown Name',
          style: const TextStyle(fontSize: 16),
        ),
        Text(
          currentUser?.createdAt.toString() ?? 'Unknown Created At',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        SizedBox(height: 16),
        ElevatedButton(
          onPressed: handleSignOff,
          child: const Text('Sign Off'),
        ),
        ElevatedButton(
          onPressed: () => handleDeleteAccount(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red, // Set the background color to red
          ),
          child: const Text('DELETE ACCOUNT'),
        ),
      ],
    );
  }
}
