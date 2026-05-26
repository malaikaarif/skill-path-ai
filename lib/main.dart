import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'screens/roadmap_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/quiz_screen.dart';

final router = GoRouter(
  initialLocation: '/onboarding',
  routes: [
    GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
    GoRoute(
      path: '/home',
      builder: (context, state) => HomeScreen(
        extra: (state.extra as Map<String, dynamic>?) ?? {},
      ),
    ),

    GoRoute(
      path: '/roadmap',
      builder: (context, state) => RoadmapScreen(
        extra: (state.extra as Map<String, dynamic>?) ?? {},
      ),
    ),
    GoRoute(path: '/chat',       builder: (context, state) => const ChatScreen()),
    GoRoute(path: '/quiz',       builder: (context, state) => const QuizScreen()),
  ],
);

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SkillPath AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF7F77DD)),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      routerConfig: router,
    );
  }
}