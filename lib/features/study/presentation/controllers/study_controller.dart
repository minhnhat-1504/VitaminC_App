import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vitaminc/features/library/data/models/vocab_model.dart';
import 'package:vitaminc/features/library/presentation/controllers/library_controller.dart';
import 'package:vitaminc/features/study/data/srs_engine.dart';
import 'package:vitaminc/features/study/presentation/study_providers.dart';

class StudyState {
  final bool isLoading;
  final List<VocabModel> dueCards;
  final int currentIndex;
  final String? errorMessage;
  final bool isFinished;

  StudyState({
    this.isLoading = false,
    this.dueCards = const [],
    this.currentIndex = 0,
    this.errorMessage,
    this.isFinished = false,
  });

  StudyState copyWith({
    bool? isLoading,
    List<VocabModel>? dueCards,
    int? currentIndex,
    String? errorMessage,
    bool? isFinished,
  }) {
    return StudyState(
      isLoading: isLoading ?? this.isLoading,
      dueCards: dueCards ?? this.dueCards,
      currentIndex: currentIndex ?? this.currentIndex,
      errorMessage: errorMessage,
      isFinished: isFinished ?? this.isFinished,
    );
  }
}

class StudyController extends StateNotifier<StudyState> {
  final Ref _ref;

  StudyController(this._ref) : super(StudyState());

  Future<void> loadDueCards({String? deckId, bool forceStudy = false}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final studyService = _ref.read(studyServiceProvider);
      final cards = await studyService.getDueCards(deckId: deckId, forceStudy: forceStudy);
      state = state.copyWith(
        isLoading: false,
        dueCards: cards,
        currentIndex: 0,
        isFinished: cards.isEmpty,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
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

      // 3. Chuyển sang thẻ tiếp theo
      final nextIndex = state.currentIndex + 1;
      final finished = nextIndex >= state.dueCards.length;

      state = state.copyWith(
        currentIndex: nextIndex,
        isFinished: finished,
      );

      // 4. Nếu đã học xong thẻ cuối, báo cho Library tải lại danh sách để hiện trạng thái "Đã học xong"
      if (finished) {
        _ref.read(libraryControllerProvider.notifier).loadDecks();
      }
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }
}

final studyControllerProvider = StateNotifierProvider<StudyController, StudyState>((ref) {
  return StudyController(ref);
});
