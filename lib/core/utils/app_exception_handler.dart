import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppException implements Exception {
  final String message;
  AppException(this.message);

  @override
  String toString() => message;
}

class AppExceptionHandler {
  // Global key để hiển thị SnackBar từ bất cứ đâu
  static final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  /// Xử lý ngoại lệ không bắt được (Uncaught Error) toàn cục
  static void handleUncaughtError(Object error, StackTrace stackTrace) {
    debugPrint('=== UNCAUGHT GLOBAL ERROR ===');
    debugPrint(error.toString());
    debugPrint(stackTrace.toString());
    
    final appException = handleException(error, 'Lỗi hệ thống');
    
    rootScaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(appException.message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  /// Chuẩn hóa tất cả các Exception (Firebase, Mạng, Ứng dụng) thành một câu thông báo thân thiện
  static AppException handleException(dynamic error, [String defaultMessage = 'Đã xảy ra lỗi']) {
    // 1. Lỗi mạng (SocketException hoặc Google Sign In network_error)
    if (error is SocketException || 
        error.toString().contains('SocketException') || 
        error.toString().contains('Failed host lookup') ||
        error.toString().contains('network_error') ||
        (error is PlatformException && error.code == 'network_error')) {
      return AppException('Không có kết nối mạng. Vui lòng kiểm tra lại Wifi/4-5G');
    }

    // 2. Lỗi Firestore
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return AppException('Hành động bị từ chối: Bạn không có quyền truy cập dữ liệu này.');
        case 'unavailable':
          return AppException('Mất kết nối với máy chủ. Ứng dụng sẽ tự đồng bộ khi có mạng trở lại.');
        case 'not-found':
          return AppException('Dữ liệu không tồn tại hoặc đã bị xóa.');
        default:
          return AppException('$defaultMessage (${error.code})');
      }
    }

    // 3. Lỗi Đăng nhập (Auth)
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
        case 'user-disabled':
          return AppException('Tài khoản không tồn tại hoặc đã bị khóa.');
        case 'wrong-password':
        case 'invalid-credential':
          return AppException('Email hoặc mật khẩu không chính xác.');
        case 'email-already-in-use':
          return AppException('Email này đã được sử dụng bởi một tài khoản khác.');
        case 'network-request-failed':
          return AppException('Lỗi kết nối máy chủ. Vui lòng kiểm tra mạng.');
        case 'too-many-requests':
          return AppException('Bạn đã thử quá nhiều lần. Vui lòng đợi một lát.');
        default:
          return AppException('$defaultMessage (${error.code})');
      }
    }

    // Nếu đã là AppException do chúng ta tự ném ra thì giữ nguyên
    if (error is AppException) {
      return error;
    }

    // Lọc bỏ chữ "Exception: " mặc định của Dart
    final errorString = error.toString();
    if (errorString.startsWith('Exception: ')) {
      return AppException(errorString.substring(11));
    }

    return AppException('$defaultMessage: $errorString');
  }
}
