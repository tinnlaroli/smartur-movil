import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/constants/api_constants.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  static const _biometricKey = 'biometric_enabled';

  // ── Token persistence ───────────────────────────────────────────────────

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<bool> hasSession() async {
    final token = await _storage.read(key: _tokenKey);
    return token != null && token.isNotEmpty;
  }

  /// Cierra sesión. Si la huella está activada, el token se conserva
  /// (queda protegido detrás del sensor biométrico).
  Future<void> clearSession() async {
    final biometric = await isBiometricEnabled();
    if (!biometric) {
      await _storage.delete(key: _tokenKey);
    }
  }

  /// Borra TODO: token + preferencia de huella. Logout total.
  Future<void> fullLogout() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _biometricKey);
  }

  // ── Biometric preference ───────────────────────────────────────────────

  Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(key: _biometricKey, value: enabled.toString());
  }

  Future<bool> isBiometricEnabled() async {
    final val = await _storage.read(key: _biometricKey);
    return val == 'true';
  }

  // ── REGISTRO ────────────────────────────────────────────────────────────

  Future<bool> register(String name, String email, String password) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.register}');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"name": name, "email": email, "password": password}),
    );
    return response.statusCode == 201 || response.statusCode == 200;
  }

  // ── LOGIN PASO 1 (Credenciales) ────────────────────────────────────────

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

  // ── LOGIN PASO 2 (OTP) — guarda el token automáticamente ───────────────

  Future<String?> verifyOTP(String email, String otpCode) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.twoFactor}');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"email": email, "token": otpCode}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final String? token = data['token'];
      if (token != null) {
        await saveToken(token);
      }
      return token;
    }
    return null;
  }
}