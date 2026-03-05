import 'package:flutter/material.dart';
import '../../core/style_guide.dart';

class WelcomeScreen extends StatelessWidget {

const WelcomeScreen({super.key});

@override
Widget build(BuildContext context) {
    return Scaffold(
    backgroundColor: SmarturStyle.bgSecondary,
    body: Stack(
        children: [
        Positioned(
            bottom: 250,
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

            child: const Text('Comenzar', style: TextStyle(fontFamily: 'CalSans', fontWeight: FontWeight.bold, color: SmarturStyle.bgSecondary)),
            ),
        ),
        ],
        ),
    );
}

void _showAuthModal(BuildContext context, {bool isLogin = false}) {
// Variable local para controlar si mostramos los inputs o solo los botones
bool _isExpanded = false; 

showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    
    builder: (context) {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
        // Si está expandido, usa 3/4 (0.75), si no, se ajusta al contenido (null)
        double? height = _isExpanded ? MediaQuery.of(context).size.height * 0.75 : null;

        return AnimatedContainer(
            duration: const Duration(milliseconds: 300), // Animación suave al crecer
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
                mainAxisSize: MainAxisSize.min, // Se ajusta al contenido inicialmente
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
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
                    style: const TextStyle(fontFamily: 'Outfit', color: SmarturStyle.textSecondary),
                ),
                const SizedBox(height: 32),

                // --- LÓGICA DE INTERFAZ DINÁMICA ---
                if (!_isExpanded) ...[
                    ElevatedButton(
                    onPressed: () => setModalState(() => _isExpanded = true),
                    style: ElevatedButton.styleFrom(backgroundColor: SmarturStyle.purple),
                    child: Text(isLogin?  'Continuar con Email' :'Registrarse con Email'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                    onPressed: () {}, // Aquí iría la lógica de Google
                    icon: const Icon(Icons.g_mobiledata, size: 30),
                    label: const Text('Continuar con Google'),
                    ),
                ] else ...[
                    // FORMULARIO EXPANDIDO (3/4 de pantalla)
                    _buildAuthFields(isLogin),
                    const SizedBox(height: 24),
                    ElevatedButton(
                    onPressed: () => print("Enviando datos..."),
                    style: ElevatedButton.styleFrom(backgroundColor: SmarturStyle.purple),
                    child: Text(isLogin ? 'ENTRAR' : 'CREAR CUENTA'),
                    ),
                ],

                const SizedBox(height: 32),

                // Link para alternar entre Login/Registro
                TextButton(
                    onPressed: () => setModalState(() => isLogin = !isLogin),
                    child: RichText(
                    text: TextSpan(
                        style: const TextStyle(fontFamily: 'Outfit', color: SmarturStyle.textPrimary),
                        children: [
                        TextSpan(text: isLogin ? '¿No tienes cuenta? ' : '¿Ya tienes una cuenta? '),
                        TextSpan(
                            text: isLogin ? 'Regístrate' : 'Inicia sesión',
                            style: const TextStyle(color: SmarturStyle.purple, fontWeight: FontWeight.bold),
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

Widget _buildAuthFields(bool isLogin) {
return Column(
    children: [
    if (!isLogin) ...[
        TextField(
        decoration: InputDecoration(
            labelText: 'Nombre completo',
            prefixIcon: const Icon(Icons.person_outline, color: SmarturStyle.purple),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        ),
        const SizedBox(height: 16),
    ],
    // Correo electrónico
    TextField(
        decoration: InputDecoration(
        labelText: 'Correo electrónico',
        prefixIcon: const Icon(Icons.email_outlined, color: SmarturStyle.purple),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
    ),
    
    const SizedBox(height: 16),
    TextField(
        obscureText: true,
        decoration: InputDecoration(
        labelText: 'Contraseña',
        prefixIcon: const Icon(Icons.lock_outline, color: SmarturStyle.purple),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
    ),
    ],
);
}

}