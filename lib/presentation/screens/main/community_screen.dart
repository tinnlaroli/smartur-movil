import 'package:flutter/material.dart';
import 'package:smartur/l10n/app_localizations.dart';

import '../../../core/theme/style_guide.dart';
import '../../../data/services/user_content_service.dart';
import '../../widgets/smartur_skeleton.dart';
import '../../widgets/smartur_user_avatar.dart';

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

  Future<void> _showCreateDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final captionCtrl = TextEditingController();
    final imageCtrl = TextEditingController();
    final scheme = Theme.of(context).colorScheme;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        actionsAlignment: MainAxisAlignment.center,
        actionsOverflowAlignment: OverflowBarAlignment.center,
        title: Text(l10n.uploadPhotoAction, style: SmarturStyle.calSansTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: captionCtrl,
                decoration: InputDecoration(
                  labelText: l10n.stepDetails,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: imageCtrl,
                decoration: InputDecoration(
                  labelText: 'URL imagen (opcional)',
                  hintText: 'https://...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel, style: TextStyle(color: scheme.onSurfaceVariant)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: SmarturStyle.purple),
            child: const Text('Publicar'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await UserContentService().createCommunityPost(
        caption: captionCtrl.text.trim(),
        imageUrl: imageCtrl.text.trim().isEmpty ? null : imageCtrl.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.profileReady)));
        await _load();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
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
        onPressed: _showCreateDialog,
        tooltip: l10n.communityCreatePost,
        child: const Icon(Icons.post_add),
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
            if (caption.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(
                  caption,
                  style: const TextStyle(fontFamily: 'Outfit', fontSize: 14),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
