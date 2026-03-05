// este es la entrada principal de la aplicacion

import 'package:flutter/material.dart'; // Importación principal

import 'core/style_guide.dart';

void main() {
  // inicio de la clase q es el punto de entrada de la aplicacion
  runApp(const SmarturApp());
}

// todo es widget: este es el widget raiz
class SmarturApp extends StatelessWidget {
  const SmarturApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // El cascarón de la app
      title: 'SMARTUR',
      debugShowCheckedModeBanner: false,

      // CONFIGURACIÓN GLOBAL (ThemeData)
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Outfit', // Letra por defecto para toda la app
        // Esquema de colores basado en tu Color Seed
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

      home: const HomeScreen(),
    );
  }
}

// Definición de la clase HomeScreen que hereda de StatelessWidget (un widget que no cambia su estado interno)
class HomeScreen extends StatelessWidget {
  // Constructor constante de HomeScreen que recibe una 'key' opcional para identificar de manera única este widget
  const HomeScreen({super.key});

  // Sobrescribimos el método build que es el encargado de construir (renderizar) la interfaz de usuario y devolver un Widget
  @override
  Widget build(BuildContext context) {
    // Retorna un Scaffold, un widget que provee la estructura visual básica (layout) de Material Design para páginas (AppBar, body, etc.)
    return Scaffold(
      // appBar define la barra superior de la aplicación
      appBar: AppBar(
        // Definimos el título usando un widget Text constante y le aplicamos un estilo de fuente personalizado ('CalSans')
        title: const Text('SMARTUR', style: TextStyle(fontFamily: 'CalSans')),
        // Centramos el título de la AppBar usando true
        centerTitle: true,
      ),
      // body es el contenido principal de la pantalla, todo lo que va debajo del AppBar
      body: Padding(
        // Aplicamos padding (margen interno) a todos los lados del contenido usando una constante de nuestra guía de estilos
        padding: const EdgeInsets.all(SmarturStyle.spacingMd),
        // El hijo de este Padding es una columna (Column), para agrupar widgets en disposición vertical (arriba a abajo)
        child: Column(
          // mainAxisAlignment al centro alínea los hijos de la columna para que se acomoden exactamente en el medio vertical del espacio disponible
          mainAxisAlignment: MainAxisAlignment.center,
          // Lista de widgets hijos que compondrán la interfaz visual de la columna
          children: [
            // Texto principal o título de bienvenida en la pantalla, se define como 'const' para optimizar
            const Text(
              'Explora las Altas Montañas',
              // Aplicamos un estilo definido en nuestra clase de estilo global (SmarturStyle.calSansTitle)
              style: SmarturStyle.calSansTitle,
              // Centramos horizontalmente el texto dentro de los límites del widget Text
              textAlign: TextAlign.center,
            ),
            // Separador vertical creando un recuadro transparente de 10 píxeles de altura
            const SizedBox(height: 10),
            // Segundo texto descriptivo de la pantalla
            const Text(
              'Selecciona una ciudad para recibir tu Top 3 de recomendaciones personalizadas.',
              // Alineamos este texto al centro horizontalmente
              textAlign: TextAlign.center,
              // Al darle un TextStyle explícito (tamaño 16) heredará la fuente 'Outfit' del tema global
              style: TextStyle(fontSize: 16),
            ),
            // Separador vertical más alto (40 píxeles) para alejar el texto del botón
            const SizedBox(height: 40),
            // Un botón elevado (con fondo de color y leve sombra), usa los estilos globales ya configurados
            ElevatedButton(
              // El evento onPressed se ejecutará al tocar el botón. Actualmente está vacío '() {}', no hace nada aún
              onPressed: () {},
              // El contenido (hijo) del botón es un widget de Text con el mensaje para la acción
              child: const Text('COMENZAR'),
            ),
          ],
        ),
      ),
    );
  }
}
