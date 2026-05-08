1. Dọn dẹp thư mục dự án (Chỉ làm Android)Nếu nhóm bạn thống nhất chỉ làm trên Android, bạn có thể xóa các thư mục sau để dự án nhẹ hơn và tránh gây nhiễu khi tìm kiếm file:Các thư mục CÓ THỂ xóa: ios, linux, macos, windows, web.Các thư mục BẮT BUỘC giữ lại:android: Chứa cấu hình quyền, icon app và cài đặt Java.lib: Chứa toàn bộ code Dart của team.assets: Chứa ảnh, icon, font.test: Chứa code kiểm thử (nếu có).pubspec.yaml: File quan trọng nhất để quản lý thư viện.2. Danh sách tổng hợp các điểm cần sửa chi tiếtA. Nhóm file Core (Nền tảng)Tên fileVấn đề cần sửaChi tiết cách sửaapp_colors.dartThiếu các bảng màu đặc thù.Thêm các static const cho: slate (từ 100-900), gold, bronze, và streakOrange.custom_label.dart (Tạo mới)Trùng lặp hàm _buildLabel.Tạo Widget này trong shared_widgets để thay thế hàm _buildLabel ở login_screen.dart và add_vocab_screen.dart.B. Nhóm file Features (Tính năng)Tên fileVị trí cần sửaNội dung sửahome_screen.dartToàn bộ các mã Hex lẻ.Thay 0xFFF8F9FD thành AppColors.backgroundLight. Thay Colors.orange, Colors.blue thành các biến tương ứng trong AppColors.login_screen.dartLogic _buildLabel.Xóa hàm này và gọi CustomLabel vừa tạo ở bước trên.leaderboard_screen.dartLeaderboardColors & Header.1. Xóa class LeaderboardColors bên trong file.2. Thay phần Header tự chế bằng CustomAppBar.streak_popup.dart_StreakColors.Xóa class màu nội bộ, chuyển các màu cam rực rỡ sang AppColors.streakOrange.pronunciation_screen.dartHeader & Màu Success/Error.1. Thay Header bằng CustomAppBar.2. Dùng AppColors.success cho điểm cao và AppColors.error cho điểm thấp thay vì mã Hex.flashcard_screen.dartNút bấm SRS.Thay ElevatedButton bằng CustomPrimaryButton hoặc tạo SRSButton chung để đồng bộ bo góc 12px và font chữ.add_vocab_screen.dartLayout & Label.1. Dùng CustomLabel.2. Bọc SingleChildScrollView cho toàn bộ body để tránh lỗi tràn màn hình khi hiện bàn phím.C. Nhóm Điều hướng (Routing)Tên fileVấn đềCách sửaapp_router.dartImports & Comments.1. Xóa các dòng code bị comment (//).2. Kiểm tra lại các GoRoute để đảm bảo không còn màn hình nào dùng Placeholder().3. Những việc cần Team thực hiện ngay (Checklist cho Lead)Nhật hãy yêu cầu 3 thành viên thực hiện đúng các đầu việc này trước khi bạn "chốt" code vào nhánh main:Sửa lỗi Overflow: Mở từng màn hình, nhấn vào các ô nhập liệu (TextField) để bàn phím hiện lên. Nếu màn hình nào bị sọc vàng đen ở cạnh dưới (do bàn phím đè), phải bọc Column vào SingleChildScrollView.Đồng bộ Font: Kiểm tra xem có chỗ nào các bạn đang dùng TextStyle(fontFamily: ...) lẻ không. Yêu cầu xóa hết để app dùng font Lexend mặc định đã cài ở main.dart.Dọn dẹp Assets: Kiểm tra xem team có ai dùng ảnh mạng (NetworkImage) không. Nếu có, yêu cầu tải về bỏ vào assets/images và dùng Image.asset để app có thể chạy Offline ở Sprint 2.Format Code: Yêu cầu cả team nhấn Shift + Alt + F (trên Windows) cho tất cả các file để code trông đồng nhất, không bị thụt thò.4. Gợi ý cho Nhật: Tạo CustomLabel dùng chungVì lỗi trùng lặp _buildLabel xuất hiện ở nhiều nơi, bạn hãy tạo file này để team tận dụng:File: lib/core/shared_widgets/custom_label.dartDartimport 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CustomLabel extends StatelessWidget {
  final String english;
  final String vietnamese;

  const CustomLabel({super.key, required this.english, required this.vietnamese});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Row(
        children: [
          Text(english, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textLight, fontSize: 15)),
          const SizedBox(width: 8),
          Text("- $vietnamese", style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
        ],
      ),
    );
  }
}