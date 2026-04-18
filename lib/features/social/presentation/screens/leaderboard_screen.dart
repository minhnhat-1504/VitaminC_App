import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/dummy_data.dart';
import 'badges_screen.dart';
import '../widgets/streak_popup.dart';

// ─── Bảng màu phụ trợ từ Figma (Slate palette) ───
class LeaderboardColors {
  static const Color slate900 = Color(0xFF0F172A);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color gold = Color(0xFFFACC15);
  static const Color goldDark = Color(0xFF713F12);
  static const Color goldLight = Color(0xFFFEF9C3);
  static const Color bronze = Color(0xFFFDBA74);
  static const Color bronzeDark = Color(0xFF7C2D12);
  static const Color bronzeLight = Color(0xFFFFEDD5);
}

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  int _selectedTab = 0;

  void _openStreakPopup() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Streak popup',
      barrierColor: Colors.black.withOpacity(0.35),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const StreakPopup();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.98, end: 1).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _buildTabSwitcher(),
                    const SizedBox(height: 32),
                    if (_selectedTab == 0) ..._buildRankingContent(),
                    if (_selectedTab == 1) const BadgesScreen(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── HEADER ───
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DummyData.leagueName,
                style: GoogleFonts.lexend(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: LeaderboardColors.slate500,
                  letterSpacing: 0.6,
                ),
              ),
              Text(
                'Leaderboard \u{1F3C6}',
                style: GoogleFonts.lexend(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: LeaderboardColors.slate900,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: LeaderboardColors.slate100,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.access_time_rounded,
                  size: 12,
                  color: LeaderboardColors.slate600,
                ),
                const SizedBox(width: 4),
                Text(
                  DummyData.leagueTimeLeft,
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: LeaderboardColors.slate600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── TAB SWITCHER ───
  Widget _buildTabSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: LeaderboardColors.slate200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [_tabItem('Ranking', 0), _tabItem('Badges', 1)]),
    );
  }

  Widget _tabItem(String label, int index) {
    final isActive = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.lexend(
              fontSize: 14,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: isActive
                  ? LeaderboardColors.slate900
                  : LeaderboardColors.slate500,
            ),
          ),
        ),
      ),
    );
  }

  // ─── RANKING TAB ───
  List<Widget> _buildRankingContent() {
    return [
      _buildPodium(),
      const SizedBox(height: 32),
      _buildYourPosition(),
      const SizedBox(height: 20),
      _buildRestOfLeague(),
      const SizedBox(height: 40),
      _buildAchievementsPreview(),
    ];
  }

  // ─── PODIUM ───
  Widget _buildPodium() {
    return SizedBox(
      height: 310,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Container(
              height: 192,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary.withOpacity(0.05),
                    AppColors.primary.withOpacity(0.0),
                  ],
                ),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: _podiumPlayer(
                  name: 'Sarah',
                  xp: '2,450 XP',
                  rank: 2,
                  avatarSize: 64,
                  ringColor: LeaderboardColors.slate300,
                  badgeColor: LeaderboardColors.slate300,
                  badgeTextColor: LeaderboardColors.slate800,
                  pedestalColors: [
                    LeaderboardColors.slate100,
                    LeaderboardColors.slate200,
                  ],
                  pedestalHeight: 96,
                  avatarBgColor: const Color(0xFF8B5CF6),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _podiumPlayer(
                  name: 'Marcus',
                  xp: '3,100 XP',
                  rank: 1,
                  avatarSize: 80,
                  ringColor: LeaderboardColors.gold,
                  badgeColor: LeaderboardColors.gold,
                  badgeTextColor: LeaderboardColors.goldDark,
                  pedestalColors: [Colors.white, LeaderboardColors.goldLight],
                  pedestalHeight: 128,
                  avatarBgColor: AppColors.primary,
                  showCrown: true,
                  isFirst: true,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _podiumPlayer(
                  name: 'Elena',
                  xp: '2,120 XP',
                  rank: 3,
                  avatarSize: 64,
                  ringColor: LeaderboardColors.bronze,
                  badgeColor: LeaderboardColors.bronze,
                  badgeTextColor: LeaderboardColors.bronzeDark,
                  pedestalColors: [
                    AppColors.backgroundLight,
                    LeaderboardColors.bronzeLight,
                  ],
                  pedestalHeight: 80,
                  avatarBgColor: const Color(0xFFF97316),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _podiumPlayer({
    required String name,
    required String xp,
    required int rank,
    required double avatarSize,
    required Color ringColor,
    required Color badgeColor,
    required Color badgeTextColor,
    required List<Color> pedestalColors,
    required double pedestalHeight,
    required Color avatarBgColor,
    bool showCrown = false,
    bool isFirst = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showCrown)
          const Padding(
            padding: EdgeInsets.only(bottom: 4),
            child: Text('\u{1F451}', style: TextStyle(fontSize: 24)),
          ),
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: ringColor, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: avatarSize / 2,
                backgroundColor: avatarBgColor.withOpacity(0.15),
                child: Icon(
                  Icons.person_rounded,
                  size: avatarSize * 0.45,
                  color: avatarBgColor,
                ),
              ),
            ),
            Positioned(
              bottom: -8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Text(
                  '$rank',
                  style: GoogleFonts.lexend(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: badgeTextColor,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          name,
          style: GoogleFonts.lexend(
            fontSize: isFirst ? 16 : 14,
            fontWeight: FontWeight.bold,
            color: isFirst ? LeaderboardColors.slate900 : AppColors.textLight,
          ),
        ),
        Text(
          xp,
          style: GoogleFonts.lexend(
            fontSize: 12,
            fontWeight: isFirst ? FontWeight.bold : FontWeight.w500,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: pedestalHeight,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: pedestalColors,
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            border: isFirst
                ? Border(
                    top: BorderSide(
                      color: const Color(0xFFFEF08A).withOpacity(0.5),
                    ),
                  )
                : null,
            boxShadow: isFirst
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
        ),
      ],
    );
  }

  // ─── YOUR POSITION ───
  Widget _buildYourPosition() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            'YOUR POSITION',
            style: GoogleFonts.lexend(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: LeaderboardColors.slate500,
              letterSpacing: 0.35,
            ),
          ),
        ),
        GestureDetector(
          onTap: _openStreakPopup,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    left: BorderSide(color: AppColors.primary, width: 4),
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        color: AppColors.primary.withOpacity(0.05),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 24,
                            child: Text(
                              '${DummyData.currentUserRank}',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lexend(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: LeaderboardColors.slate900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: LeaderboardColors.slate200,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const CircleAvatar(
                              radius: 18,
                              backgroundColor: Color(0xFFE2E8F0),
                              child: Icon(
                                Icons.person_rounded,
                                size: 20,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'You',
                                  style: GoogleFonts.lexend(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: LeaderboardColors.slate900,
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      '\u{1F525} ',
                                      style: TextStyle(fontSize: 10),
                                    ),
                                    Text(
                                      '${DummyData.currentUserStreak} day streak',
                                      style: GoogleFonts.lexend(
                                        fontSize: 12,
                                        color: LeaderboardColors.slate500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${_formatXp(DummyData.currentUserXp)} XP',
                            style: GoogleFonts.lexend(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── REST OF THE LEAGUE ───
  Widget _buildRestOfLeague() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12, top: 8),
          child: Text(
            'REST OF THE LEAGUE',
            style: GoogleFonts.lexend(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: LeaderboardColors.slate500,
              letterSpacing: 0.35,
            ),
          ),
        ),
        ...DummyData.restOfLeague.map((user) => _leagueItem(user)),
      ],
    );
  }

  Widget _leagueItem(Map<String, dynamic> user) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: LeaderboardColors.slate100),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              child: Text(
                '${user['rank']}',
                textAlign: TextAlign.center,
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: LeaderboardColors.slate400,
                ),
              ),
            ),
            const SizedBox(width: 16),
            CircleAvatar(
              radius: 18,
              backgroundColor: Color(user['avatarBg'] as int),
              child: Text(
                user['initials'] as String,
                style: GoogleFonts.lexend(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(user['avatarFg'] as int),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                user['name'] as String,
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: LeaderboardColors.slate900,
                ),
              ),
            ),
            Text(
              '${_formatXp(user['xp'] as int)} XP',
              style: GoogleFonts.lexend(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: LeaderboardColors.slate500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── ACHIEVEMENTS PREVIEW ───
  Widget _buildAchievementsPreview() {
    final previewBadges = DummyData.badges.take(6).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Achievements',
                style: GoogleFonts.lexend(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: LeaderboardColors.slate900,
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
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemCount: previewBadges.length,
          itemBuilder: (context, index) {
            final badge = previewBadges[index];
            final achieved = badge['achieved'] as bool;
            return achieved ? _achievedBadge(badge) : _lockedBadge(badge);
          },
        ),
      ],
    );
  }

  Widget _achievedBadge(Map<String, dynamic> badge) {
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

  Widget _lockedBadge(Map<String, dynamic> badge) {
    return Opacity(
      opacity: 0.5,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomPaint(
            painter: _DashedBorderPainter(
              color: LeaderboardColors.slate300,
              radius: 16,
            ),
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: LeaderboardColors.slate200,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                IconData(badge['icon'] as int, fontFamily: 'MaterialIcons'),
                size: 28,
                color: LeaderboardColors.slate400,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            badge['name'] as String,
            style: GoogleFonts.lexend(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: LeaderboardColors.slate500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatXp(int xp) {
    if (xp >= 1000) {
      final s = xp.toString();
      return '${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}';
    }
    return xp.toString();
  }
}

// ─── Custom Painter: vien dut net cho badge chua dat ───
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
