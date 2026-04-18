import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/constants/app_colors.dart';
import 'routing/app_router.dart';

void main() {
  // Đảm bảo các dịch vụ hệ thống được khởi tạo
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    // ProviderScope bao bọc toàn bộ ứng dụng để sử dụng Riverpod
    const ProviderScope(child: VitaminCApp()),
  );
}

class VitaminCApp extends StatelessWidget {
  const VitaminCApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'VitaminC',
      debugShowCheckedModeBanner: false,

      // Cấu hình giao diện (Theme)
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.backgroundLight,

        // Cách cài đặt Font Lexend cho toàn app chuẩn nhất
        textTheme: GoogleFonts.lexendTextTheme(),

        // Cấu hình màu sắc hệ thống
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          surface: AppColors.backgroundLight,
        ),

        // Định nghĩa style mặc định cho AppBar để đồng nhất các màn hình
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.backgroundLight,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.lexend(
            color: AppColors.textLight,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: const IconThemeData(color: AppColors.textLight),
        ),
      ),

      // Kết nối với GoRouter
      routerConfig: goRouter,
    );
  }
}
