import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vitaminc/features/library/data/models/vocab_model.dart';
import 'package:vitaminc/features/library/presentation/library_providers.dart';

class DeckDetailState {
  final bool isLoading;
  final List<VocabModel> vocabs;
  final String? errorMessage;

  DeckDetailState({
    this.isLoading = false,
    this.vocabs = const [],
    this.errorMessage,
  });

  DeckDetailState copyWith({
    bool? isLoading,
    List<VocabModel>? vocabs,
    String? errorMessage,
  }) {
    return DeckDetailState(
      isLoading: isLoading ?? this.isLoading,
      vocabs: vocabs ?? this.vocabs,
      errorMessage: errorMessage,
    );
  }
}

class DeckDetailController extends StateNotifier<DeckDetailState> {
  final Ref _ref;
  final String deckId;

  DeckDetailController(this._ref, this.deckId) : super(DeckDetailState()) {
    loadVocabs();
  }

  Future<void> loadVocabs() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final libraryService = _ref.read(libraryServiceProvider);
      final vocabs = await libraryService.getVocabsByDeck(deckId);
      state = state.copyWith(isLoading: false, vocabs: vocabs);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> deleteVocab(String vocabId) async {
    try {
      final libraryService = _ref.read(libraryServiceProvider);
      await libraryService.deleteVocab(vocabId);
      await loadVocabs(); // Tải lại
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> updateVocab(VocabModel updatedVocab) async {
    try {
      final libraryService = _ref.read(libraryServiceProvider);
      await libraryService.updateVocab(updatedVocab);
      await loadVocabs(); // Tải lại
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }
}

// Family provider để truyền deckId vào
final deckDetailControllerProvider = StateNotifierProvider.family.autoDispose<DeckDetailController, DeckDetailState, String>((ref, deckId) {
  return DeckDetailController(ref, deckId);
});
