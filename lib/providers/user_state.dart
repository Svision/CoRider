import 'dart:convert';

import 'package:corider/models/ride_offer_model.dart';
import 'package:corider/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserState extends ChangeNotifier {
  UserModel? _currentUser;
  List<RideOfferModel>? _offers;

  UserModel? get currentUser => _currentUser;
  List<RideOfferModel>? get offers => _offers;

  UserState(UserModel? currentUser, List<RideOfferModel> offers) {
    _currentUser = currentUser;
    _offers = offers;
  }

  void setUser(UserModel user) async {
    _currentUser = user;
    SharedPreferences sharedUser = await SharedPreferences.getInstance();
    sharedUser.setString('currentUser', jsonEncode(user.toJson()));
    debugPrint('setUser: ${sharedUser.getString('currentUser')}');
    notifyListeners();
  }

  void setOffers(List<RideOfferModel> offers) async {
    _offers = offers;
    SharedPreferences sharedOffers = await SharedPreferences.getInstance();
    sharedOffers.setString('offers', jsonEncode(offers));
    notifyListeners();
  }

  void setOfferDriverImageUrlWithEmail(
      String email, String driverImageUrl) async {
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

  void signOff() async {
    _currentUser = null;
    _offers = [];
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    debugPrint('signOffUser: ${sharedPreferences.getString('currentUser')}');
    sharedPreferences.remove('currentUser');
    sharedPreferences.remove('offers');
    notifyListeners();
  }
}
