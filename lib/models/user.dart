class User {
  final String id;
  final String username;
  final String email;
  final String bio;
  final String avatarUrl;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.bio = '',
    this.avatarUrl = '',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id:        json['id'] ?? '',
      username:  json['username'] ?? '',
      email:     json['email'] ?? '',
      bio:       json['bio'] ?? '',
      avatarUrl: json['avatarUrl'] ?? '',
    );
  }
}