import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/firestore_collections.dart';

/// Định nghĩa tất cả các ID huy hiệu trong ứng dụng
class BadgeIds {
  BadgeIds._();

  static const String firstBlood =
      'first_blood'; // Hoàn thành buổi học đầu tiên
  static const String streak7 = 'streak_7'; // Duy trì streak 7 ngày
  static const String streak30 = 'streak_30'; // Duy trì streak 30 ngày
  static const String words100 = 'words_100'; // Học đủ 100 từ vựng
}

class BadgeService {
  final FirebaseFirestore _firestore;

  BadgeService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Kiểm tra và trao huy hiệu dựa trên streak hiện tại của người dùng.
  /// Gọi hàm này ngay sau khi `updateStreak()` thành công.
  Future<void> checkAndAwardBadges({
    required String uid,
    required int newStreak,
    required int learnedVocabCount,
  }) async {
    try {
      final docRef = _firestore.collection(FirestoreCollections.users).doc(uid);

      final doc = await docRef.get();
      if (!doc.exists) return;

      final data = doc.data()!;
      final currentBadges = List<String>.from(data['earnedBadges'] ?? []);
      final badgesToAdd = <String>[];

      // --- Quy tắc trao huy hiệu ---

      // 1. Huy hiệu "Máu đầu" - Hoàn thành buổi học đầu tiên
      if (newStreak >= 1 && !currentBadges.contains(BadgeIds.firstBlood)) {
        badgesToAdd.add(BadgeIds.firstBlood);
      }

      // 2. Huy hiệu "Streak 7 ngày"
      if (newStreak >= 7 && !currentBadges.contains(BadgeIds.streak7)) {
        badgesToAdd.add(BadgeIds.streak7);
      }

      // 3. Huy hiệu "Streak 30 ngày"
      if (newStreak >= 30 && !currentBadges.contains(BadgeIds.streak30)) {
        badgesToAdd.add(BadgeIds.streak30);
      }

      // 4. Huy hiệu "100 từ vựng"
      if (learnedVocabCount >= 100 &&
          !currentBadges.contains(BadgeIds.words100)) {
        badgesToAdd.add(BadgeIds.words100);
      }

      // Chỉ ghi lên Firestore nếu có huy hiệu mới
      if (badgesToAdd.isNotEmpty) {
        await docRef.update({
          'earnedBadges': FieldValue.arrayUnion(badgesToAdd),
        });
      }
    } catch (e) {
      print('Lỗi BadgeService.checkAndAwardBadges: $e');
    }
  }
}
