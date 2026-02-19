/// Application asset paths
///
/// Centralized asset path definitions for images, icons, and other assets.
/// Ensures type-safe asset references throughout the app.
class AppAssets {
  AppAssets._();

  // Base Paths
  static const String _basePath = 'assets';
  static const String _brandPath = '$_basePath/brand';
  // ignore: unused_field - Template for production
  static const String _iconsPath = '$_basePath/icons';
  // ignore: unused_field - Template for production
  static const String _imagesPath = '$_basePath/images';

  // Brand Assets
  static const String logoDark = '$_brandPath/logo.png';
  static const String logoLight = '$_brandPath/logo2.png';

  // ─────────────────────────────────────────────────────────────────────────
  // PRODUCTION: Add more asset paths as needed
  // ─────────────────────────────────────────────────────────────────────────
  // static const String onboardingImage1 = '$_imagesPath/onboarding_1.png';
  // static const String onboardingImage2 = '$_imagesPath/onboarding_2.png';
  // static const String onboardingImage3 = '$_imagesPath/onboarding_3.png';
  // static const String avatarPlaceholder = '$_imagesPath/avatar_placeholder.png';
  // static const String emptyState = '$_imagesPath/empty_state.png';
}
