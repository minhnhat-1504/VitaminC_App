import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/dashboard_providers.dart';
import 'package:vitaminc/features/auth/presentation/providers/auth_provider.dart';
import 'package:vitaminc/features/social/presentation/providers/quest_provider.dart';
import 'package:vitaminc/core/services/local_db_provider.dart';

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
              _buildTopBar(context, ref),
              const SizedBox(height: 25),
              _buildSearchBar(context),
              const SizedBox(height: 20),
              _buildStatsCards(ref),
              const SizedBox(height: 25),
              _buildDailyGoal(ref),
              const SizedBox(height: 25),
              _buildDailyQuests(ref),
              const SizedBox(height: 25),
              _buildTools(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, WidgetRef ref) {
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
        Expanded(
          child: Row(
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
                            : 'https://i.pravatar.cc/150?img=11',
                      ),
                    ),
                  ),
                  streakAsync.when(
                    data: (streak) => streak > 0
                        ? Positioned(
                            right: -2,
                            bottom: -2,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: AppColors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 2,
                                ),
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
                          )
                        : const SizedBox.shrink(),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Chào mừng trở lại",
                      style: TextStyle(color: AppColors.slate500, fontSize: 12),
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            user?.displayName ?? 'Người dùng',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
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
              ),
            ],
          ),
        ),
        Row(
          children: [
            // [DEV ONLY] Nút ép thẻ đến hạn để test vòng quay
            IconButton(
              icon: const Icon(Icons.bug_report, color: Colors.red),
              tooltip: 'Mock: Ép tất cả thẻ đến hạn',
              onPressed: () async {
                await ref.read(localDbServiceProvider).mockAllCardsDue();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Đã ép tất cả thẻ đến hạn ôn tập!'),
                    ),
                  );
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.notifications_none_rounded, size: 28),
              onPressed: () {},
            ),
          ],
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
    final streakCountAsync = ref.watch(streakCountProvider);

    return Row(
      children: [
        Expanded(
          child: _cardWrapper(
            child: streakCountAsync.when(
              data: (streakCount) => Column(
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
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
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
              loading: () => const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => Center(
                child: Text("Lỗi: $err", style: const TextStyle(fontSize: 10)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _cardWrapper(
            child: vocabCountAsync.when(
              data: (vocabCount) => Column(
                children: [
                  CircularPercentIndicator(
                    radius: 30.0,
                    lineWidth: 6.0,
                    percent: vocabCount > 0 ? 1.0 : 0.0,
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
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
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
              loading: () => const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => Center(
                child: Text("Lỗi: $err", style: const TextStyle(fontSize: 10)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDailyGoal(WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final user = userAsync.value;

    final int dailyXp = user?.dailyXp ?? 0;
    final int dailyGoal = user?.dailyGoal ?? 50;
    final double percent = dailyGoal > 0
        ? (dailyXp / dailyGoal).clamp(0.0, 1.0)
        : 0.0;
    final int percentInt = (percent * 100).toInt();

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
            children: [
              Text(
                "$dailyXp",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                " / $dailyGoal XP",
                style: const TextStyle(
                  color: AppColors.slate500,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                "$percentInt%",
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LinearPercentIndicator(
            lineHeight: 12.0,
            percent: percent,
            padding: EdgeInsets.zero,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            progressColor: AppColors.primary,
            barRadius: const Radius.circular(10),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyQuests(WidgetRef ref) {
    final questsAsync = ref.watch(dailyQuestsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Nhiệm vụ cá nhân",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        questsAsync.when(
          data: (quests) {
            if (quests.isEmpty) {
              return _cardWrapper(
                child: const Center(
                  child: Text(
                    "Hôm nay chưa có nhiệm vụ nào.",
                    style: TextStyle(color: AppColors.slate500),
                  ),
                ),
              );
            }
            return Column(
              children: quests.map((quest) {
                final progress = quest.target > 0
                    ? (quest.current / quest.target).clamp(0.0, 1.0)
                    : 0.0;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _cardWrapper(
                    padding: const EdgeInsets.all(15),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                quest.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              LinearPercentIndicator(
                                lineHeight: 8.0,
                                percent: progress,
                                padding: EdgeInsets.zero,
                                backgroundColor: AppColors.primary.withOpacity(
                                  0.1,
                                ),
                                progressColor: AppColors.primary,
                                barRadius: const Radius.circular(4),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "${quest.current}/${quest.target} • Thưởng: ${quest.rewardXp} XP",
                                style: const TextStyle(
                                  color: AppColors.slate500,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 15),
                        if (quest.isClaimed)
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.success,
                            size: 30,
                          )
                        else if (quest.isCompleted)
                          ElevatedButton(
                            onPressed: () async {
                              final user = ref.read(authStateProvider).value;
                              if (user != null) {
                                try {
                                  await ref
                                      .read(questServiceProvider)
                                      .claimQuestReward(user.uid, quest.id);
                                  await ref
                                      .read(userServiceProvider)
                                      .addXP(user.uid, quest.rewardXp);
                                  ref.invalidate(currentUserProvider);
                                } catch (e) {
                                  debugPrint("Lỗi nhận thưởng: \$e");
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.gold,
                              minimumSize: const Size(60, 36),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              "Nhận",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        else
                          const Icon(
                            Icons.lock_outline,
                            color: AppColors.slate300,
                            size: 28,
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) =>
              const Center(child: Text("Lỗi tải nhiệm vụ: \$err")),
        ),
      ],
    );
  }

  Widget _buildTools(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Công cụ học tập",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: _toolCard(
                context,
                title: "Quét từ vựng",
                subtitle: "OCR AI",
                icon: Icons.document_scanner_rounded,
                color: AppColors.primary,
                route: '/ocr-scanner',
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _toolCard(
                context,
                title: "Luyện phát âm",
                subtitle: "AI chấm điểm",
                icon: Icons.mic_rounded,
                color: AppColors.secondary,
                route: '/pronunciation',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _toolCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String route,
  }) {
    return GestureDetector(
      onTap: () => context.push(route),
      child: _cardWrapper(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(color: AppColors.slate500, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
