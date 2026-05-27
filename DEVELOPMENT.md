# Development Guide

This guide explains the project architecture, how components work together, and development best practices.

## Architecture Overview

### Layered Architecture

```
┌─────────────────────────────────────┐
│      UI Layer (Screens)             │
│  ├── Splash Screen                  │
│  ├── Auth Screens                   │
│  └── Post Screens                   │
├─────────────────────────────────────┤
│   State Management (Providers)      │
│  ├── AuthProvider                   │
│  └── PostProvider                   │
├─────────────────────────────────────┤
│   Services & Data Layer             │
│  ├── AuthService                    │
│  ├── PostService                    │
│  └── Shared Preferences             │
├─────────────────────────────────────┤
│   Configuration & Models            │
│  ├── ApiConfig                      │
│  ├── User Model                     │
│  └── Post Model                     │
├─────────────────────────────────────┤
│   External APIs                     │
│  └── Backend REST API               │
└─────────────────────────────────────┘
```

## Data Flow

### Authentication Flow

```
User Input (Login Screen)
    ↓
LoginScreen._submit()
    ↓
AuthProvider.login()
    ↓
AuthService.login() [HTTP Call]
    ↓
Backend API (/auth/login)
    ↓
Response {token, user}
    ↓
SharedPreferences.setString() [Token Storage]
    ↓
AuthProvider notifyListeners()
    ↓
GoRouter redirect to /feed
    ↓
FeedScreen rendered
```

### Post Fetching Flow

```
FeedScreen.initState()
    ↓
PostProvider.fetchPosts()
    ↓
PostService.fetchPosts() [HTTP + Token]
    ↓
Backend API (/posts/feed) + Authorization Header
    ↓
Response {posts: [...]}
    ↓
PostProvider._posts = posts
    ↓
PostProvider notifyListeners()
    ↓
FeedScreen rebuilds with posts
```

## Component Descriptions

### 1. Models (`lib/models/`)

**Purpose**: Define data structures

#### User Model
```dart
class User {
  final String id;
  final String username;
  final String email;
  final DateTime createdAt;
  
  User.fromJson(Map<String, dynamic> json) { }
}
```

**Usage**:
- Parse JSON from API
- Type-safe user data
- Pass between services and UI

#### Post Model
```dart
class Post {
  final String id;
  final String content;
  final User author;
  final DateTime createdAt;
  
  Post.fromJson(Map<String, dynamic> json) { }
}
```

### 2. Services (`lib/services/`)

**Purpose**: Handle API calls and data persistence

#### AuthService
```dart
class AuthService {
  Future<Map<String, dynamic>> register({...}) async
  Future<Map<String, dynamic>> login({...}) async
  Future<void> logout() async
  Future<String?> getToken() async
  Future<User?> getStoredUser() async
  Future<void> _saveSession(...) async
}
```

**Key Methods**:
- `register()`: Create new account
- `login()`: Authenticate user
- `logout()`: Clear session
- `getToken()`: Retrieve stored token
- `getStoredUser()`: Get cached user data

#### PostService
```dart
class PostService {
  final Future<String?> Function() getToken;
  
  Future<List<Post>> fetchPosts() async
  Future<List<Post>> fetchUserPosts(String userId) async
  Future<Post> getPost(String postId) async
  Future<Post> createPost(String content) async
  Future<Post> updatePost(String id, String content) async
  Future<void> deletePost(String id) async
}
```

**Key Features**:
- Accepts `getToken` callback for dynamic auth
- All requests include Authorization header
- Handles JSON parsing to Post objects

### 3. Providers (`lib/providers/`)

**Purpose**: Manage app state using Provider package

#### AuthProvider
```dart
class AuthProvider extends ChangeNotifier {
  // State
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;
  
  // Getters
  bool get isLoggedIn => _token != null;
  
  // Methods
  Future<bool> register({...}) async
  Future<bool> login({...}) async
  Future<void> logout() async
  void clearError()
}
```

**Usage**:
```dart
// Read current state
final auth = context.read<AuthProvider>();

// Watch for changes (rebuild on change)
final auth = context.watch<AuthProvider>();

// Check login status
if (auth.isLoggedIn) { ... }
```

#### PostProvider
```dart
class PostProvider extends ChangeNotifier {
  final PostService postService;
  
  List<Post> _posts = [];
  bool _isLoading = false;
  
  Future<void> fetchPosts() async
  Future<Post?> getPost(String id) async
  Future<void> createPost(String content) async
  Future<void> updatePost(String id, String content) async
  Future<void> deletePost(String id) async
}
```

### 4. Screens (`lib/screens/`)

**Purpose**: UI and user interaction

#### Structure
```
screens/
├── splash_screen.dart      # Entry point
├── auth/
│   ├── login_screen.dart   # User login
│   └── register_screen.dart # User registration
└── posts/
    ├── feed_screen.dart         # Post list
    ├── post_detail_screen.dart  # Single post view
    ├── create_post_screen.dart  # Create new post
    └── edit_post_screen.dart    # Edit post
```

