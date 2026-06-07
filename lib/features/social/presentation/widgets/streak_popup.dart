import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';

class StreakPopup extends ConsumerStatefulWidget {
  const StreakPopup({super.key});

  @override
  ConsumerState<StreakPopup> createState() => _StreakPopupState();
}

class _StreakPopupState extends ConsumerState<StreakPopup>
    with SingleTickerProviderStateMixin {
  static const double _heroSize = 192;
  static const double _bottomBarHeight = 160;

  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _rotation;
  late final Animation<double> _glow;

  final GlobalKey _boundaryKey = GlobalKey();
  bool _isSharing = false;

  Future<void> _shareStreak() async {
    if (_isSharing) return;
    setState(() => _isSharing = true);

    try {
      final boundary =
          _boundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) throw Exception('Cannot find repaint boundary');

      // Chờ frame vẽ hoàn tất nếu cần
      if (boundary.debugNeedsPaint) {
        await Future.delayed(const Duration(milliseconds: 50));
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ImageByteFormat.png);
      if (byteData == null)
        throw Exception('Cannot convert image to byte data');
      final bytes = byteData.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/streak_milestone.png').create();
      await file.writeAsBytes(bytes);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text:
              'Tôi vừa đạt cột mốc Streak ${ref.read(streakCountProvider).value ?? 0} ngày trên VitaminC! 🔥 Hãy học tiếng Anh cùng tôi nhé!',
        ),
      );
    } catch (e) {
      debugPrint('Error sharing streak: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi chia sẻ: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSharing = false);
      }
    }
  }

  List<_WeekDay> _getDynamicWeekDays(int currentStreak) {
    final now = DateTime.now();
    final currentDayOfWeek = now.weekday; // 1 (Mon) -> 7 (Sun)
    
    final labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final List<_WeekDay> result = [];
    
    for (int i = 1; i <= 7; i++) {
      final label = labels[i - 1];
      
      if (i > currentDayOfWeek) {
        result.add(_WeekDay(label, _DayState.future));
      } else if (i == currentDayOfWeek) {
        result.add(_WeekDay(label, _DayState.today));
      } else {
        // Những ngày trước đó trong tuần
        // Do hôm nay vừa học xong nên streak đã bao gồm hôm nay.
        final daysAgo = currentDayOfWeek - i;
        if (currentStreak > daysAgo) {
          result.add(_WeekDay(label, _DayState.completed));
        } else {
          result.add(_WeekDay(label, _DayState.future)); // Những ngày lỡ học
        }
      }
    }
    return result;
  }

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
            colors: [AppColors.backgroundLight, AppColors.backgroundLight],
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
                        AppColors.streakOrange.withOpacity(0.1),
                        AppColors.streakOrange.withOpacity(0.0),
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
                      child: RepaintBoundary(
                        key: _boundaryKey,
                        child: Container(
                          color: AppColors.backgroundLight,
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
              color: AppColors.streakOrange,
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
        child: Icon(icon, size: 16, color: AppColors.slate900),
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
                        color: AppColors.streakOrange.withOpacity(_glow.value),
                        blurRadius: 32,
                        spreadRadius: 6,
                      ),
                    ],
                  ),
                ),
                if (child != null) child,
              ],
            ),
          ),
        );
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (rect) {
              return LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.streakOrange.withOpacity(0.7),
                  AppColors.streakOrange,
                ],
              ).createShader(rect);
            },
            child: Transform.scale(
              scale: 1.12,
              child: const Icon(
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
                '${ref.watch(streakCountProvider).value ?? 0}',
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
            color: AppColors.slate900,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          'Bạn đang rất sung sức!',
          style: GoogleFonts.lexend(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: AppColors.slate500,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 9),
          decoration: BoxDecoration(
            color: AppColors.streakOrange.withOpacity(0.1),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.streakOrange.withOpacity(0.2)),
          ),
          child: Text(
            'Don\'t give up! / Đừng bỏ cuộc!',
            style: GoogleFonts.lexend(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.streakOrange,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeekCard() {
    final streak = ref.watch(streakCountProvider).value ?? 0;
    final dynamicWeekDays = _getDynamicWeekDays(streak);

    return Container(
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slate100),
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
                    color: AppColors.slate900,
                  ),
                  children: [
                    const TextSpan(text: 'This Week '),
                    TextSpan(
                      text: '/ Tuần này',
                      style: GoogleFonts.lexend(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.slate400,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.streakOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Week ${((DateTime.now().day - 1) ~/ 7) + 1}',
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.streakOrange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: dynamicWeekDays
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
          ? AppColors.streakOrange
          : AppColors.slate400,
    );

    Widget indicator;
    switch (day.state) {
      case _DayState.completed:
        indicator = Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary,
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
                border: Border.all(color: AppColors.streakOrange, width: 2),
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.streakOrange,
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.streakOrange.withOpacity(0.4),
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
          painter: _DashedCirclePainter(color: AppColors.slate200),
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
    final user = ref.watch(currentUserProvider).value;
    
    return Row(
      children: [
        Expanded(
          child: _statCard(
            title: 'Total XP',
            value: '${user?.xp ?? 0} XP',
            icon: Icons.auto_awesome_rounded,
            background: AppColors.streakOrange.withOpacity(0.05),
            border: AppColors.streakOrange.withOpacity(0.1),
            iconColor: AppColors.streakOrange,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _statCard(
            title: 'Daily XP',
            value: '${user?.dailyXp ?? 0} XP',
            icon: Icons.local_fire_department_rounded,
            background: AppColors.primary.withOpacity(0.08),
            border: AppColors.primary.withOpacity(0.18),
            iconColor: AppColors.primary,
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
              color: AppColors.slate900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.lexend(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.slate500,
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
        color: AppColors.backgroundLight.withOpacity(0.95),
        border: const Border(top: BorderSide(color: AppColors.slate200)),
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
              color: AppColors.streakOrange,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.streakOrange.withOpacity(0.3),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: TextButton(
              onPressed: _isSharing ? null : _shareStreak,
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
                  _isSharing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.share_outlined, size: 18),
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
                color: AppColors.slate500,
              ),
            ),
          ),
        ],
      ),
    );
  }
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
