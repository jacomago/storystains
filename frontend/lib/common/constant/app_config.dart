/// Config loaded from the environment
class AppConfig {
  /// Url for the api backend
  static const baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://127.0.0.1:8080/api',
  );

  /// Default limit for requesting listed data from the api
  static const defaultLimit =
      int.fromEnvironment('defaultLimit', defaultValue: 20);
}
