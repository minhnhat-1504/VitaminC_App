import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/dummy_data.dart';

class StreakPopup extends StatefulWidget {
  const StreakPopup({super.key});

  @override
  State<StreakPopup> createState() => _StreakPopupState();
}

class _StreakPopupState extends State<StreakPopup>
    with SingleTickerProviderStateMixin {
  static const double _heroSize = 192;
  static const double _bottomBarHeight = 160;

  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _rotation;
  late final Animation<double> _glow;

  static const List<_WeekDay> _weekDays = [
    _WeekDay('M', _DayState.completed),
    _WeekDay('T', _DayState.completed),
    _WeekDay('W', _DayState.completed),
    _WeekDay('T', _DayState.today),
    _WeekDay('F', _DayState.future),
    _WeekDay('S', _DayState.future),
    _WeekDay('S', _DayState.future),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _scale = Tween<double>(
      begin: 0.98,
      end: 1.04,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _rotation = Tween<double>(
      begin: -0.02,
      end: 0.02,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _glow = Tween<double>(
      begin: 0.25,
      end: 0.55,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_StreakColors.background, _StreakColors.background],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: Container(
                  height: 260,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        _StreakColors.orange.withOpacity(0.1),
                        _StreakColors.orange.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
              Column(
                children: [
                  _buildHeader(context),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        24,
                        8,
                        24,
                        _bottomBarHeight + 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 8),
                          _buildHero(),
                          const SizedBox(height: 24),
                          _buildMotivation(),
                          const SizedBox(height: 24),
                          _buildWeekCard(),
                          const SizedBox(height: 16),
                          _buildStatsCards(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildBottomBar(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _headerButton(
            icon: Icons.close_rounded,
            onTap: () => Navigator.of(context).pop(),
          ),
          Text(
            'STREAK / CHUỖI NGÀY',
            style: GoogleFonts.lexend(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: _StreakColors.orange,
              letterSpacing: 0.7,
            ),
          ),
          _headerButton(icon: Icons.more_horiz_rounded, onTap: () {}),
        ],
      ),
    );
  }

  Widget _headerButton({required IconData icon, required VoidCallback onTap}) {
    return InkResponse(
      onTap: onTap,
      radius: 20,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.6),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Icon(icon, size: 16, color: _StreakColors.title),
      ),
    );
  }

  Widget _buildHero() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scale.value,
          child: Transform.rotate(
            angle: _rotation.value,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: _heroSize,
                  height: _heroSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _StreakColors.orange.withOpacity(_glow.value),
                        blurRadius: 32,
                        spreadRadius: 6,
                      ),
                    ],
                  ),
                ),
                ShaderMask(
                  blendMode: BlendMode.srcIn,
                  shaderCallback: (rect) {
                    return const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [_StreakColors.orangeLight, _StreakColors.orange],
                    ).createShader(rect);
                  },
                  child: Transform.scale(
                    scale: 1.12,
                    child: Icon(
                      Icons.local_fire_department_rounded,
                      size: _heroSize,
                      color: Colors.white,
                    ),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${DummyData.currentUserStreak}',
                      style: GoogleFonts.lexend(
                        fontSize: 60,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'DAYS / NGÀY',
                      style: GoogleFonts.lexend(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withOpacity(0.9),
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMotivation() {
    return Column(
      children: [
        Text(
          'You are on fire!',
          style: GoogleFonts.lexend(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: _StreakColors.title,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          'Bạn đang rất sung sức!',
          style: GoogleFonts.lexend(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: _StreakColors.subtitle,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 9),
          decoration: BoxDecoration(
            color: _StreakColors.orange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: _StreakColors.orange.withOpacity(0.2)),
          ),
          child: Text(
            'Don\'t give up! / Đừng bỏ cuộc!',
            style: GoogleFonts.lexend(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: _StreakColors.orange,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeekCard() {
    return Container(
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _StreakColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  style: GoogleFonts.lexend(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _StreakColors.title,
                  ),
                  children: [
                    const TextSpan(text: 'This Week '),
                    TextSpan(
                      text: '/ Tuần này',
                      style: GoogleFonts.lexend(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: _StreakColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _StreakColors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Week 24',
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _StreakColors.orange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _weekDays
                .map((day) => _buildDayItem(day))
                .toList(growable: false),
          ),
        ],
      ),
    );
  }

  Widget _buildDayItem(_WeekDay day) {
    final labelStyle = GoogleFonts.lexend(
      fontSize: 12,
      fontWeight: day.state == _DayState.today
          ? FontWeight.bold
          : FontWeight.w500,
      color: day.state == _DayState.today
          ? _StreakColors.orange
          : _StreakColors.muted,
    );

    Widget indicator;
    switch (day.state) {
      case _DayState.completed:
        indicator = Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: _StreakColors.blue,
            borderRadius: BorderRadius.circular(999),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: const Icon(Icons.check, size: 16, color: Colors.white),
        );
      case _DayState.today:
        indicator = Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: _StreakColors.orange, width: 2),
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _StreakColors.orange,
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: _StreakColors.orange.withOpacity(0.4),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Icon(
                Icons.local_fire_department_rounded,
                size: 16,
                color: Colors.white,
              ),
            ),
          ],
        );
      case _DayState.future:
        indicator = CustomPaint(
          painter: _DashedCirclePainter(color: _StreakColors.borderStrong),
          child: const SizedBox(width: 32, height: 32),
        );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(day.label, style: labelStyle),
        const SizedBox(height: 8),
        indicator,
      ],
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            title: 'Total XP',
            value: '1,240 XP',
            icon: Icons.auto_awesome_rounded,
            background: _StreakColors.orange.withOpacity(0.05),
            border: _StreakColors.orange.withOpacity(0.1),
            iconColor: _StreakColors.orange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _statCard(
            title: 'Time',
            value: '25m today',
            icon: Icons.schedule_rounded,
            background: _StreakColors.blueSoft,
            border: _StreakColors.blueBorder,
            iconColor: _StreakColors.blue,
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color background,
    required Color border,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.lexend(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _StreakColors.title,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.lexend(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: _StreakColors.subtitle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      decoration: BoxDecoration(
        color: _StreakColors.background.withOpacity(0.95),
        border: const Border(
          top: BorderSide(color: _StreakColors.borderStrong),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: _StreakColors.orange,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: _StreakColors.orange.withOpacity(0.3),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.share_outlined, size: 18),
                  const SizedBox(width: 8),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Share your progress',
                        style: GoogleFonts.lexend(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Chia sẻ thành tích',
                        style: GoogleFonts.lexend(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Continue / Tiếp tục',
              style: GoogleFonts.lexend(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _StreakColors.subtitle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakColors {
  static const Color background = Color(0xFFF8F7F5);
  static const Color orange = Color(0xFFF27F0D);
  static const Color orangeLight = Color(0xFFF9A33B);
  static const Color title = Color(0xFF111827);
  static const Color subtitle = Color(0xFF6B7280);
  static const Color muted = Color(0xFF9CA3AF);
  static const Color borderLight = Color(0xFFF3F4F6);
  static const Color borderStrong = Color(0xFFE5E7EB);
  static const Color blue = Color(0xFF0EA5E9);
  static const Color blueSoft = Color(0xFFEFF6FF);
  static const Color blueBorder = Color(0xFFDBEAFE);
}

enum _DayState { completed, today, future }

class _WeekDay {
  final String label;
  final _DayState state;

  const _WeekDay(this.label, this.state);
}

class _DashedCirclePainter extends CustomPainter {
  final Color color;

  _DashedCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path()..addOval(Rect.fromLTWH(0, 0, size.width, size.height));

    const dashWidth = 4.0;
    const dashSpace = 3.0;

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
