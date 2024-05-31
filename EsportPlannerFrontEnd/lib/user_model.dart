import 'package:flutter/material.dart';

class UserModel with ChangeNotifier {
  String _id = '';

  String get id => _id;

  void setID(String id) {
    _id = id;
    notifyListeners();
  }
}