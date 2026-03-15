import 'package:flutter/material.dart';

import '../../core/style_guide.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Comunidad', style: SmarturStyle.calSansTitle.copyWith(fontSize: 20)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_outline, size: 80, color: SmarturStyle.purple),
            const SizedBox(height: 16),
            Text(
              "Red Social",
              style: SmarturStyle.calSansTitle.copyWith(fontSize: 22),
            ),
            const SizedBox(height: 8),
            const Text(
              "Conecta y comparte experiencias\ncon otros turistas.",
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Outfit', color: SmarturStyle.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
