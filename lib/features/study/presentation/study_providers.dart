import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vitaminc/features/study/data/srs_engine.dart';
import 'package:vitaminc/features/study/data/study_service.dart';
import 'package:vitaminc/core/services/local_db_provider.dart';

final srsEngineProvider = Provider<SrsEngine>((ref) {
  return SrsEngine();
});

final studyServiceProvider = Provider<StudyService>((ref) {
  final localDb = ref.read(localDbServiceProvider);
  return StudyService(localDb: localDb);
});
