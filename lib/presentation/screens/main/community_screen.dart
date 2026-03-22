import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smartur/l10n/app_localizations.dart';

import '../../../core/theme/style_guide.dart';
import '../../../core/utils/notifications.dart';
import '../../../data/models/place_model.dart';
import '../../../data/services/explore_service.dart';
import '../../../data/services/user_content_service.dart';
import '../../widgets/smartur_skeleton.dart';
import '../../widgets/smartur_user_avatar.dart';

/// Devuelve kind API (`svc` / `poi`) e id numérico desde [Place.id] tipo `svc_12`.
({String kind, int id})? _parsePlaceRef(String placeId) {
  if (placeId.startsWith('svc_')) {
    final n = int.tryParse(placeId.substring(4));
    if (n != null) return (kind: 'svc', id: n);
  }
  if (placeId.startsWith('poi_')) {
    final n = int.tryParse(placeId.substring(4));
    if (n != null) return (kind: 'poi', id: n);
  }
  return null;
}

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _posts = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await UserContentService().fetchCommunityPosts();
      final list = data['posts'] as List<dynamic>? ?? [];
      if (mounted) {
        setState(() {
          _posts = list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _showCreateSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: _CreatePostSheet(
          onPublished: () {
            Navigator.pop(ctx);
            _load();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.communityTitle,
            style: SmarturStyle.calSansTitle.copyWith(fontSize: 20)),
        elevation: 0,
      ),
      body: _error != null && !_loading
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(_error!, textAlign: TextAlign.center),
              ),
            )
          : RefreshIndicator(
              color: SmarturStyle.purple,
              onRefresh: _load,
              child: SmarturShimmer(
                enabled: _loading,
                child: _loading
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 80),
                        children: const [
                          SkeletonCommunityPostCard(),
                          SkeletonCommunityPostCard(),
                          SkeletonCommunityPostCard(),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: _posts.length,
                        itemBuilder: (context, index) =>
                            _PostCard(data: _posts[index]),
                      ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: SmarturStyle.purple,
        foregroundColor: Colors.white,
        onPressed: _showCreateSheet,
        tooltip: l10n.communityCreatePost,
        child: const Icon(Icons.post_add),
      ),
    );
  }
}

class _CreatePostSheet extends StatefulWidget {
  final VoidCallback onPublished;

  const _CreatePostSheet({required this.onPublished});

  @override
  State<_CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<_CreatePostSheet> {
  final _caption = TextEditingController();
  final _picker = ImagePicker();

  List<Place> _places = [];
  Place? _selected;
  bool _loadingPlaces = true;
  String? _placesError;
  Uint8List? _imageBytes;
  String? _imageName;
  String? _imageMime;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _loadPlaces();
  }

  @override
  void dispose() {
    _caption.dispose();
    super.dispose();
  }

  Future<void> _loadPlaces() async {
    try {
      final cities = await ExploreService().fetchCities();
      final all = <Place>[];
      for (final c in cities) {
        all.addAll(c.places);
      }
      if (!mounted) return;
      setState(() {
        _places = all;
        _loadingPlaces = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadingPlaces = false;
        _placesError = AppLocalizations.of(context)!.communityLoadPlacesError;
      });
    }
  }

  Future<void> _pickImage() async {
    final x = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 2048,
      imageQuality: 88,
    );
    if (x == null) return;
    final bytes = await x.readAsBytes();
    if (!mounted) return;
    setState(() {
      _imageBytes = bytes;
      _imageName = x.name;
      _imageMime = x.mimeType;
    });
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (_selected == null) {
      SmarturNotifications.showWarning(context, l10n.communityNeedPlace);
      return;
    }
    final ref = _parsePlaceRef(_selected!.id);
    if (ref == null) {
      SmarturNotifications.showWarning(context, l10n.communityNeedPlace);
      return;
    }
    final text = _caption.text.trim();
    if (text.isEmpty && (_imageBytes == null || _imageBytes!.isEmpty)) {
      SmarturNotifications.showWarning(context, l10n.communityNeedTextOrImage);
      return;
    }

