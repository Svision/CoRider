import 'dart:convert';

import 'package:corider/cloud_functions/firebase_function.dart';
import 'package:corider/models/ride_offer_model.dart';
import 'package:corider/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class UserState extends ChangeNotifier {
  UserModel? _currentUser;
  List<RideOfferModel> _currentOffers = [];
  Map<String, UserModel> _storedUsers = {};

  UserModel? get currentUser => _currentUser;
  List<RideOfferModel> get currentOffers => _currentOffers;
  Map<String, UserModel> get storedUsers => _storedUsers;

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
    _currentOffers = offers;
    SharedPreferences sharedOffers = await SharedPreferences.getInstance();
    sharedOffers.setString('currentOffers', jsonEncode(offers));
    notifyListeners();
  }

  Future<void> setStoredUser(UserModel user) async {
    _storedUsers[user.email] = user;
    SharedPreferences sharedUsers = await SharedPreferences.getInstance();
    sharedUsers.setString('storedUser-${user.email}', jsonEncode(_storedUsers));
    notifyListeners();
  }

  Future<void> setOfferDriverImageUrlWithEmail(String email, String driverImageUrl) async {
    SharedPreferences sharedOffers = await SharedPreferences.getInstance();
    sharedOffers.setString('driverImageUrl-$email', driverImageUrl);
    notifyListeners();
  }

  Future<UserModel?> getStoredUserByEmail(String email) async {
    SharedPreferences sharedUsers;
    UserModel? storedUser;
    sharedUsers = await SharedPreferences.getInstance();
    if (sharedUsers.getString('storedUsers-$email') == null) {
      final user = await FirebaseFunctions.fetchUserByEmail(email);
      if (user != null) {
        setStoredUser(user);
        storedUser = user;
      }
    } else {
      storedUser = UserModel.fromJson(jsonDecode(sharedUsers.getString('storedUser-$email')!));
    }
    return storedUser;
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

  Future<List<types.Room>> fetchChatRooms() async {
    List<types.Room> chatRooms = [];
    try {
      chatRooms = await FirebaseFunctions.fetchChatRooms(currentUser!);
    } catch (e) {
      debugPrint('fetchChatRooms: $e');
    }
    return chatRooms;
  }

  Future<void> signOff() async {
    _currentUser = null;
    _currentOffers = [];
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    debugPrint('signOffUser: ${sharedPreferences.getString('currentUser')}');
    sharedPreferences.remove('currentUser');
    sharedPreferences.remove('currentOffers');
    sharedPreferences.remove('storedUsers');
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
            if (currentOffers.isEmpty) {
              FirebaseFunctions.fetchAllOffersbyUser(currentUser!).then((offers) {
                setCurrentOffers(offers);
              });
            }
            debugPrint('currentOffer: ${currentOffers.toString()}');
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
