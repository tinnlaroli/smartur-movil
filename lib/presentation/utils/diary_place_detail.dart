import 'package:flutter/material.dart';

import '../screens/explore/detail_view_page.dart';

/// Construye `placeId` tipo `svc_12` / `poi_34` desde un ítem de favoritos o visitas API.
String? placeIdFromDiaryItem(Map<String, dynamic> it) {
  final k = it['place_kind']?.toString();
  final raw = it['place_id'];
  final id = raw is int ? raw : int.tryParse(raw?.toString() ?? '');
  if (k == null || id == null) return null;
  if (k == 'svc') return 'svc_$id';
  if (k == 'poi') return 'poi_$id';
  return null;
}

/// Abre la vista detalle de un lugar desde favoritos o historial.
void openDiaryItemDetail(BuildContext context, Map<String, dynamic> it) {
  final pid = placeIdFromDiaryItem(it);
  final name = it['name']?.toString() ?? '';
  final imageUrl = it['image_url']?.toString() ?? '';
  final desc = it['description']?.toString() ??
      it['short_description']?.toString() ??
      '';
  final locParts = <String>[
    if (it['location_line'] != null) it['location_line'].toString(),
    if (it['city'] != null) it['city'].toString(),
  ].where((s) => s.trim().isNotEmpty).toList();
  final locationLine = locParts.isNotEmpty ? locParts.join(' · ') : ' ';
  final rating = (it['rating'] is num)
      ? (it['rating'] as num).toDouble()
      : double.tryParse(it['rating']?.toString() ?? '') ?? 0.0;

  List<String> gallery = [];
  final g = it['gallery_urls'];
  if (g is List) {
    gallery = g.map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
  }
  if (gallery.isEmpty && imageUrl.isNotEmpty) {
    gallery = [imageUrl];
  }

  final heroKey = pid ?? 'noid_${name.hashCode}';

  Navigator.push<void>(
    context,
    PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 400),
      reverseTransitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, animation, secondaryAnimation) => DetailViewPage(
        title: name.isNotEmpty ? name : '—',
        heroTag: 'diary_$heroKey',
        heroImageUrl: imageUrl,
        subtitle: desc,
        locationLine: locationLine,
        rating: rating,
        galleryUrls: gallery,
        placeId: pid,
      ),
      transitionsBuilder: (context, anim, secondaryAnim, child) {
        return FadeTransition(opacity: anim, child: child);
      },
    ),
  );
}
