import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vitaminc/core/utils/firestore_collections.dart';
import 'package:vitaminc/core/utils/app_exception_handler.dart';
import 'package:vitaminc/core/models/quest_model.dart';

class QuestService {
  final FirebaseFirestore _firestore;

  QuestService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Lấy danh sách nhiệm vụ hàng ngày của user (Stream)
  Stream<List<QuestModel>> getDailyQuests(String uid) {
    return _firestore
        .collection(FirestoreCollections.users)
        .doc(uid)
        .collection(FirestoreCollections.quests)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => QuestModel.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  /// Khởi tạo hoặc Reset nhiệm vụ hàng ngày (Gọi khi sang ngày mới)
  Future<void> initializeDailyQuests(String uid) async {
    try {
      final batch = _firestore.batch();
      final questsRef = _firestore
          .collection(FirestoreCollections.users)
          .doc(uid)
          .collection(FirestoreCollections.quests);

      final defaultQuests = [
        QuestModel(
          id: 'daily_login',
          title: 'Đăng nhập vào ứng dụng',
          target: 1,
          current: 1, // Đã hoàn thành ngay khi khởi tạo
          rewardXp: 10,
        ),
        QuestModel(
          id: 'daily_study_20',
          title: 'Học hoặc ôn tập 20 thẻ từ',
          target: 20,
          rewardXp: 30,
        ),
        QuestModel(
          id: 'daily_spin',
          title: 'Quay vòng quay may mắn',
          target: 1,
          rewardXp: 15,
        ),
      ];

      for (final quest in defaultQuests) {
        batch.set(questsRef.doc(quest.id), quest.toMap());
      }

      await batch.commit();
    } catch (e) {
      print('Lỗi khởi tạo nhiệm vụ ngày: $e');
    }
  }

  /// Cập nhật tiến độ nhiệm vụ (Tăng current thêm amount)
  Future<void> updateQuestProgress(
    String uid,
    String questId,
    int amount,
  ) async {
    try {
      final questRef = _firestore
          .collection(FirestoreCollections.users)
          .doc(uid)
          .collection(FirestoreCollections.quests)
          .doc(questId);

      await questRef.update({'current': FieldValue.increment(amount)});
    } catch (e) {
      // Ignored for offline or if quest doesn't exist yet
    }
  }

  /// Đánh dấu nhiệm vụ đã nhận thưởng
  Future<void> claimQuestReward(String uid, String questId) async {
    try {
      await _firestore
          .collection(FirestoreCollections.users)
          .doc(uid)
          .collection(FirestoreCollections.quests)
          .doc(questId)
          .update({'isClaimed': true});
    } catch (e) {
      throw AppExceptionHandler.handleException(e, 'Lỗi nhận thưởng nhiệm vụ');
    }
  }
}
