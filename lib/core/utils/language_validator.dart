/// Tiện ích kiểm tra ngôn ngữ (dùng cho tính năng "Cảnh sát ngôn ngữ" English-Only)
class LanguageValidator {
  LanguageValidator._(); // Ngăn khởi tạo, chỉ dùng static

  /// Regex phát hiện ký tự tiếng Việt có dấu đặc trưng (nguyên âm + chữ đ)
  static final RegExp _vietnameseRegex = RegExp(
    r'[áàảãạâấầẩẫậăắằẳẵặéèẻẽẹêếềểễệíìỉĩịóòỏõọôốồổỗộơớờởỡợúùủũụưứừửữựýỳỷỹỵđ]',
    caseSensitive: false,
  );

  /// Trả về `true` nếu chuỗi chứa ít nhất 1 ký tự tiếng Việt có dấu
  static bool isVietnamese(String text) {
    return _vietnameseRegex.hasMatch(text);
  }

  /// Trả về `null` nếu hợp lệ (tiếng Anh), hoặc chuỗi lỗi nếu có tiếng Việt
  static String? validateEnglishOnly(String text) {
    if (isVietnamese(text)) {
      return 'Khu vực English-Only! Hãy thử lại bằng tiếng Anh nhé!';
    }
    return null;
  }
}
