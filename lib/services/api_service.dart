import 'dart:convert';
import '../variables.dart';
import 'package:http/http.dart' as http;
import '../models/coffee.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // ===============================
  // GET COFFEES
  // ===============================
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

      // Either format:
      // { "data": [...] }
      // or [...]
      final List list = decoded is Map ? decoded['data'] : decoded;

      return list
          .map((e) => Coffee.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } else {
      throw Exception('Failed to load coffees: ${response.statusCode}');
    }
  }

  // ===============================
  // CREATE COFFEE
  // ===============================
  static Future<void> createCoffee(Coffee coffee) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final minPrice = double.tryParse(coffee.minPrice.toString()) ?? 0;
    final maxPrice = double.tryParse(coffee.maxPrice.toString()) ?? 0;

    if (minPrice > maxPrice) {
      throw Exception('Minimum price cannot be greater than maximum price.');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/coffees'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        "coffee_name": coffee.coffeeName,
        "coffee_type": coffee.coffeeType,
        "description": coffee.description,
        "ingredients": coffee.ingredients,
        "minimum_price": minPrice,
        "maximum_price": maxPrice,
        // support inserting image url from assets or server
        "image_url": coffee.imageUrl,
      }),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Failed to create coffee: ${response.body}');
    }
  }

  // ===============================
  // UPDATE COFFEE
  // ===============================
  static Future<void> updateCoffee(String id, Coffee coffee) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final minPrice = double.tryParse(coffee.minPrice.toString()) ?? 0;
    final maxPrice = double.tryParse(coffee.maxPrice.toString()) ?? 0;

    if (minPrice > maxPrice) {
      throw Exception('Minimum price cannot be greater than maximum price.');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/coffees/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        "coffee_name": coffee.coffeeName,
        "coffee_type": coffee.coffeeType,
        "description": coffee.description,
        "ingredients": coffee.ingredients,
        "minimum_price": minPrice,
        "maximum_price": maxPrice,
        "image_url": coffee.imageUrl,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update coffee: ${response.body}');
    }
  }

  // ===============================
  // DELETE COFFEE
  // ===============================
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
