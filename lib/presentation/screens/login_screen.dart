// import 'package:flutter/material.dart';
// import '../../core/style_guide.dart';

// class LoginScreen extends StatelessWidget {
// const LoginScreen({super.key});

// @override
// Widget build(BuildContext context) {
//     return Scaffold(
//     backgroundColor: Colors.white,
//     body: SafeArea(
//         child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: SmarturStyle.spacingLg),
//         child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [

//             const Text(
//                 'SMARTUR',
//                 style: SmarturStyle.calSansTitle,
//                 textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 8),
//             const Text(
//                 'Tu guía inteligente en las Altas Montañas',
//                 style: TextStyle(fontFamily: 'Outfit', color: SmarturStyle.textSecondary),
//                 textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 48),

//             TextField(
//                 decoration: InputDecoration(
//                 labelText: 'Correo electrónico',
//                 labelStyle: const TextStyle(fontFamily: 'Outfit'),
//                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                 prefixIcon: const Icon(Icons.email_outlined, color: SmarturStyle.purple),
//                 ),
//             ),
//             const SizedBox(height: 16),

//             TextField(
//                 obscureText: true,
//                 decoration: InputDecoration(
//                 labelText: 'Contraseña',
//                 labelStyle: const TextStyle(fontFamily: 'Outfit'),
//                 border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                 prefixIcon: const Icon(Icons.lock_outline, color: SmarturStyle.purple),
//                 ),
//             ),
            
//             const SizedBox(height: 32),


//             ElevatedButton(
//                 onPressed: () {

//                 print('Intento de login...');
//                 },
//                 child: const Text('INICIAR SESIÓN'),
//             ),

//             const SizedBox(height: 16),

//             TextButton(
//                 onPressed: () {},
//                 child: RichText(
//                 text: const TextSpan(
//                     style: TextStyle(fontFamily: 'Outfit', color: SmarturStyle.textPrimary),
//                     children: [
//                     TextSpan(text: '¿No tienes cuenta? '),
//                     TextSpan(
//                         text: 'Regístrate',
//                         style: TextStyle(color: SmarturStyle.purple, fontWeight: FontWeight.bold),
//                     ),
//                     ],
//                 ),
//                 ),
//             ),
//             ],
//         ),
//         ),
//     ),
//     );
// }
// }
