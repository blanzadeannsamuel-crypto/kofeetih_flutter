import 'dart:convert';
import '../variables.dart';
import 'package:http/http.dart' as http;
import '../models/coffee.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static Future<List<Coffee>> getCoffees({required String token}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/coffees'),
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);

      // handle both { data: [...] } or raw list [...]
      final List list = decoded is Map ? decoded['data'] : decoded;

      return list
          .map((e) => Coffee.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } else {
      throw Exception('Failed to load coffees: ${response.statusCode}');
    }
  }


  static Future<void> createCoffee(Coffee coffee) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await http.post(
      Uri.parse('$baseUrl/coffees'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        "coffee_type": coffee.coffeeType,
        "description": coffee.description,
      }),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Failed to create coffee: ${response.body}');
    }
  }

  static Future<void> updateCoffee(String id, Coffee coffee) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await http.put(
      Uri.parse('$baseUrl/coffees/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        "coffee_type": coffee.coffeeType,
        "description": coffee.description,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update coffee: ${response.body}');
    }
  }
  static Future<void> deleteCoffee(String id, String token) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/coffees/$id'),
      headers: {
        "Authorization": "Bearer $token",
        "Accept": "application/json",
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete coffee: ${response.body}');
    }
  }
}
