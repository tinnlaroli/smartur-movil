# Aplicación Móvil SMARTUR

## Descripción General

Esta es la aplicación móvil oficial para el proyecto SMARTUR, desarrollada con Flutter. La aplicación facilita la autenticación de usuarios, el registro y el seguimiento de destinos dentro de una interfaz de usuario de alta calidad.

## Estructura del Proyecto

El proyecto sigue un patrón de arquitectura limpia para garantizar la mantenibilidad y escalabilidad.

```text
lib/
├── core/                       <── Estilos globales, constantes y utilidades del sistema
│   ├── constants/              <── Configuración de endpoints y URLs de la API
│   └── style_guide.dart        <── Tokens de diseño centralizados (colores, tipografía)
├── data/                       <── Capa de datos para la comunicación con servicios externos
│   └── services/               <── Lógica de negocio para peticiones (Auth, Registro, OTP)
└── presentation/               <── Capa de interfaz de usuario (UI) y experiencia de usuario
    ├── screens/                <── Vistas principales (Bienvenida, Login, Inicio)
    └── widgets/                <── Componentes visuales reutilizables (Loaders, botones)
```

## Requisitos Previos

Antes de comenzar, asegúrese de tener instalado lo siguiente:

- [SDK de Flutter](https://docs.flutter.dev/get-started/install) (Canal estable)
- [SDK de Dart](https://dart.dev/get-started/sdk)
- Android Studio / VS Code con la extensión de Flutter
- Un emulador de Android/iOS o un dispositivo físico

## Instalación

1. **Clonar el repositorio:**
   ```bash
   git clone https://github.com/tinnlaroli/smartur-movil.git
   cd smartur-movil
   ```

2. **Instalar dependencias:**
   ```bash
   flutter pub get
   ```

3. **Configurar el Entorno:**
   Actualice la `baseUrl` en `lib/core/constants/api_constants.dart` con su dirección IP local para permitir que el dispositivo móvil se comunique con la API local.

   ```dart
   static const String baseUrl = 'http://SU_IP_LOCAL:3000/api/v2';
   ```

## Ejecución en Desarrollo

### Ejecutar la aplicación

Para ejecutar la aplicación en modo de desarrollo:

```bash
flutter run
```

### Generar versión de producción

Para generar un archivo de instalación (APK) para Android:

```bash
flutter build apk --release
```

## Navegación y Rutas

La aplicación utiliza un flujo de navegación estándar:

1. **Pantalla de Bienvenida**: Punto de entrada para usuarios no autenticados.
2. **Flujo de Login/Registro**: Autenticación basada en hojas inferiores (bottom-sheets) con un proceso de verificación de 2 pasos (OTP).
3. **Pantalla de Inicio**: Panel principal después de una autenticación exitosa.

## Detalles de Integración de la API

El flujo de autenticación está asegurado mediante un proceso de dos pasos:

- **Fase 1**: Validación inicial de credenciales a través de `/login`.
- **Fase 2**: Verificación de OTP a través de `/two-factor`.
- **Registro**: Incorporación de usuarios a través de `/users/register`.

## Permisos y Seguridad

- **Android**: Se ha habilitado `android:usesCleartextTraffic="true"` para la comunicación en desarrollo local.
- **Internet**: Los permisos estándar de internet están configurados en el archivo `AndroidManifest.xml`.

---
© 2026 Proyecto SMARTUR. Todos los derechos reservados.