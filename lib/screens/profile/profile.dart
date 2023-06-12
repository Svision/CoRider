import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:corider/models/user_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';

class SignOffButton extends StatelessWidget {
  final VoidCallback onPressed;

  const SignOffButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final userState = Provider.of<UserState>(context);
    final currentUser = userState.currentUser;
    ValueNotifier<String?> profileImageNotifier =
        ValueNotifier<String?>(currentUser?.profileImage);

    void handleSignOff() {
      userState.signOff();
      onPressed();
    }

    void handleUploadPhoto() async {
      final imagePicker = ImagePicker();
      final pickedImage = await imagePicker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedImage != null) {
        final croppedImage = await ImageCropper().cropImage(
          sourcePath: pickedImage.path,
          aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
          cropStyle: CropStyle.circle,
          compressQuality: 100, // Adjust the compression quality as needed
        );
        if (croppedImage != null) {
          try {
            final storage = firebase_storage.FirebaseStorage.instance;
            final storageRef =
                storage.ref().child('profile_images/${currentUser!.email}.jpg');

            // Upload the image file to Firebase Storage
            await storageRef.putFile(File(croppedImage.path));

            // Get the download URL for the uploaded image
            final imageUrl = await storageRef.getDownloadURL();

            // Update the user's profile image URL in Firestore or perform any other actions
            debugPrint('Image uploaded successfully. URL: $imageUrl');
            profileImageNotifier.value = imageUrl;
            // Update the user's profile image URL in Firestore
            final usersCollection =
                FirebaseFirestore.instance.collection('users');
            final userQuerySnapshot = await usersCollection
                .where('email', isEqualTo: currentUser.email)
                .get();

            if (userQuerySnapshot.docs.isNotEmpty) {
              final userDocumentSnapshot = userQuerySnapshot.docs.first;
              await userDocumentSnapshot.reference.update({
                'profileImage': imageUrl,
              });
            }
          } catch (e) {
            debugPrint('Error uploading image: $e');
          }
        } else {
          debugPrint('Image cropping was canceled.');
        }
      } else {
        debugPrint('No image was selected.');
      }
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
                  child:
                      const Text('Delete', style: TextStyle(color: Colors.red)),
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
        ValueListenableBuilder<String?>(
          valueListenable: profileImageNotifier,
          builder: (context, profileImage, _) {
            return GestureDetector(
              onTap: handleUploadPhoto,
              child: CircleAvatar(
                radius: 50,
                backgroundImage:
                    profileImage != null ? NetworkImage(profileImage) : null,
                child: profileImage == null
                    ? const Icon(
                        Icons.camera_alt,
                        size: 40,
                        color: Colors.white,
                      )
                    : null,
              ),
            );
          },
        ),
        SizedBox(height: 16),
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
