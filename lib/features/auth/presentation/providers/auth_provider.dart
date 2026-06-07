import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/user_service.dart';
import '../../../../core/models/user_model.dart';
import 'package:flutter/material.dart';
import '../../../../core/utils/app_exception_handler.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

// Provider cung cấp Repository cho toàn bộ app
final authRepositoryProvider = Provider((ref) => AuthRepository());

final userServiceProvider = Provider((ref) => UserService());

// StreamProvider theo dõi trạng thái đăng nhập (User có null hay không) từ Firebase
final authStateProvider = StreamProvider<User?>((ref) {
  // Truy cập vào biến auth công khai từ Repository. Dùng idTokenChanges thay vì authStateChanges để bắt token hết hạn
  return ref.watch(authRepositoryProvider).auth.idTokenChanges();
});

// StreamProvider lấy thông tin chi tiết User (bao gồm Role) từ Firestore thời gian thực
final currentUserProvider = StreamProvider<UserModel?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user != null) {
    // Kiểm tra và reset dailyXp khi khởi động / đổi ngày mới
    ref.read(userServiceProvider).checkAndResetDailyXp(user.uid);

    // Cập nhật token chủ động để Firebase Auth biết nếu tài khoản bị khóa
    user.getIdTokenResult(false).catchError((e) {
      if (e is FirebaseAuthException &&
          (e.code == 'user-disabled' || e.code == 'user-token-expired')) {
        ref.read(authRepositoryProvider).signOut();
        AppExceptionHandler.rootScaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(
            content: Text('Phiên đăng nhập đã hết hạn hoặc tài khoản bị khóa. Vui lòng đăng nhập lại.'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return null;
    });

    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((snapshot) {
          if (snapshot.exists && snapshot.data() != null) {
            return UserModel.fromMap(snapshot.data()!);
          }
          return null;
        })
        .handleError((error) {
          if (error is FirebaseException && error.code == 'permission-denied') {
            ref.read(authRepositoryProvider).signOut();
            AppExceptionHandler.rootScaffoldMessengerKey.currentState?.showSnackBar(
              const SnackBar(
                content: Text('Phiên đăng nhập không hợp lệ hoặc đã hết hạn.'),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        });
  }
  return Stream.value(null);
});
