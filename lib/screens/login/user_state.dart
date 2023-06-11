import 'package:corider/models/user_model.dart';
import 'package:flutter/material.dart';

class UserState extends ChangeNotifier {
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;

  void setUser(UserModel user) {
    _currentUser = user;
    notifyListeners();
  }
}
