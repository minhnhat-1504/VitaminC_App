import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class BadgesScreen extends ConsumerWidget {
  const BadgesScreen({super.key});

  static const Color _slate900 = Color(0xFF0F172A);
  static const Color _slate500 = Color(0xFF64748B);
  static const Color _slate400 = Color(0xFF94A3B8);
  static const Color _slate300 = Color(0xFFCBD5E1);
  static const Color _slate200 = Color(0xFFE2E8F0);

  static const List<Map<String, dynamic>> badges = [
    // Nhóm 1: Chăm chỉ & Kỷ luật
    {
      'id': 'first_blood',
      'name': 'Khởi Bước',
      'description': 'Hoàn thành bài học đầu tiên trên ứng dụng.',
      'icon': 0xeb3f, // spa
      'gradient1': 0xFF34D399,
      'gradient2': 0xFF059669,
      'shadowColor': 0xFF10B981,
    },
    {
      'id': 'streak_7',
      'name': 'Bền Bỉ',
      'description': 'Giữ chuỗi học tập (Streak) liên tục 7 ngày.',
      'icon': 0xe6e8, // whatshot
      'gradient1': 0xFFFDBA74,
      'gradient2': 0xFFEA580C,
      'shadowColor': 0xFFF97316,
    },
    {
      'id': 'streak_30',
      'name': 'Miệt Mài',
      'description': 'Giữ chuỗi học tập liên tục 30 ngày.',
      'icon': 0xea3f, // military_tech
      'gradient1': 0xFF94A3B8,
      'gradient2': 0xFF475569,
      'shadowColor': 0xFF64748B,
    },
    {
      'id': 'streak_100',
      'name': 'Kỷ Luật',
      'description': 'Giữ chuỗi học tập liên tục 100 ngày.',
      'icon': 0xea77, // workspace_premium
      'gradient1': 0xFFFDE047,
      'gradient2': 0xFFEAB308,
      'shadowColor': 0xFFFACC15,
    },
    {
      'id': 'night_owl',
      'name': 'Cú Đêm',
      'description': 'Học bài trong khoảng 22:00 - 02:00.',
      'icon': 0xef67, // nightlight_round
      'gradient1': 0xFFA78BFA,
      'gradient2': 0xFF6D28D9,
      'shadowColor': 0xFF8B5CF6,
    },
    {
      'id': 'early_bird',
      'name': 'Chim Sớm',
      'description': 'Học bài trong khoảng 05:00 - 07:00.',
      'icon': 0xe6a8, // wb_sunny
      'gradient1': 0xFFFDE047,
      'gradient2': 0xFFF97316,
      'shadowColor': 0xFFF59E0B,
    },
    // Nhóm 2: Chinh phục Từ vựng
    {
      'id': 'vocab_collector',
      'name': 'Tích Lũy',
      'description': 'Tự tạo hoặc thêm 100 từ vựng vào ứng dụng.',
      'icon': 0xe3f7, // monetization_on
      'gradient1': 0xFF6EE7B7,
      'gradient2': 0xFF047857,
      'shadowColor': 0xFF10B981,
    },
    {
      'id': 'swipe_master',
      'name': 'Siêu Tốc',
      'description': 'Quẹt đánh giá 1.000 thẻ Flashcard.',
      'icon': 0xea0b, // bolt
      'gradient1': 0xFF60A5FA,
      'gradient2': 0xFF2563EB,
      'shadowColor': 0xFF3B82F6,
    },
    {
      'id': 'photographic_memory',
      'name': 'Não Bộ',
      'description': 'Đánh giá "Dễ" cho 50 thẻ liên tiếp mà không có thẻ nào "Khó".',
      'icon': 0xea41, // psychology
      'gradient1': 0xFFF472B6,
      'gradient2': 0xFFBE185D,
      'shadowColor': 0xFFEC4899,
    },
    {
      'id': 'deck_creator',
      'name': 'Kiến Tạo',
      'description': 'Tạo thành công 5 bộ thẻ (Decks) cá nhân.',
      'icon': 0xe28a, // explore
      'gradient1': 0xFF2DD4BF,
      'gradient2': 0xFF0F766E,
      'shadowColor': 0xFF14B8A6,
    },
    // Nhóm 3: Công nghệ & AI
    {
      'id': 'golden_voice',
      'name': 'Giọng Vàng',
      'description': 'Dùng micro luyện phát âm và đạt >90% cho 50 từ khác nhau.',
      'icon': 0xe3e0, // mic
      'gradient1': 0xFFFBBF24,
      'gradient2': 0xFFD97706,
      'shadowColor': 0xFFF59E0B,
    },
    {
      'id': 'chatterbox',
      'name': 'Sôi Nổi',
      'description': 'Nhắn tin với AI Chatbot hơn 100 lượt.',
      'icon': 0xe2a6, // forum
      'gradient1': 0xFF818CF8,
      'gradient2': 0xFF4338CA,
      'shadowColor': 0xFF6366F1,
    },
    {
      'id': 'scanner_eye',
      'name': 'Mắt Thần',
      'description': 'Dùng Camera quét và lưu 30 từ vựng từ ngoài đời.',
      'icon': 0xe5fa, // document_scanner
      'gradient1': 0xFFA3E635,
      'gradient2': 0xFF4D7C0F,
      'shadowColor': 0xFF65A30D,
    },
    {
      'id': 'ai_explorer',
      'name': 'Tò Mò',
      'description': 'Nhờ Chatbot giải nghĩa hoặc lấy ví dụ 50 lần.',
      'icon': 0xe0a0, // auto_awesome
      'gradient1': 0xFFC084FC,
      'gradient2': 0xFF7E22CE,
      'shadowColor': 0xFFA855F7,
    },
    // Nhóm 4: Xã hội & Đồng đội
    {
      'id': 'team_carry',
      'name': 'Trụ Cột',
      'description': 'Đóng góp >50% vào tiến độ Nhiệm vụ Tuần của nhóm.',
      'icon': 0xe2fa, // groups
      'gradient1': 0xFF38BDF8,
      'gradient2': 0xFF0284C7,
      'shadowColor': 0xFF0EA5E9,
    },
    {
      'id': 'social_butterfly',
      'name': 'Lan Tỏa',
      'description': 'Bấm Chia sẻ thành tích lên mạng xã hội 5 lần.',
      'icon': 0xe5d0, // share
      'gradient1': 0xFFFB7185,
      'gradient2': 0xFFBE123C,
      'shadowColor': 0xFFE11D48,
    },
    {
      'id': 'english_police',
      'name': 'Cảnh Sát',
      'description': 'Gửi 200 tin nhắn tiếng Anh chuẩn 100% trong phòng chat.',
      'icon': 0xe54f, // security
      'gradient1': 0xFF94A3B8,
      'gradient2': 0xFF334155,
      'shadowColor': 0xFF475569,
    },
    // Nhóm 5: Thử thách & Vận may
    {
      'id': 'bounty_hunter',
      'name': 'Thợ Săn',
      'description': 'Hoàn thành toàn bộ Nhiệm vụ ngày liên tục 1 tuần.',
      'icon': 0xf05a, // rocket_launch
      'gradient1': 0xFFF87171,
      'gradient2': 0xFFB91C1C,
      'shadowColor': 0xFFEF4444,
    },
    {
      'id': 'lucky_charm',
      'name': 'Vận Đỏ',
      'description': 'Quay trúng giải cao nhất (Jackpot) ở Vòng Quay May Mắn.',
      'icon': 0xea23, // celebration
      'gradient1': 0xFFFCD34D,
      'gradient2': 0xFFB45309,
      'shadowColor': 0xFFD97706,
    },
    {
      'id': 'champion',
      'name': 'Quán Quân',
      'description': 'Đứng Top 1 Bảng Xếp Hạng cuối tuần.',
      'icon': 0xea21, // emoji_events
      'gradient1': 0xFFFFD700,
      'gradient2': 0xFFB8860B,
      'shadowColor': 0xFFDAA520,
    },
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider).value;
    final earnedBadges = user?.earnedBadges ?? [];

    final earnedList = badges
        .where((b) => earnedBadges.contains(b['id']))
        .toList();
    final lockedList = badges
        .where((b) => !earnedBadges.contains(b['id']))
        .toList();

    final totalBadgesCount = badges.length;
    final achievedBadgesCount = earnedList.length;
    final progress = totalBadgesCount > 0
        ? achievedBadgesCount / totalBadgesCount
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tiêu đề + tiến độ
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tất cả huy hiệu',
              style: GoogleFonts.lexend(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _slate900,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '$achievedBadgesCount / $totalBadgesCount',
                style: GoogleFonts.lexend(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Thanh tiến độ
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: _slate200,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${(progress * 100).toInt()}% hoàn thành',
            style: GoogleFonts.lexend(fontSize: 11, color: _slate500),
          ),
        ),
        const SizedBox(height: 24),

        // ─── EARNED SECTION ───
        if (earnedList.isNotEmpty) ...[
          Text(
            'ĐÃ NHẬN',
            style: GoogleFonts.lexend(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: _slate500,
              letterSpacing: 0.35,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: earnedList.length,
            itemBuilder: (context, index) {
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 300 + (index * 80)),
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
                child: GestureDetector(
                  onTap: () => _showBadgeDetails(context, earnedList[index], true),
                  child: _earnedBadgeCard(earnedList[index]),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
        ],

        // ─── LOCKED SECTION ───
        if (lockedList.isNotEmpty) ...[
          Text(
            'CHƯA NHẬN',
            style: GoogleFonts.lexend(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: _slate500,
              letterSpacing: 0.35,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: lockedList.length,
            itemBuilder: (context, index) {
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 300 + (index * 80)),
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
                child: GestureDetector(
                  onTap: () => _showBadgeDetails(context, lockedList[index], false),
                  child: _lockedBadgeCard(lockedList[index]),
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  void _showBadgeDetails(BuildContext context, Map<String, dynamic> badge, bool isEarned) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            badge['name'] as String,
            style: GoogleFonts.lexend(
              fontWeight: FontWeight.bold,
              color: AppColors.textLight,
            ),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isEarned) ...[
                _earnedBadgeCard(badge),
              ] else ...[
                _lockedBadgeCard(badge),
              ],
              const SizedBox(height: 24),
              Text(
                badge['description'] as String? ?? 'Chưa có thông tin điều kiện.',
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  color: _slate500,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (!isEarned)
                Text(
                  'Hãy nỗ lực hoàn thành để mở khóa nhé!',
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Đóng',
                style: GoogleFonts.lexend(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _earnedBadgeCard(Map<String, dynamic> badge) {
    final rotations = {
      'Bền Bỉ': 0.05, 
      'Siêu Tốc': -0.05, 
      'Khởi Bước': 0.03,
      'Quán Quân': -0.04,
      'Cú Đêm': 0.05,
      'Vận Đỏ': 0.04,
    };
    final int grad1 = badge['gradient1'] as int? ?? 0xFF94A3B8;
    final int grad2 = badge['gradient2'] as int? ?? 0xFF64748B;
    final int shadow = badge['shadowColor'] as int? ?? 0xFF475569;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform.rotate(
          angle: rotations[badge['name']] ?? 0,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(grad1), Color(grad2)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Color(shadow).withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Color(shadow).withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              IconData(badge['icon'] as int, fontFamily: 'MaterialIcons'),
              size: 28,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          badge['name'] as String,
          style: GoogleFonts.lexend(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.textLight,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _lockedBadgeCard(Map<String, dynamic> badge) {
    return Opacity(
      opacity: 0.4,
      child: _earnedBadgeCard(badge),
    );
  }
}
