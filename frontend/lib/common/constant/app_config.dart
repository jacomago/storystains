class AppConfig {
  static const baseUrl =
      String.fromEnvironment("API_HOST", defaultValue: 'http://127.0.0.1:8080');
  static const defaultLimit =
      int.fromEnvironment("defaultLimit", defaultValue: 20);
}
