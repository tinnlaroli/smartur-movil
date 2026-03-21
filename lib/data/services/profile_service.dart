import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/api_constants.dart';
import 'auth_service.dart';

class ProfileService {
  static const _prefsKey = 'preferences_saved';

  /// Retorna true si el usuario ya guardó sus preferencias previamente (caché local).
  static Future<bool> hasPreferencesSaved() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefsKey) ?? false;
  }

  /// Guarda la bandera local indicando que las preferencias ya fueron enviadas.
  static Future<void> _markPreferencesSaved() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, true);
  }

  /// Envía las preferencias al backend y marca el guardado local.
  /// Retorna true en éxito, false en caso contrario.
  static Future<bool> savePreferences(
    String token,
    Map<String, dynamic> preferences,
  ) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.preferences}');
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(preferences),
      );

      if (response.statusCode == 200) {
        await _markPreferencesSaved();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
  /// Intereses desde GET /profiles/me (traveler_profile.interests).
  static Future<List<String>> getSavedInterests() async {
    final auth = AuthService();
    final token = await auth.getToken();
    if (token == null) return [];

    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.profilesMe}');
    try {
      final response = await http
          .get(
            url,
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 15));
      if (response.statusCode != 200) return [];
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final profile = data['travelerProfile'];
      if (profile == null) return [];
      final interests = profile['interests'];
      if (interests is List) {
        return interests.map((e) => e.toString()).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }
}
