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

  /// Une `place` anidado y alias típicos del backend para la UI del diario.
  static Map<String, dynamic> normalizeDiaryPlaceRow(Map<String, dynamic> raw) {
    final out = Map<String, dynamic>.from(raw);
    final place = raw['place'];
    if (place is Map) {
      final p = Map<String, dynamic>.from(place);
      for (final e in p.entries) {
        final v = e.value;
        if (v == null) continue;
        if (!out.containsKey(e.key) || out[e.key] == null ||
            (out[e.key] is String && (out[e.key] as String).isEmpty)) {
          out[e.key] = v;
        }
      }
    }
    out['place_kind'] ??= raw['placeKind']?.toString();
    out['place_id'] ??= raw['placeId'];
    if (out['name'] == null || out['name'].toString().trim().isEmpty) {
      out['name'] = out['title'] ?? out['nombre'] ?? '';
    }
    final img = out['image_url']?.toString();
    if (img == null || img.isEmpty) {
      out['image_url'] = out['imageUrl'] ??
          out['photo_url'] ??
          out['cover_image'] ??
          out['thumbnail_url'] ??
          '';
    }
    return out;
  }

  static List<Map<String, dynamic>> _parseObjectList(Map<String, dynamic> data, List<String> keys) {
    for (final k in keys) {
      final v = data[k];
      if (v is List) {
        return v.map((e) {
          if (e is! Map) return <String, dynamic>{};
          return normalizeDiaryPlaceRow(Map<String, dynamic>.from(e));
        }).toList();
      }
      if (v is Map) {
        final inner = Map<String, dynamic>.from(v);
        for (final ik in const ['favorites', 'items', 'rows', 'data']) {
          final iv = inner[ik];
          if (iv is List) {
            return iv.map((e) {
              if (e is! Map) return <String, dynamic>{};
              return normalizeDiaryPlaceRow(Map<String, dynamic>.from(e));
            }).toList();
          }
        }
      }
    }
    return [];
  }

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
    final decoded = jsonDecode(response.body);
    if (decoded is List) {
      return decoded.map((e) {
        if (e is! Map) return <String, dynamic>{};
        return normalizeDiaryPlaceRow(Map<String, dynamic>.from(e));
      }).toList();
    }
    if (decoded is! Map<String, dynamic>) {
      return [];
    }
    final data = Map<String, dynamic>.from(decoded);
    var list = _parseObjectList(data, const ['favorites', 'data', 'items', 'results']);
    if (list.isEmpty) {
      final d = data['data'];
      if (d is Map<String, dynamic>) {
        list = _parseObjectList(d, const ['favorites', 'items', 'rows']);
      }
    }
    return list;
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
    final decoded = jsonDecode(response.body);
    if (decoded is List) {
      return decoded.map((e) {
        if (e is! Map) return <String, dynamic>{};
        return normalizeDiaryPlaceRow(Map<String, dynamic>.from(e));
      }).toList();
    }
    if (decoded is! Map<String, dynamic>) {
      return [];
    }
    final data = Map<String, dynamic>.from(decoded);
    var list = _parseObjectList(data, const ['visits', 'data', 'items', 'results']);
    if (list.isEmpty) {
      final d = data['data'];
      if (d is Map<String, dynamic>) {
        list = _parseObjectList(d, const ['visits', 'items', 'rows']);
      }
    }
    return list;
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

  static bool _samePlaceRef(Map<String, dynamic> e, String placeKind, int placeId) {
    final k = e['place_kind']?.toString();
    final raw = e['place_id'];
    final id = raw is int ? raw : int.tryParse(raw?.toString() ?? '');
    return k == placeKind && id == placeId;
  }

  Future<bool> isFavorite(String placeKind, int placeId) async {
    try {
      final list = await fetchFavorites();
      return list.any((e) => _samePlaceRef(e, placeKind, placeId));
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
