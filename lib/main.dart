import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/constants/app_colors.dart';
import 'routing/app_router.dart';

void main() async {
  // 1. Đảm bảo các ràng buộc dịch vụ hệ thống được khởi tạo
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 2. Khởi tạo kết nối với Firebase
    await Firebase.initializeApp();
    
    // In thông báo khi kết nối thành công
    debugPrint("====================================================");
    debugPrint(">>> FIREBASE CONNECTED SUCCESSFULLY! <<<");
    debugPrint("Project ID: ${Firebase.app().options.projectId}");
    debugPrint("====================================================");
  } catch (e) {
    // In lỗi nếu kết nối thất bại
    debugPrint("====================================================");
    debugPrint(">>> FIREBASE CONNECTION FAILED: $e");
    debugPrint("====================================================");
  }

  runApp(
    // 3. ProviderScope bao bọc toàn bộ ứng dụng để sử dụng Riverpod
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

      // Cấu hình giao diện (Theme) đồng nhất
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.backgroundLight,

        // Cài đặt Font Lexend cho toàn bộ hệ thống văn bản
        textTheme: GoogleFonts.lexendTextTheme(),

        // Cấu hình bảng màu hệ thống
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          surface: AppColors.backgroundLight,
        ),

        // Style mặc định cho AppBar
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

      // Kết nối với cấu hình GoRouter
      routerConfig: goRouter,
    );
  }
}