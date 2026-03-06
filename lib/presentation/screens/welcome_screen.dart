import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';

import '../../core/style_guide.dart';
import '../../data/services/auth_service.dart';
import 'home_screen.dart';

class WelcomeScreen extends StatelessWidget {
  WelcomeScreen({super.key});

  final LocalAuthentication _auth = LocalAuthentication();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SmarturStyle.bgSecondary,
      body: Stack(
        children: [
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
              
                const SizedBox(height: 40), // Espacio entre el texto y el botón

                // BOTÓN DE HUELLA DACTILAR
                GestureDetector(
                  onTap: () => _checkBiometrics(context), // Aquí disparamos el sensor
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
    bool _isExpanded = false;
    bool _isWaitingOTP = false;
    bool _isLoading = false;

    final TextEditingController _emailController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();
    final TextEditingController _nameController = TextEditingController();
    final TextEditingController _otpController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,

      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            // Si está expandido, usa 3/4 (0.75), si no, se ajusta al contenido (null)
            double? height = _isExpanded
                ? MediaQuery.of(context).size.height * 0.75
                : null;

            return AnimatedContainer(
              duration: const Duration(
                milliseconds: 300,
              ), // Animación suave al crecer
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
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min, // Se ajusta al contenido inicialmente
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

                    // --- LÓGICA DE INTERFAZ DINÁMICA ---
                    if (!_isExpanded) ...[
                      ElevatedButton(
                        onPressed: () =>
                            setModalState(() => _isExpanded = true),
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
                      OutlinedButton.icon(
                        onPressed: () {}, // Aquí iría la lógica de Google
                        icon: const Icon(Icons.g_mobiledata, size: 30),
                        label: const Text('Continuar con Google'),
                      ),
                    ] else ...[
                      if (_isWaitingOTP)
                        // Mostramos SOLO el campo del código cuando estamos verificando
                        TextField(
                          controller: _otpController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            letterSpacing: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            hintText: "000000",
                            helperText: "Ingresa el código enviado a tu correo",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        )
                      else
                        // Mostramos el formulario normal de registro/login
                        _buildAuthFields(
                          isLogin,
                          _nameController,
                          _emailController,
                          _passwordController,
                        ),

                      const SizedBox(height: 24),

                      // --------------------------------------------------------------------
                      // 2. Botón de Acción Principal
                      ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () async {
                                // Iniciamos la carga
                                setModalState(() => _isLoading = true);

                                try {
                                  if (isLogin) {
                                    if (!_isWaitingOTP) {
                                      final response = await _authService
                                          .loginStep1(
                                            _emailController.text.trim(),
                                            _passwordController.text.trim(),
                                          );

                                      if (response != null &&
                                          response['requiresVerification'] ==
                                              true) {
                                        setModalState(
                                          () => _isWaitingOTP = true,
                                        );
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Credenciales incorrectas o error en servidor",
                                            ),
                                          ),
                                        );
                                      }
                                    } else {
                                      final token = await _authService.verifyOTP(
                                        _emailController.text.trim(),
                                        _otpController.text.trim(),
                                      );

                                      if (token != null) {
                                        if (context.mounted) {
                                          Navigator.pop(context);
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const HomeScreen(),
                                            ),
                                          );
                                        }
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text("Código inválido"),
                                          ),
                                        );
                                      }
                                    }
                                  } else {
                                    bool success = await _authService.register(
                                      _nameController.text.trim(),
                                      _emailController.text.trim(),
                                      _passwordController.text.trim(),
                                    );
                                    if (success) {
                                      setModalState(() => isLogin = true);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Cuenta creada. Por favor inicia sesión.",
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                } catch (e) {
                                  // Si el servidor está apagado o no hay internet
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Error de conexión: $e"),
                                    ),
                                  );
                                } finally {
                                  setModalState(() => _isLoading = false);
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: SmarturStyle.purple,
                          disabledBackgroundColor: SmarturStyle.purple
                              .withOpacity(0.6),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                _isWaitingOTP
                                    ? 'VERIFICAR'
                                    : (isLogin ? 'ENTRAR' : 'CREAR CUENTA'),
                              ),
                      ),
                      // --------------------------------------------------------------------
                    ],

                    const SizedBox(height: 32),

                    // Link para alternar entre Login/Registro
                    TextButton(
                      onPressed: () => setModalState(() => isLogin = !isLogin),
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
                              text: isLogin ? 'Regístrate' : 'Inicia sesión',
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
  ) {
    return Column(
      children: [
        if (!isLogin) ...[
          TextField(
            controller:
                nameCtrl, // es para guardar el nombre completo del formulario
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
          ),
          const SizedBox(height: 16),
        ],
        // Correo electrónico
        TextField(
          controller:
              emailCtrl, // es para guardar el correo electrónico del formulario
          decoration: InputDecoration(
            labelText: 'Correo electrónico',
            prefixIcon: const Icon(
              Icons.email_outlined,
              color: SmarturStyle.purple,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),

        const SizedBox(height: 16),
        TextField(
          controller: passCtrl, // es para guardar la contraseña del formulario
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Contraseña',
            prefixIcon: const Icon(
              Icons.lock_outline,
              color: SmarturStyle.purple,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Future<void> _checkBiometrics(BuildContext context) async {
    try {
      // 1. Verificar que la biometría esté activada
      final bool biometricOn = await _authService.isBiometricEnabled();
      if (!biometricOn) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Inicia sesión y activa el acceso con huella desde tu perfil'),
            ),
          );
        }
        return;
      }

      // 2. Verificar que el dispositivo soporte biometría
      final bool canAuth = await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
      if (!canAuth) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tu dispositivo no soporta biometría')),
          );
        }
        return;
      }

      final List<BiometricType> available = await _auth.getAvailableBiometrics();
      if (available.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No hay huellas registradas en este dispositivo')),
          );
        }
        return;
      }

      // 3. Pedir la huella
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

      // 4. Huella OK → leer el token y entrar
      final String? token = await _authService.getToken();
      if (token != null && context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else if (context.mounted) {
        await _authService.clearSession();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sesión expirada. Inicia sesión de nuevo.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error de biometría: $e')),
        );
      }
    }
  }

}
