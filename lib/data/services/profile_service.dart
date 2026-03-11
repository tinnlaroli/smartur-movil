import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';

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
}
