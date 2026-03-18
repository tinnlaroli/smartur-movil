import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';
import 'core/theme/style_guide.dart';
import 'data/services/auth_service.dart';
import 'presentation/screens/auth/onboarding_screen.dart';
import 'presentation/screens/auth/welcome_screen.dart';
import 'presentation/screens/main/main_screen.dart';
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
  bool? _hasSession;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final auth = AuthService();
    final has = await auth.hasSession();
    final name = has ? await auth.getUserName() : null;
    if (mounted) {
      setState(() {
        _hasSession = has;
        _userName = name;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final destination = _destination();

    return Stack(
      children: [
        // Contenido real de la app (welcome / onboarding / main)
        destination,
        // Loader como overlay a pantalla completa para continuidad perfecta
        if (_showLoader)
          Positioned.fill(
            child: SmartURLoader(
              key: const ValueKey('loader'),
              onFinished: () => setState(() => _showLoader = false),
            ),
          ),
      ],
    );
  }

  Widget _destination() {
    if (_hasSession == true) {
      return MainScreen(key: const ValueKey('main'), userName: _userName);
    }
    return widget.seenOnboarding
        ? const WelcomeScreen(key: ValueKey('welcome'))
        : const OnboardingScreen(key: ValueKey('onboarding'));
  }
}