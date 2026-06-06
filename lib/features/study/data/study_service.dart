import 'package:firebase_auth/firebase_auth.dart';
import 'package:vitaminc/core/utils/app_exception_handler.dart';
import 'package:vitaminc/features/library/data/models/vocab_model.dart';
import 'package:vitaminc/core/services/local_db_service.dart';

class StudyService {
  final FirebaseAuth _auth;
  final LocalDbService? _localDb;

  StudyService({FirebaseAuth? auth, LocalDbService? localDb})
    : _auth = auth ?? FirebaseAuth.instance,
      _localDb = localDb;

  /// Lấy danh sách các thẻ cần ôn tập hôm nay từ Local DB
  Future<List<VocabModel>> getDueCards({
    String? deckId,
    bool forceStudy = false,
  }) async {
    try {
      if (_localDb == null) {
        throw AppException('Local DB chưa được khởi tạo');
      }

      final localCards = _localDb.getLocalDueCards(
        deckId: deckId,
        forceStudy: forceStudy,
      );

      // Giới hạn 50 từ vựng cho mỗi lần ôn tập
      final limitedCards = localCards.take(50).toList();

      return limitedCards.map((e) => e.toVocabModel()).toList();
    } catch (e) {
      throw AppExceptionHandler.handleException(
        e,
        'Lỗi khi tải thẻ ôn tập từ Local DB',
      );
    }
  }

  /// Cập nhật kết quả thẻ từ xuống Local DB và thêm vào Queue
  Future<void> updateCardAfterReview(VocabModel updatedCard) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        throw AppException('Vui lòng đăng nhập.');
      }

      if (_localDb == null) {
        throw AppException('Local DB chưa được khởi tạo');
      }

      // 1. Cập nhật thẻ trên Local DB (tự động thêm vào Queue bên trong hàm này)
      await _localDb.updateLocalVocab(updatedCard);

      // 2. Kích hoạt tiến trình ngầm đồng bộ lên Firestore (không dùng await để tránh block UI)
      _localDb.processSyncQueue(uid);
    } catch (e) {
      throw AppExceptionHandler.handleException(
        e,
        'Lỗi khi lưu kết quả ôn tập',
      );
    }
  }
}
