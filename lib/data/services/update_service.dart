import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateService {
  static const _apiUrl =
      'https://api.github.com/repos/tinnlaroli/smartur-movil/releases/latest';
  static const _downloadUrl =
      'https://github.com/tinnlaroli/smartur-movil/releases/latest/download/app-release.apk';

  /// Versión instalada actualmente (ej. "2.2.7").
  static Future<String> currentVersion() async {
    final info = await PackageInfo.fromPlatform();
    return info.version;
  }

  /// Retorna hasUpdate=true y la versión latest si hay una versión más nueva.
  /// Silencioso — nunca lanza excepción.
  static Future<({bool hasUpdate, String latestVersion, String currentVersion})> check() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final current = info.version;

      final resp = await http
          .get(Uri.parse(_apiUrl),
              headers: {'Accept': 'application/vnd.github+json'})
          .timeout(const Duration(seconds: 8));

      if (resp.statusCode != 200) {
        return (hasUpdate: false, latestVersion: current, currentVersion: current);
      }

      final tag = (jsonDecode(resp.body)['tag_name'] as String? ?? '')
          .replaceFirst('v', '');
      if (tag.isEmpty) {
        return (hasUpdate: false, latestVersion: current, currentVersion: current);
      }

      return (
        hasUpdate: _isNewer(tag, current),
        latestVersion: tag,
        currentVersion: current,
      );
    } catch (_) {
      final info = await PackageInfo.fromPlatform().catchError((_) =>
          PackageInfo(appName: '', packageName: '', version: '?', buildNumber: ''));
      return (hasUpdate: false, latestVersion: '?', currentVersion: info.version);
    }
  }

  static bool _isNewer(String latest, String current) {
    final parse = (String v) =>
        v.split('.').map((p) => int.tryParse(p) ?? 0).toList();
    final l = parse(latest);
    final c = parse(current);
    for (var i = 0; i < 3; i++) {
      final lv = i < l.length ? l[i] : 0;
      final cv = i < c.length ? c[i] : 0;
      if (lv > cv) return true;
      if (lv < cv) return false;
    }
    return false;
  }

  /// Abre el APK en el navegador externo. Usa launchUrl directo — canLaunchUrl
  /// falla en Android con https si no está declarado el intent (ya está en manifest).
  static Future<void> openDownload() async {
    final uri = Uri.parse(_downloadUrl);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      // Fallback: intentar con el modo de plataforma por defecto
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    }
  }

  /// Muestra diálogo de actualización disponible.
  static void showUpdateDialog(BuildContext context, String latestVersion) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.system_update_rounded, color: Color(0xFF7C3AED)),
            SizedBox(width: 8),
            Text('Nueva versión disponible',
                style: TextStyle(fontFamily: 'CalSans', fontSize: 18)),
          ],
        ),
        content: Text(
          'La versión $latestVersion de SMARTUR está disponible.\n'
          'Descárgala para disfrutar las últimas mejoras y correcciones.',
          style: const TextStyle(fontFamily: 'Outfit', fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Después', style: TextStyle(color: Colors.grey)),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              UpdateService.openDownload();
            },
            icon: const Icon(Icons.download_rounded),
            label: const Text('Actualizar ahora'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF7C3AED),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}
