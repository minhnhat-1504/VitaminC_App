import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/firestore_collections.dart';
import '../../auth/presentation/providers/auth_provider.dart';

String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';

class AiService {
  final String? userId;
  late final GenerativeModel _model;
  ChatSession? _chat;

  AiService({this.userId}) {
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
        "4. Hình thức: Trả lời chủ yếu bằng tiếng Việt. Trình bày súc tích, chia ý rõ ràng (dùng gạch đầu dòng) để tối ưu trải nghiệm đọc trên thiết bị di động.",
      ),
    );
  }

  Future<void> initSession() async {
    if (_chat != null) return;

    List<Content> history = [];

    if (userId != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection(FirestoreCollections.users)
            .doc(userId)
            .collection('chatbot')
            .doc('history')
            .get();

        if (doc.exists) {
          final data = doc.data()!;
          final List<dynamic> historyData = data['messages'] ?? [];
          for (var item in historyData) {
            history.add(Content(item['role'], [TextPart(item['text'])]));
          }
        }
      } catch (e) {
        print('Lỗi parse history từ Firestore: $e');
      }
    }

    _chat = _model.startChat(history: history);
  }

  Future<void> _saveHistory() async {
    if (_chat == null || userId == null) return;
    final List<Map<String, dynamic>> historyToSave = [];

    for (var content in _chat!.history) {
      final text = content.parts
          .whereType<TextPart>()
          .map((p) => p.text)
          .join('\n');
      historyToSave.add({'role': content.role, 'text': text});
    }

    await FirebaseFirestore.instance
        .collection(FirestoreCollections.users)
        .doc(userId)
        .collection('chatbot')
        .doc('history')
        .set({'messages': historyToSave}, SetOptions(merge: true));
  }

  Future<String?> askTeacher(String prompt) async {
    if (_chat == null) {
      await initSession();
    }
    try {
      final response = await _chat!.sendMessage(Content.text(prompt));
      await _saveHistory();
      return response.text;
    } catch (e) {
      print('Lỗi khi gọi Gemini AI: $e');
      return 'Xin lỗi, giáo viên AI đang gặp chút sự cố kết nối. Hãy thử lại nhé! Lỗi: $e';
    }
  }

  Future<List<Map<String, dynamic>>> getHistoryForUI() async {
    await initSession();
    final uiMessages = <Map<String, dynamic>>[];
    for (var content in _chat!.history) {
      final text = content.parts
          .whereType<TextPart>()
          .map((p) => p.text)
          .join('\n');
      uiMessages.add({'isUser': content.role == 'user', 'text': text});
    }
    return uiMessages;
  }

  Future<void> clearHistory() async {
    if (userId != null) {
      try {
        await FirebaseFirestore.instance
            .collection(FirestoreCollections.users)
            .doc(userId)
            .collection('chatbot')
            .doc('history')
            .delete();
      } catch (e) {
        print('Lỗi xóa lịch sử từ Firestore: $e');
      }
    }
    _chat = _model.startChat();
  }
}

final aiServiceProvider = Provider<AiService>((ref) {
  final user = ref.watch(authStateProvider).value;
  return AiService(userId: user?.uid);
});
