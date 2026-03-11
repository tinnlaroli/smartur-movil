import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';

import '../../core/style_guide.dart';
import '../../core/utils/notifications.dart';
import '../../data/services/auth_service.dart';
import 'home_screen.dart';

class WelcomeScreen extends StatelessWidget {
  WelcomeScreen({super.key});

  final LocalAuthentication _auth = LocalAuthentication();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Stack(
        children: [
          // CAPA 0: Fondo SVG
          Positioned.fill(
            child: SvgPicture.asset(
              'assets/svg/bg.svg',
              fit: BoxFit.cover,
            ),
          ),
          // Capa de desenfoque superior
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18.0, sigmaY: 18.0),
              child: Container(
                color: Colors.white.withOpacity(0.65),
              ),
            ),
          ),
          Positioned(
            bottom: 150,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Image.asset(
                  'assets/imgs/logo_costado.png',
                  width: 100,
                  height: 100,
                ),

                const Text(
                  'Experiencias Únicas\nEmpiezan Aquí',
                  style: SmarturStyle.calSansTitle,
                  textAlign: TextAlign.center,
                ),
              
                const SizedBox(height: 40),

                // BOTÓN DE HUELLA DACTILAR
                GestureDetector(
                  onTap: () => _checkBiometrics(context),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: SmarturStyle.purple.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: SmarturStyle.purple, width: 2),
                    ),
                    child: const Icon(
                      Icons.fingerprint,
                      size: 40,
                      color: SmarturStyle.purple,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Ingresar con huella',
                  style: TextStyle(
                    fontFamily: 'Outfit',
                    color: SmarturStyle.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 50,
            left: SmarturStyle.spacingLg,
            right: SmarturStyle.spacingLg,
            child: ElevatedButton(
              onPressed: () => _showAuthModal(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: SmarturStyle.purple,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Comenzar',
                style: TextStyle(
                  fontFamily: 'CalSans',
                  fontWeight: FontWeight.bold,
                  color: SmarturStyle.bgSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAuthModal(BuildContext context, {bool isLogin = false}) {
    bool isExpanded = false;
    bool isWaitingOTP = false;
    bool isLoading = false;
    bool isPasswordVisible = false;
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
                          onPressed: () =>
                              setModalState(() => isExpanded = true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: SmarturStyle.purple,
                          ),
                          child: Text(
                            isLogin
                                ? 'Continuar con Email'
                                : 'Registrarse con Email',
                          ),
                        ),
                        const SizedBox(height: 12),
                        // ── GOOGLE LOGIN ────────────────────────────────────
                        OutlinedButton.icon(
                          onPressed: isLoading
                              ? null
                              : () async {
                                  setModalState(() => isLoading = true);
                                  try {
                                    final result =
                                        await _authService.loginWithGoogle();
                                    if (result != null) {
                                      if (context.mounted) {
                                        // Extrae el nombre del usuario de la respuesta del backend
                                        final String? name =
                                            result['name'] as String? ??
                                                result['user']?['name']
                                                    as String?;
                                        Navigator.pop(context);
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => HomeScreen(
                                              userName: name,
                                              isNewLogin: true,
                                            ),
                                          ),
                                        );
                                      }
                                    } else {
                                      if (context.mounted) {
                                        SmarturNotifications.showError(
                                          context,
                                          "No se pudo iniciar sesión con Google",
                                        );
                                      }
                                    }
                                  } finally {
                                    setModalState(() => isLoading = false);
                                  }
                                },
                          icon: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: SmarturStyle.purple,
                                  ),
                                )
                              : const Icon(Icons.g_mobiledata, size: 30),
                          label:
                              Text(isLoading ? 'Cargando...' : 'Continuar con Google'),
                        ),
                      ] else ...[
                        if (isWaitingOTP)
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
                              helperText:
                                  "Ingresa el código enviado a tu correo",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          )
                        else
                          _buildAuthFields(
                            isLogin,
                            nameController,
                            emailController,
                            passwordController,
                            isPasswordVisible,
                            (bool visible) =>
                                setModalState(() => isPasswordVisible = visible),
                          ),

                        const SizedBox(height: 24),

                        ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () async {
                                  if (formKey.currentState!.validate()) {
                                    setModalState(() => isLoading = true);

                                    try {
                                      if (isLogin) {
                                        if (!isWaitingOTP) {
                                          final response =
                                              await _authService.loginStep1(
                                            emailController.text.trim(),
                                            passwordController.text.trim(),
                                          );

                                          if (response != null &&
                                              response[
                                                      'requiresVerification'] ==
                                                  true) {
                                            setModalState(
                                              () => isWaitingOTP = true,
                                            );
                                          } else {
                                            SmarturNotifications.showError(
                                              context,
                                              "Credenciales incorrectas o problema de servidor.",
                                            );
                                          }
                                        } else {
                                          // ── OTP LOGIN ──────────────────────────────────────
                                          final token =
                                              await _authService.verifyOTP(
                                            emailController.text.trim(),
                                            otpController.text.trim(),
                                          );

                                          if (token != null) {
                                            if (context.mounted) {
                                              Navigator.pop(context);
                                              Navigator.pushReplacement(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      const HomeScreen(
                                                    isNewLogin: false,
                                                  ),
                                                ),
                                              );
                                            }
                                          } else {
                                            SmarturNotifications.showError(
                                              context,
                                              "El código de verificación es inválido o ha expirado.",
                                            );
                                          }
                                        }
                                      } else {
                                        bool success =
                                            await _authService.register(
                                          nameController.text.trim(),
                                          emailController.text.trim(),
                                          passwordController.text.trim(),
                                        );
                                        if (success) {
                                          setModalState(() => isLogin = true);
                                          SmarturNotifications.showSuccess(
                                            context,
                                            "Cuenta creada exitosamente. Por favor, inicia sesión.",
                                          );
                                        }
                                      }
                                    } catch (e) {
                                      SmarturNotifications.showError(
                                        context,
                                        "Error de conexión. Verifica tu internet e intenta de nuevo.",
                                      );
                                    } finally {
                                      setModalState(() => isLoading = false);
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: SmarturStyle.purple,
                            disabledBackgroundColor:
                                SmarturStyle.purple.withOpacity(0.6),
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  isWaitingOTP
                                      ? 'VERIFICAR'
                                      : (isLogin ? 'ENTRAR' : 'CREAR CUENTA'),
                                ),
                        ),
                      ],

                      const SizedBox(height: 32),

                      TextButton(
                        onPressed: () =>
                            setModalState(() => isLogin = !isLogin),
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontFamily: 'Outfit',
                              color: SmarturStyle.textPrimary,
                            ),
                            children: [
                              TextSpan(
                                text: isLogin
                                    ? '¿No tienes cuenta? '
                                    : '¿Ya tienes una cuenta? ',
                              ),
                              TextSpan(
                                text:
                                    isLogin ? 'Regístrate' : 'Inicia sesión',
                                style: const TextStyle(
                                  color: SmarturStyle.purple,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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
    bool isPasswordVisible,
    Function(bool) onVisibilityChanged,
  ) {
    return Column(
      children: [
        if (!isLogin) ...[
          TextFormField(
            controller: nameCtrl,
            decoration: InputDecoration(
              labelText: 'Nombre completo',
              prefixIcon: const Icon(
                Icons.person_outline,
                color: SmarturStyle.purple,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ingresa tu nombre completo';
              }
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
            prefixIcon: const Icon(
              Icons.email_outlined,
              color: SmarturStyle.purple,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Ingresa tu correo';
            }
            if (isLogin) return null;
            final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
            if (!emailRegex.hasMatch(value)) {
              return 'Ingresa un correo válido';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),
        TextFormField(
          controller: passCtrl,
          obscureText: !isPasswordVisible,
          decoration: InputDecoration(
            labelText: 'Contraseña',
            prefixIcon: const Icon(
              Icons.lock_outline,
              color: SmarturStyle.purple,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey,
              ),
              onPressed: () {
                onVisibilityChanged(!isPasswordVisible);
              },
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Ingresa tu contraseña';
            }
            if (isLogin) return null;
            if (value.length < 8) {
              return 'Mínimo 8 caracteres';
            }
            if (!RegExp(r'[A-Z]').hasMatch(value)) {
              return 'Al menos una mayúscula';
            }
            if (!RegExp(r'[a-z]').hasMatch(value)) {
              return 'Al menos una minúscula';
            }
            if (!RegExp(r'[0-9]').hasMatch(value)) {
              return 'Al menos un número';
            }
            if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
              return 'Al menos un carácter especial';
            }
            return null;
          },
        ),
      ],
    );
  }

  Future<void> _checkBiometrics(BuildContext context) async {
    try {
      final bool biometricOn = await _authService.isBiometricEnabled();
      if (!biometricOn) {
        if (context.mounted) {
          SmarturNotifications.showWarning(context,
              'Inicia sesión y activa el acceso con huella desde tu perfil');
        }
        return;
      }

      final bool canAuth =
          await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
      if (!canAuth) {
        if (context.mounted) {
          SmarturNotifications.showWarning(context,
              'Tu dispositivo no soporta autenticación biométrica');
        }
        return;
      }

      final List<BiometricType> available =
          await _auth.getAvailableBiometrics();
      if (available.isEmpty) {
        if (context.mounted) {
          SmarturNotifications.showInfo(
              context, 'No hay huellas registradas en tu dispositivo');
        }
        return;
      }

      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: 'Accede a tus rutas de SMARTUR',
        authMessages: const <AuthMessages>[
          AndroidAuthMessages(
            signInTitle: 'Seguridad SMARTUR',
            biometricHint: 'Toca el sensor de huellas',
            cancelButton: 'No, gracias',
          ),
        ],
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (!didAuthenticate) return;

      final String? token = await _authService.getToken();
      if (token != null && context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else if (context.mounted) {
        await _authService.clearSession();
        SmarturNotifications.showInfo(context,
            'Tu sesión ha expirado. Por favor, inicia sesión de nuevo.');
      }
    } catch (e) {
      if (context.mounted) {
        SmarturNotifications.showError(context,
            'Hubo un error al intentar leer tu huella. Intenta de nuevo.');
      }
    }
  }
}
