import '../constants/app_colors.dart';

class DummyData {
  static final List<Map<String, dynamic>> decks = [
    {'title': 'IELTS Vocabulary', 'count': 120, 'color': AppColors.primary},
    {'title': 'Giao tiếp cơ bản', 'count': 50, 'color': AppColors.success},
    {'title': 'IT Tiếng Anh', 'count': 85, 'color': AppColors.warning},
  ];

  static const List<Map<String, dynamic>> vocabularies = [
    {
      'id': '1',
      'word': 'Resilience',
      'meaning': 'Sự kiên cường, khả năng phục hồi',
      'type': 'noun',
      'example': 'Her resilience helped her overcome the crisis.',
      'level': 'Hard',
    },
    {
      'id': '2',
      'word': 'Wanderlust',
      'meaning': 'Niềm đam mê xê dịch',
      'type': 'noun',
      'example': 'His wanderlust led him to explore 50 countries.',
      'level': 'Easy',
    },
  ];

  // Dữ liệu bảng xếp hạng
  static const String leagueName = 'RUBY LEAGUE';
  static const String leagueTimeLeft = '2d 14h';
  static const int currentUserRank = 4;
  static const int currentUserXp = 1950;
  static const int currentUserStreak = 12;

  static const List<Map<String, dynamic>> topPlayers = [
    {'rank': 1, 'name': 'Marcus', 'xp': 3100},
    {'rank': 2, 'name': 'Sarah', 'xp': 2450},
    {'rank': 3, 'name': 'Elena', 'xp': 2120},
  ];

  static const List<Map<String, dynamic>> restOfLeague = [
    {
      'rank': 5,
      'name': 'John L.',
      'xp': 1820,
      'initials': 'JL',
      'avatarBg': 0xFFE0E7FF,
      'avatarFg': 0xFF6366F1,
    },
    {
      'rank': 6,
      'name': 'Maria G.',
      'xp': 1750,
      'initials': 'MG',
      'avatarBg': 0xFFFCE7F3,
      'avatarFg': 0xFFEC4899,
    },
    {
      'rank': 7,
      'name': 'Tom K.',
      'xp': 1600,
      'initials': 'TK',
      'avatarBg': 0xFFD1FAE5,
      'avatarFg': 0xFF10B981,
    },
  ];

  // Dữ liệu huy hiệu (Badges)
  static const int totalBadges = 50;
  static const int achievedBadges = 12;

  static const List<Map<String, dynamic>> badges = [
    {
      'name': 'On Fire',
      'icon': 0xe518,
      'achieved': true,
      'gradient1': 0xFF38BDF8,
      'gradient2': 0xFF2563EB,
      'shadowColor': 0xFF3B82F6,
    },
    {
      'name': 'Scholar',
      'icon': 0xe3c7,
      'achieved': true,
      'gradient1': 0xFF34D399,
      'gradient2': 0xFF16A34A,
      'shadowColor': 0xFF22C55E,
    },
    {
      'name': 'Speedster',
      'icon': 0xe0e7,
      'achieved': true,
      'gradient1': 0xFFFBBF24,
      'gradient2': 0xFFEA580C,
      'shadowColor': 0xFFF97316,
    },
    {'name': 'Elite', 'icon': 0xe1f5, 'achieved': false},
    {'name': 'Orator', 'icon': 0xf518, 'achieved': false},
    {'name': 'Master', 'icon': 0xe559, 'achieved': false},
    {'name': 'Polyglot', 'icon': 0xe8e2, 'achieved': false},
    {'name': 'Night Owl', 'icon': 0xef67, 'achieved': false},
    {'name': 'Pioneer', 'icon': 0xe55f, 'achieved': false},
  ];
}
