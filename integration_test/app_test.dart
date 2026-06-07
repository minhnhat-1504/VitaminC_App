import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:vitaminc/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('E2E App Flow', () {
    testWidgets('Luồng Đăng nhập -> Vào Thư viện', (WidgetTester tester) async {
      // 1. Chạy app
      app.main();
      
      // Chờ các init async và splash screen kết thúc (tối đa 5-10s)
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Do luồng auto login có thể diễn ra, ta cần kiểm tra xem có đang ở trang Home hay Login.
      // Tìm xem có input của trang Login không
      final emailInput = find.byType(TextField).first;
      
      // Nếu có input, nghĩa là đang ở trang Login
      if (emailInput.evaluate().isNotEmpty) {
        // 2. Nhập thông tin đăng nhập
        await tester.enterText(emailInput, 'test@example.com');
        await tester.pumpAndSettle();
        
        final passwordInput = find.byType(TextField).last;
        await tester.enterText(passwordInput, 'password123');
        await tester.pumpAndSettle();

        // 3. Bấm đăng nhập
        final loginButton = find.textContaining('Đăng nhập');
        await tester.tap(loginButton);
        
        // Chờ xử lý mạng
        await tester.pumpAndSettle(const Duration(seconds: 5));
      }

      // 4. Kiểm tra đã vào Home chưa (dựa vào BottomNavBar)
      final homeTab = find.text('Home');
      expect(homeTab, findsOneWidget);

      // 5. Chuyển sang tab Thư viện
      final libraryTab = find.text('Library');
      await tester.tap(libraryTab);
      await tester.pumpAndSettle();

      // 6. Xác nhận đang ở trang thư viện (ví dụ tìm AppBar có chữ 'Global Decks' hoặc icon Add)
      // Tùy theo thiết kế, ta tìm chữ 'Thư viện' hoặc icon thêm từ
      expect(find.byType(FloatingActionButton), findsWidgets);
    });
  });
}
