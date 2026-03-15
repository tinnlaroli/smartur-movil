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
  bool seenOnboarding = prefs.getBool('onboarding_seen') ?? false;

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
            brightness: Brightness.light,
          ),
          textTheme: const TextTheme(
            displayLarge: TextStyle(fontFamily: 'CalSans', fontWeight: FontWeight.bold),
            displayMedium: TextStyle(fontFamily: 'CalSans', fontWeight: FontWeight.bold),
            titleLarge: TextStyle(fontFamily: 'CalSans', fontWeight: FontWeight.w600),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            titleTextStyle: TextStyle(
              fontFamily: 'CalSans',
              fontSize: 20,
              color: SmarturStyle.textPrimary,
            ),
            iconTheme: IconThemeData(color: SmarturStyle.textPrimary),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: SmarturStyle.purple,
              foregroundColor: Colors.white,
              elevation: 4,
              shadowColor: SmarturStyle.purple.withValues(alpha: 0.3),
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(
                fontFamily: 'CalSans',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: SmarturStyle.purple,
              side: const BorderSide(color: SmarturStyle.purple, width: 2),
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(
                fontFamily: 'Outfit',
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: SmarturStyle.purple, width: 2),
            ),
            labelStyle: const TextStyle(fontFamily: 'Outfit', color: SmarturStyle.textSecondary),
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
  bool _showLoader = true;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 800),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: _showLoader
          ? SmartURLoader(
              key: const ValueKey('loader'),
              onFinished: () => setState(() => _showLoader = false),
            )
          : (widget.seenOnboarding ? const WelcomeScreen() : const OnboardingScreen()),
    );
  }
}