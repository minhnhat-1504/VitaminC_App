import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/shared_widgets/custom_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../controllers/study_controller.dart';

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
    final count = studyState.dueCards.length;
    final xp = count * 10; // 10 XP per word reviewed

    setState(() {
      _wordsReviewed = count;
      _xpEarned = xp;
    });

    if (xp > 0) {
      final user = ref.read(authStateProvider).value;
      if (user != null) {
        try {
          await ref.read(userServiceProvider).addXP(user.uid, xp);
          // Invalidate user data to update the stream for real-time XP values
          ref.invalidate(currentUserProvider);
        } catch (e) {
          debugPrint('Lỗi cộng XP: $e');
        }
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
                'Amazing job!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'You have completed your study session.',
                style: TextStyle(fontSize: 16, color: AppColors.textLight),
              ),
              const SizedBox(height: 40),

              // Hộp thống kê
              Container(
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
                    _buildStatItem('Words Reviewed', '$_wordsReviewed', AppColors.primary),
                    _buildStatItem('XP Earned', _isUpdating ? '...' : '+$_xpEarned', AppColors.success),
                  ],
                ),
              ),

              const SizedBox(height: 60),

              CustomPrimaryButton(
                text: 'BACK TO HOME',
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

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: color,
          ),
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
