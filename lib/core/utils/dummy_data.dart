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
}
