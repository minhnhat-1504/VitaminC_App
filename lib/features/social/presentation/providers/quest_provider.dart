import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vitaminc/core/models/quest_model.dart';
import 'package:vitaminc/features/auth/presentation/providers/auth_provider.dart';
import 'package:vitaminc/features/social/data/quest_service.dart';

final questServiceProvider = Provider<QuestService>((ref) {
  return QuestService();
});

final dailyQuestsProvider = StreamProvider.autoDispose<List<QuestModel>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) {
    return Stream.value([]);
  }

  final questService = ref.watch(questServiceProvider);
  return questService.getDailyQuests(user.uid);
});
