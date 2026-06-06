import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_colors.dart';

class CoopQuestScreen extends ConsumerWidget {
  const CoopQuestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('quests')
            .doc('weekly_coop')
            .snapshots(),
        builder: (context, snapshot) {
          int totalFlipped = 0;
          int target = 500;

          if (snapshot.hasData && snapshot.data!.exists) {
            final data = snapshot.data!.data() as Map<String, dynamic>?;
            if (data != null) {
              totalFlipped = data['totalFlipped'] ?? 0;
              target = data['target'] ?? 500;
            }
          }

          final percentage = target > 0
              ? (totalFlipped / target).clamp(0.0, 1.0)
              : 0.0;
          final isCompleted = totalFlipped >= target;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thẻ thông tin nhiệm vụ chính
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    border: Border.all(color: AppColors.slate100),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Icon nhiệm vụ
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.diversity_3_rounded,
                          color: AppColors.primary,
                          size: 48,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Tiêu đề
                      Text(
                        'WEEKLY CO-OP QUEST',
                        style: GoogleFonts.lexend(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Nhiệm Vụ Đồng Đội Tuần',
                        style: GoogleFonts.lexend(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.slate900,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Mô tả
                      Text(
                        'Tất cả học viên trong hệ thống cùng lật thẻ từ vựng để đạt mục tiêu chung!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.lexend(
                          fontSize: 14,
                          color: AppColors.slate500,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Chỉ số
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tiến trình hệ thống',
                            style: GoogleFonts.lexend(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.slate700,
                            ),
                          ),
                          Text(
                            '$totalFlipped / $target thẻ',
                            style: GoogleFonts.lexend(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Thanh tiến độ Custom
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: 16,
                          width: double.infinity,
                          color: AppColors.slate100,
                          child: Stack(
                            children: [
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  return AnimatedContainer(
                                    duration: const Duration(milliseconds: 500),
                                    width: constraints.maxWidth * percentage,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          AppColors.primary,
                                          Color(0xFF38BDF8),
                                        ],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Phần trăm hiển thị
                      Text(
                        '${(percentage * 100).toStringAsFixed(1)}% hoàn thành',
                        style: GoogleFonts.lexend(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.slate600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Trạng thái / Phần thưởng
                Text(
                  'Quest Reward / Phần thưởng',
                  style: GoogleFonts.lexend(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.slate900,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppColors.success.withValues(alpha: 0.08)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isCompleted
                          ? AppColors.success.withValues(alpha: 0.3)
                          : AppColors.slate200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? AppColors.success.withValues(alpha: 0.12)
                              : AppColors.slate100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.emoji_events_rounded,
                          color: isCompleted
                              ? AppColors.success
                              : AppColors.slate400,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isCompleted
                                  ? 'Nhiệm vụ đã hoàn thành!'
                                  : 'Đang thực hiện',
                              style: GoogleFonts.lexend(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isCompleted
                                    ? AppColors.success
                                    : AppColors.slate800,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '+100 XP cho toàn bộ học viên khi kết thúc tuần.',
                              style: GoogleFonts.lexend(
                                fontSize: 12,
                                color: AppColors.slate500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Luật chơi
                Text(
                  'How it works / Hướng dẫn đồng đội',
                  style: GoogleFonts.lexend(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.slate900,
                  ),
                ),
                const SizedBox(height: 12),
                _buildInstructionRow(
                  icon: Icons.flash_on_rounded,
                  text:
                      'Học thẻ từ vựng hàng ngày giúp cộng dồn điểm lật thẻ của bạn vào hệ thống chung.',
                ),
                const SizedBox(height: 10),
                _buildInstructionRow(
                  icon: Icons.people_outline_rounded,
                  text:
                      'Mỗi lượt đánh giá (Hard, Good, Easy) được tính là một lượt lật thẻ hợp lệ.',
                ),
                const SizedBox(height: 10),
                _buildInstructionRow(
                  icon: Icons.calendar_today_rounded,
                  text: 'Tiến độ được đặt lại vào thứ 2 hàng tuần lúc 00:00.',
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInstructionRow({required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.slate500, size: 16),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.lexend(
              fontSize: 13,
              color: AppColors.slate600,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
