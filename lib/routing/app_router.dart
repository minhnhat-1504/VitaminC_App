import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// Tạm thời comment các file chưa tồn tại để hết lỗi đỏ
// import '../features/dashboard/presentation/screens/home_screen.dart';
// import '../features/library/presentation/screens/deck_list_screen.dart';
// import '../features/social/presentation/screens/leaderboard_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../core/shared_widgets/bottom_nav_bar.dart';

// Import các màn hình của Thành viên 3
import '../features/library/presentation/screens/deck_list_screen.dart';
import '../features/library/presentation/screens/add_vocab_screen.dart';
import '../features/study/presentation/screens/flashcard_screen.dart';
import '../features/study/presentation/screens/study_summary_screen.dart';

// Tạo key để quản lý trạng thái của Bottom Navigation Bar
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final goRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return Scaffold(
          body: child,
          bottomNavigationBar: const MainBottomNavBar(),
        );
      },
      routes: [
        // Sử dụng Scaffold tạm thời để app chạy được
        GoRoute(
          path: '/home',
          builder: (context, state) => const Scaffold(
            body: Center(child: Text("Home Screen Placeholder")),
          ),
        ),
        GoRoute(
          path: '/library',
          builder: (context, state) => const DeckListScreen(),
        ),
        GoRoute(
          path: '/social',
          builder: (context, state) => const Scaffold(
            body: Center(child: Text("Social Screen Placeholder")),
          ),
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
  ],
);
