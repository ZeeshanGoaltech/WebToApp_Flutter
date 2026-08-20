class OnboardingSlideModel {
  OnboardingSlideModel({
    required this.id,
    this.title = '',
    this.description = '',
    this.imagePath,
    this.ctaEnabled = false,
    this.ctaLabel = '',
  });

  final String id;
  String title;
  String description;
  String? imagePath;
  bool ctaEnabled;
  String ctaLabel;
}
