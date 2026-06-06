import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/utils/firestore_collections.dart';

import 'package:vitaminc/core/utils/app_exception_handler.dart';

class UserService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  UserService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  /// Cập nhật thông tin hồ sơ người dùng (Đồng bộ Auth và Firestore)
  Future<void> updateUserProfile({
    required String displayName,
    required String photoUrl,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw AppException("Tài khoản chưa đăng nhập");

      // 1. Cập nhật trên Firebase Auth
      await user.updateDisplayName(displayName);
      await user.updatePhotoURL(photoUrl);

      // 2. Cập nhật trên Firestore
      await _firestore
          .collection(FirestoreCollections.users)
          .doc(user.uid)
          .update({'displayName': displayName, 'photoUrl': photoUrl});
    } catch (e) {
      throw AppExceptionHandler.handleException(e, 'Lỗi cập nhật hồ sơ');
    }
  }

  /// Cộng điểm XP cho người dùng (bao gồm cả XP tổng và XP ngày)
  Future<void> addXP(String uid, int amount) async {
    try {
      await _firestore.collection(FirestoreCollections.users).doc(uid).update({
        'xp': FieldValue.increment(amount),
        'dailyXp': FieldValue.increment(amount),
      });
    } catch (e) {
      throw AppExceptionHandler.handleException(e, 'Lỗi cộng điểm XP');
    }
  }

  /// Kiểm tra và reset dailyXp nếu đã sang ngày mới
  Future<void> checkAndResetDailyXp(String uid) async {
    try {
      final doc = await _firestore.collection(FirestoreCollections.users).doc(uid).get();
      if (!doc.exists) return;
      
      final data = doc.data();
      if (data == null) return;
      
      final todayStr = DateTime.now().toIso8601String().substring(0, 10);
      final lastActiveDate = data['lastActiveDate']?.toString() ?? '';
      
      final updates = <String, dynamic>{};
      
      // Reset dailyXp nếu qua ngày mới
      if (lastActiveDate != todayStr) {
        updates['dailyXp'] = 0;
        updates['lastActiveDate'] = todayStr;
      }
      
      // Đảm bảo có trường dailyGoal nếu chưa tồn tại
      if (!data.containsKey('dailyGoal')) {
        updates['dailyGoal'] = 50;
      }
      
      // Đảm bảo có trường dailyXp nếu chưa tồn tại
      if (!data.containsKey('dailyXp')) {
        updates['dailyXp'] = 0;
      }

      // Đảm bảo có trường lastActiveDate nếu chưa tồn tại
      if (!data.containsKey('lastActiveDate')) {
        updates['lastActiveDate'] = todayStr;
      }

      if (updates.isNotEmpty) {
        await _firestore.collection(FirestoreCollections.users).doc(uid).update(updates);
      }
    } catch (e) {
      // Ghi log lỗi nhẹ nhàng để không làm sập ứng dụng
      print('Lỗi reset daily XP: $e');
    }
  }
}
