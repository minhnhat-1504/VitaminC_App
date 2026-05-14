import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/firestore_collections.dart';

class DashboardService {
  final FirebaseFirestore _firestore;

  DashboardService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Lấy tổng từ vựng người dùng đã học
  /// Bằng cách đếm các từ có repetition > 0 trong collection vocabs
  Future<int> getLearnedVocabCount(String uid) async {
    try {
      final query = _firestore
          .collection(FirestoreCollections.users)
          .doc(uid)
          .collection(FirestoreCollections.vocabs)
          .where('repetition', isGreaterThan: 0);

      final countQuery = await query.count().get();
      return countQuery.count ?? 0;
    } catch (e) {
      // Trong trường hợp chưa có collection hoặc lỗi, trả về 0
      return 0;
    }
  }
  /// Lấy tổng số từ vựng người dùng có trong collection vocabs (tất cả các deck)
  Future<int> getTotalVocabCount(String uid) async {
    try {
      final query = _firestore
          .collection(FirestoreCollections.users)
          .doc(uid)
          .collection(FirestoreCollections.vocabs);

      final countQuery = await query.count().get();
      return countQuery.count ?? 0;
    } catch (e) {
      return 0;
    }
  }
}
