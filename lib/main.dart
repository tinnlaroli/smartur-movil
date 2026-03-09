import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';
import 'core/style_guide.dart';
import 'presentation/screens/onboarding_screen.dart';
import 'presentation/screens/welcome_screen.dart';
import 'presentation/widgets/smartur_loader.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  
  // Leemos si ya vio el onboarding (por defecto es false)
  bool seenOnboarding = prefs.getBool('onboarding_seen') ?? false;
  // bool seenOnboarding = false; // TEMPORALMENTE DESACTIVADO PARA VER SIEMPRE EL ONBOARDING

  runApp(SmarturApp(seenOnboarding: seenOnboarding));
}

class SmarturApp extends StatelessWidget {
  final bool seenOnboarding;
  const SmarturApp({super.key, required this.seenOnboarding});

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: MaterialApp(
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
        home: _SplashGate(seenOnboarding: seenOnboarding),
      ),
    );
  }
}

class _SplashGate extends StatefulWidget {
  final bool seenOnboarding;
  const _SplashGate({required this.seenOnboarding});

  @override
  State<_SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<_SplashGate> {
  bool _loading = true;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.seenOnboarding ? WelcomeScreen() : OnboardingScreen(),
        if (_loading)
          SmartURLoader(
            onFinished: () => setState(() => _loading = false),
          ),
      ],
    );
  }
}