import 'screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/topic_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'screens/roadmap_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/quiz_screen.dart';
import 'services/firebase_service.dart';

final router = GoRouter(
  initialLocation: '/splash',
  routes: [
    // Splash — checks auth + roadmap, redirects accordingly
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
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
    GoRoute(
      path: '/topic',
      builder: (context, state) => TopicDetailScreen(
        extra: (state.extra as Map<String, dynamic>?) ?? {},
      ),
    ),
    GoRoute(
      path: '/chat',
      builder: (context, state) => ChatScreen(
        extra: (state.extra as Map<String, dynamic>?) ?? {},
      ),
    ),
    GoRoute(
      path: '/quiz',
      builder: (context, state) => QuizScreen(
        extra: (state.extra as Map<String, dynamic>?) ?? {},
      ),
    ),
  ],
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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

// ─── SPLASH SCREEN ────────────────────────────────────────────────────────────
// Checks auth state and roadmap, then redirects:
// - Not logged in → /login
// - Logged in + has roadmap → /home
// - Logged in + no roadmap → /onboarding
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    final user = FirebaseService.currentUser;

    if (user == null) {
      context.go('/login');
      return;
    }

    // User is logged in — check if they have a roadmap
    try {
      final roadmap = await FirebaseService.getRoadmap();
      if (!mounted) return;

      if (roadmap != null && roadmap.isNotEmpty) {
        // Returning user — go straight to home
        context.go('/home', extra: {});
      } else {
        // New user — go to onboarding
        context.go('/onboarding');
      }
    } catch (e) {
      if (mounted) context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF7F77DD),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.auto_awesome,
                  color: Colors.white, size: 40),
            ),
            const SizedBox(height: 20),
            const Text(
              'SkillPath AI',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF7F77DD),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Building your learning path...',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(color: Color(0xFF7F77DD)),
          ],
        ),
      ),
    );
  }
}