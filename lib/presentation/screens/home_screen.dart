import 'package:flutter/material.dart';
import '../../core/style_guide.dart'; 

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('SMARTUR', style: SmarturStyle.calSansTitle.copyWith(fontSize: 20)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline, color: SmarturStyle.textPrimary),
            onPressed: () {
              // Aquí irá el perfil de Martín
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hola, Martín 👋",
              style: SmarturStyle.calSansTitle.copyWith(fontSize: 28),
            ),
            const SizedBox(height: 8),
            const Text(
              "¿Qué aventura te espera hoy en las Altas Montañas?",
              style: TextStyle(fontFamily: 'Outfit', color: SmarturStyle.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 24),
            
            // BUSCADOR (UX Tip: Siempre accesible)
            TextField(
              decoration: InputDecoration(
                hintText: "Buscar rutas o destinos...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // SECCIÓN DE RECOMENDACIONES (IA Ready)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Recomendado para ti", style: SmarturStyle.calSansTitle.copyWith(fontSize: 18)),
                const Text("Ver todo", style: TextStyle(color: SmarturStyle.purple, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            
            // Tarjeta de ejemplo
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  colors: [SmarturStyle.purple, SmarturStyle.purple.withOpacity(0.7)],
                ),
              ),
              child: const Center(
                child: Text(
                  "Aquí aparecerán tus rutas",
                  style: TextStyle(color: Colors.white, fontFamily: 'Outfit'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}