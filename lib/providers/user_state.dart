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
  Map<String, RideOfferModel> _storedOffers = {};
  static const String _storedOffersKey = 'storedOffers';
  Map<String, UserModel> _storedUsers = {};
  static const String _storedUsersKey = 'storedUsers';
  Map<String, types.Room> _storedChatRooms = {};
  static const String _storedChatRoomsKey = 'storedChatRooms';
  Map<String, int> _totalNotifications = {};
  static const String _totalNotificationsKey = 'totalNotifications';

  UserModel? get currentUser => _currentUser;
  Map<String, RideOfferModel> get storedOffers => _storedOffers;
  Map<String, UserModel> get storedUsers => _storedUsers;
  Map<String, types.Room> get storedChatRooms => _storedChatRooms;
  Map<String, int> get totalNotifications => _totalNotifications;
  int get totalNotificationsCount =>
      _totalNotifications.values.fold(0, (previousValue, element) => previousValue + element);

  Future<void> setTotalNotifications(Map<String, int> newTotalNotifications) async {
    _totalNotifications = newTotalNotifications;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(_totalNotificationsKey, jsonEncode(_totalNotifications));
    notifyListeners();
  }

  Future<List<types.Room>> fetchAllChatRooms() async {
    List<types.Room> allChatRooms = [];
    try {
      allChatRooms = await FirebaseFunctions.fetchAllChatRooms(this, currentUser!);
      Map<String, int> newTotalNotifications = {};
      for (final chatRoom in allChatRooms) {
        final previousNotifications = _totalNotifications[chatRoom.id] ?? 0;
        int newNotifications =
            chatRoom.lastMessages!.length - (_storedChatRooms[chatRoom.id]?.lastMessages?.length ?? 0);
        if (newNotifications < 0) {
          newNotifications = 0;
        }
        newTotalNotifications[chatRoom.id] = previousNotifications + newNotifications;
      }
      await setTotalNotifications(newTotalNotifications);
    } catch (e) {
      debugPrint('fetchAllChatRooms: $e');
    }
    await setAllStoredChatRooms(allChatRooms);
    return allChatRooms;
  }

  Future<List<RideOfferModel>> fetchAllOffers() async {
    List<RideOfferModel> allOffers = [];
    try {
      allOffers = await FirebaseFunctions.fetchAllOffersbyUser(currentUser!);
    } catch (e) {
      debugPrint('fetchAllOffers: $e');
    }
    await setAllStoredOffers(allOffers);
    return allOffers;
  }

  Future<void> setCurrentUser(UserModel user) async {
    _currentUser = user;
    SharedPreferences sharedUser = await SharedPreferences.getInstance();
    sharedUser.setString(_currentUserKey, jsonEncode(user.toJson()));
    debugPrint('currentUser: ${sharedUser.getString(_currentUserKey)}');
    notifyListeners();
  }

  Future<void> setAllStoredOffers(List<RideOfferModel> offers) async {
    _storedOffers = {for (final offer in offers) offer.id: offer};
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(_storedOffersKey, jsonEncode(_storedOffers));
    notifyListeners();
  }

  Future<void> setStoredOffer(String offerId, RideOfferModel? offer) async {
    if (offer != null && (!_storedOffers.containsKey(offer.id) || _storedOffers[offer.id] != offer)) {
      _storedOffers[offerId] = offer;
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      sharedPreferences.setString(_storedOffersKey, jsonEncode(_storedOffers));
      notifyListeners();
    } else if (offer == null && _storedOffers.containsKey(offerId)) {
      _storedOffers.remove(offerId);
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      sharedPreferences.setString(_storedOffersKey, jsonEncode(_storedOffers));
      notifyListeners();
    }
  }

  Future<void> setStoredUser(String userId, UserModel? user) async {
    if (user != null && (!_storedUsers.containsKey(user.email) || _storedUsers[user.email] != user)) {
      _storedUsers[user.email] = user;
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      sharedPreferences.setString(_storedUsersKey, jsonEncode(_storedUsers));
      notifyListeners();
    } else if (user == null && _storedUsers.containsKey(userId)) {
      _storedUsers.remove(userId);
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      sharedPreferences.setString(_storedUsersKey, jsonEncode(_storedUsers));
      notifyListeners();
    }
  }

  Future<void> setAllStoredChatRooms(List<types.Room> chatRooms) async {
    _storedChatRooms = {for (final chatRoom in chatRooms) chatRoom.id: chatRoom};
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(_storedChatRoomsKey, jsonEncode(_storedChatRooms));
    notifyListeners();
  }

  Future<void> setStoredChatRoom(String chatRoomId, types.Room? chatRoom) async {
    if (chatRoom != null && (!_storedChatRooms.containsKey(chatRoom.id) || _storedChatRooms[chatRoom.id] != chatRoom)) {
      _storedChatRooms[chatRoom.id] = chatRoom;
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      sharedPreferences.setString(_storedChatRoomsKey, jsonEncode(_storedChatRooms));
      notifyListeners();
    } else if (chatRoom == null && _storedChatRooms.containsKey(chatRoomId)) {
      _storedChatRooms.remove(chatRoomId);
      SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      sharedPreferences.setString(_storedChatRoomsKey, jsonEncode(_storedChatRooms));
      notifyListeners();
    }
  }

  Future<RideOfferModel?> getStoredOfferById(String id, {bool forceUpdate = false}) async {
    RideOfferModel? storedOffer;
    if (_storedOffers.containsKey(id) && !forceUpdate) {
      storedOffer = _storedOffers[id];
      FirebaseFunctions.fetchRideOfferById(currentUser!, id).then((fetchedOffer) {
        setStoredOffer(id, fetchedOffer);
      });
      return storedOffer;
    }
    final fetchedOffer = await FirebaseFunctions.fetchRideOfferById(currentUser!, id);
    setStoredOffer(id, fetchedOffer);
    return fetchedOffer;
  }

  Future<types.Room?> getStoredChatRoomByRoomId(String roomId, {bool forceUpdate = false}) async {
    types.Room? storedChatRoom;
    if (_storedChatRooms.containsKey(roomId) && !forceUpdate) {
      storedChatRoom = _storedChatRooms[roomId];
      FirebaseFunctions.fetchChatRoom(this, currentUser!, roomId).then((fetchedChatRoom) {
        setStoredChatRoom(roomId, fetchedChatRoom);
      });
      return storedChatRoom;
    }
    final fetchedChatRoom = await FirebaseFunctions.fetchChatRoom(this, currentUser!, roomId);
    setStoredChatRoom(roomId, fetchedChatRoom);
    return fetchedChatRoom;
  }

  Future<UserModel?> getStoredUserByEmail(String email, {bool forceUpdate = false}) async {
    UserModel? storedUser;
    if (_storedUsers.containsKey(email) && !forceUpdate) {
      storedUser = storedUsers[email];
      FirebaseFunctions.fetchUserByEmail(email).then((fetchedUser) {
        setStoredUser(email, fetchedUser);
      });
      return storedUser;
    }
    final fetchedUser = await FirebaseFunctions.fetchUserByEmail(email);
    setStoredUser(email, fetchedUser);
    return fetchedUser;
  }

  Future<void> signOff() async {
    _currentUser = null;
    _storedOffers = {};
    _storedUsers = {};
    _storedChatRooms = {};
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    debugPrint('signOffUser: ${sharedPreferences.getString(_currentUserKey)}');
    sharedPreferences.remove(_currentUserKey);
    sharedPreferences.remove(_storedOffersKey);
    sharedPreferences.remove(_storedUsersKey);
    sharedPreferences.remove(_storedChatRoomsKey);
    sharedPreferences.remove(_totalNotificationsKey);
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
            _storedOffers = (jsonDecode(storedOffersString) as Map<String, dynamic>)
                .map((key, value) => MapEntry(key, RideOfferModel.fromJson(value)));
            debugPrint('storedOffers: ${_storedOffers.toString()}');
          } catch (e) {
            debugPrint('Error parsing currentOfferString: $e');
          }
        } else {
          // fetch offers from firebase
          FirebaseFunctions.fetchAllOffersbyUser(currentUser!).then((offers) {
            setAllStoredOffers(offers);
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
          FirebaseFunctions.fetchAllChatRooms(this, currentUser!).then((chatRooms) {
            setAllStoredChatRooms(chatRooms);
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
