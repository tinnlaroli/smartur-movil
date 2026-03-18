// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'SMARTUR';

  @override
  String get settingsTitle => 'Configurações';

  @override
  String get appearanceSection => 'Aparência';

  @override
  String get accountSection => 'Conta';

  @override
  String get infoSection => 'Informações';

  @override
  String get darkMode => 'Modo escuro';

  @override
  String get language => 'Idioma';

  @override
  String get colorblindMode => 'Modo daltônico';

  @override
  String get changePassword => 'Alterar senha';

  @override
  String get editName => 'Editar nome';

  @override
  String get deleteAccount => 'Excluir conta';

  @override
  String get appVersion => 'Versão do app';

  @override
  String get termsAndConditions => 'Termos e Condições';

  @override
  String get logout => 'Sair';

  @override
  String get selectLanguage => 'Selecionar idioma';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Salvar';

  @override
  String get deleteAccountTitle => 'Excluir conta';

  @override
  String get deleteAccountConfirm =>
      'Tem certeza de que deseja excluir sua conta? Esta ação é irreversível e você perderá seu histórico de viagens.';

  @override
  String get deleteAccountYes => 'Sim, excluir';

  @override
  String get editNameTitle => 'Editar nome';

  @override
  String get yourName => 'Seu nome';

  @override
  String get changePasswordTitle => 'Alterar senha';

  @override
  String get changePasswordStep0Hint =>
      'Enviaremos um código de verificação para o seu e-mail.';

  @override
  String get changePasswordStep1Hint => 'Digite o código e sua nova senha.';

  @override
  String get verificationCode => 'Código de verificação';

  @override
  String get newPassword => 'Nova senha';

  @override
  String get confirmPassword => 'Confirmar senha';

  @override
  String get sendCode => 'Enviar código';

  @override
  String get updatePassword => 'Atualizar senha';

  @override
  String get resendCode => 'Reenviar código';

  @override
  String get codeSixDigits => 'Código de 6 dígitos';

  @override
  String get passwordMinChars => 'Mínimo de 8 caracteres';

  @override
  String get passwordNeedUpper => 'Inclua pelo menos uma letra maiúscula';

  @override
  String get passwordNeedLower => 'Inclua pelo menos uma letra minúscula';

  @override
  String get passwordNeedNumber => 'Inclua pelo menos um número';

  @override
  String get passwordsDontMatch => 'As senhas não coincidem';

  @override
  String codeSentToEmail(Object email) {
    return 'Código enviado para $email';
  }

  @override
  String get emailNotFound => 'E-mail não encontrado';

  @override
  String get loading => 'Carregando...';

  @override
  String get welcomeBack => 'Bem-vindo de volta';

  @override
  String get startNow => 'Começar';

  @override
  String get loginSubtitle => 'Digite suas credenciais para continuar.';

  @override
  String get registerSubtitle =>
      'Cadastre-se para descobrir rotas personalizadas.';

  @override
  String get continueWithEmail => 'Continuar com e-mail';

  @override
  String get registerWithEmail => 'Cadastrar com e-mail';

  @override
  String get tagline => 'IA que guia, turismo que une';

  @override
  String get start => 'Começar';

  @override
  String get loginWithBiometrics => 'Entrar com impressão digital';

  @override
  String get navHome => 'Início';

  @override
  String get navDiary => 'Diário';

  @override
  String get navRecommend => 'Recomendar';

  @override
  String get navCommunity => 'Comunidade';

  @override
  String get navUser => 'Usuário';

  @override
  String get communityTitle => 'Comunidade';

  @override
  String get uploadPhotoAction => 'Ação para enviar uma foto';

  @override
  String get diaryTitle => 'Meu Diário';

  @override
  String get favoritesTab => 'Favoritos';

  @override
  String get historyTab => 'Histórico';

  @override
  String get offlineAvailable => 'Disponível offline';

  @override
  String recommendationsInCity(Object city) {
    return 'Recomendações em $city';
  }

  @override
  String recommendationNumber(Object number) {
    return 'Recomendação #$number';
  }

  @override
  String recommendationSubtitle(Object city) {
    return 'Sugerido pela IA da SMARTUR para sua visita a $city.';
  }

  @override
  String get mapDiscoverHint =>
      'Descubra pontos-chave sem rastrear sua localização em tempo real.';

  @override
  String get mapTapPinHint =>
      'Toque em um pin para ver detalhes gerados por IA';

  @override
  String get filterAll => 'Todos';

  @override
  String get filterMuseums => 'Museus';

  @override
  String get filterCafes => 'Cafés';

  @override
  String get filterViewpoints => 'Mirantes';

  @override
  String get filterMuseumsOnly => 'Somente museus';

  @override
  String get aiSmartur => 'IA Smartur';

  @override
  String get enableBiometricsHint =>
      'Faça login e ative a impressão digital no seu perfil';

  @override
  String get deviceNotSupported => 'Dispositivo não compatível';

  @override
  String get noBiometricsEnrolled => 'Nenhuma impressão digital cadastrada';

  @override
  String get biometricReason => 'Acesse suas rotas da SMARTUR';

  @override
  String get sessionExpired => 'Sessão expirada. Faça login novamente.';

  @override
  String get biometricReadError => 'Erro ao ler a impressão digital.';
}
