import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/dummy_data.dart';

class BadgesScreen extends StatelessWidget {
  const BadgesScreen({super.key});

  static const Color _slate900 = Color(0xFF0F172A);
  static const Color _slate500 = Color(0xFF64748B);
  static const Color _slate400 = Color(0xFF94A3B8);
  static const Color _slate300 = Color(0xFFCBD5E1);
  static const Color _slate200 = Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tiêu đề + tiến độ
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'All Achievements',
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
                '${DummyData.achievedBadges} / ${DummyData.totalBadges}',
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
            value: DummyData.achievedBadges / DummyData.totalBadges,
            minHeight: 8,
            backgroundColor: _slate200,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${((DummyData.achievedBadges / DummyData.totalBadges) * 100).toInt()}% completed',
            style: GoogleFonts.lexend(fontSize: 11, color: _slate500),
          ),
        ),
        const SizedBox(height: 24),

        // ─── EARNED SECTION ───
        Text(
          'EARNED',
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
          itemCount: DummyData.badges
              .where((b) => b['achieved'] == true)
              .length,
          itemBuilder: (context, index) {
            final badge = DummyData.badges
                .where((b) => b['achieved'] == true)
                .toList()[index];
            return _earnedBadgeCard(badge);
          },
        ),

        const SizedBox(height: 32),

        // ─── LOCKED SECTION ───
        Text(
          'LOCKED',
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
          itemCount: DummyData.badges
              .where((b) => b['achieved'] == false)
              .length,
          itemBuilder: (context, index) {
            final badge = DummyData.badges
                .where((b) => b['achieved'] == false)
                .toList()[index];
            return _lockedBadgeCard(badge);
          },
        ),
      ],
    );
  }

  Widget _earnedBadgeCard(Map<String, dynamic> badge) {
    final rotations = {'On Fire': 0.05, 'Scholar': -0.035, 'Speedster': 0.018};
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
                colors: [
                  Color(badge['gradient1'] as int),
                  Color(badge['gradient2'] as int),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Color(badge['shadowColor'] as int).withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Color(badge['shadowColor'] as int).withOpacity(0.2),
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
