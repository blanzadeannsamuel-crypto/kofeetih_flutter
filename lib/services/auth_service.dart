import 'dart:convert';
import 'package:http/http.dart' as http;
import '../variables.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static Future<bool> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json"
      },
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      String token = jsonDecode(response.body)["token"];
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      return true;
    } else {
      return false;
    }
  }

  // ✅ Added register method (same pattern as login)
  static Future<bool> register(String lastname, String firstname, String age, String email, String password, String passwordConfirmation) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json"
      },
      body: jsonEncode({
        "last_name": lastname,
        "first_name": firstname,
        "age": int.tryParse(age),
        "email": email,
        "password": password,
        "password_confirmation": passwordConfirmation
      }),
    );

    if (response.statusCode == 200) {
      // Optional: store token if the API returns it right away
      var data = jsonDecode(response.body);
      if (data.containsKey("token")) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data["token"]);
      }
      return true;
    } else {
      return false;
    }
  }
}