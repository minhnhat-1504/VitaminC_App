import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_ce/hive.dart';

class AppException implements Exception {
  final String message;
  AppException(this.message);

  @override
  String toString() => message;
}

class AppExceptionHandler {
  // Global key để hiển thị SnackBar từ bất cứ đâu
  static final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  /// Xử lý ngoại lệ không bắt được (Uncaught Error) toàn cục
  static void handleUncaughtError(Object error, StackTrace stackTrace) {
    final errorString = error.toString();
    
    // Lọc bỏ các lỗi "ồn ào" (không cần hiện SnackBar làm phiền user)
    if (errorString.contains('RenderFlex overflowed') ||
        errorString.contains("looking up a deactivated widget's ancestor")) {
      debugPrint('=== SILENT ERROR IGNORED ===\n$errorString');
      return;
    }

    // Các lỗi Platform exception đặc biệt không cần hiện (vd: cancel sign in)
    if (error is PlatformException && error.code == 'sign_in_canceled') {
      return;
    }

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
  static AppException handleException(
    dynamic error, [
    String defaultMessage = 'Đã xảy ra lỗi',
  ]) {
    // 1. Lỗi mạng (SocketException hoặc Google Sign In network_error)
    if (error is SocketException ||
        error.toString().contains('SocketException') ||
        error.toString().contains('Failed host lookup') ||
        error.toString().contains('network_error') ||
        (error is PlatformException && error.code == 'network_error')) {
      return AppException(
        'Không có kết nối mạng. Vui lòng kiểm tra lại Wifi/4-5G',
      );
    }

    // 2. Lỗi Firestore & Firebase Chung
    if (error is FirebaseException && error is! FirebaseAuthException) {
      switch (error.code) {
        case 'permission-denied':
          return AppException(
            'Hành động bị từ chối: Bạn không có quyền truy cập dữ liệu này.',
          );
        case 'unavailable':
          return AppException(
            'Mất kết nối với máy chủ. Ứng dụng sẽ tự đồng bộ khi có mạng trở lại.',
          );
        case 'not-found':
          return AppException('Dữ liệu không tồn tại hoặc đã bị xóa.');
        case 'cancelled':
          return AppException('Thao tác đã bị hủy.');
        case 'deadline-exceeded':
          return AppException('Máy chủ phản hồi quá chậm. Vui lòng thử lại sau.');
        case 'already-exists':
          return AppException('Dữ liệu đã tồn tại, không thể tạo trùng.');
        case 'resource-exhausted':
        case 'quota-exceeded':
          return AppException('Hệ thống đang quá tải. Vui lòng thử lại sau ít phút.');
        case 'data-loss':
          return AppException('Dữ liệu bị hỏng hoặc mất. Vui lòng liên hệ hỗ trợ.');
        case 'unauthenticated':
          return AppException('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
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
          return AppException(
            'Email này đã được sử dụng bởi một tài khoản khác.',
          );
        case 'weak-password':
          return AppException('Mật khẩu quá yếu. Hãy dùng ít nhất 6 ký tự.');
        case 'invalid-email':
          return AppException('Địa chỉ Email không hợp lệ.');
        case 'account-exists-with-different-credential':
          return AppException('Email này đã được đăng ký bằng phương thức khác (Google/Facebook).');
        case 'operation-not-allowed':
          return AppException('Phương thức đăng nhập này chưa được kích hoạt.');
        case 'expired-action-code':
          return AppException('Link đặt lại mật khẩu đã hết hạn.');
        case 'invalid-action-code':
          return AppException('Link đặt lại mật khẩu không hợp lệ.');
        case 'network-request-failed':
          return AppException('Lỗi kết nối máy chủ. Vui lòng kiểm tra mạng.');
        case 'too-many-requests':
          return AppException(
            'Bạn đã thử quá nhiều lần. Vui lòng đợi một lát.',
          );
        default:
          return AppException('$defaultMessage (${error.code})');
      }
    }

    // 4. Lỗi Hive (Local DB)
    if (error is HiveError) {
      return AppException('Lỗi cơ sở dữ liệu cục bộ. Vui lòng khởi động lại ứng dụng.');
    }

    // 5. Lỗi Platform (như Google Sign In)
    if (error is PlatformException) {
      if (error.code == 'sign_in_canceled') {
        return AppException('Đã hủy thao tác.');
      }
      if (error.code == 'sign_in_failed') {
        return AppException('Đăng nhập thất bại. Vui lòng thử lại.');
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
