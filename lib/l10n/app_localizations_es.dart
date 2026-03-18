// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'SMARTUR';

  @override
  String get settingsTitle => 'Configuración';

  @override
  String get appearanceSection => 'Apariencia';

  @override
  String get accountSection => 'Cuenta';

  @override
  String get infoSection => 'Información';

  @override
  String get darkMode => 'Modo Oscuro';

  @override
  String get language => 'Idioma';

  @override
  String get colorblindMode => 'Modo Daltónico';

  @override
  String get changePassword => 'Cambiar Contraseña';

  @override
  String get editName => 'Editar Nombre';

  @override
  String get deleteAccount => 'Eliminar Cuenta';

  @override
  String get appVersion => 'Versión de la App';

  @override
  String get termsAndConditions => 'Términos y Condiciones';

  @override
  String get logout => 'Cerrar sesión';

  @override
  String get selectLanguage => 'Seleccionar Idioma';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get deleteAccountTitle => 'Eliminar cuenta';

  @override
  String get deleteAccountConfirm =>
      '¿Estás seguro de que deseas eliminar tu cuenta? Esta acción es irreversible y perderás tu historial de viajes.';

  @override
  String get deleteAccountYes => 'Sí, eliminar';

  @override
  String get editNameTitle => 'Editar nombre';

  @override
  String get yourName => 'Tu nombre';

  @override
  String get changePasswordTitle => 'Cambiar Contraseña';

  @override
  String get changePasswordStep0Hint =>
      'Te enviaremos un código de verificación a tu correo electrónico.';

  @override
  String get changePasswordStep1Hint =>
      'Ingresa el código y tu nueva contraseña.';

  @override
  String get verificationCode => 'Código de verificación';

  @override
  String get newPassword => 'Nueva contraseña';

  @override
  String get confirmPassword => 'Confirmar contraseña';

  @override
  String get sendCode => 'Enviar código';

  @override
  String get updatePassword => 'Actualizar contraseña';

  @override
  String get resendCode => 'Reenviar código';

  @override
  String get codeSixDigits => 'Código de 6 dígitos';

  @override
  String get passwordMinChars => 'Mínimo 8 caracteres';

  @override
  String get passwordNeedUpper => 'Incluye al menos una mayúscula';

  @override
  String get passwordNeedLower => 'Incluye al menos una minúscula';

  @override
  String get passwordNeedNumber => 'Incluye al menos un número';

  @override
  String get passwordsDontMatch => 'Las contraseñas no coinciden';

  @override
  String codeSentToEmail(Object email) {
    return 'Código enviado a $email';
  }

  @override
  String get emailNotFound => 'No se encontró tu email';

  @override
  String get loading => 'Cargando...';

  @override
  String get welcomeBack => 'Bienvenido de nuevo';

  @override
  String get startNow => 'Empezar ahora';

  @override
  String get loginSubtitle => 'Ingresa tus credenciales para continuar.';

  @override
  String get registerSubtitle =>
      'Regístrate para descubrir rutas personalizadas.';

  @override
  String get continueWithEmail => 'Continuar con Email';

  @override
  String get registerWithEmail => 'Registrarse con Email';

  @override
  String get tagline => 'IA que guía, Turismo que une';

  @override
  String get start => 'Comenzar';

  @override
  String get loginWithBiometrics => 'Ingresar con huella';

  @override
  String get navHome => 'Inicio';

  @override
  String get navDiary => 'Diario';

  @override
  String get navRecommend => 'Recomendar';

  @override
  String get navCommunity => 'Comunidad';

  @override
  String get navUser => 'Usuario';

  @override
  String get communityTitle => 'Comunidad';

  @override
  String get uploadPhotoAction => 'Acción para subir una foto';

  @override
  String get diaryTitle => 'Mi Diario';

  @override
  String get favoritesTab => 'Favoritos';

  @override
  String get historyTab => 'Historial';

  @override
  String get offlineAvailable => 'Disponible sin internet';

  @override
  String recommendationsInCity(Object city) {
    return 'Recomendaciones en $city';
  }

  @override
  String recommendationNumber(Object number) {
    return 'Recomendación #$number';
  }

  @override
  String recommendationSubtitle(Object city) {
    return 'Sugerido por la IA de SMARTUR para tu visita a $city.';
  }

  @override
  String get mapDiscoverHint =>
      'Descubre puntos clave sin rastrear tu ubicación en tiempo real.';

  @override
  String get mapTapPinHint => 'Toca un pin para ver detalles generados por IA';

  @override
  String get filterAll => 'Todos';

  @override
  String get filterMuseums => 'Museos';

  @override
  String get filterCafes => 'Cafés';

  @override
  String get filterViewpoints => 'Miradores';

  @override
  String get filterMuseumsOnly => 'Solo ver Museos';

  @override
  String get aiSmartur => 'IA Smartur';

  @override
  String get enableBiometricsHint =>
      'Inicia sesión y activa la huella en tu perfil';

  @override
  String get deviceNotSupported => 'Dispositivo no compatible';

  @override
  String get noBiometricsEnrolled => 'No hay huellas registradas';

  @override
  String get biometricReason => 'Accede a tus rutas de SMARTUR';

  @override
  String get sessionExpired => 'Sesión expirada. Inicia sesión de nuevo.';

  @override
  String get biometricReadError => 'Error al leer huella.';
}
