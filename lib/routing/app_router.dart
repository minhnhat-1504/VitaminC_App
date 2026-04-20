import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vitaminc/features/auth/presentation/screens/login_screen.dart';
import 'package:vitaminc/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:vitaminc/features/auth/presentation/screens/splash_screen.dart';
import 'package:vitaminc/features/dashboard/presentation/screens/home_screen.dart';
import '../features/social/presentation/screens/leaderboard_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../core/shared_widgets/bottom_nav_bar.dart';

import '../features/library/presentation/screens/deck_list_screen.dart';
import '../features/library/presentation/screens/add_vocab_screen.dart';
import '../features/study/presentation/screens/flashcard_screen.dart';
import '../features/study/presentation/screens/study_summary_screen.dart';
import '../features/tools/presentation/screens/pronunciation_screen.dart';

final _shellNavigatorKey = GlobalKey<NavigatorState>();

final goRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),

    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),

    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return Scaffold(
          body: child,
          bottomNavigationBar: const MainBottomNavBar(),
        );
      },
      routes: [
        GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
        GoRoute(
          path: '/library',
          builder: (context, state) => const DeckListScreen(),
        ),
        GoRoute(
          path: '/social',
          builder: (context, state) => const LeaderboardScreen(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/add-vocab',
      builder: (context, state) => const AddVocabScreen(),
    ),
    GoRoute(
      path: '/study',
      builder: (context, state) => const FlashcardScreen(),
    ),
    GoRoute(
      path: '/study-summary',
      builder: (context, state) => const StudySummaryScreen(),
    ),
    GoRoute(
      path: '/pronunciation',
      builder: (context, state) => const PronunciationScreen(),
    ),
  ],
);
