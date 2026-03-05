import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';

class AuthService {
  // REGISTRO
  Future<bool> register(String name, String email, String password) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.register}');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"name": name, "email": email, "password": password}),
    );
    return response.statusCode == 201 || response.statusCode == 200;
  }

  // LOGIN PASO 1 (Credenciales)
  Future<Map<String, dynamic>?> loginStep1(String email, String password) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.login}');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"email": email, "password": password}),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body); 
    }
    return null;
  }

  // LOGIN PASO 2 (OTP)
  Future<String?> verifyOTP(String email, String otpCode) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.twoFactor}');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"email": email, "token": otpCode}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['token']; 
    }
    return null;
  }
}