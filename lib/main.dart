import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/constants/app_colors.dart';
import 'routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    debugPrint("====================================================");
    debugPrint(">>> FIREBASE CONNECTED SUCCESSFULLY! <<<");
    debugPrint("Project ID: ${Firebase.app().options.projectId}");
    debugPrint("====================================================");
  } catch (e) {
    debugPrint("====================================================");
    debugPrint(">>> FIREBASE CONNECTION FAILED: $e");
    debugPrint("====================================================");
  }

  runApp(
    const ProviderScope(child: VitaminCApp()),
  );
}

class VitaminCApp extends ConsumerWidget { // Chuyển thành ConsumerWidget
  const VitaminCApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lấy router từ Provider đã định nghĩa trong app_router.dart
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'VitaminC',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.backgroundLight,
        textTheme: GoogleFonts.lexendTextTheme(),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          surface: AppColors.backgroundLight,
        ),
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
      // Kết nối config mới từ Provider
      routerConfig: router, 
    );
  }
}