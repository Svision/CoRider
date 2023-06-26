import 'dart:convert';

import 'package:corider/cloud_functions/firebase_function.dart';
import 'package:corider/models/ride_offer_model.dart';
import 'package:corider/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class UserState extends ChangeNotifier {
  UserModel? _currentUser;
  List<RideOfferModel> _storedOffers = [];
  Map<String, UserModel> _storedUsers = {};
  Map<String, types.Room> _storedChatRooms = {};

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
    setCurrentOffers(allOffers);
    return allOffers;
  }

  Future<void> setCurrentUser(UserModel user) async {
    _currentUser = user;
    SharedPreferences sharedUser = await SharedPreferences.getInstance();
    sharedUser.setString('currentUser', jsonEncode(user.toJson()));
    debugPrint('setUser: ${sharedUser.getString('currentUser')}');
    notifyListeners();
  }

  Future<void> setCurrentOffers(List<RideOfferModel> offers) async {
    _storedOffers = offers;
    SharedPreferences sharedOffers = await SharedPreferences.getInstance();
    sharedOffers.setString('currentOffers', jsonEncode(offers));
    notifyListeners();
  }

  Future<void> setStoredUser(UserModel user) async {
    SharedPreferences sharedUsers = await SharedPreferences.getInstance();
    final storedData = sharedUsers.getString('storedUsers') ?? '{}';
    final storedUsersMap = jsonDecode(storedData) as Map<String, dynamic>;
    storedUsersMap[user.email] = user.toJson();

    sharedUsers.setString('storedUsers', jsonEncode(_storedUsers));

    _storedUsers = storedUsersMap.map((key, value) => MapEntry(key, UserModel.fromJson(value)));
    notifyListeners();
  }

  Future<void> setStoredChatRoom(types.Room chatRoom) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    final storedData = sharedPreferences.getString('storedChatRooms') ?? '{}';
    final storedChatRoomsMap = jsonDecode(storedData) as Map<String, dynamic>;
    storedChatRoomsMap[chatRoom.id] = chatRoom.toJson();

    sharedPreferences.setString('storedChatRooms', jsonEncode(_storedChatRooms));

    _storedChatRooms = storedChatRoomsMap.map((key, value) => MapEntry(key, types.Room.fromJson(value)));
    notifyListeners();
  }

  Future<void> setOfferDriverImageUrlWithEmail(String email, String driverImageUrl) async {
    SharedPreferences sharedOffers = await SharedPreferences.getInstance();
    sharedOffers.setString('driverImageUrl-$email', driverImageUrl);
    notifyListeners();
  }

  Future<types.Room?> getStoredChatRoomByRoomId(String roomId) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    types.Room? storedChatRoom;
    if (sharedPreferences.getString('storedChatRooms') != null) {
      Map<String, types.Room> storedChatRooms = (jsonDecode(sharedPreferences.getString('storedChatRooms')!) as Map)
          .map((key, value) => MapEntry(key, types.Room.fromJson(value)));
      if (storedChatRooms.containsKey(roomId)) {
        storedChatRoom = storedChatRooms[roomId];
      }
    }
    final fetchedChatRoom = await FirebaseFunctions.fetchChatRoom(currentUser!, roomId);
    if (fetchedChatRoom != null && fetchedChatRoom != storedChatRoom) {
      // update storedChatRooms
      setStoredChatRoom(fetchedChatRoom);
    }
    return fetchedChatRoom;
  }

  Future<UserModel?> getStoredUserByEmail(String email) async {
    SharedPreferences sharedUsers = await SharedPreferences.getInstance();
    UserModel? storedUser;
    if (sharedUsers.getString('storedUsers') != null) {
      Map<String, UserModel> storedUsers = (jsonDecode(sharedUsers.getString('storedUsers')!) as Map)
          .map((key, value) => MapEntry(key, UserModel.fromJson(value)));
      if (storedUsers.containsKey(email)) {
        storedUser = storedUsers[email];
      }
    }
    final fetchedUser = await FirebaseFunctions.fetchUserByEmail(email);
    if (fetchedUser != null && fetchedUser != storedUser) {
      // update storedUser
      setStoredUser(fetchedUser);
    }
    return fetchedUser;
  }

  Future<String?> getDriverImageUrlByEmail(String email) async {
    SharedPreferences sharedOffers;
    String? driverImageUrl;
    try {
      sharedOffers = await SharedPreferences.getInstance();
      driverImageUrl = sharedOffers.getString('driverImageUrl-$email');
    } catch (e) {
      debugPrint('OfferDriverImageUrl not set for: $email');
    }
    return driverImageUrl;
  }

  Future<void> signOff() async {
    _currentUser = null;
    _storedOffers = [];
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    debugPrint('signOffUser: ${sharedPreferences.getString('currentUser')}');
    sharedPreferences.remove('currentUser');
    sharedPreferences.remove('currentOffers');
    sharedPreferences.remove('storedUsers');
    sharedPreferences.remove('storedChatRooms');
    notifyListeners();
  }

  Future<void> loadData() async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    String? currentUserString = sharedPref.getString('currentUser');
    String? currentOffersString = sharedPref.getString('currentOffers');
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
        if (currentOffersString != null) {
          try {
            setCurrentOffers(
                (jsonDecode(currentOffersString) as List<dynamic>).map((e) => RideOfferModel.fromJson(e)).toList());
            if (storedOffers.isEmpty) {
              FirebaseFunctions.fetchAllOffersbyUser(currentUser!).then((offers) {
                setCurrentOffers(offers);
              });
            }
            debugPrint('currentOffer: ${storedOffers.toString()}');
          } catch (e) {
            debugPrint('Error parsing currentOfferString: $e');
          }
        } else {
          // fetch offers from firebase
          FirebaseFunctions.fetchAllOffersbyUser(currentUser!).then((offers) {
            setCurrentOffers(offers);
          });
        }
      } catch (e) {
        debugPrint('Error parsing currentUserString: $e');
      }
    } else {
      debugPrint('currentUserString is null');
    }
  }
}
