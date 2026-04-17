import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/constants/app_colors.dart';
import 'routing/app_router.dart';

void main() {
  // ProviderScope là bắt buộc để sử dụng Riverpod
  runApp(const ProviderScope(child: VitaminCApp()));
}

class VitaminCApp extends StatelessWidget {
  const VitaminCApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'VitaminC',
      debugShowCheckedModeBanner: false, // Tắt chữ debug góc phải
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.backgroundLight,
        // Cấu hình font Lexend cho toàn bộ app
        textTheme: GoogleFonts.lexendTextTheme(Theme.of(context).textTheme),
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
      ),
      // Kết nối với GoRouter đã setup ở Bước 3
      routerConfig: goRouter,
    );
  }
}