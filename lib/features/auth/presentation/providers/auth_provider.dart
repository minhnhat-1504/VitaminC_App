import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/user_service.dart';
import '../../../../core/models/user_model.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

// Provider cung cấp Repository cho toàn bộ app
final authRepositoryProvider = Provider((ref) => AuthRepository());

final userServiceProvider = Provider((ref) => UserService());

// StreamProvider theo dõi trạng thái đăng nhập (User có null hay không) từ Firebase
final authStateProvider = StreamProvider<User?>((ref) {
  // Truy cập vào biến auth công khai từ Repository
  return ref.watch(authRepositoryProvider).auth.authStateChanges();
});

// StreamProvider lấy thông tin chi tiết User (bao gồm Role) từ Firestore thời gian thực
final currentUserProvider = StreamProvider<UserModel?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user != null) {
    // Kiểm tra và reset dailyXp khi khởi động / đổi ngày mới
    ref.read(userServiceProvider).checkAndResetDailyXp(user.uid);

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((snapshot) {
          if (snapshot.exists && snapshot.data() != null) {
            return UserModel.fromMap(snapshot.data()!);
          }
          return null;
        });
  }
  return Stream.value(null);
});
