import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/shared_widgets/custom_app_bar.dart';
import '../../../../core/models/user_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../dashboard/presentation/providers/dashboard_providers.dart';
import '../providers/social_providers.dart';
import 'badges_screen.dart';
import '../widgets/streak_popup.dart';
import 'chat_room_list_screen.dart';
import 'coop_quest_screen.dart';
import '../../../../core/shared_widgets/empty_state_widget.dart';
import '../../../../core/shared_widgets/shimmer_loading.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  int _selectedTab = 0;

  // Hạng giải đấu tĩnh (Local constants)
  static const String leagueName = 'GIẢI ĐẤU RUBY';
  static const String leagueTimeLeft = '2 ngày 14 giờ';

  void _openStreakPopup() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Streak popup',
      barrierColor: Colors.black.withOpacity(0.35),
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const StreakPopup();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.85, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Đọc dữ liệu Leaderboard thời gian thực từ Firestore StreamProvider
    final leaderboardAsync = ref.watch(leaderboardProvider);
    final currentUser = ref.watch(currentUserProvider).value;
    final currentStreak = ref.watch(streakCountProvider).value ?? 0;

    return Scaffold(
      appBar: const CustomAppBar(title: 'Cộng đồng', showBackButton: false),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLeagueInfo(),
                  const SizedBox(height: 16),
                  _buildTabSwitcher(),
                ],
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: KeyedSubtree(
                  key: ValueKey(_selectedTab),
                  child: _buildTabContent(
                    leaderboardAsync: leaderboardAsync,
                    currentUser: currentUser,
                    currentStreak: currentStreak,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent({
    required AsyncValue<List<UserModel>> leaderboardAsync,
    required UserModel? currentUser,
    required int currentStreak,
  }) {
    switch (_selectedTab) {
      case 0:
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...leaderboardAsync.when(
                data: (users) {
                  if (users.isEmpty) {
                    return [
                      const SizedBox(height: 60),
                      const EmptyStateWidget(
                        title: 'Bảng xếp hạng trống',
                        message:
                            'Chưa có ai ở đây cả.\nHãy là người đầu tiên học bài để đạt Top 1 nhé!',
                        icon: Icons.emoji_events_outlined,
                      ),
                    ];
                  }
                  return _buildRankingContent(
                    users,
                    currentUser,
                    currentStreak,
                  );
                },
                loading: () => [
                  const SizedBox(height: 20),
                  const SizedBox(height: 400, child: ShimmerLoadingList()),
                ],
                error: (err, stack) => [
                  const SizedBox(height: 120),
                  Center(
                    child: Text(
                      'Lỗi khi tải bảng xếp hạng: $err',
                      style: GoogleFonts.lexend(color: AppColors.error),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      case 1:
        return const SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(children: [BadgesScreen(), SizedBox(height: 24)]),
        );
      case 2:
        return const ChatRoomListScreen();
      case 3:
        return const CoopQuestScreen();
      default:
        return const SizedBox.shrink();
    }
  }

  // ─── LEAGUE INFO ───
  Widget _buildLeagueInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          leagueName,
          style: GoogleFonts.lexend(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.slate500,
            letterSpacing: 0.6,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.slate100,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.access_time_rounded,
                size: 12,
                color: AppColors.slate600,
              ),
              const SizedBox(width: 4),
              Text(
                leagueTimeLeft,
                style: GoogleFonts.lexend(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.slate600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── TAB SWITCHER ───
  Widget _buildTabSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.slate200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _tabItem('Xếp hạng', 0),
          _tabItem('Huy hiệu', 1),
          _tabItem('Trò chuyện', 2),
          _tabItem('Đồng đội', 3),
        ],
      ),
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
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.lexend(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: isActive ? AppColors.slate900 : AppColors.slate500,
            ),
          ),
        ),
      ),
    );
  }

  // ─── RANKING TAB CONTENT ───
  List<Widget> _buildRankingContent(
    List<UserModel> users,
    UserModel? currentUser,
    int currentStreak,
  ) {
    return [
      _buildPodium(users),
      const SizedBox(height: 32),
      _buildYourPosition(users, currentUser, currentStreak),
      const SizedBox(height: 20),
      _buildRestOfLeague(users),
      const SizedBox(height: 40),
    ];
  }

  // ─── PODIUM ───
  Widget _buildPodium(List<UserModel> users) {
    final first = users.isNotEmpty ? users[0] : null;
    final second = users.length > 1 ? users[1] : null;
    final third = users.length > 2 ? users[2] : null;

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
                child: TweenAnimationBuilder<Offset>(
                  tween: Tween(begin: const Offset(0, 0.4), end: Offset.zero),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeOutBack,
                  builder: (context, offset, child) {
                    return FractionalTranslation(
                      translation: offset,
                      child: Opacity(
                        opacity: (1 - offset.dy * 2.5).clamp(0.0, 1.0),
                        child: child,
                      ),
                    );
                  },
                  child: _podiumPlayer(
                    user: second,
                    rank: 2,
                    avatarSize: 64,
                    ringColor: AppColors.slate300,
                    badgeColor: AppColors.slate300,
                    badgeTextColor: AppColors.slate800,
                    pedestalColors: [AppColors.slate100, AppColors.slate200],
                    pedestalHeight: 96,
                    avatarBgColor: const Color(0xFF8B5CF6),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TweenAnimationBuilder<Offset>(
                  tween: Tween(begin: const Offset(0, 0.5), end: Offset.zero),
                  duration: const Duration(milliseconds: 700),
                  curve: Curves.easeOutBack,
                  builder: (context, offset, child) {
                    return FractionalTranslation(
                      translation: offset,
                      child: Opacity(
                        opacity: (1 - offset.dy * 2).clamp(0.0, 1.0),
                        child: child,
                      ),
                    );
                  },
                  child: _podiumPlayer(
                    user: first,
                    rank: 1,
                    avatarSize: 80,
                    ringColor: AppColors.gold,
                    badgeColor: AppColors.gold,
                    badgeTextColor: AppColors.slate900,
                    pedestalColors: [
                      Colors.white,
                      AppColors.gold.withOpacity(0.25),
                    ],
                    pedestalHeight: 128,
                    avatarBgColor: AppColors.primary,
                    showCrown: true,
                    isFirst: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TweenAnimationBuilder<Offset>(
                  tween: Tween(begin: const Offset(0, 0.3), end: Offset.zero),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutBack,
                  builder: (context, offset, child) {
                    return FractionalTranslation(
                      translation: offset,
                      child: Opacity(
                        opacity: (1 - offset.dy * 3.3).clamp(0.0, 1.0),
                        child: child,
                      ),
                    );
                  },
                  child: _podiumPlayer(
                    user: third,
                    rank: 3,
                    avatarSize: 64,
                    ringColor: AppColors.bronze,
                    badgeColor: AppColors.bronze,
                    badgeTextColor: AppColors.slate900,
                    pedestalColors: [
                      AppColors.backgroundLight,
                      AppColors.bronze.withOpacity(0.25),
                    ],
                    pedestalHeight: 80,
                    avatarBgColor: AppColors.streakOrange,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _podiumPlayer({
    required UserModel? user,
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
    if (user == null) {
      // Giữ chỗ trống nếu chưa đủ người dùng trong database
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: avatarSize + (showCrown ? 28 : 0) + 12 + 20),
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
            ),
          ),
        ],
      );
    }

    final name = user.displayName.isNotEmpty ? user.displayName : 'Learner';

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
                backgroundImage: user.photoUrl.isNotEmpty
                    ? NetworkImage(user.photoUrl)
                    : null,
                child: user.photoUrl.isEmpty
                    ? Icon(
                        Icons.person_rounded,
                        size: avatarSize * 0.45,
                        color: avatarBgColor,
                      )
                    : null,
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
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.lexend(
            fontSize: isFirst ? 16 : 14,
            fontWeight: FontWeight.bold,
            color: isFirst ? AppColors.slate900 : AppColors.textLight,
          ),
        ),
        Text(
          '${_formatXp(user.xp)} XP',
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
                    top: BorderSide(color: AppColors.gold.withOpacity(0.4)),
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
  Widget _buildYourPosition(
    List<UserModel> users,
    UserModel? currentUser,
    int currentStreak,
  ) {
    if (currentUser == null) return const SizedBox.shrink();

    final index = users.indexWhere((u) => u.uid == currentUser.uid);
    final rankStr = index != -1
        ? '${index + 1}'
        : (currentUser.rank > 0 ? '${currentUser.rank}' : '-');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12),
          child: Text(
            'HẠNG CỦA BẠN',
            style: GoogleFonts.lexend(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.slate500,
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
                              rankStr,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.lexend(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.slate900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.slate200,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: AppColors.slate200,
                              backgroundImage: currentUser.photoUrl.isNotEmpty
                                  ? NetworkImage(currentUser.photoUrl)
                                  : null,
                              child: currentUser.photoUrl.isEmpty
                                  ? const Icon(
                                      Icons.person_rounded,
                                      size: 20,
                                      color: AppColors.slate400,
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  currentUser.displayName.isNotEmpty
                                      ? currentUser.displayName
                                      : 'You',
                                  style: GoogleFonts.lexend(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.slate900,
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      '\u{1F525} ',
                                      style: TextStyle(fontSize: 10),
                                    ),
                                    Text(
                                      '$currentStreak chuỗi ngày học',
                                      style: GoogleFonts.lexend(
                                        fontSize: 12,
                                        color: AppColors.slate500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${_formatXp(currentUser.xp)} XP',
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
  Widget _buildRestOfLeague(List<UserModel> users) {
    if (users.length <= 3) return const SizedBox.shrink();

    final restUsers = users.sublist(3);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 12, top: 8),
          child: Text(
            'PHẦN CÒN LẠI',
            style: GoogleFonts.lexend(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.slate500,
              letterSpacing: 0.35,
            ),
          ),
        ),
        ...restUsers.asMap().entries.map((entry) {
          final rank = entry.key + 4;
          final user = entry.value;
          return _leagueItem(user, rank);
        }),
      ],
    );
  }

  Widget _leagueItem(UserModel user, int rank) {
    final name = user.displayName.isNotEmpty ? user.displayName : 'Học viên';
    final initials = name.length >= 2
        ? name.substring(0, 2).toUpperCase()
        : (name.isNotEmpty ? name[0].toUpperCase() : 'L');
    final avatarBg = user.uid.hashCode % 2 == 0 ? 0xFFE0E7FF : 0xFFFCE7F3;
    final avatarFg = user.uid.hashCode % 2 == 0 ? 0xFF6366F1 : 0xFFEC4899;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.slate100),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 24,
              child: Text(
                '$rank',
                textAlign: TextAlign.center,
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.slate400,
                ),
              ),
            ),
            const SizedBox(width: 16),
            CircleAvatar(
              radius: 18,
              backgroundColor: user.photoUrl.isNotEmpty
                  ? Colors.transparent
                  : Color(avatarBg),
              backgroundImage: user.photoUrl.isNotEmpty
                  ? NetworkImage(user.photoUrl)
                  : null,
              child: user.photoUrl.isEmpty
                  ? Text(
                      initials,
                      style: GoogleFonts.lexend(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(avatarFg),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                name,
                style: GoogleFonts.lexend(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.slate900,
                ),
              ),
            ),
            Text(
              '${_formatXp(user.xp)} XP',
              style: GoogleFonts.lexend(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.slate500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── ACHIEVEMENTS PREVIEW ───
  Widget _buildAchievementsPreview(UserModel? currentUser) {
    final earnedBadges = currentUser?.earnedBadges ?? [];
    final previewBadges = BadgesScreen.badges
        .map((badge) {
          final isAchieved = earnedBadges.contains(badge['id']);
          return {...badge, 'achieved': isAchieved};
        })
        .take(6)
        .toList();

    final achievedCount = BadgesScreen.badges
        .where((b) => earnedBadges.contains(b['id']))
        .length;
    final totalCount = BadgesScreen.badges.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Thành tựu',
                style: GoogleFonts.lexend(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.slate900,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$achievedCount / $totalCount',
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
    final rotations = {'Phong độ': 0.05, 'Học giả': -0.035, 'Tốc độ': 0.018};
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
              color: AppColors.slate300,
              radius: 16,
            ),
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.slate200,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                IconData(badge['icon'] as int, fontFamily: 'MaterialIcons'),
                size: 28,
                color: AppColors.slate400,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            badge['name'] as String,
            style: GoogleFonts.lexend(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.slate500,
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
