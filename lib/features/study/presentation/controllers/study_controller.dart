import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vitaminc/features/library/data/models/vocab_model.dart';
import 'package:vitaminc/features/library/presentation/controllers/library_controller.dart';
import 'package:vitaminc/features/study/data/srs_engine.dart';
import 'package:vitaminc/features/study/presentation/study_providers.dart';
import 'package:vitaminc/core/services/local_db_provider.dart';
import 'package:vitaminc/features/auth/presentation/providers/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

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
  int _internalIndex = 0;

  StudyController(this._ref) : super(StudyState());

  Future<void> loadDueCards({String? deckId, bool forceStudy = false}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      // 1. Tự động đồng bộ từ Firestore về Local DB trước khi lấy thẻ học
      final user = _ref.read(authStateProvider).value;
      if (user != null) {
        await _ref
            .read(localDbServiceProvider)
            .syncVocabsFromFirestore(user.uid);
      }

      // 2. Lấy thẻ từ Local DB
      final studyService = _ref.read(studyServiceProvider);
      final cards = await studyService.getDueCards(
        deckId: deckId,
        forceStudy: forceStudy,
      );
      if (mounted) {
        _internalIndex = 0;
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
      if (mounted) {
        state = state.copyWith(isLoading: false, errorMessage: e.toString());
      }
    }
  }

  Future<void> processReview(ReviewQuality quality) async {
    if (state.isFinished || _internalIndex >= state.dueCards.length) return;

    final currentCard = state.dueCards[_internalIndex];
    _internalIndex++; // Tăng đồng bộ để xử lý vuốt nhanh an toàn

    final srsEngine = _ref.read(srsEngineProvider);
    final studyService = _ref.read(studyServiceProvider);

    try {
      // 1. Tính toán thẻ mới dựa trên đánh giá Hard/Good/Easy
      final updatedCard = srsEngine.processReview(currentCard, quality);

      // 2. Lưu lên Firestore (Chạy ngầm, không await để tránh lag UI)
      studyService.updateCardAfterReview(updatedCard).catchError((e) {
        debugPrint('Error updating card: $e');
      });

      // 2b. Tăng tiến độ nhiệm vụ đồng đội (Co-op Quest) chạy ngầm
      FirebaseFirestore.instance
          .collection('quests')
          .doc('weekly_coop')
          .update({'totalFlipped': FieldValue.increment(1)})
          .catchError((e) {
         debugPrint('Error updating coop quest: $e');
      });

      // 3. Delay cập nhật state để UI thẻ lướt đi xong mới tăng progress
      Future.delayed(const Duration(milliseconds: 400), () {
        if (!mounted) return;

        final nextIndex = state.currentIndex + 1;
        final finished = nextIndex >= state.dueCards.length;

        // Cập nhật Map chất lượng đã đánh giá
        final newReviewedQualities = Map<String, ReviewQuality>.from(
          state.reviewedQualities,
        )..[currentCard.id] = quality;

        state = state.copyWith(
          currentIndex: nextIndex,
          isFinished: finished,
          reviewedQualities: newReviewedQualities,
        );

        // Nếu đã học xong thẻ cuối, báo cho Library tải lại
        if (finished) {
          _ref.read(libraryControllerProvider.notifier).loadDecks();
        }
      });
    } catch (e) {
      if (mounted) state = state.copyWith(errorMessage: e.toString());
    }
  }
}

final studyControllerProvider =
    StateNotifierProvider.autoDispose<StudyController, StudyState>((ref) {
      return StudyController(ref);
    });
