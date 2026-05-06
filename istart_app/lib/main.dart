// lib/main.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/idea_provider.dart';
import 'providers/discussion_provider.dart';
import 'providers/join_request_provider.dart';
import 'providers/doc_request_provider.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/onboarding/role_selection_screen.dart';
import 'screens/onboarding/register_screen.dart';
import 'screens/onboarding/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/profile/profile_screen.dart';

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, _) => const SplashScreen()),
    GoRoute(
      path: '/role-selection',
      builder: (_, _) => const RoleSelectionScreen(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return RegisterScreen(role: extra?['role'] ?? 'founder');
      },
    ),
    GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
    GoRoute(path: '/home', builder: (_, _) => const HomeScreen()),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
);

void main() {
  runApp(const IStartApp());
}

class IStartApp extends StatelessWidget {
  const IStartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => IdeaProvider()),
        ChangeNotifierProvider(create: (_) => DiscussionProvider()),
        ChangeNotifierProvider(create: (_) => JoinRequestProvider()),
        ChangeNotifierProvider(create: (_) => DocRequestProvider()),
      ],
      child: MaterialApp.router(
        title: 'iStart',
        debugShowCheckedModeBanner: false,
        routerConfig: _router,
        theme: ThemeData(
          scaffoldBackgroundColor: const Color(0xFF0D0D0D),
          fontFamily: 'DM Sans',
        ),
      ),
    );
  }
}
