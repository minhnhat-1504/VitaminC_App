import '../domain/models/pronunciation_topic.dart';
import '../domain/models/pronunciation_exercise.dart';

class MockPronunciationData {
  static const List<PronunciationTopic> topics = [
    PronunciationTopic(
      id: 'greetings',
      title: 'Giao tiếp hằng ngày',
      description: 'Các mẫu câu chào hỏi và hội thoại cơ bản nhất.',
      iconCodePoint: 0xe153, // Icons.chat_bubble
      colorValue: 0xFF3B82F6, // AppColors.primary
    ),
    PronunciationTopic(
      id: 'shopping',
      title: 'Mua sắm',
      description: 'Mặc cả, hỏi giá và các tình huống mua bán.',
      iconCodePoint: 0xe59c, // Icons.shopping_cart
      colorValue: 0xFF10B981, // AppColors.success
    ),
    PronunciationTopic(
      id: 'travel',
      title: 'Du lịch & Di chuyển',
      description: 'Hỏi đường, mua vé, và các tiện ích công cộng.',
      iconCodePoint: 0xe244, // Icons.flight_takeoff
      colorValue: 0xFFF59E0B, // AppColors.warning
    ),
    PronunciationTopic(
      id: 'restaurant',
      title: 'Nhà hàng & Ăn uống',
      description: 'Gọi món, tính tiền và đặt bàn.',
      iconCodePoint: 0xe532, // Icons.restaurant
      colorValue: 0xFFEF4444, // AppColors.error
    ),
  ];

  static const List<PronunciationExercise> exercises = [
    // --- Greetings ---
    PronunciationExercise(
      id: 'greet_1',
      topicId: 'greetings',
      phrase: 'Hello, how are you?',
      translation: 'Xin chào, bạn có khỏe không?',
      tip: 'Nhấn mạnh âm "h"',
    ),
    PronunciationExercise(
      id: 'greet_2',
      topicId: 'greetings',
      phrase: 'Nice to meet you.',
      translation: 'Rất vui được gặp bạn.',
      tip: 'Nối âm "t" và "y" thành âm /tʃ/',
    ),
    PronunciationExercise(
      id: 'greet_3',
      topicId: 'greetings',
      phrase: 'What is your name?',
      translation: 'Tên của bạn là gì?',
      tip: 'Lên giọng ở cuối câu nhẹ nhàng.',
    ),
    PronunciationExercise(
      id: 'greet_4',
      topicId: 'greetings',
      phrase: 'Have a good day!',
      translation: 'Chúc một ngày tốt lành!',
      tip: 'Phát âm rõ đuôi "d" trong từ "good".',
    ),

    // --- Shopping ---
    PronunciationExercise(
      id: 'shop_1',
      topicId: 'shopping',
      phrase: 'How much does it cost?',
      translation: 'Cái này giá bao nhiêu?',
      tip: 'Nhấn mạnh âm "ch" trong chữ "much".',
    ),
    PronunciationExercise(
      id: 'shop_2',
      topicId: 'shopping',
      phrase: 'Can I try it on?',
      translation: 'Tôi có thể mặc thử không?',
      tip: 'Nối âm "try" và "it".',
    ),
    PronunciationExercise(
      id: 'shop_3',
      topicId: 'shopping',
      phrase: 'Do you have this in a smaller size?',
      translation: 'Bạn có cái này size nhỏ hơn không?',
      tip: 'Lên giọng ở cuối câu hỏi.',
    ),
    PronunciationExercise(
      id: 'shop_4',
      topicId: 'shopping',
      phrase: 'I will take it.',
      translation: 'Tôi sẽ lấy cái này.',
      tip: 'Rút gọn "I will" thành "I\'ll" nếu đọc nhanh.',
    ),

    // --- Travel ---
    PronunciationExercise(
      id: 'travel_1',
      topicId: 'travel',
      phrase: 'Where is the nearest station?',
      translation: 'Ga gần nhất ở đâu?',
      tip: 'Chú ý phát âm từ "nearest".',
    ),
    PronunciationExercise(
      id: 'travel_2',
      topicId: 'travel',
      phrase: 'I need a ticket to New York.',
      translation: 'Tôi cần một vé đi New York.',
      tip: 'Nối âm "need" và "a".',
    ),
    PronunciationExercise(
      id: 'travel_3',
      topicId: 'travel',
      phrase: 'Can you show me on the map?',
      translation: 'Bạn có thể chỉ cho tôi trên bản đồ không?',
      tip: 'Lên giọng ở cuối câu hỏi.',
    ),

    // --- Restaurant ---
    PronunciationExercise(
      id: 'rest_1',
      topicId: 'restaurant',
      phrase: 'A table for two, please.',
      translation: 'Cho một bàn hai người.',
      tip: 'Ngắt nhịp nhẹ trước chữ "please".',
    ),
    PronunciationExercise(
      id: 'rest_2',
      topicId: 'restaurant',
      phrase: 'Can I see the menu?',
      translation: 'Cho tôi xem thực đơn được không?',
      tip: 'Lên giọng ở cuối câu.',
    ),
    PronunciationExercise(
      id: 'rest_3',
      topicId: 'restaurant',
      phrase: 'The check, please.',
      translation: 'Cho tôi hóa đơn.',
      tip: 'Nhấn mạnh âm "ch" trong "check".',
    ),
  ];
}
