import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();

  TtsService() {
    _initTts();
  }

  Future<void> _initTts() async {
    // Thiết lập ngôn ngữ mặc định trước
    await _flutterTts.setLanguage("en-US");
    
    // Tìm các giọng đọc có chất lượng cao (Network Voices thường nghe rất tự nhiên)
    try {
      List<dynamic>? voices = await _flutterTts.getVoices;
      if (voices != null) {
        List<Map<dynamic, dynamic>> usVoices = voices
            .cast<Map<dynamic, dynamic>>()
            .where((v) => v["locale"] == "en-US" || v["locale"] == "en_US")
            .toList();

        if (usVoices.isNotEmpty) {
          // Ưu tiên 1: Giọng network (Giọng AI đám mây của Google, cực kỳ tự nhiên)
          var bestVoice = usVoices.cast<Map<dynamic, dynamic>?>().firstWhere(
            (v) => v!["name"].toString().contains("network"),
            orElse: () => null,
          );

          // Ưu tiên 2: Các gói giọng chất lượng cao (thường có chữ smt hoặc female)
          bestVoice ??= usVoices.cast<Map<dynamic, dynamic>?>().firstWhere(
            (v) => v!["name"].toString().contains("sfg") || v["name"].toString().contains("female"),
            orElse: () => usVoices.first, // Fallback lấy cái đầu tiên
          );

          if (bestVoice != null) {
            await _flutterTts.setVoice({
              "name": bestVoice["name"],
              "locale": bestVoice["locale"]
            });
          }
        }
      }
    } catch (e) {
      print("Lỗi khi chọn voice: $e");
    }

    // Tinh chỉnh một chút thông số để giọng bớt bị "robot" và "nghẹt"
    await _flutterTts.setSpeechRate(0.45); // Chậm lại một chút xíu để nghe rõ âm tiết
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.05); // Tăng pitch lên 1 tí xíu cho giọng sáng hơn
  }

  Future<void> speak(String text) async {
    if (text.isNotEmpty) {
      await _flutterTts.speak(text);
    }
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }
}

final ttsServiceProvider = Provider<TtsService>((ref) {
  return TtsService();
});
