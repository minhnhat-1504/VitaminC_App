import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vitaminc/features/study/data/srs_engine.dart';
import 'package:vitaminc/features/study/data/study_service.dart';

final srsEngineProvider = Provider<SrsEngine>((ref) {
  return SrsEngine();
});

final studyServiceProvider = Provider<StudyService>((ref) {
  return StudyService();
});
