# Smartur Mobile

Cliente Flutter para **Smartur**: exploración de destinos, perfil de viajero, diario (favoritos y visitas), comunidad y autenticación frente al API REST del backend.

Este documento describe la estructura del repositorio, el flujo de la aplicación, la configuración del entorno y las dependencias principales.

---

## Requisitos

- Flutter SDK compatible con `environment.sdk: ^3.11.1` (ver `pubspec.yaml`).
- Dispositivo o emulador Android o iOS.
- Backend Smartur accesible desde la red del dispositivo (misma LAN o URL pública).

---

## Inicio rápido

1. Clonar el repositorio e instalar dependencias:

   ```bash
   flutter pub get
   ```

2. Configurar variables de entorno y API (ver sección [Configuración](#configuración)).

3. Generar localizaciones si se modifican los `.arb`:

   ```bash
   flutter gen-l10n
   ```

4. Ejecutar la aplicación:

   ```bash
   flutter run
   ```

5. Análisis estático recomendado antes de commits:

   ```bash
   flutter analyze
   ```

---

## Configuración

### URL del API y claves

La base del API no se obtiene de un archivo `.env` en tiempo de ejecución: se define mediante **`dart-define`** o valores por defecto en código.

| Símbolo | Archivo | Uso |
|--------|---------|-----|
| `API_BASE_URL_DEV` | `lib/core/constants/env_config.dart` | URL base del API (por defecto apunta a un despliegue de ejemplo). |
| `GOOGLE_SERVER_CLIENT_ID` | `env_config.dart` | Server Client ID de Google Sign-In (OAuth). |
| `OPENWEATHER_API_KEY` | `env_config.dart` | Clave para datos meteorológicos en pantalla de inicio. |

`lib/core/constants/api_constants.dart` expone `baseUrl` leyendo `EnvConfig.apiBaseUrl` y concatena rutas relativas (`/login`, `/explore/home`, etc.).

Ejemplo de ejecución con API local:

```bash
flutter run --dart-define=API_BASE_URL_DEV=http://192.168.1.10:3000/api/v2
```

### Internacionalización

- Archivos fuente: `lib/l10n/app_*.arb` (plantilla: `app_es.arb`, configuración en `l10n.yaml`).
- Código generado: `lib/l10n/app_localizations*.dart` (no editar a mano; usar `flutter gen-l10n`).

### Activos

Rutas declaradas en `pubspec.yaml` bajo `flutter.assets`: imágenes, Lottie, SVG y fuentes (`assets/imgs/`, `assets/lottie/`, `assets/svg/`, `assets/fonts/`).

---

## Arquitectura y organización del código

El proyecto combina una **separación por capas** (`core`, `data`, `presentation`) con **agrupación por funcionalidad** dentro de `presentation/screens`. No se usa un contenedor de inyección de dependencias global: los servicios se instancian donde se necesitan (por ejemplo `AuthService()`).

### Principios

- **core**: utilidades transversales sin acoplar la UI a un feature concreto (tema, constantes, ajustes globales, validadores).
- **data**: modelos serializables y servicios HTTP que hablan con el backend.
- **presentation**: widgets de pantalla y componentes reutilizables; el estado suele ser local (`StatefulWidget`) o persistido vía `SharedPreferences` / `FlutterSecureStorage` según el caso.

### Árbol de carpetas (`lib/`)

```text
lib/
├── main.dart                 # Punto de entrada: splash, sesión, tema, localización, ToastificationWrapper
├── core/
│   ├── constants/            # api_constants, env_config, avatar_icon_map
│   ├── theme/                # style_guide (colores, tipografía, tokens)
│   ├── utils/                # notifications, profile_photo_validation
│   └── settings/             # AppSettings: tema, idioma, modo daltónico (color_blindness)
├── data/
│   ├── models/               # onboarding, traveler_profile, place, etc.
│   └── services/             # auth_service, profile_service, explore_service, user_content_service
├── presentation/
│   ├── screens/
│   │   ├── auth/             # onboarding, welcome (login, registro, OTP, Google)
│   │   ├── main/             # shell con tabs: home, diario, comunidad, perfil; edición de avatar
│   │   ├── settings/         # ajustes de cuenta y app
│   │   ├── preferences/      # wizard de preferencias del viajero (pasos)
│   │   └── explore/          # mapa, detalle de lugar, recomendaciones
│   └── widgets/              # fondo, loader, skeleton, avatar de usuario
└── l10n/                     # ARB + generados AppLocalizations
```

### Carpetas raíz adicionales

| Carpeta | Rol |
|---------|-----|
| `android/`, `ios/` | Proyectos nativos; permisos de cámara/galería y configuración de firma según plataforma. |
| `assets/` | Recursos estáticos referenciados en `pubspec.yaml`. |
| `test/` | Pruebas unitarias/widget (ampliar según necesidad). |

### Convención aplicada

Las pantallas del área **Perfil** (pestaña principal y edición de foto/icono) residen en `presentation/screens/main/` para mantener cohesión con `profile_screen.dart` y evitar una carpeta `profile/` con un solo archivo.

---

## Flujos principales

### 1. Arranque y sesión (`main.dart`)

1. `WidgetsFlutterBinding.ensureInitialized()`.
2. Lectura de `onboarding_seen` en `SharedPreferences`.
3. Carga de `AppSettingsNotifier` (tema, locale, accesibilidad de color).
4. `_SplashGate`: comprueba token y expiración vía `AuthService.hasSession()`.
5. Destino:
   - Sin onboarding visto: `OnboardingScreen`.
   - Onboarding visto y sin sesión: `WelcomeScreen`.
   - Sesión válida: `MainScreen` con nombre de usuario opcional.
6. Si el usuario ya había visto el onboarding, se puede mostrar `SmartURLoader` como overlay hasta finalizar la animación.

### 2. Autenticación (`data/services/auth_service.dart`, pantallas en `auth/`)

- Registro, login, recuperación de contraseña, verificación en dos pasos cuando aplique.
- Token JWT almacenado con `flutter_secure_storage`.
- Google Sign-In inicializado con `EnvConfig.googleServerClientId`.
- Perfil y avatar: lectura/actualización de usuario, subida multipart de imagen con tipo MIME correcto (`http_parser`).

### 3. Contenedor principal (`main_screen.dart`)

- Cuatro pestañas: **Inicio** (`HomeScreen`), **Diario** (`DiaryScreen`), **Comunidad** (`CommunityScreen`), **Perfil** (`ProfileScreen`).
- La ruta de **recomendaciones IA** se enlaza desde la UI de inicio hacia `RecommendationScreen` (no es una pestaña del `BottomNavigationBar`).

### 4. Exploración y datos de inicio (`explore_service.dart`, `home_screen.dart`)

- Ciudades y contenido de exploración desde el endpoint configurado en `ApiConstants.exploreHome`.
- Modelos como `Place` en `data/models/` para listados y filtros en UI.

### 5. Diario y comunidad (`user_content_service.dart`)

- Favoritos y visitas bajo rutas `meFavorites` / `meVisits`.
- Publicaciones de comunidad bajo `communityPosts`.

### 6. Preferencias del viajero (`preferences/`)

- Flujo multipaso posterior al registro o según navegación; persiste vía `profile_service` / API de perfiles.

### 7. Ajustes globales (`settings/`, `AppSettings`)

- Tema claro/oscuro, idioma y simulación daltónica (`color_blindness`) propagados con `AppSettingsScope` y `ValueListenableBuilder` en `main.dart`.

---

## Dependencias principales (`pubspec.yaml`)

| Paquete | Función |
|---------|---------|
| `http`, `http_parser` | Cliente HTTP y tipos MIME para multipart. |
| `flutter_secure_storage` | Almacenamiento seguro del JWT. |
| `shared_preferences` | Flags y preferencias no sensibles (p. ej. onboarding). |
| `google_sign_in` | Inicio de sesión con Google. |
| `local_auth` (+ `local_auth_android`) | Autenticación biométrica opcional. |
| `flutter_map`, `latlong2` | Mapas y coordenadas. |
| `image_picker` | Selección de imagen para avatar. |
| `lottie`, `flutter_svg` | Animaciones y gráficos vectoriales. |
| `toastification` | Notificaciones tipo toast envueltas en `ToastificationWrapper`. |
| `intl`, `flutter_localizations` | Fechas, formatos e i18n oficial de Flutter. |
| `color_blindness` | Ajuste de paleta para accesibilidad. |

Desarrollo: `flutter_lints`, `flutter_launcher_icons`, `flutter_test`.

---

## Extensión y buenas prácticas

- Nuevos endpoints: añadir constantes en `api_constants.dart` y métodos en el servicio correspondiente bajo `lib/data/services/`.
- Textos visibles: claves en `lib/l10n/app_*.arb` y regenerar con `flutter gen-l10n`.
- Estilo visual: tokens en `lib/core/theme/style_guide.dart`.
- Tras cambios estructurales, ejecutar `flutter analyze` y probar los flujos de login, home y perfil.

---

## Licencia y proyecto

Proyecto **SMARTUR** (2026). Consulte los términos del repositorio o del equipo de producto para uso y distribución.
