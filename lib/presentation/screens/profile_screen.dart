import 'package:flutter/material.dart';

import '../../core/style_guide.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Perfil Completo', style: SmarturStyle.calSansTitle.copyWith(fontSize: 20)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_outline, size: 80, color: SmarturStyle.purple),
            const SizedBox(height: 16),
            Text(
              "Tu Perfil",
              style: SmarturStyle.calSansTitle.copyWith(fontSize: 22),
            ),
            const SizedBox(height: 8),
            const Text(
              "Administra todos tus datos.",
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Outfit', color: SmarturStyle.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
