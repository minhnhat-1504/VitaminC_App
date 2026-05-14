import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/dashboard_providers.dart';
import 'package:vitaminc/features/auth/presentation/providers/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(ref),
              const SizedBox(height: 25),
              _buildSearchBar(context),
              const SizedBox(height: 20),
              _buildStatsCards(ref),
              const SizedBox(height: 25),
              _buildDailyGoal(),
              const SizedBox(height: 25),
              _buildContinueLearning(context, ref),
              const SizedBox(height: 20),
              _buildCommonPhrases(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.value;
    
    // Theo dõi streak để hiển thị viền
    final streakAsync = ref.watch(streakCountProvider);
    final streak = streakAsync.value ?? 0;

    // Xác định màu viền dựa trên thứ hạng (Rank)
    Color ringColor = AppColors.slate200; // Mặc định là xám cho các hạng khác
    final rank = user?.rank ?? 0;
    
    if (rank == 1) {
      ringColor = AppColors.gold;
    } else if (rank == 2) {
      ringColor = AppColors.slate300; // Xám bạc
    } else if (rank == 3) {
      ringColor = AppColors.secondary; // Hổ phách
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  padding: const EdgeInsets.all(2.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: ringColor, width: 3),
                  ),
                  child: CircleAvatar(
                    radius: 22,
                    backgroundImage: NetworkImage(
                      user?.photoUrl.isNotEmpty == true 
                        ? user!.photoUrl 
                        : 'https://i.pravatar.cc/150?img=11'
                    ),
                  ),
                ),
                if (streak > 0)
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: ringColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "🔥",
                              style: TextStyle(fontSize: 8),
                            ),
                            Text(
                              "$streak",
                              style: const TextStyle(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Chào mừng trở lại",
                  style: TextStyle(color: AppColors.slate500, fontSize: 12),
                ),
                Row(
                  children: [
                    Text(
                      "${user?.displayName ?? 'Người dùng'}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "${user?.xp ?? 0} XP",
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded, size: 28),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tra cứu từ vựng...',
                hintStyle: const TextStyle(color: AppColors.slate400),
                prefixIcon: const Icon(Icons.search, color: AppColors.slate400),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () => context.push('/chatbot'),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome, // Biểu tượng tia sáng đặc trưng của AI/Gemini
              color: AppColors.white,
              size: 26,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCards(WidgetRef ref) {
    // Theo dõi giá trị số từ vựng đã học và Streak
    final vocabCountAsync = ref.watch(learnedVocabCountProvider);
    final vocabCount = vocabCountAsync.value ?? 0;

    final streakCountAsync = ref.watch(streakCountProvider);
    final streakCount = streakCountAsync.value ?? 0;

    return Row(
      children: [
        Expanded(
          child: _cardWrapper(
            child: Column(
              children: [
                CircularPercentIndicator(
                  radius: 30.0,
                  lineWidth: 6.0,
                  percent: streakCount > 0 ? 1.0 : 0.0,
                  center: const Icon(
                    Icons.local_fire_department_rounded,
                    color: AppColors.warning,
                    size: 26,
                  ),
                  progressColor: AppColors.warning,
                  backgroundColor: AppColors.warning.withOpacity(0.1),
                  circularStrokeCap: CircularStrokeCap.round,
                ),
                const SizedBox(height: 10),
                Text(
                  "$streakCount",
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "CHUỖI NGÀY",
                  style: TextStyle(
                    fontSize: 12, 
                    color: AppColors.slate500,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _cardWrapper(
            child: Column(
              children: [
                CircularPercentIndicator(
                  radius: 30.0,
                  lineWidth: 6.0,
                  percent: vocabCount > 0 ? 1.0 : 0.0, // Tạm setup mặc định, khi có goal sẽ khác
                  center: const Icon(
                    Icons.school_rounded,
                    color: AppColors.primary,
                    size: 26,
                  ),
                  progressColor: AppColors.primary,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  circularStrokeCap: CircularStrokeCap.round,
                ),
                const SizedBox(height: 8),
                Text(
                  "$vocabCount",
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "TỪ ĐÃ HỌC",
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.slate500,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDailyGoal() {
    return _cardWrapper(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Mục tiêu ngày",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.flag_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
            ],
          ),
          const Text(
            "Bạn đang làm rất tốt!",
            style: TextStyle(color: AppColors.slate500, fontSize: 13),
          ),
          const SizedBox(height: 15),
          Row(
            children: const [
              Text(
                "20",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Text(
                " / 30 XP",
                style: TextStyle(
                  color: AppColors.slate500,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Spacer(),
              Text(
                "66%",
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LinearPercentIndicator(
            lineHeight: 12.0,
            percent: 0.66,
            padding: EdgeInsets.zero,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            progressColor: AppColors.primary,
            barRadius: const Radius.circular(10),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueLearning(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              "Tiếp tục học",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              "Xem tất cả",
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        _cardWrapper(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: Image.network(
                  'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?w=500',
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "3000 từ vựng Oxford",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            "🎴 Còn 25 thẻ",
                            style: TextStyle(
                              color: AppColors.slate500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final user = ref.read(authStateProvider).value;
                        if (user != null) {
                          await ref.read(streakServiceProvider).updateStreak(user.uid);
                          // Refresh lại streak count sau khi học
                          ref.invalidate(streakCountProvider);
                          
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Tuyệt vời! Streak của bạn đã được cập nhật."),
                                backgroundColor: AppColors.success,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Học ▶",
                        style: TextStyle(color: AppColors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCommonPhrases() {
    return _cardWrapper(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.translate, color: Colors.purple),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Mẫu câu thông dụng",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  "120 từ • 15 phút",
                  style: TextStyle(color: AppColors.slate500, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.lock_outline, color: AppColors.slate400),
        ],
      ),
    );
  }

  Widget _cardWrapper({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(20),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: child,
    );
  }
}
