import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vitaminc/features/library/data/models/vocab_model.dart';
import 'package:vitaminc/features/library/presentation/controllers/library_controller.dart';
import 'package:vitaminc/features/study/data/srs_engine.dart';
import 'package:vitaminc/features/study/presentation/study_providers.dart';
import 'package:vitaminc/core/services/local_db_provider.dart';
import 'package:vitaminc/features/auth/presentation/providers/auth_provider.dart';

class StudyState {
  final bool isLoading;
  final List<VocabModel> dueCards;
  final int currentIndex;
  final String? errorMessage;
  final bool isFinished;
  final Map<String, ReviewQuality> reviewedQualities;
  final bool forceStudy;

  StudyState({
    this.isLoading = false,
    this.dueCards = const [],
    this.currentIndex = 0,
    this.errorMessage,
    this.isFinished = false,
    this.reviewedQualities = const {},
    this.forceStudy = false,
  });

  StudyState copyWith({
    bool? isLoading,
    List<VocabModel>? dueCards,
    int? currentIndex,
    String? errorMessage,
    bool? isFinished,
    Map<String, ReviewQuality>? reviewedQualities,
    bool? forceStudy,
  }) {
    return StudyState(
      isLoading: isLoading ?? this.isLoading,
      dueCards: dueCards ?? this.dueCards,
      currentIndex: currentIndex ?? this.currentIndex,
      errorMessage: errorMessage,
      isFinished: isFinished ?? this.isFinished,
      reviewedQualities: reviewedQualities ?? this.reviewedQualities,
      forceStudy: forceStudy ?? this.forceStudy,
    );
  }
}

class StudyController extends StateNotifier<StudyState> {
  final Ref _ref;

  StudyController(this._ref) : super(StudyState());

  Future<void> loadDueCards({String? deckId, bool forceStudy = false}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      // 1. Tự động đồng bộ từ Firestore về Local DB trước khi lấy thẻ học
      final user = _ref.read(authStateProvider).value;
      if (user != null) {
        await _ref.read(localDbServiceProvider).syncVocabsFromFirestore(user.uid);
      }

      // 2. Lấy thẻ từ Local DB
      final studyService = _ref.read(studyServiceProvider);
      final cards = await studyService.getDueCards(deckId: deckId, forceStudy: forceStudy);
      if (mounted) {
        state = state.copyWith(
          isLoading: false,
          dueCards: cards,
          currentIndex: 0,
          isFinished: cards.isEmpty,
          reviewedQualities: {},
          forceStudy: forceStudy,
        );
      }
    } catch (e) {
      if (mounted) state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> processReview(ReviewQuality quality) async {
    if (state.isFinished || state.currentIndex >= state.dueCards.length) return;

    final currentCard = state.dueCards[state.currentIndex];
    final srsEngine = _ref.read(srsEngineProvider);
    final studyService = _ref.read(studyServiceProvider);

    try {
      // 1. Tính toán thẻ mới dựa trên đánh giá Hard/Good/Easy
      final updatedCard = srsEngine.processReview(currentCard, quality);

      // 2. Lưu lên Firestore (Chờ lưu xong để Library cập nhật chuẩn xác)
      await studyService.updateCardAfterReview(updatedCard);

      if (!mounted) return;

      // 3. Chuyển sang thẻ tiếp theo
      final nextIndex = state.currentIndex + 1;
      final finished = nextIndex >= state.dueCards.length;

      // Cập nhật Map chất lượng đã đánh giá
      final newReviewedQualities = Map<String, ReviewQuality>.from(state.reviewedQualities)
        ..[currentCard.id] = quality;

      state = state.copyWith(
        currentIndex: nextIndex,
        isFinished: finished,
        reviewedQualities: newReviewedQualities,
      );

      // 4. Nếu đã học xong thẻ cuối, báo cho Library tải lại danh sách để hiện trạng thái "Đã học xong"
      if (finished) {
        _ref.read(libraryControllerProvider.notifier).loadDecks();
      }
    } catch (e) {
      if (mounted) state = state.copyWith(errorMessage: e.toString());
    }
  }
}

final studyControllerProvider = StateNotifierProvider<StudyController, StudyState>((ref) {
  return StudyController(ref);
});
