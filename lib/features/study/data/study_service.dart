import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vitaminc/core/utils/firestore_collections.dart';
import 'package:vitaminc/features/library/data/models/vocab_model.dart';

class StudyService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  StudyService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Lấy danh sách các thẻ cần ôn tập hôm nay
  Future<List<VocabModel>> getDueCards({String? deckId, bool forceStudy = false}) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        throw Exception('Vui lòng đăng nhập để thực hiện chức năng này.');
      }

      // Query Firestore lấy những thẻ có nextReview <= thời điểm hiện tại
      Query query = _firestore
          .collection(FirestoreCollections.users)
          .doc(uid)
          .collection(FirestoreCollections.vocabs);

      if (!forceStudy) {
        query = query.where('nextReview', isLessThanOrEqualTo: Timestamp.now());
      }

      if (deckId != null) {
        query = query.where('deckId', isEqualTo: deckId);
      }

      final querySnapshot = await query
          .orderBy('nextReview')
          .limit(50) // Giới hạn 50 từ vựng cho mỗi lần ôn tập
          .get();

      // Map DocumentSnapshot thành VocabModel
      return querySnapshot.docs.map((doc) {
        return VocabModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } on FirebaseException catch (e) {
      // Firebase yêu cầu Composite Index (deckId + nextReview)
      if (e.message != null && e.message!.contains('requires an index')) {
        return await _getDueCardsFallback(deckId: deckId, forceStudy: forceStudy);
      }
      throw Exception('Lỗi kết nối CSDL: ${e.message}');
    } catch (e) {
      throw Exception('Lỗi không xác định khi tải thẻ ôn tập: $e');
    }
  }

  /// Hàm tải dự phòng khi thiếu Firebase Composite Index (Lọc thủ công trên máy)
  Future<List<VocabModel>> _getDueCardsFallback({String? deckId, bool forceStudy = false}) async {
    final uid = _auth.currentUser!.uid;
    Query query = _firestore
        .collection(FirestoreCollections.users)
        .doc(uid)
        .collection(FirestoreCollections.vocabs);

    if (deckId != null) {
      query = query.where('deckId', isEqualTo: deckId);
    }
    
    // Tải toàn bộ thẻ của deck (hoặc của user nếu deckId == null)
    final querySnapshot = await query.get();
    
    final now = Timestamp.now();
    var allCards = querySnapshot.docs.map((doc) {
      return VocabModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();

    // Lọc thủ công các thẻ tới hạn (nếu không phải học ép)
    if (!forceStudy) {
      allCards = allCards.where((card) => card.nextReview.compareTo(now) <= 0).toList();
    }

    // Sắp xếp theo hạn ôn tập
    allCards.sort((a, b) => a.nextReview.compareTo(b.nextReview));

    return allCards.take(50).toList();
  }

  /// Cập nhật kết quả thẻ từ lên Firestore sau khi review
  Future<void> updateCardAfterReview(VocabModel updatedCard) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        throw Exception('Vui lòng đăng nhập.');
      }

      await _firestore
          .collection(FirestoreCollections.users)
          .doc(uid)
          .collection(FirestoreCollections.vocabs)
          .doc(updatedCard.id)
          .update(updatedCard.toMap());
    } catch (e) {
      throw Exception('Lỗi khi lưu kết quả ôn tập: $e');
    }
  }
}
