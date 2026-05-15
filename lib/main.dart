import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/constants/app_colors.dart';
import 'core/services/notification_service.dart';
import 'core/utils/app_exception_handler.dart';
import 'routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Bắt các lỗi do Flutter UI ném ra
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    AppExceptionHandler.handleUncaughtError(details.exception, details.stack ?? StackTrace.empty);
  };
  
  // Bắt các lỗi Async (Platform) ném ra
  PlatformDispatcher.instance.onError = (error, stack) {
    AppExceptionHandler.handleUncaughtError(error, stack);
    return true; // Ngăn chặn crash app
  };

  try {
    await dotenv.load(fileName: ".env");
    await Firebase.initializeApp();
    debugPrint("====================================================");
    debugPrint(">>> FIREBASE CONNECTED SUCCESSFULLY! <<<");
    debugPrint("Project ID: ${Firebase.app().options.projectId}");
    debugPrint("====================================================");
    
    // Khởi tạo Notification Service
    await NotificationService().initialize();
  } catch (e) {
    debugPrint("====================================================");
    debugPrint(">>> FIREBASE CONNECTION FAILED: $e");
    debugPrint("====================================================");
  }

  runApp(
    const ProviderScope(child: VitaminCApp()),
  );
}

class VitaminCApp extends ConsumerWidget {
  const VitaminCApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      scaffoldMessengerKey: AppExceptionHandler.rootScaffoldMessengerKey,
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