import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/utils/firestore_collections.dart';

import 'package:vitaminc/core/utils/app_exception_handler.dart';

class UserService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  UserService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
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
          .update({
        'displayName': displayName,
        'photoUrl': photoUrl,
      });
    } catch (e) {
      throw AppExceptionHandler.handleException(e, 'Lỗi cập nhật hồ sơ');
    }
  }
}
