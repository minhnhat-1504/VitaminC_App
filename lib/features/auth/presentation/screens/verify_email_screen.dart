import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vitaminc/core/constants/app_colors.dart';
import 'package:vitaminc/core/utils/app_exception_handler.dart';
import 'dart:async';

class VerifyEmailScreen extends ConsumerStatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  ConsumerState<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends ConsumerState<VerifyEmailScreen> {
  bool isEmailVerified = false;
  bool canResendEmail = false;
  int countdown = 30;
  Timer? timer;
  Timer? countdownTimer;

  @override
  void initState() {
    super.initState();
    isEmailVerified = FirebaseAuth.instance.currentUser?.emailVerified ?? false;

    if (!isEmailVerified) {
      sendVerificationEmail();

      timer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => checkEmailVerified(),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> checkEmailVerified() async {
    // Gọi reload() để cập nhật trạng thái mới nhất từ Firebase
    await FirebaseAuth.instance.currentUser?.reload();
    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser?.emailVerified ?? false;
    });

    if (isEmailVerified) {
      timer?.cancel();
      // GoRouter sẽ tự động nhảy về /home do authState thay đổi (emailVerified = true)
      // Nhưng vì GoRouter chỉ bắt sự kiện thay đổi User (đăng nhập/xuất),
      // Việc reload() không tự trigger GoRouter. Ta cần force redirect hoặc đơn giản là gọi setState
      // Ở file app_router, ta sẽ handle logic redirect.
    }
  }

  Future<void> sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      await user?.sendEmailVerification();

      setState(() {
        canResendEmail = false;
        countdown = 30;
      });

      countdownTimer?.cancel();
      countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) {
          t.cancel();
          return;
        }
        setState(() {
          if (countdown > 0) {
            countdown--;
          } else {
            canResendEmail = true;
            t.cancel();
          }
        });
      });
    } catch (e) {
      if (mounted) {
        final error = AppExceptionHandler.handleException(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Xác minh Email'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.mark_email_unread_outlined, size: 80, color: AppColors.primary),
            const SizedBox(height: 24),
            const Text(
              'Chúng tôi đã gửi một email xác minh đến địa chỉ của bạn.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textDark),
            ),
            const SizedBox(height: 16),
            const Text(
              'Vui lòng kiểm tra hộp thư (kể cả thư mục Spam) và nhấn vào đường link để kích hoạt tài khoản.\n\nMàn hình này sẽ tự động chuyển tiếp khi xác minh thành công.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textLight),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: canResendEmail ? sendVerificationEmail : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: Text(
                canResendEmail ? 'Gửi lại Email xác minh' : 'Gửi lại sau ${countdown}s',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => FirebaseAuth.instance.signOut(),
              child: const Text('Hủy và Quay lại Đăng nhập', style: TextStyle(color: AppColors.textLight, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
