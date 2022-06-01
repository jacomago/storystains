const baseUrl =
    String.fromEnvironment("API_HOST", defaultValue: 'http://127.0.0.1:8080');
const default_limit = int.fromEnvironment("DEFAULT_LIMIT", defaultValue: 20);
