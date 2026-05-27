import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'providers/auth_provider.dart';
import 'providers/post_provider.dart';
import 'services/post_service.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/posts/feed_screen.dart';
import 'screens/posts/post_detail_screen.dart';
import 'screens/posts/create_post_screen.dart';
import 'screens/posts/edit_post_screen.dart';

void main() {
  runApp(MyApp());
}

final _router = GoRouter(
  initialLocation: '/',
  redirect: (context, state) {
    final auth = context.read<AuthProvider>();
    final loggedIn = auth.isLoggedIn;
    final onAuthPage =
        state.matchedLocation == '/login' ||
        state.matchedLocation == '/register';
    if (!loggedIn && !onAuthPage && state.matchedLocation != '/') {
      return '/login';
    }
    return null;
  },
  routes: [
    GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
    GoRoute(path: '/feed', builder: (_, __) => const FeedScreen()),
    GoRoute(
      path: '/posts/:id',
      builder: (_, state) =>
          PostDetailScreen(postId: state.pathParameters['id']!),
    ),
    GoRoute(path: '/create', builder: (_, __) => const CreatePostScreen()),
    GoRoute(
      path: '/edit/:id',
      builder: (_, state) =>
          EditPostScreen(postId: state.pathParameters['id']!),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..init()),
        ChangeNotifierProxyProvider<AuthProvider, PostProvider>(
          create: (ctx) => PostProvider(
            postService: PostService(getToken: () async => null),
          ),
          update: (ctx, auth, prev) => PostProvider(
            postService: PostService(getToken: auth.authService.getToken),
          ),
        ),
      ],
      child: MaterialApp.router(
        title: 'Social Media',
        routerConfig: _router,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
      ),
    );
  }
}
