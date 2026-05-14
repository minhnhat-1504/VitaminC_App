import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/dashboard_service.dart';
import '../../data/streak_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

final dashboardServiceProvider = Provider<DashboardService>((ref) {
  return DashboardService();
});

final streakServiceProvider = Provider<StreakService>((ref) {
  return StreakService();
});

/// FutureProvider lấy [Streak] từ Firestore
final streakCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return 0;

  final service = ref.watch(streakServiceProvider);
  return await service.getStreakCount(user.uid);
});

/// FutureProvider lấy [Số từ đã học] từ Firestore
final learnedVocabCountProvider = FutureProvider.autoDispose<int>((ref) async {
  // Lấy uid của người dùng đang đăng nhập
  final user = ref.watch(authStateProvider).value;
  if (user == null) {
    return 0; // Trả về 0 nếu chưa đăng nhập
  }

  // Gọi Service để đếm
  final service = ref.watch(dashboardServiceProvider);
  return await service.getLearnedVocabCount(user.uid);
});
