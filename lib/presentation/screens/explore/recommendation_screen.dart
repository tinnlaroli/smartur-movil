import 'package:flutter/material.dart';
import 'package:smartur/l10n/app_localizations.dart';

import '../../../core/theme/style_guide.dart';
import '../../widgets/smartur_background.dart';

class RecommendationScreen extends StatelessWidget {
  final String? city;

  const RecommendationScreen({super.key, this.city});

  @override
  Widget build(BuildContext context) {
    final displayCity = city ?? 'Altas Montañas';
    final l10n = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        title: Text(
          l10n.recommendationsInCity(displayCity),
          style: SmarturStyle.calSansTitle.copyWith(fontSize: 20),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: SmarturBackgroundTop(
        child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            elevation: 3,
            shadowColor: Colors.black.withValues(alpha: 0.06),
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: SmarturStyle.purple.withValues(alpha: 0.1),
                child: const Icon(Icons.star, color: SmarturStyle.purple),
              ),
              title: Text(
                l10n.recommendationNumber('${index + 1}'),
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              subtitle: Text(
                l10n.recommendationSubtitle(displayCity),
                style: TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 12,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              trailing: Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
              onTap: () {},
            ),
          );
        },
      ),
      ),
    );
  }
}

