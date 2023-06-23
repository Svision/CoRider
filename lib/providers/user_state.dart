import 'dart:convert';

import 'package:corider/cloud_functions/firebase_function.dart';
import 'package:corider/models/ride_offer_model.dart';
import 'package:corider/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class UserState extends ChangeNotifier {
  UserModel? _currentUser;
  List<RideOfferModel>? _currentOffers;

  UserModel? get currentUser => _currentUser;
  List<RideOfferModel>? get currentOffers => _currentOffers;

  UserState(UserModel? currentUser, List<RideOfferModel>? offers) {
    _currentUser = currentUser;
    _currentOffers = offers;
  }

  Future<List<RideOfferModel>> fetchAllOffers() async {
    List<RideOfferModel> allOffers = [];
    try {
      allOffers = await FirebaseFunctions.fetchAllOffersbyUser(currentUser!);
    } catch (e) {
      debugPrint('fetchAllOffers: $e');
    }
    setOffers(allOffers);
    return allOffers;
  }

  Future<void> setUser(UserModel user) async {
    _currentUser = user;
    SharedPreferences sharedUser = await SharedPreferences.getInstance();
    sharedUser.setString('currentUser', jsonEncode(user.toJson()));
    debugPrint('setUser: ${sharedUser.getString('currentUser')}');
    notifyListeners();
  }

  Future<void> setOffers(List<RideOfferModel> offers) async {
    _currentOffers = offers;
    SharedPreferences sharedOffers = await SharedPreferences.getInstance();
    sharedOffers.setString('currentOffers', jsonEncode(offers));
    notifyListeners();
  }

  Future<void> setOfferDriverImageUrlWithEmail(String email, String driverImageUrl) async {
    SharedPreferences sharedOffers = await SharedPreferences.getInstance();
    sharedOffers.setString('driverImageUrl-$email', driverImageUrl);
    notifyListeners();
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
    notifyListeners();
  }

  Future<void> loadData() async {
    SharedPreferences sharedPref = await SharedPreferences.getInstance();
    String? currentUserString = sharedPref.getString('currentUser');
    String? currentOffersString = sharedPref.getString('currentOffers');
    if (currentUserString != null) {
      try {
        await setUser(UserModel.fromJson(jsonDecode(currentUserString)));
        // fetch user from firebase
        FirebaseFunctions.fetchUserByEmail(currentUser!.email).then((user) {
          // compare currentUser with user
          if (jsonEncode(currentUser!.toJson()) != jsonEncode(user!.toJson())) {
            // print different
            debugPrint('difference: ${jsonEncode(currentUser!.toJson())} != ${jsonEncode(user.toJson())}');
            // if different, update currentUser
            setUser(user);
          }
          debugPrint('currentUser: ${currentUser!.toJson().toString()}');
        });
        if (currentOffersString != null) {
          try {
            setOffers(
                (jsonDecode(currentOffersString) as List<dynamic>).map((e) => RideOfferModel.fromJson(e)).toList());
            if (currentOffers!.isEmpty) {
              FirebaseFunctions.fetchAllOffersbyUser(currentUser!).then((offers) {
                setOffers(offers);
              });
            }
            debugPrint('currentOffer: ${currentOffers.toString()}');
          } catch (e) {
            debugPrint('Error parsing currentOfferString: $e');
          }
        } else {
          // fetch offers from firebase
          FirebaseFunctions.fetchAllOffersbyUser(currentUser!).then((offers) {
            setOffers(offers);
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
