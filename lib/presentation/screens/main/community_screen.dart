import 'package:flutter/material.dart';
import 'package:smartur/l10n/app_localizations.dart';

import '../../../core/theme/style_guide.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.communityTitle,
            style: SmarturStyle.calSansTitle.copyWith(fontSize: 20)),
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(bottom: 80),
        itemCount: 8,
        itemBuilder: (context, index) => _PostCard(index: index),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: SmarturStyle.purple,
        onPressed: () {
          // Aquí integrarías ImagePicker para subir foto real
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.uploadPhotoAction)),
          );
        },
        child: const Icon(Icons.add_a_photo),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final int index;

  const _PostCard({required this.index});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: SmarturStyle.purple.withValues(alpha: 0.15),
                child: const Icon(Icons.person, color: SmarturStyle.purple),
              ),
              title: Text(
                'Turista ${index + 1}',
                style: const TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.w600),
              ),
              subtitle: const Text(
                'Lugar destacado en las Altas Montañas',
                style: TextStyle(fontFamily: 'Outfit', fontSize: 12),
              ),
            ),
            AspectRatio(
              aspectRatio: 4 / 3,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                ),
                child: const Icon(Icons.photo, size: 64, color: SmarturStyle.textSecondary),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.favorite_border),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.bookmark_border),
                  ),
                  const Spacer(),
                  Text(
                    'Hace ${index + 1} h',
                    style: const TextStyle(
                      fontFamily: 'Outfit',
                      fontSize: 11,
                      color: SmarturStyle.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
