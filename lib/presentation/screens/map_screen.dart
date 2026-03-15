import 'package:flutter/material.dart';

import '../../core/style_guide.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Mapa', style: SmarturStyle.calSansTitle.copyWith(fontSize: 20)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.map_outlined, size: 80, color: SmarturStyle.purple),
            const SizedBox(height: 16),
            Text(
              "Mapa de Exploración",
              style: SmarturStyle.calSansTitle.copyWith(fontSize: 22),
            ),
            const SizedBox(height: 8),
            const Text(
              "Aquí se mostrarán los pines de los lugares\ncon la ficha resumen de la IA.",
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Outfit', color: SmarturStyle.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
