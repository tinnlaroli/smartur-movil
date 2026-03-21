import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';
import 'auth_service.dart';

class UserContentException implements Exception {
  final String message;
  UserContentException(this.message);
  @override
  String toString() => message;
}

/// Favoritos, historial de visitas y comunidad (API v2).
class UserContentService {
  final AuthService _auth = AuthService();

  Future<Map<String, String>> _headers() async {
    final token = await _auth.getToken();
    if (token == null) throw UserContentException('Sin sesión');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<Map<String, dynamic>>> fetchFavorites() async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.meFavorites}');
    final response =
        await http.get(uri, headers: await _headers()).timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) {
      throw UserContentException('No se pudieron cargar favoritos');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final list = data['favorites'] as List<dynamic>? ?? [];
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<void> addFavorite(String placeKind, int placeId) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.meFavorites}');
    final response = await http
        .post(
          uri,
          headers: await _headers(),
          body: jsonEncode({'place_kind': placeKind, 'place_id': placeId}),
        )
        .timeout(const Duration(seconds: 15));
    if (response.statusCode != 201 && response.statusCode != 200) {
      final msg = jsonDecode(response.body)['message'] ?? 'Error al guardar favorito';
      throw UserContentException(msg.toString());
    }
  }

  Future<void> removeFavorite(String placeKind, int placeId) async {
    final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.meFavorites}/$placeKind/$placeId');
    final response =
        await http.delete(uri, headers: await _headers()).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw UserContentException('No se pudo quitar el favorito');
    }
  }

  Future<List<Map<String, dynamic>>> fetchVisits({int limit = 50}) async {
    final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.meVisits}?limit=$limit');
    final response =
        await http.get(uri, headers: await _headers()).timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) {
      throw UserContentException('No se pudo cargar el historial');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final list = data['visits'] as List<dynamic>? ?? [];
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<void> recordVisit(String placeKind, int placeId) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.meVisits}');
    try {
      await http
          .post(
            uri,
            headers: await _headers(),
            body: jsonEncode({'place_kind': placeKind, 'place_id': placeId}),
          )
          .timeout(const Duration(seconds: 10));
    } catch (_) {
      // No bloquear UX si falla el registro de visita
    }
  }

  Future<bool> isFavorite(String placeKind, int placeId) async {
    try {
      final list = await fetchFavorites();
      return list.any(
        (e) => e['place_kind'] == placeKind && e['place_id'] == placeId,
      );
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>> fetchCommunityPosts({int page = 1, int limit = 20}) async {
    final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.communityPosts}?page=$page&limit=$limit');
    final response = await http.get(uri).timeout(const Duration(seconds: 20));
    if (response.statusCode != 200) {
      throw UserContentException('No se pudieron cargar las publicaciones');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<void> createCommunityPost({required String caption, String? imageUrl}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.communityPosts}');
    final body = <String, dynamic>{'caption': caption};
    if (imageUrl != null && imageUrl.isNotEmpty) body['image_url'] = imageUrl;
    final response = await http
        .post(uri, headers: await _headers(), body: jsonEncode(body))
        .timeout(const Duration(seconds: 20));
    if (response.statusCode != 201) {
      final msg = jsonDecode(response.body)['message'] ?? 'Error al publicar';
      throw UserContentException(msg.toString());
    }
  }
}
