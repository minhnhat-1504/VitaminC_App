import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vitaminc/features/library/data/import_service.dart';
import 'package:vitaminc/features/library/data/library_service.dart';

final libraryServiceProvider = Provider<LibraryService>((ref) {
  return LibraryService();
});

final importServiceProvider = Provider<ImportService>((ref) {
  return ImportService();
});
