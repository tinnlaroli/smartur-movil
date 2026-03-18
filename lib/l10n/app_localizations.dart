import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('pt'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In es, this message translates to:
  /// **'SMARTUR'**
  String get appTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In es, this message translates to:
  /// **'Configuración'**
  String get settingsTitle;

  /// No description provided for @appearanceSection.
  ///
  /// In es, this message translates to:
  /// **'Apariencia'**
  String get appearanceSection;

  /// No description provided for @accountSection.
  ///
  /// In es, this message translates to:
  /// **'Cuenta'**
  String get accountSection;

  /// No description provided for @infoSection.
  ///
  /// In es, this message translates to:
  /// **'Información'**
  String get infoSection;

  /// No description provided for @darkMode.
  ///
  /// In es, this message translates to:
  /// **'Modo Oscuro'**
  String get darkMode;

  /// No description provided for @language.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get language;

  /// No description provided for @colorblindMode.
  ///
  /// In es, this message translates to:
  /// **'Modo Daltónico'**
  String get colorblindMode;

  /// No description provided for @changePassword.
  ///
  /// In es, this message translates to:
  /// **'Cambiar Contraseña'**
  String get changePassword;

  /// No description provided for @editName.
  ///
  /// In es, this message translates to:
  /// **'Editar Nombre'**
  String get editName;

  /// No description provided for @deleteAccount.
  ///
  /// In es, this message translates to:
  /// **'Eliminar Cuenta'**
  String get deleteAccount;

  /// No description provided for @appVersion.
  ///
  /// In es, this message translates to:
  /// **'Versión de la App'**
  String get appVersion;

  /// No description provided for @termsAndConditions.
  ///
  /// In es, this message translates to:
  /// **'Términos y Condiciones'**
  String get termsAndConditions;

  /// No description provided for @logout.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get logout;

  /// No description provided for @selectLanguage.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar Idioma'**
  String get selectLanguage;

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In es, this message translates to:
  /// **'Guardar'**
  String get save;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar cuenta'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que deseas eliminar tu cuenta? Esta acción es irreversible y perderás tu historial de viajes.'**
  String get deleteAccountConfirm;

  /// No description provided for @deleteAccountYes.
  ///
  /// In es, this message translates to:
  /// **'Sí, eliminar'**
  String get deleteAccountYes;

  /// No description provided for @editNameTitle.
  ///
  /// In es, this message translates to:
  /// **'Editar nombre'**
  String get editNameTitle;

  /// No description provided for @yourName.
  ///
  /// In es, this message translates to:
  /// **'Tu nombre'**
  String get yourName;

  /// No description provided for @changePasswordTitle.
  ///
  /// In es, this message translates to:
  /// **'Cambiar Contraseña'**
  String get changePasswordTitle;

  /// No description provided for @changePasswordStep0Hint.
  ///
  /// In es, this message translates to:
  /// **'Te enviaremos un código de verificación a tu correo electrónico.'**
  String get changePasswordStep0Hint;

  /// No description provided for @changePasswordStep1Hint.
  ///
  /// In es, this message translates to:
  /// **'Ingresa el código y tu nueva contraseña.'**
  String get changePasswordStep1Hint;

  /// No description provided for @verificationCode.
  ///
  /// In es, this message translates to:
  /// **'Código de verificación'**
  String get verificationCode;

  /// No description provided for @newPassword.
  ///
  /// In es, this message translates to:
  /// **'Nueva contraseña'**
  String get newPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In es, this message translates to:
  /// **'Confirmar contraseña'**
  String get confirmPassword;

  /// No description provided for @sendCode.
  ///
  /// In es, this message translates to:
  /// **'Enviar código'**
  String get sendCode;

  /// No description provided for @updatePassword.
  ///
  /// In es, this message translates to:
  /// **'Actualizar contraseña'**
  String get updatePassword;

  /// No description provided for @resendCode.
  ///
  /// In es, this message translates to:
  /// **'Reenviar código'**
  String get resendCode;

  /// No description provided for @codeSixDigits.
  ///
  /// In es, this message translates to:
  /// **'Código de 6 dígitos'**
  String get codeSixDigits;

  /// No description provided for @passwordMinChars.
  ///
  /// In es, this message translates to:
  /// **'Mínimo 8 caracteres'**
  String get passwordMinChars;

  /// No description provided for @passwordNeedUpper.
  ///
  /// In es, this message translates to:
  /// **'Incluye al menos una mayúscula'**
  String get passwordNeedUpper;

  /// No description provided for @passwordNeedLower.
  ///
  /// In es, this message translates to:
  /// **'Incluye al menos una minúscula'**
  String get passwordNeedLower;

  /// No description provided for @passwordNeedNumber.
  ///
  /// In es, this message translates to:
  /// **'Incluye al menos un número'**
  String get passwordNeedNumber;

  /// No description provided for @passwordsDontMatch.
  ///
  /// In es, this message translates to:
  /// **'Las contraseñas no coinciden'**
  String get passwordsDontMatch;

  /// No description provided for @codeSentToEmail.
  ///
  /// In es, this message translates to:
  /// **'Código enviado a {email}'**
  String codeSentToEmail(Object email);

  /// No description provided for @emailNotFound.
  ///
  /// In es, this message translates to:
  /// **'No se encontró tu email'**
  String get emailNotFound;

  /// No description provided for @loading.
  ///
  /// In es, this message translates to:
  /// **'Cargando...'**
  String get loading;

  /// No description provided for @welcomeBack.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido de nuevo'**
  String get welcomeBack;

  /// No description provided for @startNow.
  ///
  /// In es, this message translates to:
  /// **'Empezar ahora'**
  String get startNow;

  /// No description provided for @loginSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Ingresa tus credenciales para continuar.'**
  String get loginSubtitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Regístrate para descubrir rutas personalizadas.'**
  String get registerSubtitle;

  /// No description provided for @continueWithEmail.
  ///
  /// In es, this message translates to:
  /// **'Continuar con Email'**
  String get continueWithEmail;

  /// No description provided for @registerWithEmail.
  ///
  /// In es, this message translates to:
  /// **'Registrarse con Email'**
  String get registerWithEmail;

  /// No description provided for @tagline.
  ///
  /// In es, this message translates to:
  /// **'IA que guía, Turismo que une'**
  String get tagline;

  /// No description provided for @start.
  ///
  /// In es, this message translates to:
  /// **'Comenzar'**
  String get start;

  /// No description provided for @loginWithBiometrics.
  ///
  /// In es, this message translates to:
  /// **'Ingresar con huella'**
  String get loginWithBiometrics;

  /// No description provided for @navHome.
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get navHome;

  /// No description provided for @navDiary.
  ///
  /// In es, this message translates to:
  /// **'Diario'**
  String get navDiary;

  /// No description provided for @navRecommend.
  ///
  /// In es, this message translates to:
  /// **'Recomendar'**
  String get navRecommend;

  /// No description provided for @navCommunity.
  ///
  /// In es, this message translates to:
  /// **'Comunidad'**
  String get navCommunity;

  /// No description provided for @navUser.
  ///
  /// In es, this message translates to:
  /// **'Usuario'**
  String get navUser;

  /// No description provided for @communityTitle.
  ///
  /// In es, this message translates to:
  /// **'Comunidad'**
  String get communityTitle;

  /// No description provided for @uploadPhotoAction.
  ///
  /// In es, this message translates to:
  /// **'Acción para subir una foto'**
  String get uploadPhotoAction;

  /// No description provided for @diaryTitle.
  ///
  /// In es, this message translates to:
  /// **'Mi Diario'**
  String get diaryTitle;

  /// No description provided for @favoritesTab.
  ///
  /// In es, this message translates to:
  /// **'Favoritos'**
  String get favoritesTab;

  /// No description provided for @historyTab.
  ///
  /// In es, this message translates to:
  /// **'Historial'**
  String get historyTab;

  /// No description provided for @offlineAvailable.
  ///
  /// In es, this message translates to:
  /// **'Disponible sin internet'**
  String get offlineAvailable;

  /// No description provided for @recommendationsInCity.
  ///
  /// In es, this message translates to:
  /// **'Recomendaciones en {city}'**
  String recommendationsInCity(Object city);

  /// No description provided for @recommendationNumber.
  ///
  /// In es, this message translates to:
  /// **'Recomendación #{number}'**
  String recommendationNumber(Object number);

  /// No description provided for @recommendationSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Sugerido por la IA de SMARTUR para tu visita a {city}.'**
  String recommendationSubtitle(Object city);

  /// No description provided for @mapDiscoverHint.
  ///
  /// In es, this message translates to:
  /// **'Descubre puntos clave sin rastrear tu ubicación en tiempo real.'**
  String get mapDiscoverHint;

  /// No description provided for @mapTapPinHint.
  ///
  /// In es, this message translates to:
  /// **'Toca un pin para ver detalles generados por IA'**
  String get mapTapPinHint;

  /// No description provided for @filterAll.
  ///
  /// In es, this message translates to:
  /// **'Todos'**
  String get filterAll;

  /// No description provided for @filterMuseums.
  ///
  /// In es, this message translates to:
  /// **'Museos'**
  String get filterMuseums;

  /// No description provided for @filterCafes.
  ///
  /// In es, this message translates to:
  /// **'Cafés'**
  String get filterCafes;

  /// No description provided for @filterViewpoints.
  ///
  /// In es, this message translates to:
  /// **'Miradores'**
  String get filterViewpoints;

  /// No description provided for @filterMuseumsOnly.
  ///
  /// In es, this message translates to:
  /// **'Solo ver Museos'**
  String get filterMuseumsOnly;

  /// No description provided for @aiSmartur.
  ///
  /// In es, this message translates to:
  /// **'IA Smartur'**
  String get aiSmartur;

  /// No description provided for @enableBiometricsHint.
  ///
  /// In es, this message translates to:
  /// **'Inicia sesión y activa la huella en tu perfil'**
  String get enableBiometricsHint;

  /// No description provided for @deviceNotSupported.
  ///
  /// In es, this message translates to:
  /// **'Dispositivo no compatible'**
  String get deviceNotSupported;

  /// No description provided for @noBiometricsEnrolled.
  ///
  /// In es, this message translates to:
  /// **'No hay huellas registradas'**
  String get noBiometricsEnrolled;

  /// No description provided for @biometricReason.
  ///
  /// In es, this message translates to:
  /// **'Accede a tus rutas de SMARTUR'**
  String get biometricReason;

  /// No description provided for @sessionExpired.
  ///
  /// In es, this message translates to:
  /// **'Sesión expirada. Inicia sesión de nuevo.'**
  String get sessionExpired;

  /// No description provided for @biometricReadError.
  ///
  /// In es, this message translates to:
  /// **'Error al leer huella.'**
  String get biometricReadError;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'fr', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
