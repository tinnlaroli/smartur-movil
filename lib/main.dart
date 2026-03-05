import 'package:flutter/material.dart';

import 'core/style_guide.dart';
import 'presentation/screens/welcome_screen.dart';
import 'presentation/widgets/smartur_loader.dart';

void main() {
  runApp(const SmarturApp());
}

class SmarturApp extends StatelessWidget {
  const SmarturApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SMARTUR',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Outfit',
        colorScheme: ColorScheme.fromSeed(
          seedColor: SmarturStyle.purple,
          primary: SmarturStyle.purple,
          secondary: SmarturStyle.pink,
          surface: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: SmarturStyle.purple,
            foregroundColor: Colors.white,
            minimumSize: const Size(
              double.infinity,
              SmarturStyle.touchTargetComfortable,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(fontFamily: 'CalSans', fontSize: 18),
          ),
        ),
      ),
      home: const _SplashGate(),
    );
  }
}

class _SplashGate extends StatefulWidget {
  const _SplashGate();

  @override
  State<_SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<_SplashGate> {
  bool _loading = true;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const WelcomeScreen(),
        if (_loading)
          SmartURLoader(
            onFinished: () => setState(() => _loading = false),
          ),
      ],
    );
  }
}