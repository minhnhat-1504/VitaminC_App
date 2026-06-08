import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'core/models/vocab_local.dart';
import 'core/models/sync_queue_item.dart';
import 'core/services/local_db_service.dart';

import 'core/constants/app_colors.dart';
import 'core/constants/app_theme.dart';
import 'core/providers/theme_provider.dart';
import 'core/services/notification_service.dart';
import 'core/utils/app_exception_handler.dart';
import 'routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Bật chế độ debug animation slow-motion (uncomment khi cần test):
  // timeDilation = 5.0;

  try {
    await dotenv.load(fileName: ".env");

    // Khởi tạo Local DB (Hive CE)
    await Hive.initFlutter();
    await Hive.openBox('settingsBox');
    Hive.registerAdapter(VocabLocalAdapter());
    Hive.registerAdapter(SyncQueueItemAdapter());

    await Firebase.initializeApp();

    // Bắt các lỗi do Flutter UI ném ra
    FlutterError.onError = (FlutterErrorDetails details) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(details);
      // Bỏ qua lỗi ngầm (VD: lỗi tải ảnh từ NetworkImage) để không spam SnackBar
      if (details.silent || details.library == 'image resource service') {
        debugPrint('Silent or Image error ignored: ${details.exception}');
        return;
      }
      FlutterError.presentError(details);
      AppExceptionHandler.handleUncaughtError(
        details.exception,
        details.stack ?? StackTrace.empty,
      );
    };

    // Bắt các lỗi Async (Platform) ném ra
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      AppExceptionHandler.handleUncaughtError(error, stack);
      return true; // Ngăn chặn crash app
    };

    await LocalDbService().init();
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

  runApp(const ProviderScope(child: VitaminCApp()));
}

class VitaminCApp extends ConsumerWidget {
  const VitaminCApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      scaffoldMessengerKey: AppExceptionHandler.rootScaffoldMessengerKey,
      title: 'VitaminC',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
