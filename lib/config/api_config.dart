class ApiConfig {
  // Change this to your deployed URL when not running locally
  static const String baseUrl = 'http://10.0.2.2:3000';

  static const String register = '$baseUrl/auth/register';
  static const String login    = '$baseUrl/auth/login';
  static const String posts    = '$baseUrl/posts';
  static const String feed     = '$baseUrl/posts/feed';
  static const String users    = '$baseUrl/users';
  static const String me       = '$baseUrl/users/me';
}