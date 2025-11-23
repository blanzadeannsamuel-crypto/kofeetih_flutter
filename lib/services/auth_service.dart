import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../variables.dart';

class AuthService {
  /// Login method (unchanged)
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

  /// Register method with full validation error handling
  static Future<Map<String, dynamic>> register({
    required String lastName,
    required String firstName,
    required String age,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    // Ensure age is a valid integer
    int? parsedAge = int.tryParse(age);
    if (parsedAge == null) {
      return {
        "success": false,
        "errors": {"age": ["Age must be a number."]}
      };
    }

    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json"
      },
      body: jsonEncode({
        "last_name": lastName,
        "first_name": firstName,
        "age": parsedAge,
        "email": email,
        "password": password,
        "password_confirmation": passwordConfirmation,
      }),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      // Store token if returned
      if (data.containsKey("token")) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data["token"]);
      }
      return {"success": true};
    } else if (response.statusCode == 422) {
      // Validation errors from Laravel
      var data = jsonDecode(response.body);
      return {
        "success": false,
        "errors": data['errors'] ?? {"form": ["Validation failed."]}
      };
    } else {
      // Other server errors
      var data = jsonDecode(response.body);
      return {
        "success": false,
        "errors": {"server": [data['message'] ?? "Unknown server error"]}
      };
    }
  }
}
