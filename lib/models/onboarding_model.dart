class OnboardingContent {
  final String title;
  final String description;
  final String lottiePath;
  OnboardingContent({required this.title, required this.description, required this.lottiePath});
}

List<OnboardingContent> contents = [
  OnboardingContent(
    title: "Tu aventura comienza aquí",
    lottiePath: 'assets/lottie/mountain.json',
    description: "Explora los rincones más mágicos de las Altas Montañas con rutas diseñadas para el explorador moderno.",
  ),
  OnboardingContent(
    title: "Inteligencia que te conoce",
    lottiePath: 'assets/lottie/ia.json',
    description: "Analizamos tus preferencias para que cada recomendación se sienta escrita solo para ti.",
  ),
  OnboardingContent(
    title: "Vive lo auténtico",
    lottiePath: 'assets/lottie/mapa.json',
    description: "Conecta con guías locales y apoya el turismo de nuestra región mientras creas recuerdos inolvidables.",
  ),
];
