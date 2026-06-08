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
    {
      'id': 'streak_7',
      'name': 'Phong độ',
      'icon': 0xe518,
      'gradient1': 0xFF38BDF8,
      'gradient2': 0xFF2563EB,
      'shadowColor': 0xFF3B82F6,
    },
    {
      'id': 'words_100',
      'name': 'Học giả',
      'icon': 0xe3c7,
      'gradient1': 0xFF34D399,
      'gradient2': 0xFF16A34A,
      'shadowColor': 0xFF22C55E,
    },
    {
      'id': 'first_blood',
      'name': 'Tốc độ',
      'icon': 0xe0e7,
      'gradient1': 0xFFFBBF24,
      'gradient2': 0xFFEA580C,
      'shadowColor': 0xFFF97316,
    },
    {
      'id': 'streak_30',
      'name': 'Tinh anh',
      'icon': 0xe1f5,
      'gradient1': 0xFFEC4899,
      'gradient2': 0xFFBE185D,
      'shadowColor': 0xFFF43F5E,
    },
    {
      'id': 'orator',
      'name': 'Hùng biện',
      'icon': 0xf518,
      'gradient1': 0xFFA855F7,
      'gradient2': 0xFF4F46E5,
      'shadowColor': 0xFF6366F1,
    },
    {
      'id': 'master',
      'name': 'Bậc thầy',
      'icon': 0xe559,
      'gradient1': 0xFF0D9488,
      'gradient2': 0xFF0891B2,
      'shadowColor': 0xFF06B6D4,
    },
    {
      'id': 'polyglot',
      'name': 'Đa ngôn ngữ',
      'icon': 0xe8e2,
      'gradient1': 0xFF8B5CF6,
      'gradient2': 0xFF6D28D9,
      'shadowColor': 0xFF7C3AED,
    },
    {
      'id': 'night_owl',
      'name': 'Cú đêm',
      'icon': 0xef67,
      'gradient1': 0xFF1E293B,
      'gradient2': 0xFF0F172A,
      'shadowColor': 0xFF334155,
    },
    {
      'id': 'pioneer',
      'name': 'Tiên phong',
      'icon': 0xe55f,
      'gradient1': 0xFFF97316,
      'gradient2': 0xFFDC2626,
      'shadowColor': 0xFFEF4444,
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
                child: _earnedBadgeCard(earnedList[index]),
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
                child: _lockedBadgeCard(lockedList[index]),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _earnedBadgeCard(Map<String, dynamic> badge) {
    final rotations = {'Phong độ': 0.05, 'Học giả': -0.035, 'Tốc độ': 0.018};
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
      opacity: 0.5,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomPaint(
            painter: _DashedBorderPainter(color: _slate300, radius: 16),
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _slate200,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                IconData(badge['icon'] as int, fontFamily: 'MaterialIcons'),
                size: 28,
                color: _slate400,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            badge['name'] as String,
            style: GoogleFonts.lexend(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _slate500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;

  _DashedBorderPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(radius),
        ),
      );

    const dashWidth = 6.0;
    const dashSpace = 4.0;

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final end = (distance + dashWidth).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