#### Screen Example
```dart
class FeedScreen extends StatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);
  
  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch posts when screen loads
    Future.microtask(() {
      context.read<PostProvider>().fetchPosts();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<PostProvider>(
        builder: (context, posts, _) {
          if (posts.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            itemCount: posts.posts.length,
            itemBuilder: (context, index) {
              return PostCard(post: posts.posts[index]);
            },
          );
        },
      ),
    );
  }
}
```

### 5. Config (`lib/config/`)

**Purpose**: Central configuration management

```dart
class ApiConfig {
  static const String baseUrl = 'http://10.0.2.2:3000';
  
  static const String register = '$baseUrl/auth/register';
  static const String login    = '$baseUrl/auth/login';
  static const String posts    = '$baseUrl/posts';
  // ... more endpoints
}
```

### 6. Router (main.dart)

**Purpose**: Navigation management using GoRouter

```dart
final _router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    // Check authentication
    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn && !onAuthPage) {
      return '/login';
    }
    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (_, __) => LoginScreen()),
    GoRoute(path: '/feed', builder: (_, __) => FeedScreen()),
    // ... more routes
  ],
);
```

## Common Tasks

### Add a New Screen

1. **Create screen file**:
```dart
// lib/screens/profile_screen.dart
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);
  
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: Center(child: Text('Profile Screen')),
    );
  }
}
```

2. **Add route in main.dart**:
```dart
GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
```

3. **Navigate to it**:
```dart
context.go('/profile');
```

### Add a New API Endpoint

1. **Add to ApiConfig**:
```dart
static const String userProfile = '$baseUrl/users/profile';
```

2. **Add service method**:
```dart
Future<User> getUserProfile() async {
  final token = await getToken();
  final response = await http.get(
    Uri.parse(ApiConfig.userProfile),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
  
  if (response.statusCode == 200) {
    return User.fromJson(jsonDecode(response.body));
  }
  throw Exception('Failed to load profile');
}
```

3. **Add provider method**:
```dart
Future<void> fetchProfile() async {
  _isLoading = true;
  try {
    _user = await _authService.getUserProfile();
    _error = null;
  } catch (e) {
    _error = e.toString();
  }
  _isLoading = false;
  notifyListeners();
}
```

4. **Use in UI**:
```dart
Consumer<AuthProvider>(
  builder: (context, auth, _) {
    return Text(auth.user?.username ?? 'Unknown');
  },
)
```

### Handle Loading States

```dart
// In provider
bool _isLoading = false;
bool get isLoading => _isLoading;

void _setLoading(bool value) {
  _isLoading = value;
  notifyListeners();
}

// In UI
Consumer<AuthProvider>(
  builder: (context, auth, _) {
    return ElevatedButton(
      onPressed: auth.isLoading ? null : () => auth.login(...),
      child: auth.isLoading
          ? CircularProgressIndicator()
          : Text('Login'),
    );
  },
)
```

### Handle Errors

```dart
// In provider
String? _error;
String? get error => _error;

// In UI
if (auth.error != null) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Error'),
      content: Text(auth.error!),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('OK'),
        ),
      ],
    ),
  );
}
```

## Best Practices

### 1. Type Safety
```dart
// ✅ Good
Future<List<Post>> fetchPosts() async { }

// ❌ Avoid
Future<dynamic> fetchPosts() async { }
```

### 2. Error Handling
```dart
// ✅ Good
try {
  final result = await authService.login(...);
  if (result['success']) {
    // Handle success
  } else {
    _error = result['message'];
  }
} catch (e) {
  _error = 'Unexpected error: $e';
}

// ❌ Avoid
final result = await authService.login(...);
// No error handling
```

### 3. Resource Management
```dart
// ✅ Good
@override
void dispose() {
  _controller.dispose();
  super.dispose();
}

// ❌ Avoid
// Not disposing resources
```

### 4. Async/Await
```dart
// ✅ Good
Future<void> loadData() async {
  _isLoading = true;
  try {
    _data = await fetchData();
  } finally {
    _isLoading = false;
  }
}

// ❌ Avoid
Future<void> loadData() {
  _isLoading = true;
  return fetchData().then((data) {
    _data = data;
    _isLoading = false;
  });
}
```

### 5. Null Safety
```dart
// ✅ Good
String? getUsername() {
  return _user?.username;
}

// ❌ Avoid
String getUsername() {
  return _user.username; // Can throw if _user is null
}
```

## Debugging

### Enable Verbose Logging
```bash
flutter run -v
```

### Common Issues

#### Provider not found
```
Error: Error: Could not find the correct Provider
```
**Solution**: Ensure Provider is wrapped in the widget tree
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthProvider()),
  ],
  child: MaterialApp(...),
)
```

#### State not updating
```dart
// ❌ Wrong - doesn't call notifyListeners()
_user = newUser;

// ✅ Correct
_user = newUser;
notifyListeners();
```

#### Token not sent in request
```dart
// Ensure Authorization header is added
headers: {
  'Authorization': 'Bearer $token',
  'Content-Type': 'application/json',
}
```

---

**Happy coding!** 🚀
