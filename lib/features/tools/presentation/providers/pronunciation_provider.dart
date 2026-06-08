import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/pronunciation_topic.dart';
import '../../domain/models/pronunciation_exercise.dart';
import '../../data/mock_pronunciation_data.dart';

final pronunciationTopicsProvider = Provider<List<PronunciationTopic>>((ref) {
  return MockPronunciationData.topics;
});

final pronunciationExercisesProvider =
    Provider.family<List<PronunciationExercise>, String>((ref, topicId) {
      return MockPronunciationData.exercises
          .where((e) => e.topicId == topicId)
          .toList();
    });

final currentPronunciationTopicProvider =
    Provider.family<PronunciationTopic?, String>((ref, topicId) {
      final topics = ref.read(pronunciationTopicsProvider);
      try {
        return topics.firstWhere((t) => t.id == topicId);
      } catch (e) {
        return null;
      }
    });
