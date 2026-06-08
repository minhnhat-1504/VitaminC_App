import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vitaminc/features/auth/presentation/providers/auth_provider.dart';
import 'package:vitaminc/features/auth/presentation/screens/login_screen.dart';
import 'package:vitaminc/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:vitaminc/features/auth/presentation/screens/splash_screen.dart';
import 'package:vitaminc/features/auth/presentation/screens/verify_email_screen.dart';
import 'package:vitaminc/features/dashboard/presentation/screens/home_screen.dart';
import '../features/social/presentation/screens/leaderboard_screen.dart';
import '../features/social/presentation/screens/chat_room_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
import '../core/shared_widgets/bottom_nav_bar.dart';

import '../features/library/presentation/screens/deck_list_screen.dart';
import '../features/library/presentation/screens/deck_detail_screen.dart';
import '../features/library/presentation/screens/add_vocab_screen.dart';
import '../features/study/presentation/screens/flashcard_screen.dart';
import '../features/study/presentation/screens/study_summary_screen.dart';
import '../features/tools/presentation/screens/pronunciation_screen.dart';
import '../features/tools/presentation/screens/chatbot_screen.dart';
import '../features/tools/presentation/screens/ocr_scanner_screen.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

// ─── CUSTOM PAGE TRANSITIONS ───

/// Fade transition — dùng cho auth flow và shell tabs
CustomTransitionPage<void> _fadePage({
  required GoRouterState state,
  required Widget child,
  Duration duration = const Duration(milliseconds: 300),
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      );
    },
  );
}

/// Slide + Fade transition — dùng cho push screens
CustomTransitionPage<void> _slideFadePage({
  required GoRouterState state,
  required Widget child,
  Duration duration = const Duration(milliseconds: 300),
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.08, 0),
          end: Offset.zero,
        ).animate(curved),
        child: FadeTransition(
          opacity: curved,
          child: child,
        ),
      );
    },
  );
}

/// Slide-up + Fade transition — dùng cho fullscreen dialogs
CustomTransitionPage<void> _slideUpFadePage({
  required GoRouterState state,
  required Widget child,
  Duration duration = const Duration(milliseconds: 350),
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutQuart,
      );
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.06),
          end: Offset.zero,
        ).animate(curved),
        child: FadeTransition(
          opacity: curved,
          child: child,
        ),
      );
    },
  );
}

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
    final bool isEmailVerified = authState.value?.emailVerified ?? false;
    final String location = state.matchedLocation;

    // Các đường dẫn thuộc nhóm xác thực
    final bool isAuthPath =
        location == '/login' ||
        location == '/splash' ||
        location == '/onboarding';

    // 1. Nếu chưa đăng nhập: Buộc quay về màn Login (trừ khi đang ở Splash/Onboarding)
    if (!loggedIn) {
      return isAuthPath ? null : '/login';
    }

    // 2. Nếu đã đăng nhập thành công:
    // Chặn người dùng chưa xác minh email (chỉ cho phép ở màn hình verify-email)
    if (!isEmailVerified && location != '/verify-email') {
      return '/verify-email';
    }

    // Nếu đã xác minh xong nhưng đang ở màn hình verify-email -> cho vào Home
    if (isEmailVerified && location == '/verify-email') {
      return '/home';
    }

    if (isAuthPath) {
      return isEmailVerified ? '/home' : '/verify-email';
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
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: notifier,
    redirect: notifier.redirect,
    observers: [
      FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance),
    ],
    routes: [
      // ─── Auth screens (Fade transition) ───
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) =>
            _fadePage(state: state, child: const SplashScreen(), duration: const Duration(milliseconds: 400)),
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) =>
            _fadePage(state: state, child: const OnboardingScreen(), duration: const Duration(milliseconds: 400)),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) =>
            _fadePage(state: state, child: const LoginScreen(), duration: const Duration(milliseconds: 400)),
      ),
      GoRoute(
        path: '/verify-email',
        pageBuilder: (context, state) =>
            _fadePage(state: state, child: const VerifyEmailScreen(), duration: const Duration(milliseconds: 400)),
      ),

      // ─── Shell Route — Bottom Nav tabs (Fade giữa các tab) ───
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return Scaffold(
            body: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: child,
            ),
            bottomNavigationBar: const MainBottomNavBar(),
          );
        },
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (context, state) =>
                _fadePage(state: state, child: const HomeScreen(), duration: const Duration(milliseconds: 200)),
          ),
          GoRoute(
            path: '/library',
            pageBuilder: (context, state) =>
                _fadePage(state: state, child: const DeckListScreen(), duration: const Duration(milliseconds: 200)),
          ),
          GoRoute(
            path: '/social',
            pageBuilder: (context, state) =>
                _fadePage(state: state, child: const LeaderboardScreen(), duration: const Duration(milliseconds: 200)),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (context, state) =>
                _fadePage(state: state, child: const SettingsScreen(), duration: const Duration(milliseconds: 200)),
          ),
        ],
      ),

      // ─── Push screens (Slide + Fade) ───
      GoRoute(
        path: '/deck-detail',
        pageBuilder: (context, state) {
          final deckId = state.extra as String;
          return _slideFadePage(state: state, child: DeckDetailScreen(deckId: deckId));
        },
      ),
      GoRoute(
        path: '/add-vocab',
        pageBuilder: (context, state) {
          // Hỗ trợ cả 2 kiểu: String (tương thích ngược) và Map (từ OCR)
          if (state.extra is Map<String, String>) {
            final data = state.extra as Map<String, String>;
            return _slideFadePage(
              state: state,
              child: AddVocabScreen(deckId: data['deckId']!, initialWord: data['word']),
            );
          }
          final deckId = state.extra as String;
          return _slideFadePage(state: state, child: AddVocabScreen(deckId: deckId));
        },
      ),
      GoRoute(
        path: '/study',
        pageBuilder: (context, state) {
          final deckId = state.extra as String?;
          return _slideFadePage(state: state, child: FlashcardScreen(deckId: deckId));
        },
      ),
      GoRoute(
        path: '/pronunciation',
        pageBuilder: (context, state) =>
            _slideFadePage(state: state, child: const PronunciationScreen()),
      ),
      GoRoute(
        path: '/chatbot',
        pageBuilder: (context, state) =>
            _slideFadePage(state: state, child: const ChatbotScreen()),
      ),
      GoRoute(
        path: '/ocr',
        pageBuilder: (context, state) =>
            _slideFadePage(state: state, child: const OcrScannerScreen()),
      ),
      GoRoute(
        path: '/social/chat/:roomId',
        pageBuilder: (context, state) {
          final roomId = state.pathParameters['roomId']!;
          final roomName = state.uri.queryParameters['name'] ?? 'Chat Room';
          return _slideFadePage(
            state: state,
            child: ChatRoomScreen(roomId: roomId, roomName: roomName),
          );
        },
      ),

      // ─── Fullscreen dialog (Slide up + Fade) ───
      GoRoute(
        path: '/study-summary',
        pageBuilder: (context, state) =>
            _slideUpFadePage(state: state, child: const StudySummaryScreen()),
      ),
    ],
  );
});

