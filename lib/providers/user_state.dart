import 'dart:convert';

import 'package:corider/cloud_functions/firebase_function.dart';
import 'package:corider/models/ride_offer_model.dart';
import 'package:corider/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class UserState extends ChangeNotifier {
  UserModel? _currentUser;
  static const String _currentUserKey = 'currentUser';
  List<RideOfferModel> _storedOffers = [];
  static const String _storedOffersKey = 'storedOffers';
  Map<String, UserModel> _storedUsers = {};
  static const String _storedUsersKey = 'storedUsers';
  Map<String, types.Room> _storedChatRooms = {};
  static const String _storedChatRoomsKey = 'storedChatRooms';

  UserModel? get currentUser => _currentUser;
  List<RideOfferModel> get storedOffers => _storedOffers;
  Map<String, UserModel> get storedUsers => _storedUsers;
  Map<String, types.Room> get storedChatRooms => _storedChatRooms;

  Future<List<RideOfferModel>> fetchAllOffers() async {
    List<RideOfferModel> allOffers = [];
    try {
      allOffers = await FirebaseFunctions.fetchAllOffersbyUser(currentUser!);
    } catch (e) {
      debugPrint('fetchAllOffers: $e');
    }
    setStoredOffers(allOffers);
    return allOffers;
  }

  Future<void> setCurrentUser(UserModel user) async {
    _currentUser = user;
    SharedPreferences sharedUser = await SharedPreferences.getInstance();
    sharedUser.setString(_currentUserKey, jsonEncode(user.toJson()));
    debugPrint('currentUser: ${sharedUser.getString(_currentUserKey)}');
    notifyListeners();
  }

  Future<void> setStoredOffers(List<RideOfferModel> offers) async {
    _storedOffers = offers;
    SharedPreferences sharedOffers = await SharedPreferences.getInstance();
    sharedOffers.setString(_storedOffersKey, jsonEncode(offers));
    notifyListeners();
  }

  Future<void> setStoredUser(UserModel user) async {
    SharedPreferences sharedUsers = await SharedPreferences.getInstance();
    final storedData = sharedUsers.getString(_storedUsersKey) ?? '{}';
    final storedUsersMap = jsonDecode(storedData) as Map<String, dynamic>;
    if (!storedUsersMap.containsKey(user.email) || storedUsersMap[user.email] != user.toJson()) {
      storedUsersMap[user.email] = user.toJson();
      sharedUsers.setString(_storedUsersKey, jsonEncode(_storedUsers));

      _storedUsers = storedUsersMap.map((key, value) => MapEntry(key, UserModel.fromJson(value)));
      notifyListeners();
    }
  }

  Future<void> setStoredChatRoom(types.Room chatRoom) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final storedData = sharedPreferences.getString(_storedChatRoomsKey) ?? '{}';
    final storedChatRoomsMap = jsonDecode(storedData) as Map<String, dynamic>;
    if (!storedChatRoomsMap.containsKey(chatRoom.id) || storedChatRoomsMap[chatRoom.id] != chatRoom.toJson()) {
      storedChatRoomsMap[chatRoom.id] = chatRoom.toJson();
      sharedPreferences.setString(_storedChatRoomsKey, jsonEncode(_storedChatRooms));

      _storedChatRooms = storedChatRoomsMap.map((key, value) => MapEntry(key, types.Room.fromJson(value)));
      notifyListeners();
    }
  }

  Future<types.Room?> getStoredChatRoomByRoomId(String roomId, {bool forceUpdate = false}) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    types.Room? storedChatRoom;
    if (sharedPreferences.getString(_storedChatRoomsKey) != null) {
      Map<String, types.Room> storedChatRooms = (jsonDecode(sharedPreferences.getString(_storedChatRoomsKey)!) as Map)
          .map((key, value) => MapEntry(key, types.Room.fromJson(value)));
      if (storedChatRooms.containsKey(roomId) && !forceUpdate) {
        storedChatRoom = storedChatRooms[roomId];
        FirebaseFunctions.fetchChatRoom(currentUser!, roomId).then((fetchedChatRoom) {
          if (fetchedChatRoom != null && fetchedChatRoom != storedChatRoom) {
            // update storedChatRooms
            setStoredChatRoom(fetchedChatRoom);
          }
        });
        return storedChatRoom;
      }
    }
    final fetchedChatRoom = await FirebaseFunctions.fetchChatRoom(currentUser!, roomId);
    if (fetchedChatRoom != null) {
      // update storedChatRooms
      setStoredChatRoom(fetchedChatRoom);
    }
    return fetchedChatRoom;
  }

  Future<UserModel?> getStoredUserByEmail(String email, {bool forceUpdate = false}) async {
    SharedPreferences sharedUsers = await SharedPreferences.getInstance();
    UserModel? storedUser;
    if (sharedUsers.getString(_storedUsersKey) != null) {
      Map<String, UserModel> storedUsers = (jsonDecode(sharedUsers.getString(_storedUsersKey)!) as Map)
          .map((key, value) => MapEntry(key, UserModel.fromJson(value)));
      if (storedUsers.containsKey(email) && !forceUpdate) {
        storedUser = storedUsers[email];
        FirebaseFunctions.fetchUserByEmail(email).then((fetchedUser) {
          if (fetchedUser != null && fetchedUser != storedUser) {
            // update storedUser
            setStoredUser(fetchedUser);
          }
        });
        return storedUser;
      }
    }
    final fetchedUser = await FirebaseFunctions.fetchUserByEmail(email);
    if (fetchedUser != null) {
      // update storedUser
      setStoredUser(fetchedUser);
    }
    return fetchedUser;
  }

  Future<void> signOff() async {
    _currentUser = null;
    _storedOffers = [];
    _storedUsers = {};
    _storedChatRooms = {};
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    debugPrint('signOffUser: ${sharedPreferences.getString(_currentUserKey)}');
    sharedPreferences.remove(_currentUserKey);
    sharedPreferences.remove(_storedOffersKey);
    sharedPreferences.remove(_storedUsersKey);
    sharedPreferences.remove(_storedChatRoomsKey);
    notifyListeners();
  }

  Future<void> loadData() async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    String? currentUserString = sharedPref.getString(_currentUserKey);
    String? storedOffersString = sharedPref.getString(_storedOffersKey);
    String? storedUsersString = sharedPref.getString(_storedUsersKey);
    String? storedChatRoomsString = sharedPref.getString(_storedChatRoomsKey);
    if (currentUserString != null) {
      try {
        await setCurrentUser(UserModel.fromJson(jsonDecode(currentUserString)));
        // fetch user from firebase
        FirebaseFunctions.fetchUserByEmail(currentUser!.email).then((user) {
          // compare currentUser with user
          if (jsonEncode(currentUser!.toJson()) != jsonEncode(user!.toJson())) {
            // print different
            debugPrint('difference: ${jsonEncode(currentUser!.toJson())} != ${jsonEncode(user.toJson())}');
            // if different, update currentUser
            setCurrentUser(user);
          }
          debugPrint('currentUser: ${currentUser!.toJson().toString()}');
        });

        // get stored offers
        if (storedOffersString != null) {
          try {
            setStoredOffers(
                (jsonDecode(storedOffersString) as List<dynamic>).map((e) => RideOfferModel.fromJson(e)).toList());
            if (storedOffers.isEmpty) {
              FirebaseFunctions.fetchAllOffersbyUser(currentUser!).then((offers) {
                setStoredOffers(offers);
              });
            }
            debugPrint('storedOffers: ${storedOffers.toString()}');
          } catch (e) {
            debugPrint('Error parsing currentOfferString: $e');
          }
        } else {
          // fetch offers from firebase
          FirebaseFunctions.fetchAllOffersbyUser(currentUser!).then((offers) {
            setStoredOffers(offers);
          });
        }

        // get stored users
        if (storedUsersString != null) {
          try {
            _storedUsers = (jsonDecode(storedUsersString) as Map<String, dynamic>)
                .map((key, value) => MapEntry(key, UserModel.fromJson(value)));
            debugPrint('storedUsers: ${_storedUsers.toString()}');
          } catch (e) {
            debugPrint('Error parsing storedUsersString: $e');
          }
        }

        // get stored chatRooms
        if (storedChatRoomsString != null) {
          try {
            _storedChatRooms = (jsonDecode(storedChatRoomsString) as Map<String, dynamic>)
                .map((key, value) => MapEntry(key, types.Room.fromJson(value)));
            debugPrint('storedChatRooms: ${_storedChatRooms.toString()}');
          } catch (e) {
            debugPrint('Error parsing storedChatRoomsString: $e');
          }
        } else {
          // fetch chatRooms from firebase
          for (final chatRoomId in currentUser!.chatRoomIds) {
            getStoredChatRoomByRoomId(chatRoomId);
          }
        }
      } catch (e) {
        debugPrint('Error parsing currentUserString: $e');
      }
    } else {
      debugPrint('currentUserString is null');
    }
  }
}
