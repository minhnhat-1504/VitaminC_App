import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  double _opacity = 0.0;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) setState(() => _opacity = 1.0);
    });

    // Timeout an toàn: nếu sau 5 giây vẫn chưa chuyển trang, buộc chuyển sang login
    Future.delayed(const Duration(seconds: 5), () {
      _navigateIfNeeded();
    });
  }

  void _navigateIfNeeded() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;

    final authState = ref.read(authStateProvider);
    final loggedIn = authState.value != null && !authState.isLoading;

    if (loggedIn) {
      context.go('/home');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lắng nghe authState: khi Firebase trả kết quả xong → chuyển trang ngay
    ref.listen(authStateProvider, (prev, next) {
      if (!next.isLoading) {
        // Chờ animation logo hiện xong rồi mới chuyển (tối thiểu 1.5s)
        Future.delayed(const Duration(milliseconds: 1500), () {
          _navigateIfNeeded();
        });
      }
    });

    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 1000),
          opacity: _opacity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 3),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: MediaQuery.of(context).size.width * 0.9,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
