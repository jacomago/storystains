class AppConfig {
  static const baseUrl = String.fromEnvironment("BASE_URL",
      defaultValue: "http://127.0.0.1:8080/api");
  static const defaultLimit =
      int.fromEnvironment("defaultLimit", defaultValue: 20);
  static const appName = 'Story Stains';
  static const appTitle = 'Story Stains';
  static const search = 'Search...';
  static const empty = 'No data.';
  static const failed = 'Fetching data failed.';
}
