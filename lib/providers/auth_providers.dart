import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider extends ChangeNotifier{
  bool _isLoggedin = false;
  bool get isLoggedin => _isLoggedin;

  AuthProvider(){
    loadLoginState();
  }

  Future<void> loadLoginState() async{
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    _isLoggedin =   token != null;
    notifyListeners();
  }

  Future<void> login(String token) async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);

    _isLoggedin = true;
    notifyListeners();
  }

  Future<void> logout() async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');

    _isLoggedin = false;
    notifyListeners();
  }
}