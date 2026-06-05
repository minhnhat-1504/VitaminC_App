import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vitaminc/core/services/local_db_service.dart';

final localDbServiceProvider = Provider<LocalDbService>((ref) {
  return LocalDbService();
});
