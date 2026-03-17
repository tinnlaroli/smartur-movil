# 🏔️ Smartur Mobile

## *Tu portal inteligente a las Altas Montañas*

**Smartur** es una aplicación móvil de última generación diseñada para exploradores modernos. Combina una estética visual premium con procesos de seguridad avanzados y una experiencia de usuario fluida, permitiendo conectar con guías locales y descubrir rutas auténticas mediante inteligencia artificial.

---

## 🚀 Inicio Rápido

Para poner en marcha el proyecto en tu entorno local:

1. **Clona el repositorio**

   ```bash
   git clone https://github.com/tinnlaroli/smartur-movil.git
   ```

2. **Instala las dependencias**

   ```bash
   flutter pub get
   ```

3. **Configura la conectividad (IMPORTANTE)**

   Para que el dispositivo físico o emulador conecte con el backend, abre `lib/core/constants/api_constants.dart` y cambia la `baseUrl` por tu IP local:

   ```dart
   static const String baseUrl = 'http://192.168.1.X:3000/api/v2';
   ```

4. **Corre la aplicación**

   ```bash
   flutter run
   ```

---

## 📂 Arquitectura del Proyecto

Smartur sigue una estructura orientada a **Clean Architecture** simplificada para Flutter, con pantallas agrupadas por feature y separación clara de responsabilidades:

```text
lib/
├── main.dart                        # Punto de entrada de la aplicación
│
├── core/                            # Capa núcleo (sin dependencias de negocio)
│   ├── constants/
│   │   └── api_constants.dart       # Base URL y endpoints del API
│   ├── theme/
│   │   └── style_guide.dart         # Tokens de diseño (colores, tipografía, medidas)
│   └── utils/
│       └── notifications.dart       # Toasts/notificaciones reutilizables
│
├── data/                            # Capa de datos
│   ├── models/
│   │   ├── onboarding_model.dart    # Contenido de las pantallas de onboarding
│   │   └── traveler_profile_model.dart  # Modelo del perfil del viajero
│   └── services/
│       ├── auth_service.dart        # Autenticación, JWT, gestión de usuario
│       └── profile_service.dart     # Preferencias y perfil del viajero
│
└── presentation/                    # Capa de interfaz (UI)
    ├── screens/
    │   ├── auth/                    # Flujo de autenticación
    │   │   ├── onboarding_screen.dart
    │   │   └── welcome_screen.dart  # Login, registro, OTP, Google Sign-In
    │   ├── main/                    # Tabs principales del app
    │   │   ├── main_screen.dart     # Contenedor con bottom navigation
    │   │   ├── home_screen.dart     # Explorar ciudades, clima, mapa
    │   │   ├── diary_screen.dart    # Favoritos e historial de visitas
    │   │   ├── community_screen.dart # Feed de la comunidad
    │   │   └── profile_screen.dart  # Perfil del usuario (datos del API)
    │   ├── settings/
    │   │   └── settings_screen.dart # Configuración, cambio de contraseña, cuenta
    │   ├── preferences/             # Onboarding de preferencias (3 pasos)
    │   │   ├── preferences_screen.dart
    │   │   ├── step1_personal_screen.dart
    │   │   ├── step2_interests_screen.dart
    │   │   └── step3_extra_screen.dart
    │   └── explore/                 # Exploración y recomendaciones IA
    │       ├── map_screen.dart
    │       └── recommendation_screen.dart
    └── widgets/                     # Componentes reutilizables
        ├── smartur_background.dart  # Fondo animado con glassmorphism
        ├── smartur_loader.dart      # Splash animado del logo
        └── smartur_skeleton.dart    # Shimmer y skeleton loading
```

---

## ✨ Características UX Premium

### 1. Atmósfera Dinámica e Infinita

Utilizamos el widget `SmarturBackground` para crear una sensación de profundidad. Este componente cicla suavemente entre 5 colores armónicos (Rosa, Morado, Naranja, Azul, Verde) con un efecto de **Glassmorphism** (cristal esmerilado) que no distrae al usuario.

### 2. Autenticación Robusta y Segura

- **OTP (Two Factor Auth)**: Confirmación visual del correo y opción de cambio rápido de identidad si se cometió un error.
- **Validación en Tiempo Real**: Checklist interactivo que verifica requisitos de contraseña (Mayúsculas, Números, Longitud) mientras el usuario escribe.
- **Biometría Nativa**: Integración con sensor de huellas/rostro para accesos rápidos.
- **Smart Google Login**: Botón persistente con diseño oficial y estados de carga integrados.

### 3. Onboarding de Parallax

Navegación intuitiva con efectos de movimiento sincronizados, soportando tanto animaciones **Lottie** (JSON) como vectores **SVG** de alta fidelidad, garantizando tiempos de carga ínfimos.

---

## 🧩 Componentes Core (Para Desarrolladores)

Si necesitas extender o modificar la app, estos son los widgets clave:

| Widget | Descripción |
| :--- | :--- |
| `SmarturBackground` | Fondo animado con degradado cíclico y desenfoque gausiano. |
| `SmarturShimmer` | Generador de efecto de brillo para cargas (Skeleton loading). |
| `SkeletonContainer` | Forma base para crear esqueletos de carga rectangulares o circulares. |
| `SmarturNotifications` | Capa de abstracción sobre Snackbars/Toasts con diseño personalizado. |

### Cómo añadir una pantalla de carga (Skeleton)

```dart
SmarturShimmer(
  enabled: _isLoading,
  child: _isLoading 
    ? SkeletonText(width: 200) 
    : Text("Datos cargados")
)
```

---

## 🛠 Stack Tecnológico

- **Framework**: Flutter ^3.11.1
- **State Management**: Stateful widgets (local) + SharedPreferences (persistente).
- **Seguridad**: `flutter_secure_storage` para tokens JWT.
- **Animaciones**: `Lottie` + `AnimatedBuilder` (Custom).
- **Iconografía**: `flutter_svg` para vectores limpios.

---

## 👨‍💻 Guía de Contribución

1. Crea un **Feature Branch** (`git checkout -b feature/novedad`).
2. Sigue los tokens de color definidos en `lib/core/theme/style_guide.dart`.
3. Documenta cualquier nuevo servicio en la sección de `lib/data/services/`.
4. Asegúrate de pasar el análisis estático (`flutter analyze`).

---

© 2026 **SMARTUR Project**. Diseñado con ❤️ para la exploración consciente.