    setState(() => _submitting = true);
    try {
      await UserContentService().createCommunityPost(
        placeKind: ref.kind,
        placeId: ref.id,
        caption: text,
        imageBytes: _imageBytes,
        imageFilename: _imageName,
        imageMimeType: _imageMime,
      );
      if (!mounted) return;
      SmarturNotifications.showSuccess(context, l10n.communityPostPublished);
      widget.onPublished();
    } on UserContentException catch (e) {
      if (mounted) {
        SmarturNotifications.showError(context, e.message);
      }
    } catch (e) {
      if (mounted) {
        SmarturNotifications.showError(context, e.toString());
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: scheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(l10n.communityCreatePost, style: SmarturStyle.calSansTitle.copyWith(fontSize: 22)),
            const SizedBox(height: 16),
            if (_loadingPlaces)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator(color: SmarturStyle.purple)),
              )
            else if (_placesError != null)
              Text(_placesError!, style: TextStyle(color: scheme.error, fontFamily: 'Outfit'))
            else
              InputDecorator(
                decoration: InputDecoration(
                  labelText: l10n.communitySelectPlace,
                  prefixIcon: const Icon(Icons.place_outlined, color: SmarturStyle.purple),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<Place>(
                    isExpanded: true,
                    hint: Text(
                      l10n.communitySelectPlaceHint,
                      style: TextStyle(fontFamily: 'Outfit', color: scheme.onSurfaceVariant),
                    ),
                    value: _selected,
                    items: _places
                        .map(
                          (p) => DropdownMenuItem(
                            value: p,
                            child: Text(
                              '${p.name} · ${p.city}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontFamily: 'Outfit', fontSize: 14),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _selected = v),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            TextField(
              controller: _caption,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: l10n.communityPostCaptionHint,
                alignLabelWithHint: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            if (_imageBytes != null)
              Stack(
                alignment: Alignment.topRight,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.memory(
                      _imageBytes!,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() {
                      _imageBytes = null;
                      _imageName = null;
                      _imageMime = null;
                    }),
                    icon: const Icon(Icons.close, color: Colors.white),
                    style: IconButton.styleFrom(backgroundColor: Colors.black54),
                    tooltip: l10n.communityRemoveImage,
                  ),
                ],
              )
            else
              OutlinedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.image_outlined),
                label: Text(l10n.communityAttachImage, style: const TextStyle(fontFamily: 'Outfit')),
              ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: SmarturStyle.purple,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _submitting
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(l10n.communityPublish, style: const TextStyle(fontFamily: 'Outfit')),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const _PostCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final caption = data['caption']?.toString() ?? '';
    final imageUrl = data['image_url']?.toString() ?? '';
    final placeName = data['place_name']?.toString() ?? '';
    final author = data['author'] as Map<String, dynamic>? ?? {};
    final name = author['name']?.toString() ?? 'Usuario';
    final photoUrl = author['photo_url'] as String?;
    final iconKey = author['avatar_icon_key'] as String?;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: SmarturUserAvatar(
                radius: 22,
                photoUrl: photoUrl,
                avatarIconKey: iconKey,
                displayName: name,
                backgroundColor: SmarturStyle.purple.withValues(alpha: 0.12),
                foregroundColor: SmarturStyle.purple,
              ),
              title: Text(
                name,
                style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w600),
              ),
            ),
            if (placeName.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Chip(
                    avatar: const Icon(Icons.place, size: 18, color: SmarturStyle.purple),
                    label: Text(
                      placeName,
                      style: const TextStyle(fontFamily: 'Outfit', fontSize: 13),
                    ),
                    backgroundColor: SmarturStyle.purple.withValues(alpha: 0.12),
                    side: BorderSide.none,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ),
            if (caption.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Text(
                  caption,
                  style: const TextStyle(fontFamily: 'Outfit', fontSize: 14),
                ),
              ),
            if (imageUrl.isNotEmpty)
              AspectRatio(
                aspectRatio: 4 / 3,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: scheme.outlineVariant,
                      child: Icon(Icons.photo, size: 64, color: scheme.onSurfaceVariant),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
