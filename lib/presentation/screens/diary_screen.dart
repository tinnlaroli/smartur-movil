import 'package:flutter/material.dart';

import '../../core/style_guide.dart';

class DiaryScreen extends StatelessWidget {
  const DiaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Mi Diario', style: SmarturStyle.calSansTitle.copyWith(fontSize: 20)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.menu_book_outlined, size: 80, color: SmarturStyle.purple),
            const SizedBox(height: 16),
            Text(
              "Tus Recuerdos e Historial",
              style: SmarturStyle.calSansTitle.copyWith(fontSize: 22),
            ),
            const SizedBox(height: 8),
            const Text(
              "Lugares favoritos y tu registro de visitas.\n(Disponible offline)",
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Outfit', color: SmarturStyle.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
