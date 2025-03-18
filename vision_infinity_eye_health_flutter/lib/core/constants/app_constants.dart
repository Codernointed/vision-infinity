class AppConstants {
  static const String appName = 'Vision Infinity Eye Health';
  static const String apiBaseUrl =
      'https://api.visioninfinity.com'; // Replace with actual API URL

  // Route Names
  static const String homeRoute = '/';
  static const String profileRoute = '/profile';
  static const String historyRoute = '/history';
  static const String resultsRoute = '/results';

  // Asset Paths
  static const String imagesPath = 'assets/images/';
  static const String iconsPath = 'assets/icons/';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'app_theme';

  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String scanEndpoint = '/scan';
  static const String historyEndpoint = '/history';

  // Error Messages
  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError = 'Please check your internet connection.';
  static const String authError = 'Authentication failed. Please login again.';
}
