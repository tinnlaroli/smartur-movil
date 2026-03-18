// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'SMARTUR';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get appearanceSection => 'Apparence';

  @override
  String get accountSection => 'Compte';

  @override
  String get infoSection => 'Informations';

  @override
  String get darkMode => 'Mode sombre';

  @override
  String get language => 'Langue';

  @override
  String get colorblindMode => 'Mode daltonien';

  @override
  String get changePassword => 'Changer le mot de passe';

  @override
  String get editName => 'Modifier le nom';

  @override
  String get deleteAccount => 'Supprimer le compte';

  @override
  String get appVersion => 'Version de l’application';

  @override
  String get termsAndConditions => 'Conditions d’utilisation';

  @override
  String get logout => 'Se déconnecter';

  @override
  String get selectLanguage => 'Choisir la langue';

  @override
  String get cancel => 'Annuler';

  @override
  String get save => 'Enregistrer';

  @override
  String get deleteAccountTitle => 'Supprimer le compte';

  @override
  String get deleteAccountConfirm =>
      'Êtes-vous sûr de vouloir supprimer votre compte ? Cette action est irréversible et vous perdrez votre historique de voyages.';

  @override
  String get deleteAccountYes => 'Oui, supprimer';

  @override
  String get editNameTitle => 'Modifier le nom';

  @override
  String get yourName => 'Votre nom';

  @override
  String get changePasswordTitle => 'Changer le mot de passe';

  @override
  String get changePasswordStep0Hint =>
      'Nous vous enverrons un code de vérification par e-mail.';

  @override
  String get changePasswordStep1Hint =>
      'Saisissez le code et votre nouveau mot de passe.';

  @override
  String get verificationCode => 'Code de vérification';

  @override
  String get newPassword => 'Nouveau mot de passe';

  @override
  String get confirmPassword => 'Confirmer le mot de passe';

  @override
  String get sendCode => 'Envoyer le code';

  @override
  String get updatePassword => 'Mettre à jour le mot de passe';

  @override
  String get resendCode => 'Renvoyer le code';

  @override
  String get codeSixDigits => 'Code à 6 chiffres';

  @override
  String get passwordMinChars => 'Minimum 8 caractères';

  @override
  String get passwordNeedUpper => 'Incluez au moins une majuscule';

  @override
  String get passwordNeedLower => 'Incluez au moins une minuscule';

  @override
  String get passwordNeedNumber => 'Incluez au moins un chiffre';

  @override
  String get passwordsDontMatch => 'Les mots de passe ne correspondent pas';

  @override
  String codeSentToEmail(Object email) {
    return 'Code envoyé à $email';
  }

  @override
  String get emailNotFound => 'E-mail introuvable';

  @override
  String get loading => 'Chargement...';

  @override
  String get welcomeBack => 'Bon retour';

  @override
  String get startNow => 'Commencer';

  @override
  String get loginSubtitle => 'Saisissez vos identifiants pour continuer.';

  @override
  String get registerSubtitle =>
      'Inscrivez-vous pour découvrir des itinéraires personnalisés.';

  @override
  String get continueWithEmail => 'Continuer avec e-mail';

  @override
  String get registerWithEmail => 'S’inscrire avec e-mail';

  @override
  String get tagline => 'IA qui guide, tourisme qui unit';

  @override
  String get start => 'Commencer';

  @override
  String get loginWithBiometrics => 'Se connecter avec empreinte';

  @override
  String get navHome => 'Accueil';

  @override
  String get navDiary => 'Journal';

  @override
  String get navRecommend => 'Recommander';

  @override
  String get navCommunity => 'Communauté';

  @override
  String get navUser => 'Profil';

  @override
  String get communityTitle => 'Communauté';

  @override
  String get uploadPhotoAction => 'Action pour téléverser une photo';

  @override
  String get diaryTitle => 'Mon journal';

  @override
  String get favoritesTab => 'Favoris';

  @override
  String get historyTab => 'Historique';

  @override
  String get offlineAvailable => 'Disponible hors ligne';

  @override
  String recommendationsInCity(Object city) {
    return 'Recommandations à $city';
  }

  @override
  String recommendationNumber(Object number) {
    return 'Recommandation #$number';
  }

  @override
  String recommendationSubtitle(Object city) {
    return 'Suggéré par l’IA de SMARTUR pour votre visite à $city.';
  }

  @override
  String get mapDiscoverHint =>
      'Découvrez des points clés sans suivre votre position en temps réel.';

  @override
  String get mapTapPinHint =>
      'Touchez un repère pour voir des détails générés par l’IA';

  @override
  String get filterAll => 'Tous';

  @override
  String get filterMuseums => 'Musées';

  @override
  String get filterCafes => 'Cafés';

  @override
  String get filterViewpoints => 'Belvédères';

  @override
  String get filterMuseumsOnly => 'Musées uniquement';

  @override
  String get aiSmartur => 'IA Smartur';

  @override
  String get enableBiometricsHint =>
      'Connectez-vous et activez l’empreinte dans votre profil';

  @override
  String get deviceNotSupported => 'Appareil non compatible';

  @override
  String get noBiometricsEnrolled => 'Aucune empreinte enregistrée';

  @override
  String get biometricReason => 'Accédez à vos itinéraires SMARTUR';

  @override
  String get sessionExpired => 'Session expirée. Veuillez vous reconnecter.';

  @override
  String get biometricReadError => 'Erreur lors de la lecture de l’empreinte.';
}
