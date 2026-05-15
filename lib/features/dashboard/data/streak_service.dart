import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/firestore_collections.dart';
import '../../../../core/services/notification_service.dart';

class StreakService {
  final FirebaseFirestore _firestore;

  StreakService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Lấy chuỗi ngày học hiện tại (Streak) của người dùng
  Future<int> getStreakCount(String uid) async {
    try {
      final doc = await _firestore.collection(FirestoreCollections.users).doc(uid).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null && data.containsKey('streak_count')) {
          // Tính toán xem streak có bị đứt không
          final lastStudyTimestamp = data['last_study_date'] as Timestamp?;
          int currentStreak = data['streak_count'] as int;

          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);

          if (lastStudyTimestamp != null) {
            final lastStudyTime = lastStudyTimestamp.toDate();
            final lastStudyDay = DateTime(lastStudyTime.year, lastStudyTime.month, lastStudyTime.day);
            final difference = today.difference(lastStudyDay).inDays;

            if (difference > 1) {
              // Bị đứt chuỗi rồi nên trả về 0 (nhưng chưa update vào DB cho đến khi action updateStreak được gọi)
              return 0;
            }
          }
          return currentStreak;
        }
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  /// Cập nhật chuỗi ngày học liên tiếp (Streak)
  /// Trả về số streak mới sau khi cập nhật
  Future<int> updateStreak(String uid) async {
    try {
      final userDocRef = _firestore.collection(FirestoreCollections.users).doc(uid);
      int newStreak = 0;

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(userDocRef);

        if (!snapshot.exists) {
          return;
        }

        final data = snapshot.data();
        int currentStreak = data?['streak_count'] as int? ?? 0;
        final Timestamp? lastStudyTimestamp = data?['last_study_date'] as Timestamp?;

        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);

        if (lastStudyTimestamp != null) {
          final lastStudyTime = lastStudyTimestamp.toDate();
          final lastStudyDay = DateTime(lastStudyTime.year, lastStudyTime.month, lastStudyTime.day);
          
          final difference = today.difference(lastStudyDay).inDays;

          if (difference == 0) {
            // Đã học hôm nay rồi -> Giữ nguyên streak
            newStreak = currentStreak;
            return;
          } else if (difference == 1) {
            // Ngày hôm qua học, hôm nay học tiếp -> Tăng streak
            newStreak = currentStreak + 1;
          } else {
            // Bỏ lỡ > 1 ngày -> Reset streak về 1 (vì hôm nay đang học)
            newStreak = 1;
          }
        } else {
          // Chưa học bao giờ -> Chuỗi ngày đầu tiên
          newStreak = 1;
        }

        // Lưu lại kết quả mới
        transaction.update(userDocRef, {
          'streak_count': newStreak,
          'last_study_date': FieldValue.serverTimestamp(),
        });
      });
      
      // Thành công cập nhật streak (tức là đã học hôm nay),
      // Dời lịch nhắc nhở sang 20:00 ngày mai.
      await NotificationService().scheduleDailyStreakReminder(startFromTomorrow: true);

      return newStreak;
    } catch (e) {
      print("Lỗi updateStreak: $e");
      return 0;
    }
  }
}
