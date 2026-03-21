import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../models/place_model.dart';
import 'auth_service.dart';

class ExploreService {
  final AuthService _auth;

  ExploreService({AuthService? authService})
      : _auth = authService ?? AuthService();

  Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  // Maps API service_type values to our PlaceCategory enum
  static PlaceCategory? _categoryFromServiceType(String? type) {
    if (type == null) return null;
    final lower = type.toLowerCase();
    if (lower.contains('hotel') || lower.contains('hospedaje') || lower.contains('alojamiento')) {
      return PlaceCategory.hotels;
    }
    if (lower.contains('restaurante') || lower.contains('comida') || lower.contains('gastro')) {
      return PlaceCategory.restaurants;
    }
    if (lower.contains('museo') || lower.contains('cultural') || lower.contains('galería')) {
      return PlaceCategory.museums;
    }
    if (lower.contains('aventura') || lower.contains('deporte') || lower.contains('ecoturismo')) {
      return PlaceCategory.adventures;
    }
    return null;
  }

  static PlaceCategory? _categoryFromPoiType(int? idType) {
    if (idType == null) return null;
    switch (idType) {
      case 1:
        return PlaceCategory.museums;
      case 2:
        return PlaceCategory.adventures;
      case 3:
        return PlaceCategory.restaurants;
      default:
        return null;
    }
  }

  /// Fetches all locations from the API and converts them to [CityData].
  /// Each city is fetched with its places (services + POIs).
  Future<List<CityData>> fetchCities() async {
    final token = await _auth.getToken();
    if (token == null) throw AuthException('No auth token available');

    final uri = Uri.parse(
      '${ApiConstants.baseUrl}${ApiConstants.locations}?limit=50',
    );
    final response = await http
        .get(uri, headers: _headers(token))
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) {
      throw ExploreException('Failed to load locations (${response.statusCode})');
    }

    final data = jsonDecode(response.body);
    final List<dynamic> rawLocations = data['locations'] ?? [];

    final List<CityData> cities = [];
    for (final loc in rawLocations) {
      final int locationId = loc['id_location'] as int;
      final double lat = _toDouble(loc['latitude']);
      final double lon = _toDouble(loc['longitude']);
      final String name = (loc['name'] ?? '') as String;

      final places = await _fetchPlacesForLocation(token, locationId, name);

      cities.add(CityData(
        name: name,
        chipIcon: _iconForCity(name),
        lat: lat,
        lon: lon,
        places: places,
      ));
    }
    return cities;
  }

  /// Fetches tourist services + points of interest for a single location.
  Future<List<Place>> _fetchPlacesForLocation(
      String token, int locationId, String cityName) async {
    final results = await Future.wait([
      _fetchTouristServices(token, locationId, cityName),
      _fetchPointsOfInterest(token, locationId, cityName),
    ]);
    return [...results[0], ...results[1]];
  }

  Future<List<Place>> _fetchTouristServices(
      String token, int locationId, String cityName) async {
    try {
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.touristServices}?active=true&limit=50&id_location=$locationId',
      );
      final response = await http
          .get(uri, headers: _headers(token))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return [];

      final data = jsonDecode(response.body);
      final List<dynamic> services = data['services'] ?? [];

      return services.map((s) {
            final cat = _categoryFromServiceType(s['service_type'] as String?);
            if (cat == null) return null;
            return Place(
              id: 'svc_${s['id_service']}',
              name: (s['name'] ?? '') as String,
              city: cityName,
              category: cat,
              imageUrl: (s['image_url'] as String?) ?? '',
              rating: _toDouble(s['total_score'], fallback: 4.0),
              shortDescription: _truncate(s['description'] as String?, 80),
              description: (s['description'] ?? '') as String,
              locationLine: cityName,
              galleryUrls: const [],
            );
          })
          .whereType<Place>()
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<Place>> _fetchPointsOfInterest(
      String token, int locationId, String cityName) async {
    try {
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.pointsOfInterest}?id_location=$locationId&limit=50',
      );
      final response = await http
          .get(uri, headers: _headers(token))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return [];

      final data = jsonDecode(response.body);
      final List<dynamic> points = data['points'] ?? [];

      return points.map((p) {
        final cat =
            _categoryFromPoiType(p['id_type'] as int?) ?? PlaceCategory.museums;
        return Place(
          id: 'poi_${p['id_point']}',
          name: (p['name'] ?? '') as String,
          city: cityName,
          category: cat,
          imageUrl: (p['image_url'] as String?) ?? '',
          rating: _toDouble(p['rating'], fallback: 4.0),
          shortDescription: _truncate(p['description'] as String?, 80),
          description: (p['description'] ?? '') as String,
          locationLine: cityName,
          galleryUrls: const [],
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static double _toDouble(dynamic value, {double fallback = 0.0}) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? fallback;
    return fallback;
  }

  static String _truncate(String? text, int maxLen) {
    if (text == null || text.length <= maxLen) return text ?? '';
    return '${text.substring(0, maxLen)}…';
  }

  static IconData _iconForCity(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('orizaba')) return Icons.cable;
    if (lower.contains('córdoba') || lower.contains('cordoba')) {
      return Icons.local_cafe;
    }
    if (lower.contains('fortín') || lower.contains('fortin')) {
      return Icons.local_florist;
    }
    return Icons.location_city;
  }
}

class ExploreException implements Exception {
  final String message;
  ExploreException(this.message);
  @override
  String toString() => message;
}
