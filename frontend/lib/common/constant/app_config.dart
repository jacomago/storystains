class AppConfig {
  static const baseUrl =
      String.fromEnvironment("BASE_URL", defaultValue: "http://127.0.0.1:8080");
  static const defaultLimit =
      int.fromEnvironment("defaultLimit", defaultValue: 20);
}
