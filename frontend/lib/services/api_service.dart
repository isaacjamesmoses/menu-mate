import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../models/menu_item.dart';

class ApiService {
  // Use your Render.com URL here once deployed. 
  // Example: 'https://menumate-api.onrender.com'
  static const String baseUrl = 'YOUR_RENDER_URL_HERE';

  Future<List<MenuItem>> uploadMenuImage(XFile image) async {
    final uri = Uri.parse('$baseUrl/scan-menu');

    // Read bytes and instantly encode into a raw base64 native string
    final bytes = await image.readAsBytes();
    final base64String = base64Encode(bytes);

    try {
      // Send string inside standard JSON format, bypassing form boundary quirks!
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({"image_base64": base64String}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        return jsonList.map((e) => MenuItem.fromJson(e)).toList();
      } else {
        throw Exception('Failed to process menu. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error uploading image: $e');
    }
  }

  Future<Map<String, dynamic>> recommendMeal({
    required List<MenuItem> menuItems,
    required int peopleCount,
    required double budget,
    required String preferredFoods,
    required String foodsToAvoid,
    required Map<String, bool> dietaryToggles,
  }) async {
    final uri = Uri.parse('$baseUrl/recommend-meal');
    
    final payload = {
      'people_count': peopleCount,
      'budget': budget,
      'preferred_foods': preferredFoods,
      'foods_to_avoid': foodsToAvoid,
      'dietary_toggles': dietaryToggles,
      'menu_items': menuItems.map((e) => e.toJson()).toList(),
    };

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get recommendations. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<void> savePlan({
    required Map<String, dynamic> planData,
    required Map<String, dynamic> preferencesData,
  }) async {
    final uri = Uri.parse('$baseUrl/save-plan');
    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'plan': planData,
          'preferences': preferencesData,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to save plan: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<List<dynamic>> getSavedPlans() async {
    final uri = Uri.parse('$baseUrl/plans');
    try {
      final response = await http.get(uri);
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        throw Exception('Failed to fetch saved plans: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}


