import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vitaminc/features/auth/presentation/providers/auth_provider.dart';
import 'package:vitaminc/features/auth/presentation/screens/login_screen.dart';
import 'package:vitaminc/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:vitaminc/features/auth/presentation/screens/splash_screen.dart';
import 'package:vitaminc/features/dashboard/presentation/screens/home_screen.dart';
import '../features/social/presentation/screens/leaderboard_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../core/shared_widgets/bottom_nav_bar.dart';

import '../features/library/presentation/screens/deck_list_screen.dart';
import '../features/library/presentation/screens/deck_detail_screen.dart';
import '../features/library/presentation/screens/add_vocab_screen.dart';
import '../features/study/presentation/screens/flashcard_screen.dart';
import '../features/study/presentation/screens/study_summary_screen.dart';
import '../features/tools/presentation/screens/pronunciation_screen.dart';
import '../features/tools/presentation/screens/chatbot_screen.dart';

final _shellNavigatorKey = GlobalKey<NavigatorState>();

// Notifier để lắng nghe các thay đổi trạng thái và thông báo cho GoRouter
class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    // Lắng nghe thay đổi của authStateProvider và currentUserProvider
    _ref.listen(authStateProvider, (_, __) => notifyListeners());
    _ref.listen(currentUserProvider, (_, __) => notifyListeners());
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final authState = _ref.read(authStateProvider);
    final userModel = _ref.read(currentUserProvider);

    // Chờ cho đến khi Firebase tải xong dữ liệu khởi tạo (tránh nhảy màn hình quá sớm)
    if (authState.isLoading || userModel.isLoading) return null;

    final bool loggedIn = authState.value != null;
    final String location = state.matchedLocation;
    
    // Các đường dẫn thuộc nhóm xác thực
    final bool isAuthPath = location == '/login' || 
                            location == '/splash' || 
                            location == '/onboarding';

    // 1. Nếu chưa đăng nhập: Buộc quay về màn Login (trừ khi đang ở Splash/Onboarding)
    if (!loggedIn) {
      return isAuthPath ? null : '/login';
    }

    // 2. Nếu đã đăng nhập thành công:
    if (isAuthPath) {
      return '/home';
    }

    return null;
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

// Provider cung cấp GoRouter ổn định
final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      // Các màn hình độc lập
      GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      
      // Cấu hình ShellRoute cho các màn hình có BottomNavigationBar
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
          GoRoute(path: '/library', builder: (context, state) => const DeckListScreen()),
          GoRoute(path: '/social', builder: (context, state) => const LeaderboardScreen()),
          GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
        ],
      ),

      // Các màn hình chức năng sâu (Full screen)
      GoRoute(
        path: '/deck-detail', 
        builder: (context, state) {
          final deckId = state.extra as String;
          return DeckDetailScreen(deckId: deckId);
        }
      ),
      GoRoute(
        path: '/add-vocab', 
        builder: (context, state) {
          final deckId = state.extra as String;
          return AddVocabScreen(deckId: deckId);
        }
      ),
      GoRoute(
        path: '/study',
        builder: (context, state) {
          // Ép kiểu extra thành String để lấy deckId
          final deckId = state.extra as String?; 
          return FlashcardScreen(deckId: deckId);
        },
      ),
      GoRoute(path: '/study-summary', builder: (context, state) => const StudySummaryScreen()),
      GoRoute(path: '/pronunciation', builder: (context, state) => const PronunciationScreen()),
      GoRoute(path: '/chatbot', builder: (context, state) => const ChatbotScreen()),
    ],
  );
});