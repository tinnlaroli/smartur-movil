import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';

import '../../../core/theme/style_guide.dart';
import '../../../core/utils/notifications.dart';
import '../../../data/services/auth_service.dart';
import '../../widgets/smartur_background.dart';
import '../main/main_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  final LocalAuthentication _auth = LocalAuthentication();
  final AuthService _authService = AuthService();
  
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _logoScale; // para huella/botón
  late Animation<double> _logoZoom;  // continuidad del zoom del loader
  late Animation<Offset> _textSlide;
  late Animation<double> _buttonFade;
  late Animation<double> _buttonScale;
  late Animation<Offset> _buttonSlide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    // Fade general para textos/huella/botón (claramente visible)
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.25, 1.0, curve: Curves.easeOutQuad),
    );

    // Escala 0.8 → 1.05 para contenido (texto/huella) con rebote suave.
    _logoScale = Tween<double>(begin: 0.8, end: 1.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.9, curve: Curves.easeOutBack),
      ),
    );

    // Logo: pequeño rebote  (1.02 → 0.96 → 1.0) para dar vida al final del zoom.
    _logoZoom = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.12, end: 0.36)
            .chain(CurveTween(curve: Curves.easeOutQuad)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.36, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 60,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
    ));

    _buttonFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.55, 1.0, curve: Curves.easeOutQuad),
    );

    // Botón "Comenzar": pop claro y deslizamiento largo hacia arriba
    _buttonScale = Tween<double>(begin: 0.75, end: 1.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.elasticOut),
      ),
    );

    _buttonSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.55, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    // Importante: NO iniciar animaciones inmediatamente.
    // Esperamos aproximadamente la duración del loader para que
    // las animaciones se vean recién cuando el overlay desaparece.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 4600));
      if (mounted && !_controller.isAnimating && _controller.value == 0.0) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // --- RESTORED AUTH MODAL LOGIC ---
  void _showAuthModal(BuildContext context, {bool isLogin = false}) {
    bool isExpanded = false;
    bool isWaitingOTP = false;
    bool isLoadingEmail = false;
    bool isLoadingGoogle = false;
    bool rememberMe = false;
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController otpController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            double? height = isExpanded
                ? MediaQuery.of(context).size.height * 0.75
                : null;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: height,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              padding: EdgeInsets.only(
                left: SmarturStyle.spacingLg,
                right: SmarturStyle.spacingLg,
                top: 12,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        isLogin ? 'Bienvenido de nuevo' : 'Empezar ahora',
                        style: SmarturStyle.calSansTitle,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isLogin
                            ? 'Ingresa tus credenciales para continuar.'
                            : 'Regístrate para descubrir rutas personalizadas.',
                        style: const TextStyle(
                          fontFamily: 'Outfit',
                          color: SmarturStyle.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 32),
                      if (!isExpanded) ...[
                        ElevatedButton(
                          onPressed: () => setModalState(() => isExpanded = true),
                          child: Text(isLogin ? 'Continuar con Email' : 'Registrarse con Email'),
                        ),
                      ] else ...[
                        if (isWaitingOTP)
                          Column(
                            children: [
                              Text(
                                "Se envió un código a:",
                                style: TextStyle(fontFamily: 'Outfit', color: SmarturStyle.textSecondary, fontSize: 13),
                              ),
                              Text(
                                emailController.text,
                                style: TextStyle(fontFamily: 'Outfit', fontWeight: FontWeight.bold, color: SmarturStyle.textPrimary),
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                controller: otpController,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 24,
                                  letterSpacing: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                                decoration: InputDecoration(
                                  hintText: "000000",
                                  helperText: "Ingresa el código de 6 dígitos",
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                              ),
                              TextButton(
                                onPressed: () => setModalState(() {
                                  isWaitingOTP = false;
                                  otpController.clear();
                                }),
                                child: const Text('Cambiar correo', style: TextStyle(color: SmarturStyle.purple)),
                              ),
                            ],
                          )
                        else ...[
                          _buildAuthFields(
                            isLogin,
                            nameController,
                            emailController,
                            passwordController,
                            setModalState,
                          ),
                          if (isLogin) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Checkbox(
                                  value: rememberMe,
                                  onChanged: (val) {
                                    setModalState(() {
                                      rememberMe = val ?? false;
                                    });
                                  },
                                ),
                                const SizedBox(width: 4),
                                const Expanded(
                                  child: Text(
                                    'Recuérdame durante 7 días en este dispositivo',
                                    style: TextStyle(
                                      fontFamily: 'Outfit',
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: (isLoadingEmail || isLoadingGoogle)
                              ? null
                              : () async {
                                  if (formKey.currentState!.validate()) {
                                    setModalState(() => isLoadingEmail = true);
                                    try {
                                      if (isLogin) {
                                        if (!isWaitingOTP) {
                                          final response = await _authService.loginStep1(
                                            emailController.text.trim(),
                                            passwordController.text.trim(),
                                          );
                                          if (response != null && response['requiresVerification'] == true) {
                                            setModalState(() => isWaitingOTP = true);
                                          } else {
                                            if (context.mounted) {
                                              SmarturNotifications.showError(context, "Credenciales incorrectas.");
                                            }
                                          }
                                        } else {
                                          final token = await _authService.verifyOTP(
                                            emailController.text.trim(),
                                            otpController.text.trim(),
                                            rememberMe: rememberMe,
                                          );
                                          if (token != null && context.mounted) {
                                            Navigator.pop(context);
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => MainScreen(
                                                  userName: nameController.text.trim().isNotEmpty
                                                      ? nameController.text.trim()
                                                      : null,
                                                  isNewLogin: true,
                                                ),
                                              ),
                                            );
                                          } else {
                                            if (context.mounted) {
                                              SmarturNotifications.showError(context, "Código inválido o expirado.");
                                            }
                                          }
                                        }
                                      } else {
                                        bool success = await _authService.register(
                                          nameController.text.trim(),
                                          emailController.text.trim(),
                                          passwordController.text.trim(),
                                        );
                                        if (success && context.mounted) {
                                          setModalState(() => isLogin = true);
                                          SmarturNotifications.showSuccess(context, "Cuenta creada exitosamente. Por favor, inicia sesión.");
                                        }
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        SmarturNotifications.showError(context, "Error de conexión.");
                                      }
                                    } finally {
                                      setModalState(() => isLoadingEmail = false);
                                    }
                                  }
                                },
                          child: isLoadingEmail
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : Text(isWaitingOTP ? 'VERIFICAR' : (isLogin ? 'ENTRAR' : 'CREAR CUENTA')),
                        ),
                      ],
                      if (!isWaitingOTP) ...[
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: (isLoadingEmail || isLoadingGoogle)
                              ? null
                              : () async {
                                  setModalState(() => isLoadingGoogle = true);
                                  try {
                                    final response = await _authService.loginWithGoogle(
                                      rememberMe: rememberMe,
                                    );
                                    if (response != null && context.mounted) {
                                      Navigator.pop(context);
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const MainScreen(
                                            userName: null,
                                            isNewLogin: true,
                                          ),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      SmarturNotifications.showError(context, e.toString());
                                    }
                                  } finally {
                                    setModalState(() => isLoadingGoogle = false);
                                  }
                                },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey[300]!),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: isLoadingGoogle
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: SmarturStyle.purple),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.network(
                                      'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1024px-Google_%22G%22_logo.svg.png',
                                      height: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Continuar con Google',
                                      style: TextStyle(
                                        color: SmarturStyle.textPrimary,
                                        fontFamily: 'Outfit',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ],
                      const SizedBox(height: 32),
                      TextButton(
                        onPressed: () => setModalState(() {
                          isLogin = !isLogin;
                          isWaitingOTP = false; // Reset OTP state when switching
                          otpController.clear();
                        }),
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(fontFamily: 'Outfit', color: SmarturStyle.textPrimary),
                            children: [
                              TextSpan(text: isLogin ? '¿No tienes cuenta? ' : '¿Ya tienes una cuenta? '),
                              TextSpan(text: isLogin ? 'Regístrate' : 'Inicia sesión', style: const TextStyle(color: SmarturStyle.purple, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAuthFields(
    bool isLogin,
    TextEditingController nameCtrl,
    TextEditingController emailCtrl,
    TextEditingController passCtrl,
    StateSetter setModalState,
  ) {
    String password = passCtrl.text;
    double strength = _getPasswordStrength(password);
    Color strengthColor = _getStrengthColor(strength);

    // Regex checks for real-time feedback
    bool hasMinLength = password.length >= 8;
    bool hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
    bool hasLowercase = RegExp(r'[a-z]').hasMatch(password);
    bool hasNumber = RegExp(r'[0-9]').hasMatch(password);
    bool hasSpecial = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);

    return Column(
      children: [
        if (!isLogin) ...[
          TextFormField(
            controller: nameCtrl,
            decoration: InputDecoration(
              labelText: 'Nombre completo',
              prefixIcon: const Icon(Icons.person_outline, color: SmarturStyle.purple),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Ingresa tu nombre completo';
              if (v.length < 3) return 'Mínimo 3 letras';
              return null;
            },
          ),
          const SizedBox(height: 16),
        ],
        TextFormField(
          controller: emailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Correo electrónico',
            prefixIcon: const Icon(Icons.email_outlined, color: SmarturStyle.purple),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Ingresa tu correo';
            if (isLogin) return null;
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) return 'Ingresa un correo válido';
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: passCtrl,
          obscureText: true,
          onChanged: (value) => setModalState(() {}), // Trigger modal rebuild for real-time feedback
          decoration: InputDecoration(
            labelText: 'Contraseña',
            prefixIcon: const Icon(Icons.lock_outline, color: SmarturStyle.purple),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Ingresa tu contraseña';
            if (isLogin) return null;
            if (v.length < 8) return 'Mínimo 8 caracteres';
            if (!RegExp(r'[A-Z]').hasMatch(v)) return 'Al menos una mayúscula';
            if (!RegExp(r'[a-z]').hasMatch(v)) return 'Al menos una minúscula';
            if (!RegExp(r'[0-9]').hasMatch(v)) return 'Al menos un número';
            if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(v)) return 'Al menos un carácter especial';
            return null;
          },
        ),
        if (!isLogin) ...[
          const SizedBox(height: 12),
          // Strength Meter
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: strength,
              backgroundColor: Colors.grey[200],
              color: strengthColor,
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              _getStrengthText(strength),
              style: TextStyle(
                fontSize: 12,
                color: strengthColor,
                fontWeight: FontWeight.bold,
                fontFamily: 'Outfit',
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Requirements Checklist
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'La contraseña debe tener:',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                ),
                const SizedBox(height: 8),
                _buildRequirementRow('Mínimo 8 caracteres', hasMinLength),
                _buildRequirementRow('Al menos una mayúscula', hasUppercase),
                _buildRequirementRow('Al menos una minúscula', hasLowercase),
                _buildRequirementRow('Al menos un número', hasNumber),
                _buildRequirementRow('Un carácter especial (!@#\$%^&*)', hasSpecial),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildRequirementRow(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.circle_outlined,
            size: 16,
            color: isMet ? Colors.green : Colors.grey[400],
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: isMet ? Colors.green[700] : Colors.grey[600],
              fontFamily: 'Outfit',
              decoration: isMet ? TextDecoration.lineThrough : null,
            ),
          ),
        ],
      ),
    );
  }

  double _getPasswordStrength(String password) {
    if (password.isEmpty) return 0.1; // Show a tiny bit so bar isn't empty
    double strength = 0;
    if (password.length >= 8) strength += 0.2;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.2;
    if (RegExp(r'[a-z]').hasMatch(password)) strength += 0.2;
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.2;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) strength += 0.2;
    return strength;
  }

  Color _getStrengthColor(double strength) {
    if (strength <= 0.2) return Colors.red;
    if (strength <= 0.4) return Colors.orange;
    if (strength <= 0.6) return Colors.amber;
    if (strength <= 0.8) return Colors.lightGreen;
    return Colors.green;
  }

  String _getStrengthText(double strength) {
    if (strength <= 0.2) return 'Muy débil';
    if (strength <= 0.4) return 'Débil';
    if (strength <= 0.6) return 'Regular';
    if (strength <= 0.8) return 'Fuerte';
    return 'Muy fuerte';
  }

  // --- RESTORED BIOMETRICS LOGIC ---
  Future<void> _checkBiometrics(BuildContext context) async {
    try {
      final bool biometricOn = await _authService.isBiometricEnabled();
      if (!biometricOn) {
        if (context.mounted) SmarturNotifications.showWarning(context, 'Inicia sesión y activa la huella en tu perfil');
        return;
      }

      final bool canAuth = await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
      if (!canAuth) {
        if (context.mounted) SmarturNotifications.showWarning(context, 'Dispositivo no compatible');
        return;
      }

      final List<BiometricType> available = await _auth.getAvailableBiometrics();
      if (available.isEmpty) {
        if (context.mounted) SmarturNotifications.showInfo(context, 'No hay huellas registradas');
        return;
      }

      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: 'Accede a tus rutas de SMARTUR',
        options: const AuthenticationOptions(biometricOnly: true, stickyAuth: true),
      );

      if (!didAuthenticate) return;

      final String? token = await _authService.getToken();
      if (token != null && context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const MainScreen(
              userName: null,
              isNewLogin: false,
            ),
          ),
        );
      } else if (context.mounted) {
        await _authService.clearSession();
        SmarturNotifications.showInfo(context, 'Sesión expirada. Inicia sesión de nuevo.');
      }
    } catch (e) {
      if (context.mounted) SmarturNotifications.showError(context, 'Error al leer huella.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SmarturBackground(
        child: Stack(
          children: [
            // Logo principal EXACTAMENTE centrado (mismas dimensiones que el SVG del loader)
            // Mientras corre el loader, este logo permanece invisible; solo se muestra
            // cuando el controller del WelcomeScreen arranca, evitando "doble logo".
            Align(
              alignment: Alignment.center,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: AnimatedBuilder(
                  animation: _logoZoom,
                  builder: (_, child) {
                    return Transform.scale(
                      scale: _logoZoom.value,
                      child: child,
                    );
                  },
                  child: Image.asset(
                    'assets/imgs/logo.png',
                    width: 170.42,
                    height: 219.53,
                  ),
                ),
              ),
            ),
            // Textos y huella: flotan justo por encima del botón "Comenzar"
            Positioned(
              left: SmarturStyle.spacingLg,
              right: SmarturStyle.spacingLg,
              bottom: 130, // un poco por encima del botón (que está en bottom: 50)
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SlideTransition(
                    position: _textSlide,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: const Text(
                        'Experiencias Únicas\nEmpiezan Aquí',
                        style: SmarturStyle.calSansTitle,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _logoScale,
                      child: GestureDetector(
                        onTap: () => _checkBiometrics(context),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: SmarturStyle.purple.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(color: SmarturStyle.purple, width: 2),
                          ),
                          child: const Icon(Icons.fingerprint, size: 40, color: SmarturStyle.purple),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: const Text(
                      'Ingresar con huella',
                      style: TextStyle(
                        fontFamily: 'Outfit',
                        color: SmarturStyle.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 50,
              left: SmarturStyle.spacingLg,
              right: SmarturStyle.spacingLg,
              child: FadeTransition(
                opacity: _buttonFade,
                child: SlideTransition(
                  position: _buttonSlide,
                  child: ScaleTransition(
                    scale: _buttonScale,
                    child: ElevatedButton(
                      onPressed: () => _showAuthModal(context, isLogin: true),
                      child: const Text('Comenzar'),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
