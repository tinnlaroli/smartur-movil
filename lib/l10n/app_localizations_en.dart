// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SMARTUR';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get appearanceSection => 'Appearance';

  @override
  String get accountSection => 'Account';

  @override
  String get infoSection => 'Info';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get language => 'Language';

  @override
  String get colorblindMode => 'Colorblind Mode';

  @override
  String get changePassword => 'Change Password';

  @override
  String get editName => 'Edit Name';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get appVersion => 'App Version';

  @override
  String get termsAndConditions => 'Terms and Conditions';

  @override
  String get logout => 'Log out';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get deleteAccountTitle => 'Delete account';

  @override
  String get deleteAccountConfirm =>
      'Are you sure you want to delete your account? This action is irreversible and you will lose your trip history.';

  @override
  String get deleteAccountYes => 'Yes, delete';

  @override
  String get editNameTitle => 'Edit name';

  @override
  String get yourName => 'Your name';

  @override
  String get changePasswordTitle => 'Change Password';

  @override
  String get changePasswordStep0Hint =>
      'We will send you a verification code to your email.';

  @override
  String get changePasswordStep1Hint => 'Enter the code and your new password.';

  @override
  String get verificationCode => 'Verification code';

  @override
  String get newPassword => 'New password';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get sendCode => 'Send code';

  @override
  String get updatePassword => 'Update password';

  @override
  String get resendCode => 'Resend code';

  @override
  String get codeSixDigits => '6-digit code';

  @override
  String get passwordMinChars => 'Minimum 8 characters';

  @override
  String get passwordNeedUpper => 'Include at least one uppercase letter';

  @override
  String get passwordNeedLower => 'Include at least one lowercase letter';

  @override
  String get passwordNeedNumber => 'Include at least one number';

  @override
  String get passwordsDontMatch => 'Passwords do not match';

  @override
  String codeSentToEmail(Object email) {
    return 'Code sent to $email';
  }

  @override
  String get emailNotFound => 'Email not found';

  @override
  String get loading => 'Loading...';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get startNow => 'Get started';

  @override
  String get loginSubtitle => 'Enter your credentials to continue.';

  @override
  String get registerSubtitle => 'Sign up to discover personalized routes.';

  @override
  String get continueWithEmail => 'Continue with Email';

  @override
  String get registerWithEmail => 'Sign up with Email';

  @override
  String get tagline => 'AI that guides, Tourism that unites';

  @override
  String get start => 'Start';

  @override
  String get loginWithBiometrics => 'Sign in with fingerprint';

  @override
  String get navHome => 'Home';

  @override
  String get navDiary => 'Diary';

  @override
  String get navRecommend => 'Recommend';

  @override
  String get navCommunity => 'Community';

  @override
  String get navUser => 'User';

  @override
  String get communityTitle => 'Community';

  @override
  String get uploadPhotoAction => 'Action to upload a photo';

  @override
  String get diaryTitle => 'My Diary';

  @override
  String get favoritesTab => 'Favorites';

  @override
  String get historyTab => 'History';

  @override
  String get offlineAvailable => 'Available offline';

  @override
  String recommendationsInCity(Object city) {
    return 'Recommendations in $city';
  }

  @override
  String recommendationNumber(Object number) {
    return 'Recommendation #$number';
  }

  @override
  String recommendationSubtitle(Object city) {
    return 'Suggested by SMARTUR AI for your visit to $city.';
  }

  @override
  String get mapDiscoverHint =>
      'Discover key points without tracking your location in real time.';

  @override
  String get mapTapPinHint => 'Tap a pin to see AI-generated details';

  @override
  String get filterAll => 'All';

  @override
  String get filterMuseums => 'Museums';

  @override
  String get filterCafes => 'Cafés';

  @override
  String get filterViewpoints => 'Viewpoints';

  @override
  String get filterMuseumsOnly => 'Museums only';

  @override
  String get aiSmartur => 'SMARTUR AI';

  @override
  String get enableBiometricsHint =>
      'Sign in and enable fingerprint in your profile';

  @override
  String get deviceNotSupported => 'Device not supported';

  @override
  String get noBiometricsEnrolled => 'No fingerprints enrolled';

  @override
  String get biometricReason => 'Access your SMARTUR routes';

  @override
  String get sessionExpired => 'Session expired. Please sign in again.';

  @override
  String get biometricReadError => 'Error reading fingerprint.';
}
