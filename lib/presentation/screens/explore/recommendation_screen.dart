import 'package:flutter/material.dart';

import '../../../core/theme/style_guide.dart';

class RecommendationScreen extends StatelessWidget {
  final String? city;

  const RecommendationScreen({super.key, this.city});

  @override
  Widget build(BuildContext context) {
    final displayCity = city ?? 'Altas Montañas';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Recomendaciones en $displayCity',
          style: SmarturStyle.calSansTitle.copyWith(fontSize: 20),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            elevation: 3,
            shadowColor: Colors.black.withOpacity(0.06),
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: CircleAvatar(
                backgroundColor: SmarturStyle.purple.withOpacity(0.1),
                child: const Icon(Icons.star, color: SmarturStyle.purple),
              ),
              title: Text(
                'Recomendación #${index + 1}',
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              subtitle: Text(
                'Sugerido por la IA de SMARTUR para tu visita a $displayCity.',
                style: const TextStyle(
                  fontFamily: 'Outfit',
                  fontSize: 12,
                  color: SmarturStyle.textSecondary,
                ),
              ),
              trailing: const Icon(Icons.chevron_right, color: SmarturStyle.textSecondary),
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}

