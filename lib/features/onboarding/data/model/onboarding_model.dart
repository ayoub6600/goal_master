class OnboardingModel {
  final int imageIndex;

  /// The admin-panel screen this slide reads from (`intro_1` …).
  final String slug;
  final String title;
  final String subtitle;

  /// Bundled picture, shown when the admin has not set one or it is still
  /// on its way.
  final String images;

  /// Set from the admin panel (compressed there), or null.
  final String? imageUrl;

  OnboardingModel({
    required this.imageIndex,
    required this.slug,
    required this.title,
    required this.subtitle,
    required this.images,
    this.imageUrl,
  });
}
