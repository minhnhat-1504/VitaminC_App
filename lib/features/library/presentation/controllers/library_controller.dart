import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vitaminc/features/library/data/models/deck_model.dart';
import 'package:vitaminc/features/library/presentation/library_providers.dart';

class LibraryState {
  final bool isLoading;
  final List<DeckModel> decks;
  final Map<String, int> dueCardsCount;
  final Map<String, int> totalCardsCount;
  final String? errorMessage;

  LibraryState({
    this.isLoading = false,
    this.decks = const [],
    this.dueCardsCount = const {},
    this.totalCardsCount = const {},
    this.errorMessage,
  });

  LibraryState copyWith({
    bool? isLoading,
    List<DeckModel>? decks,
    Map<String, int>? dueCardsCount,
    Map<String, int>? totalCardsCount,
    String? errorMessage,
  }) {
    return LibraryState(
      isLoading: isLoading ?? this.isLoading,
      decks: decks ?? this.decks,
      dueCardsCount: dueCardsCount ?? this.dueCardsCount,
      totalCardsCount: totalCardsCount ?? this.totalCardsCount,
      errorMessage: errorMessage,
    );
  }
}

class LibraryController extends StateNotifier<LibraryState> {
  final Ref _ref;

  LibraryController(this._ref) : super(LibraryState()) {
    loadDecks();
  }

  Future<void> loadDecks() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final libraryService = _ref.read(libraryServiceProvider);
      final decks = await libraryService.getDecks();
      
      // Load due counts and total counts for each deck
      final Map<String, int> dueCounts = {};
      final Map<String, int> totalCounts = {};
      for (var deck in decks) {
        dueCounts[deck.id] = await libraryService.getDueCount(deck.id);
        totalCounts[deck.id] = await libraryService.getTotalCount(deck.id);
      }
      
      state = state.copyWith(isLoading: false, decks: decks, dueCardsCount: dueCounts, totalCardsCount: totalCounts);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<DeckModel?> addDeck(String title, String desc) async {
    try {
      final libraryService = _ref.read(libraryServiceProvider);
      
      // Kiểm tra trùng tên (Case-insensitive)
      final isDuplicate = state.decks.any((d) => d.title.toLowerCase().trim() == title.toLowerCase().trim());
      if (isDuplicate) {
        throw Exception('Tên bộ thẻ "$title" đã tồn tại!');
      }

      final newDeck = await libraryService.addDeck(title, description: desc);
      await loadDecks(); // Tải lại danh sách sau khi thêm
      return newDeck;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return null;
    }
  }

  Future<DeckModel?> importExcel() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final importService = _ref.read(importServiceProvider);
      final newDeck = await importService.importExcel();
      await loadDecks(); // Tải lại danh sách Deck vì file Excel tự tạo Deck mới
      return newDeck;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return null;
    }
  }

  Future<void> updateDeck(DeckModel deck) async {
    try {
      final libraryService = _ref.read(libraryServiceProvider);
      
      // Kiểm tra trùng tên (loại trừ chính nó)
      final isDuplicate = state.decks.any((d) => 
          d.id != deck.id && 
          d.title.toLowerCase().trim() == deck.title.toLowerCase().trim()
      );
      if (isDuplicate) {
        throw Exception('Tên bộ thẻ "${deck.title}" đã tồn tại!');
      }

      await libraryService.updateDeck(deck);
      await loadDecks(); // Tải lại danh sách
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }


  Future<void> deleteDeck(String deckId) async {
    try {
      final libraryService = _ref.read(libraryServiceProvider);
      await libraryService.deleteDeck(deckId);
      await loadDecks(); // Tải lại danh sách
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }
}

final libraryControllerProvider = StateNotifierProvider<LibraryController, LibraryState>((ref) {
  return LibraryController(ref);
});
