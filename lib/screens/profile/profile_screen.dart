import 'package:cached_network_image/cached_network_image.dart';
import 'package:corider/cloud_functions/firebase_function.dart';
import 'package:corider/providers/user_state.dart';
import 'package:corider/screens/login/login.dart';
import 'package:corider/screens/profile/add_vehicle_screen.dart';
import 'package:corider/screens/profile/user_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'dart:io';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userState = Provider.of<UserState>(context);
    final currentUser = userState.currentUser;
    ValueNotifier<String?> profileImageNotifier = ValueNotifier<String?>(currentUser?.profileImage);

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
            FirebaseFunctions.uploadProfileImageByUser(
              currentUser!,
              File(croppedImage.path),
            ).then((err) => {
                  if (err == null)
                    {
                      FirebaseFunctions.getProfileImageUrlByUser(currentUser).then((imageUrl) => {
                            if (imageUrl != null)
                              {
                                currentUser.saveProfileImage(userState, imageUrl),
                                profileImageNotifier.value = imageUrl,
                              }
                          })
                    }
                  else
                    {
                      debugPrint('Error uploading image: $err'),
                    }
                });
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
              content: const Text('Are you sure you want to delete your account? This action cannot be undone.'),
              actions: [
                TextButton(
                  onPressed: () async {
                    try {
                      FirebaseFunctions.deleteUserAccount(currentUser!);
                      // Account deleted successfully
                      debugPrint('Account deleted successfully!');
                      userState.signOff();
                      // Show snackbar
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Account deleted successfully!'),
                        ),
                      );
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => LoginScreen(
                                  userState: userState,
                                )),
                      );
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
        ValueListenableBuilder<String?>(
          valueListenable: profileImageNotifier,
          builder: (context, profileImage, _) {
            return GestureDetector(
              onTap: handleUploadPhoto,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: profileImage == null ? Colors.grey : null,
                child: profileImage == null
                    ? const Icon(
                        Icons.camera_alt,
                        size: 40,
                        color: Colors.white,
                      )
                    : ClipOval(
                        child: CachedNetworkImage(
                        imageUrl: profileImage,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const CircularProgressIndicator(),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                      )),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => UserProfileScreen(
                        user: currentUser!,
                        isCurrentUser: true,
                      )),
            );
          },
          child: Column(
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
                currentUser?.companyName ?? 'Unknown Company',
                style: const TextStyle(fontSize: 16),
              ),
              Text(
                currentUser?.createdAt.toString() ?? 'Unknown Created At',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AddVehiclePage(
                        vehicle: currentUser!.vehicle,
                      )),
            );
          },
          child: const Text('My Vehicle'),
        ),
        ElevatedButton(
          onPressed: () {},
          child: const Text('My Company'),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () => {
            userState.signOff(),
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => LoginScreen(
                        userState: userState,
                      )),
            ),
          },
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
