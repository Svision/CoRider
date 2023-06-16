import 'dart:convert';

import 'package:corider/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserState extends ChangeNotifier {
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;

  UserState(UserModel? currentUser) {
    _currentUser = currentUser;
  }

  void setUser(UserModel user) async {
    _currentUser = user;
    SharedPreferences sharedUser = await SharedPreferences.getInstance();
    sharedUser.setString('currentUser', jsonEncode(user.toJson()));
    debugPrint('setUser: ${sharedUser.getString('currentUser')}');
    notifyListeners();
  }

  void unsetUser() async {
    _currentUser = null;
    SharedPreferences sharedUser = await SharedPreferences.getInstance();
    debugPrint('signOffUser: ${sharedUser.getString('currentUser')}');
    sharedUser.remove('currentUser');
    notifyListeners();
  }
}
