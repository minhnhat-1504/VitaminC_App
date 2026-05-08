import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

class AiService {
  late final GenerativeModel _model;
  late final ChatSession _chat;

  AiService() {
    _initModel();
  }

  void _initModel() {
    _model = GenerativeModel(
      model: 'gemini-3-flash-preview',
      apiKey: _apiKey,
      systemInstruction: Content.system(
        "Bạn là một trợ lý ảo dạy tiếng Anh thân thiện và chuyên nghiệp. Hãy tuân thủ các quy tắc sau: "
        "1. Phạm vi: Chỉ giải đáp các câu hỏi liên quan đến tiếng Anh. Nếu người dùng hỏi chủ đề khác, hãy từ chối lịch sự và lái câu chuyện về việc học tiếng Anh. "
        "2. Xử lý Từ vựng: Nếu người dùng hỏi về một hoặc nhiều từ vựng cụ thể, BẮT BUỘC cung cấp nghĩa tiếng Việt, từ loại, và ít nhất 2 câu ví dụ minh họa bằng tiếng Anh (kèm dịch nghĩa). "
        "3. Xử lý Ngữ pháp/Chủ đề khác: Trả lời đúng trọng tâm, giải thích bằng ngôn ngữ đơn giản, dễ hiểu. "
        "4. Hình thức: Trả lời chủ yếu bằng tiếng Việt. Trình bày súc tích, chia ý rõ ràng (dùng gạch đầu dòng) để tối ưu trải nghiệm đọc trên thiết bị di động."
      ),
    );
    
    _chat = _model.startChat();
  }

  Future<String?> askTeacher(String prompt) async {
    try {
      final response = await _chat.sendMessage(Content.text(prompt));
      return response.text;
    } catch (e) {
      print('Lỗi khi gọi Gemini AI: $e');
      return 'Xin lỗi, giáo viên AI đang gặp chút sự cố kết nối. Hãy thử lại nhé! Lỗi: $e';
    }
  }
}

final aiServiceProvider = Provider<AiService>((ref) {
  return AiService();
});
