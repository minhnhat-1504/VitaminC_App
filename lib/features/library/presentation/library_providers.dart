import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vitaminc/features/library/data/import_service.dart';
import 'package:vitaminc/features/library/data/library_service.dart';
import 'package:vitaminc/features/library/data/global_deck_service.dart';
import 'package:vitaminc/features/library/data/models/deck_model.dart';

final libraryServiceProvider = Provider<LibraryService>((ref) {
  return LibraryService();
});

final importServiceProvider = Provider<ImportService>((ref) {
  return ImportService();
});

final globalDeckServiceProvider = Provider<GlobalDeckService>((ref) {
  return GlobalDeckService();
});

final globalDecksProvider = FutureProvider<List<DeckModel>>((ref) async {
  return ref.watch(globalDeckServiceProvider).getGlobalDecks();
});
