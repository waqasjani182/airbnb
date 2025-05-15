enum Environment {
  development,
  staging,
  production,
}

class AppConfig {
  static final AppConfig _instance = AppConfig._internal();
  factory AppConfig() => _instance;
  AppConfig._internal();

  // Default to development environment
  Environment _environment = Environment.development;

  // API URLs for different environments
  final Map<Environment, String> _baseUrls = {
    Environment.development: 'http://10.0.2.2:3004', // Android emulator
    Environment.staging: 'https://staging-api.example.com',
    Environment.production: 'https://api.example.com',
  };

  // Base URL for macOS
  String get macOSBaseUrl => 'http://localhost:3004';

  // Initialize the configuration
  void initialize({Environment environment = Environment.development}) {
    _environment = environment;
  }

  // Get the current environment
  Environment get environment => _environment;

  // Get the base URL for the current environment
  String get baseUrl => _baseUrls[_environment]!;

  // Get the base URL for iOS simulator (127.0.0.1 instead of 10.0.2.2)
  String get iosBaseUrl => 'http://127.0.0.1:3004';

  // Get the base URL for physical devices
  String get deviceBaseUrl =>
      'http://127.0.0.1:3004'; // Using loopback address for local development
}
