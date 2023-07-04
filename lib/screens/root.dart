import 'dart:async';

import 'package:corider/providers/push_notificaions/local_notification_service.dart';
import 'package:corider/providers/user_state.dart';
import 'package:corider/screens/ride/exploreRides/explore_rides.dart';
import 'package:corider/screens/home/home.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'profile/profile_screen.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:collection/collection.dart';

class RootNavigationView extends StatefulWidget {
  final UserState userState;
  const RootNavigationView({super.key, required this.userState});

  @override
  State<RootNavigationView> createState() => _RootNavigationViewState();
}

class _RootNavigationViewState extends State<RootNavigationView> {
  int currentPageIndex = 0;
  bool isBackgroundFethching = false;

  @override
  void initState() {
    super.initState();
    _startBackgroundFethching();
  }

  void _startBackgroundFethching() {
    // Fetch new messages every 3 seconds
    Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!isBackgroundFethching) {
        setState(() {
          isBackgroundFethching = true;
        });
        final storedChatRooms = Map<String, types.Room>.from(widget.userState.storedChatRooms);
        widget.userState.fetchAllChatRooms().then((allChatRooms) async {
          // compare storedChatRooms and allChatRooms

          for (final chatRoom in allChatRooms) {
            // if there is a new chat room, then show notification
            if (!storedChatRooms.containsKey(chatRoom.id)) {
              final otherUser = chatRoom.users.where((user) => user.id != widget.userState.currentUser!.email).first;
              // show notification
              LocalNotificationService.showNewMessageLocalNotification(
                'New Chat',
                '${otherUser.firstName} ${otherUser.lastName} requested to chat with you',
              );
            } else {
              // if there is a new message, then show notification
              final storedChatRoom = storedChatRooms[chatRoom.id]!;
              if (storedChatRoom.lastMessages!.length < chatRoom.lastMessages!.length) {
                final latestMessage = chatRoom.lastMessages!.first;
                final otherUserId =
                    chatRoom.users.firstWhereOrNull((user) => user.id != widget.userState.currentUser!.email)?.id;
                final otherUser = otherUserId != null ? await widget.userState.getStoredUserByEmail(otherUserId) : null;
                // show notification
                LocalNotificationService.showNewMessageLocalNotification(
                  otherUser?.fullName ?? 'New Notification',
                  latestMessage is types.TextMessage ? latestMessage.text : '[Attachment]]',
                );
              }
            }
          }

          setState(() {
            isBackgroundFethching = false;
          });
        });
      }
    });
  }

  void changePageIndex(int index) {
    setState(() {
      currentPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    UserState userState = Provider.of<UserState>(context);
    return Scaffold(
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.commute),
            icon: Icon(Icons.commute_outlined),
            label: 'Rides',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.person),
            icon: Icon(Icons.person_outlined),
            label: 'Profile',
          ),
        ],
      ),
      body: <Widget>[
        Container(
          alignment: Alignment.center,
          child: HomeScreen(
            userState: userState,
            changePageIndex: changePageIndex,
          ),
        ),
        Container(
          alignment: Alignment.center,
          child: ExploreRidesScreen(
            userState: userState,
          ),
        ),
        Container(
          alignment: Alignment.center,
          child: ProfileScreen(),
        ),
      ][currentPageIndex],
    );
  }
}
