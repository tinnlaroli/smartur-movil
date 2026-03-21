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
  String get appVersion => 'Version de l\'application';

  @override
  String get termsAndConditions => 'Conditions d\'utilisation';

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
  String get registerWithEmail => 'S\'inscrire avec e-mail';

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
    return 'Suggéré par l\'IA de SMARTUR pour votre visite à $city.';
  }

  @override
  String get mapDiscoverHint =>
      'Découvrez des points clés sans suivre votre position en temps réel.';

  @override
  String get mapTapPinHint =>
      'Touchez un repère pour voir des détails générés par l\'IA';

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
      'Connectez-vous et activez l\'empreinte dans votre profil';

  @override
  String get deviceNotSupported => 'Appareil non compatible';

  @override
  String get noBiometricsEnrolled => 'Aucune empreinte enregistrée';

  @override
  String get biometricReason => 'Accédez à vos itinéraires SMARTUR';

  @override
  String get sessionExpired => 'Session expirée. Veuillez vous reconnecter.';

  @override
  String get biometricReadError => 'Erreur lors de la lecture de l\'empreinte.';

  @override
  String get quickAccess => 'Accès rapide';

  @override
  String get activate => 'Activer';

  @override
  String get notNow => 'Pas maintenant';

  @override
  String get dontRemindMe => 'Ne plus me rappeler';

  @override
  String get biometricPrompt =>
      'Voulez-vous utiliser votre empreinte pour vous connecter plus vite la prochaine fois ?';

  @override
  String get biometricActivateReason =>
      'Confirmez votre empreinte pour activer l\'accès rapide';

  @override
  String get biometricActivateTitle => 'Activer l\'empreinte — SMARTUR';

  @override
  String get biometricTouchSensor => 'Touchez le capteur';

  @override
  String get biometricActivated => 'Accès par empreinte activé';

  @override
  String biometricActivateError(Object error) {
    return 'Impossible d\'activer : $error';
  }

  @override
  String get biometricDeactivated => 'L\'empreinte ne sera plus demandée';

  @override
  String get biometricConfirmActivate =>
      'Confirmez votre empreinte pour activer';

  @override
  String get biometricCouldNotActivate => 'Impossible d\'activer l\'empreinte';

  @override
  String get myProfile => 'Mon profil';

  @override
  String get manageAccount => 'Gérez votre compte rapidement';

  @override
  String get myPreferences => 'Mes préférences';

  @override
  String get yourPreferences => 'Vos préférences';

  @override
  String get noPreferencesSaved =>
      'Vous n\'avez pas encore enregistré de préférences.';

  @override
  String get confirmChangePreferences =>
      'Êtes-vous sûr de vouloir les modifier ?';

  @override
  String get change => 'Modifier';

  @override
  String get fingerprintAccess => 'Accès par empreinte';

  @override
  String get configuration => 'Paramètres';

  @override
  String exploreGreeting(Object name) {
    return 'Explorer$name';
  }

  @override
  String get highMountainsVeracruz => 'Altas Montañas, Veracruz';

  @override
  String get exploreHighMountains => 'Explorez les Hautes Montagnes';

  @override
  String recommendationsForYou(Object name) {
    return 'Recommandations pour vous, $name';
  }

  @override
  String get weatherNow => 'Météo actuelle';

  @override
  String get notAvailable => 'Non disponible';

  @override
  String get allCategories => 'Tous';

  @override
  String get noCategoryPlaces =>
      'Aucun lieu dans cette catégorie pour le moment';

  @override
  String get tabHistory => 'Histoire';

  @override
  String get tabLocation => 'Emplacement';

  @override
  String get tabGastronomy => 'Gastronomie';

  @override
  String get tabAiSummary => 'Résumé IA';

  @override
  String get fromPrice => 'Depuis';

  @override
  String get free => 'Gratuit';

  @override
  String get createOneDayRoute => 'Créer un itinéraire d\'1 jour';

  @override
  String get tabLocationPlaceholder => 'Carte et points clés à visiter.';

  @override
  String get tabGastronomyPlaceholder =>
      'Plats typiques et cafés recommandés de la zone.';

  @override
  String get tabAiPlaceholder =>
      'Résumé généré par IA avec avis et notes d\'autres touristes.';

  @override
  String get invalidCredentials => 'Identifiants incorrects.';

  @override
  String get invalidCode => 'Code invalide ou expiré.';

  @override
  String get tooManyAttempts => 'Trop de tentatives. Réessayez dans 1 minute.';

  @override
  String get accountCreated =>
      'Compte créé avec succès. Veuillez vous connecter.';

  @override
  String get connectionError => 'Erreur de connexion.';

  @override
  String get changeEmail => 'Changer l\'e-mail';

  @override
  String get confirmLogoutTitle => 'Se déconnecter';

  @override
  String get confirmLogoutMessage =>
      'Êtes-vous sûr de vouloir vous déconnecter ?';

  @override
  String get next => 'Suivant';

  @override
  String get back => 'Retour';

  @override
  String get sustainablePreferences => 'Préférences durables';

  @override
  String get sessionExpiredPreferences =>
      'Session expirée. Veuillez vous reconnecter.';

  @override
  String get profileReady =>
      'Profil prêt ! Nous vous donnerons des recommandations sur mesure 🎉';

  @override
  String get couldNotSavePreferences =>
      'Impossible d\'enregistrer les préférences. Réessayez.';

  @override
  String get selectGender => 'Veuillez sélectionner votre genre';

  @override
  String get selectAtLeastOneInterest => 'Sélectionnez au moins un intérêt';

  @override
  String get completeAllFields => 'Complétez tous les champs';

  @override
  String get categoryHotels => 'Hôtellerie';

  @override
  String get categoryRestaurants => 'Restaurants';

  @override
  String get categoryMuseums => 'Musées';

  @override
  String get categoryAdventures => 'Aventures';

  @override
  String get tourist => 'touriste';

  @override
  String get codeSentToLabel => 'Un code a été envoyé à :';

  @override
  String get enterSixDigitCode => 'Saisissez le code à 6 chiffres';

  @override
  String get rememberMe7Days =>
      'Se souvenir de moi pendant 7 jours sur cet appareil';

  @override
  String get verify => 'VÉRIFIER';

  @override
  String get signInButton => 'SE CONNECTER';

  @override
  String get createAccount => 'CRÉER UN COMPTE';

  @override
  String get continueWithGoogle => 'Continuer avec Google';

  @override
  String get noAccountPrompt => 'Pas de compte ? ';

  @override
  String get haveAccountPrompt => 'Déjà un compte ? ';

  @override
  String get signUp => 'Inscrivez-vous';

  @override
  String get signInAction => 'Connectez-vous';

  @override
  String get fullName => 'Nom complet';

  @override
  String get enterFullName => 'Saisissez votre nom complet';

  @override
  String get minThreeChars => 'Minimum 3 caractères';

  @override
  String get emailAddress => 'Adresse e-mail';

  @override
  String get enterEmail => 'Saisissez votre e-mail';

  @override
  String get enterValidEmail => 'Saisissez un e-mail valide';

  @override
  String get password => 'Mot de passe';

  @override
  String get enterPassword => 'Saisissez votre mot de passe';

  @override
  String get minEightChars => 'Minimum 8 caractères';

  @override
  String get atLeastOneUppercase => 'Au moins une majuscule';

  @override
  String get atLeastOneLowercase => 'Au moins une minuscule';

  @override
  String get atLeastOneNumber => 'Au moins un chiffre';

  @override
  String get atLeastOneSpecial => 'Au moins un caractère spécial';

  @override
  String get passwordRequirements => 'Le mot de passe doit contenir :';

  @override
  String get specialCharHint => 'Un caractère spécial (!@#\$%^&*)';

  @override
  String get strengthVeryWeak => 'Très faible';

  @override
  String get strengthWeak => 'Faible';

  @override
  String get strengthFair => 'Moyen';

  @override
  String get strengthStrong => 'Fort';

  @override
  String get strengthVeryStrong => 'Très fort';

  @override
  String get defaultUserName => 'Touriste SMARTUR';

  @override
  String get myInterests => 'Mes centres d\'intérêt';

  @override
  String get quickSettings => 'Paramètres rapides';

  @override
  String memberSince(Object date) {
    return 'Membre depuis $date';
  }

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsSubtitle =>
      'Gérez les alertes météo, itinéraires et communauté';

  @override
  String get appPreferences => 'Préférences de l\'app';

  @override
  String get appPreferencesSubtitle => 'Langue, unités et thème visuel';

  @override
  String get editProfile => 'Modifier le profil';

  @override
  String get editProfileSubtitle =>
      'Modifiez votre nom et vos données personnelles';

  @override
  String get changePasswordSubtitle =>
      'Mettez à jour votre mot de passe d\'accès';

  @override
  String get sessionClosed => 'Session fermée';

  @override
  String stepXOfY(Object current, Object total) {
    return 'Étape $current sur $total';
  }

  @override
  String get stepAboutYou => 'À propos de vous';

  @override
  String get stepAboutYouSubtitle => 'Parlez-nous un peu de vous';

  @override
  String get stepYourTastes => 'Vos goûts';

  @override
  String get stepYourTastesSubtitle => 'Ce qui vous passionne';

  @override
  String get stepDetails => 'Détails';

  @override
  String get stepDetailsSubtitle => 'Dernières préférences';

  @override
  String get birthYear => 'Année de naissance';

  @override
  String get enterBirthYear => 'Entrez votre année de naissance';

  @override
  String get invalidYear => 'Année non valide';

  @override
  String get gender => 'Genre';

  @override
  String get genderMale => 'Masculin';

  @override
  String get genderFemale => 'Féminin';

  @override
  String get genderNonBinary => 'Non binaire';

  @override
  String get genderPreferNotToSay => 'Je préfère ne pas dire';

  @override
  String get yourInterests => 'Vos intérêts';

  @override
  String get activityLevel => 'Niveau d\'activité';

  @override
  String get travelType => 'Type de voyage';

  @override
  String get preferredPlace => 'Lieu préféré';

  @override
  String get interestCulture => 'Culture';

  @override
  String get interestGastronomy => 'Gastronomie';

  @override
  String get interestAdventure => 'Aventure';

  @override
  String get interestNature => 'Nature';

  @override
  String get interestHistory => 'Histoire';

  @override
  String get interestPhotography => 'Photographie';

  @override
  String get interestSports => 'Sports';

  @override
  String get interestWellness => 'Bien-être';

  @override
  String get interestArt => 'Art';

  @override
  String get interestNightlife => 'Vie nocturne';

  @override
  String get activityLow => 'Bas';

  @override
  String get activityModerate => 'Modéré';

  @override
  String get activityHigh => 'Élevé';

  @override
  String get activityExtreme => 'Extrême';

  @override
  String get travelBackpacker => 'Routard';

  @override
  String get travelFamily => 'Famille';

  @override
  String get travelLuxury => 'Luxe';

  @override
  String get travelAdventure => 'Aventure';

  @override
  String get travelRomantic => 'Romantique';

  @override
  String get travelBusiness => 'Affaires';

  @override
  String get placeBeach => 'Plage';

  @override
  String get placeMountain => 'Montagne';

  @override
  String get placeCity => 'Ville';

  @override
  String get placeCountryside => 'Campagne';

  @override
  String get placeForest => 'Forêt';

  @override
  String get placeDesert => 'Désert';

  @override
  String get needAccessibility =>
      'Avez-vous besoin d\'accessibilité spéciale ?';

  @override
  String get accessibilitySubtitle =>
      'Itinéraires adaptés à la mobilité réduite ou autres besoins';

  @override
  String get describeNeedOptional => 'Décrivez votre besoin (optionnel)';

  @override
  String get accessibilityHint => 'Ex : fauteuil roulant, canne...';

  @override
  String get visitedHighMountains => 'Avez-vous visité les Hautes Montagnes ?';

  @override
  String get visitedSubtitle =>
      'Cela nous aide à mieux personnaliser vos recommandations';

  @override
  String get dietaryRestrictions => 'Restrictions alimentaires ou médicales';

  @override
  String get dietaryHint =>
      'Ex : végétarien, allergie aux fruits de mer... (laisser vide si aucune)';

  @override
  String get sustainableNoPref => 'Sans préférence';

  @override
  String get sustainableLow => 'Priorité basse';

  @override
  String get sustainableMedium => 'Priorité moyenne';

  @override
  String get sustainableHigh => 'Priorité élevée';
}
