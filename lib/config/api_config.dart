class ApiConfig {
  // On Android emulator, localhost of the HOST machine is 10.0.2.2
  // Set ENV variable API_BASE_URL to override in CI
  static String get baseUrl {
    const env = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (env.isNotEmpty) return env;
    return 'http://10.0.2.2:3000'; // emulator → host machine
  }

  static String get register => '$baseUrl/auth/register';
  static String get login    => '$baseUrl/auth/login';
  static String get posts    => '$baseUrl/posts';
  static String get feed     => '$baseUrl/posts/feed';
  static String get users    => '$baseUrl/users';
  static String get me       => '$baseUrl/users/me';
}
