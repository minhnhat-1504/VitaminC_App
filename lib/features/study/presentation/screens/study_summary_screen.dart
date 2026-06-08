import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/shared_widgets/custom_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../../../social/presentation/providers/social_providers.dart';
import '../../../social/presentation/screens/lucky_spin_screen.dart';
import '../../../social/presentation/providers/quest_provider.dart';
import '../../../social/presentation/widgets/streak_popup.dart';
import '../../data/srs_engine.dart';
import '../controllers/study_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudySummaryScreen extends ConsumerStatefulWidget {
  const StudySummaryScreen({super.key});

  @override
  ConsumerState<StudySummaryScreen> createState() => _StudySummaryScreenState();
}

class _StudySummaryScreenState extends ConsumerState<StudySummaryScreen> {
  int _wordsReviewed = 0;
  int _xpEarned = 0;
  bool _isUpdating = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateStatsAndXP();
    });
  }

  Future<void> _updateStatsAndXP() async {
    final studyState = ref.read(studyControllerProvider);

    int totalWordsReviewed = 0;
    int validWordsReviewed = 0;
    int xp = 0;

    // Cơ chế chống spam điểm XP vô tận: không cộng điểm trong chế độ học ép (forceStudy)
    if (!studyState.forceStudy) {
      for (final card in studyState.dueCards) {
        final quality = studyState.reviewedQualities[card.id];
        if (quality != null) {
          totalWordsReviewed++;
          validWordsReviewed++;

          // Từ mới (repetition == 0 trước phiên học) -> không được tính điểm XP (0 XP)
          if (card.repetition == 0) {
            continue;
          }

          // Chỉ tính điểm trong lượt nhắc (repetition > 0 trước phiên học) dựa theo chất lượng lựa chọn
          if (card.repetition > 0) {
            if (quality == ReviewQuality.good) {
              xp += 10;
            } else if (quality == ReviewQuality.easy) {
              xp += 15;
            } else if (quality == ReviewQuality.hard) {
              xp += 0; // Chọn Hard (quên từ) -> 0 XP
            }
          }
        }
      }
    } else {
      // Trong chế độ học ép, vẫn đếm số từ đã học nhưng không cộng XP và không tính vào tiến trình nhiệm vụ
      for (final card in studyState.dueCards) {
        if (studyState.reviewedQualities[card.id] != null) {
          totalWordsReviewed++;
        }
      }
    }

    setState(() {
      _wordsReviewed = totalWordsReviewed;
      _xpEarned = xp;
    });

    final user = ref.read(authStateProvider).value;
    if (user != null) {
      try {
        // 1. Cộng XP nếu có tích lũy XP hợp lệ
        if (xp > 0) {
          await ref.read(userServiceProvider).addXP(user.uid, xp);
        }

        // 2. Cập nhật Streak và nhận số streak mới
        final newStreak = await ref
            .read(streakServiceProvider)
            .updateStreak(user.uid);
        ref.invalidate(streakCountProvider);

        // Kiểm tra và hiển thị Popup chúc mừng Streak (1 lần/ngày)
        final prefs = await SharedPreferences.getInstance();
        final todayStr = DateTime.now().toIso8601String().substring(0, 10);
        final lastStreakPopupDate = prefs.getString(
          'last_streak_popup_${user.uid}',
        );

        bool willShowStreakPopup = false;
        if (lastStreakPopupDate != todayStr && newStreak > 0) {
          await prefs.setString('last_streak_popup_${user.uid}', todayStr);
          willShowStreakPopup = true;
          if (mounted) {
            Future.microtask(() {
              showGeneralDialog(
                context: context,
                barrierDismissible: true,
                barrierLabel: "StreakPopup",
                barrierColor: Colors.black.withOpacity(0.5),
                transitionDuration: const Duration(milliseconds: 300),
                pageBuilder: (context, animation, secondaryAnimation) {
                  return const StreakPopup();
                },
              );
            });
          }
        }

        // 3. Lấy số từ vựng đã học thực tế để làm căn cứ trao huy hiệu
        final learnedVocabCount = await ref
            .read(dashboardServiceProvider)
            .getLearnedVocabCount(user.uid);

        // Cập nhật nhiệm vụ ngày: Học 20 từ (tăng theo số từ vừa học hợp lệ)
        if (validWordsReviewed > 0) {
          await ref
              .read(questServiceProvider)
              .updateQuestProgress(
                user.uid,
                'daily_study_20',
                validWordsReviewed,
              );
        }

        // 4. Kiểm tra và trao huy hiệu tự động
        await ref
            .read(badgeServiceProvider)
            .checkAndAwardBadges(
              uid: user.uid,
              newStreak: newStreak,
              learnedVocabCount: learnedVocabCount,
            );

        // 5. Làm mới thông tin người dùng hiện tại để đồng bộ UI
        ref.invalidate(currentUserProvider);

        // 6. Kích hoạt vòng quay may mắn (Daily Gacha) nếu đủ điều kiện (Đã tắt check giới hạn 1 lần/ngày để test)
        if (validWordsReviewed >= 5) {
          if (mounted) {
            // Delay vòng quay một chút nếu Streak popup cũng được hiện, để tránh đè chéo đột ngột
            Future.delayed(
              Duration(milliseconds: willShowStreakPopup ? 800 : 100),
              () {
                if (mounted) {
                  showGeneralDialog(
                    context: context,
                    barrierDismissible: false,
                    barrierColor: Colors.black.withOpacity(0.5),
                    transitionDuration: const Duration(milliseconds: 400),
                    pageBuilder: (context, animation, secondaryAnimation) {
                      return const LuckySpinScreen();
                    },
                    transitionBuilder:
                        (context, animation, secondaryAnimation, child) {
                          final curvedAnimation = CurvedAnimation(
                            parent: animation,
                            curve:
                                Curves.easeOutBack, // Hiệu ứng nảy nhẹ rất mượt
                          );
                          return ScaleTransition(
                            scale: curvedAnimation,
                            child: FadeTransition(
                              opacity: animation,
                              child: child,
                            ),
                          );
                        },
                  );
                }
              },
            );
          }
        }
      } catch (e) {
        debugPrint('Lỗi cập nhật tiến trình học (XP, Streak, Badges): $e');
      }
    }

    setState(() {
      _isUpdating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.stars, size: 100, color: AppColors.secondary),
              const SizedBox(height: 24),
              const Text(
                'Tuyệt vời!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Bạn đã hoàn thành phiên học.',
                style: TextStyle(fontSize: 16, color: AppColors.textLight),
              ),
              const SizedBox(height: 40),

              // Hộp thống kê
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutBack,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Opacity(
                      opacity: value.clamp(0.0, 1.0),
                      child: child,
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        'Từ đã ôn tập',
                        _wordsReviewed,
                        AppColors.primary,
                      ),
                      _buildStatItem(
                        'XP nhận được',
                        _isUpdating ? 0 : _xpEarned,
                        AppColors.success,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 60),

              CustomPrimaryButton(
                text: 'Quay về trang chủ',
                onPressed: () {
                  // Chuyển hướng về tab Home
                  context.go('/home');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int value, Color color) {
    return Column(
      children: [
        TweenAnimationBuilder<int>(
          tween: IntTween(begin: 0, end: value),
          duration: const Duration(milliseconds: 1500),
          curve: Curves.easeOutQuart,
          builder: (context, val, child) {
            final displayValue = label == 'XP Earned' ? '+$val' : '$val';
            return Text(
              _isUpdating && label == 'XP Earned' ? '...' : displayValue,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            );
          },
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textLight,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
