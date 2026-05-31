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

  // Cache: avoid hitting GitHub API on every tap
  static DateTime? _lastCheck;
  static ({bool hasUpdate, String latestVersion, String currentVersion})? _cached;

  // Don't show the dialog more than once per session
  static bool _shownThisSession = false;

  static Future<String> currentVersion() async {
    final info = await PackageInfo.fromPlatform();
    return info.version;
  }

  /// Checks GitHub for a newer release. Caches result for 1 hour.
  /// Never throws — returns hasUpdate=false on any error.
  static Future<({bool hasUpdate, String latestVersion, String currentVersion})> check({
    bool forceRefresh = false,
  }) async {
    final now = DateTime.now();
    if (!forceRefresh &&
        _cached != null &&
        _lastCheck != null &&
        now.difference(_lastCheck!) < const Duration(hours: 1)) {
      return _cached!;
    }

    try {
      final info = await PackageInfo.fromPlatform();
      final current = info.version;

      final resp = await http
          .get(Uri.parse(_apiUrl),
              headers: {'Accept': 'application/vnd.github+json'})
          .timeout(const Duration(seconds: 8));

      if (resp.statusCode != 200) {
        return _cache((hasUpdate: false, latestVersion: current, currentVersion: current));
      }

      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      final tag = (body['tag_name'] as String? ?? '').replaceFirst('v', '');
      if (tag.isEmpty || (body['prerelease'] as bool? ?? false)) {
        return _cache((hasUpdate: false, latestVersion: current, currentVersion: current));
      }

      return _cache((
        hasUpdate: _isNewer(tag, current),
        latestVersion: tag,
        currentVersion: current,
      ));
    } catch (_) {
      final fallback = await PackageInfo.fromPlatform().catchError((_) =>
          PackageInfo(appName: '', packageName: '', version: '?', buildNumber: ''));
      return (hasUpdate: false, latestVersion: '?', currentVersion: fallback.version);
    }
  }

  static ({bool hasUpdate, String latestVersion, String currentVersion}) _cache(
      ({bool hasUpdate, String latestVersion, String currentVersion}) result) {
    _cached = result;
    _lastCheck = DateTime.now();
    return result;
  }

  /// Call once after login. Shows dialog only if update available and not yet
  /// shown this session. Non-blocking — caller does not need to await.
  static Future<void> checkAndPromptIfNeeded(BuildContext context) async {
    if (_shownThisSession) return;
    final result = await check();
    if (!result.hasUpdate) return;
    if (!context.mounted) return;
    _shownThisSession = true;
    showUpdateDialog(context, result.latestVersion);
  }

  static bool _isNewer(String latest, String current) {
    // Strip any pre-release suffix (e.g. "2.3.2-beta" → "2.3.2")
    final clean = (String v) => v.split('-').first;
    final parse = (String v) =>
        clean(v).split('.').map((p) => int.tryParse(p) ?? 0).toList();
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

  /// Open the APK download URL in the external browser.
  static Future<void> openDownload() async {
    final uri = Uri.parse(_downloadUrl);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    }
  }

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
