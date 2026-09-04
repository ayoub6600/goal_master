/// One signup screen as the admin panel configured it.
///
/// Every field but [slug] is optional on purpose: an admin who has not
/// uploaded artwork or overridden the wording must leave the app exactly as
/// it ships, not blank out a screen.
class OnboardingScreenModel {
  const OnboardingScreenModel({
    required this.slug,
    this.title,
    this.subtitle,
    this.imageUrl,
  });

  final String slug;
  final String? title;
  final String? subtitle;
  final String? imageUrl;

  static String? _clean(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  factory OnboardingScreenModel.fromJson(Map<String, dynamic> json) {
    return OnboardingScreenModel(
      slug: (json['slug'] ?? '').toString(),
      title: _clean(json['title']),
      subtitle: _clean(json['subtitle']),
      imageUrl: _clean(json['image_url']),
    );
  }
}

/// The screen names the app asks for. These match the slugs the backend
/// seeds and are not user-editable there.
class OnboardingSlugs {
  static const name = 'name';
  static const phone = 'phone';
  static const password = 'password';
  static const success = 'success';
}
