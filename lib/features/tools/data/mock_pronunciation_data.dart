import '../domain/models/pronunciation_topic.dart';
import '../domain/models/pronunciation_exercise.dart';

class MockPronunciationData {
  static const List<PronunciationTopic> topics = [
    PronunciationTopic(
      id: 'greetings',
      title: 'Giao tiếp cơ bản',
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
    PronunciationTopic(
      id: 'work',
      title: 'Công việc & Văn phòng',
      description: 'Giao tiếp tại nơi làm việc và đồng nghiệp.',
      iconCodePoint: 0xe8f9, // Icons.work
      colorValue: 0xFF6366F1, // Indigo
    ),
    PronunciationTopic(
      id: 'hobbies',
      title: 'Sở thích & Thể thao',
      description: 'Nói về những gì bạn yêu thích.',
      iconCodePoint: 0xea3c, // Icons.sports_soccer
      colorValue: 0xFF8B5CF6, // Purple
    ),
    PronunciationTopic(
      id: 'health',
      title: 'Sức khỏe & Bệnh viện',
      description: 'Trao đổi tình trạng sức khỏe với bác sĩ.',
      iconCodePoint: 0xe873, // Icons.favorite
      colorValue: 0xFFEC4899, // Pink
    ),
    PronunciationTopic(
      id: 'education',
      title: 'Giáo dục & Trường học',
      description: 'Trao đổi về việc học, lớp học và môn học.',
      iconCodePoint: 0xe80c, // Icons.school
      colorValue: 0xFF14B8A6, // Teal
    ),
    PronunciationTopic(
      id: 'family',
      title: 'Gia đình & Bạn bè',
      description: 'Giới thiệu về người thân và bạn bè.',
      iconCodePoint: 0xe1af, // Icons.family_restroom
      colorValue: 0xFFF97316, // Orange
    ),
    PronunciationTopic(
      id: 'hotel',
      title: 'Khách sạn & Chỗ ở',
      description: 'Đặt phòng, nhận phòng và trả phòng.',
      iconCodePoint: 0xe53a, // Icons.hotel
      colorValue: 0xFF06B6D4, // Cyan
    ),
  ];

  static const List<PronunciationExercise> exercises = [
    // --- 1. Greetings (10 câu) ---
    PronunciationExercise(
      id: 'g_1',
      topicId: 'greetings',
      phrase: 'Hello, how are you?',
      translation: 'Xin chào, bạn có khỏe không?',
      tip: 'Nhấn mạnh âm "h"',
    ),
    PronunciationExercise(
      id: 'g_2',
      topicId: 'greetings',
      phrase: 'Nice to meet you.',
      translation: 'Rất vui được gặp bạn.',
      tip: 'Nối âm "t" và "y" thành âm /tʃ/',
    ),
    PronunciationExercise(
      id: 'g_3',
      topicId: 'greetings',
      phrase: 'What is your name?',
      translation: 'Tên của bạn là gì?',
      tip: 'Lên giọng ở cuối câu nhẹ nhàng.',
    ),
    PronunciationExercise(
      id: 'g_4',
      topicId: 'greetings',
      phrase: 'Have a good day!',
      translation: 'Chúc một ngày tốt lành!',
      tip: 'Phát âm rõ đuôi "d" trong từ "good".',
    ),
    PronunciationExercise(
      id: 'g_5',
      topicId: 'greetings',
      phrase: 'How have you been?',
      translation: 'Dạo này bạn thế nào?',
      tip: 'Nhấn mạnh vào "been"',
    ),
    PronunciationExercise(
      id: 'g_6',
      topicId: 'greetings',
      phrase: 'Long time no see.',
      translation: 'Lâu rồi không gặp.',
      tip: 'Phát âm dài âm "ee" trong "see"',
    ),
    PronunciationExercise(
      id: 'g_7',
      topicId: 'greetings',
      phrase: 'It is a pleasure to meet you.',
      translation: 'Thật hân hạnh được gặp bạn.',
      tip: 'Âm "s" trong "pleasure" đọc là /ʒ/',
    ),
    PronunciationExercise(
      id: 'g_8',
      topicId: 'greetings',
      phrase: 'How is everything going?',
      translation: 'Mọi chuyện thế nào rồi?',
      tip: 'Lên giọng nhẹ ở cuối câu',
    ),
    PronunciationExercise(
      id: 'g_9',
      topicId: 'greetings',
      phrase: 'I am doing great, thank you.',
      translation: 'Tôi đang rất ổn, cảm ơn bạn.',
      tip: 'Đừng quên âm "th" trong "thank"',
    ),
    PronunciationExercise(
      id: 'g_10',
      topicId: 'greetings',
      phrase: 'See you later.',
      translation: 'Hẹn gặp lại sau.',
      tip: 'Âm "t" trong "later" có thể đọc thành âm /d/ nhẹ ở giọng Mỹ',
    ),

    // --- 2. Shopping (10 câu) ---
    PronunciationExercise(
      id: 's_1',
      topicId: 'shopping',
      phrase: 'How much does it cost?',
      translation: 'Cái này giá bao nhiêu?',
      tip: 'Nhấn mạnh âm "ch" trong chữ "much".',
    ),
    PronunciationExercise(
      id: 's_2',
      topicId: 'shopping',
      phrase: 'Can I try it on?',
      translation: 'Tôi có thể mặc thử không?',
      tip: 'Nối âm "try" và "it".',
    ),
    PronunciationExercise(
      id: 's_3',
      topicId: 'shopping',
      phrase: 'Do you have this in a smaller size?',
      translation: 'Bạn có cái này size nhỏ hơn không?',
      tip: 'Lên giọng ở cuối câu hỏi.',
    ),
    PronunciationExercise(
      id: 's_4',
      topicId: 'shopping',
      phrase: 'I will take it.',
      translation: 'Tôi sẽ lấy cái này.',
      tip: 'Rút gọn "I will" thành "I\'ll" nếu đọc nhanh.',
    ),
    PronunciationExercise(
      id: 's_5',
      topicId: 'shopping',
      phrase: 'Where is the fitting room?',
      translation: 'Phòng thử đồ ở đâu?',
      tip: 'Nhấn mạnh từ "fitting"',
    ),
    PronunciationExercise(
      id: 's_6',
      topicId: 'shopping',
      phrase: 'Is this on sale?',
      translation: 'Cái này có đang giảm giá không?',
      tip: 'Lên giọng ở cuối câu hỏi.',
    ),
    PronunciationExercise(
      id: 's_7',
      topicId: 'shopping',
      phrase: 'I am just looking around.',
      translation: 'Tôi chỉ đang xem thôi.',
      tip: 'Nối âm "looking" và "around"',
    ),
    PronunciationExercise(
      id: 's_8',
      topicId: 'shopping',
      phrase: 'Can I pay by credit card?',
      translation: 'Tôi có thể trả bằng thẻ tín dụng không?',
      tip: 'Lên giọng ở từ "card"',
    ),
    PronunciationExercise(
      id: 's_9',
      topicId: 'shopping',
      phrase: 'Do you offer a refund?',
      translation: 'Bạn có cho phép hoàn tiền không?',
      tip: 'Nhấn mạnh từ "refund"',
    ),
    PronunciationExercise(
      id: 's_10',
      topicId: 'shopping',
      phrase: 'It is too expensive.',
      translation: 'Nó quá đắt.',
      tip: 'Phát âm rõ âm "x" và "sive" trong "expensive"',
    ),

    // --- 3. Travel (10 câu) ---
    PronunciationExercise(
      id: 't_1',
      topicId: 'travel',
      phrase: 'Where is the nearest station?',
      translation: 'Ga gần nhất ở đâu?',
      tip: 'Chú ý phát âm từ "nearest".',
    ),
    PronunciationExercise(
      id: 't_2',
      topicId: 'travel',
      phrase: 'I need a ticket to New York.',
      translation: 'Tôi cần một vé đi New York.',
      tip: 'Nối âm "need" và "a".',
    ),
    PronunciationExercise(
      id: 't_3',
      topicId: 'travel',
      phrase: 'Can you show me on the map?',
      translation: 'Bạn có thể chỉ cho tôi trên bản đồ không?',
      tip: 'Lên giọng ở cuối câu hỏi.',
    ),
    PronunciationExercise(
      id: 't_4',
      topicId: 'travel',
      phrase: 'How far is the airport?',
      translation: 'Sân bay cách đây bao xa?',
      tip: 'Ngắt giọng nhẹ trước từ "airport".',
    ),
    PronunciationExercise(
      id: 't_5',
      topicId: 'travel',
      phrase: 'Which platform does the train leave from?',
      translation: 'Tàu khởi hành từ sân ga nào?',
      tip: 'Nhấn mạnh từ "platform" và "leave".',
    ),
    PronunciationExercise(
      id: 't_6',
      topicId: 'travel',
      phrase: 'I would like to rent a car.',
      translation: 'Tôi muốn thuê một chiếc xe hơi.',
      tip: 'Nối âm "rent" và "a"',
    ),
    PronunciationExercise(
      id: 't_7',
      topicId: 'travel',
      phrase: 'Does this bus go to the city center?',
      translation: 'Xe buýt này có đi đến trung tâm thành phố không?',
      tip: 'Lên giọng ở cuối câu hỏi.',
    ),
    PronunciationExercise(
      id: 't_8',
      topicId: 'travel',
      phrase: 'How much is the fare?',
      translation: 'Giá vé là bao nhiêu?',
      tip: 'Âm "r" trong "fare" cần đọc rõ',
    ),
    PronunciationExercise(
      id: 't_9',
      topicId: 'travel',
      phrase: 'I am lost.',
      translation: 'Tôi bị lạc đường.',
      tip: 'Phát âm rõ âm "st" trong "lost"',
    ),
    PronunciationExercise(
      id: 't_10',
      topicId: 'travel',
      phrase: 'Please take me to this address.',
      translation: 'Làm ơn đưa tôi đến địa chỉ này.',
      tip: 'Nhấn mạnh từ "address"',
    ),

    // --- 4. Restaurant (10 câu) ---
    PronunciationExercise(
      id: 'r_1',
      topicId: 'restaurant',
      phrase: 'A table for two, please.',
      translation: 'Cho một bàn hai người.',
      tip: 'Ngắt nhịp nhẹ trước chữ "please".',
    ),
    PronunciationExercise(
      id: 'r_2',
      topicId: 'restaurant',
      phrase: 'Can I see the menu?',
      translation: 'Cho tôi xem thực đơn được không?',
      tip: 'Lên giọng ở cuối câu.',
    ),
    PronunciationExercise(
      id: 'r_3',
      topicId: 'restaurant',
      phrase: 'The check, please.',
      translation: 'Cho tôi hóa đơn.',
      tip: 'Nhấn mạnh âm "ch" trong "check".',
    ),
    PronunciationExercise(
      id: 'r_4',
      topicId: 'restaurant',
      phrase: 'What do you recommend?',
      translation: 'Bạn có gợi ý món nào không?',
      tip: 'Nhấn mạnh từ "recommend"',
    ),
    PronunciationExercise(
      id: 'r_5',
      topicId: 'restaurant',
      phrase: 'I am allergic to peanuts.',
      translation: 'Tôi bị dị ứng với đậu phộng.',
      tip: 'Phát âm rõ từ "allergic"',
    ),
    PronunciationExercise(
      id: 'r_6',
      topicId: 'restaurant',
      phrase: 'I would like to order now.',
      translation: 'Tôi muốn gọi món bây giờ.',
      tip: 'Nối âm "would" và "like"',
    ),
    PronunciationExercise(
      id: 'r_7',
      topicId: 'restaurant',
      phrase: 'Is this dish spicy?',
      translation: 'Món này có cay không?',
      tip: 'Lên giọng ở cuối câu hỏi.',
    ),
    PronunciationExercise(
      id: 'r_8',
      topicId: 'restaurant',
      phrase: 'Can I have a glass of water?',
      translation: 'Cho tôi một ly nước được không?',
      tip: 'Nối âm "glass" và "of"',
    ),
    PronunciationExercise(
      id: 'r_9',
      topicId: 'restaurant',
      phrase: 'The food was delicious.',
      translation: 'Đồ ăn rất ngon.',
      tip: 'Trọng âm rơi vào âm tiết thứ hai của từ "delicious"',
    ),
    PronunciationExercise(
      id: 'r_10',
      topicId: 'restaurant',
      phrase: 'Keep the change.',
      translation: 'Bạn cứ giữ lại tiền thừa.',
      tip: 'Nhấn mạnh từ "change"',
    ),

    // --- 5. Work (10 câu) ---
    PronunciationExercise(
      id: 'w_1',
      topicId: 'work',
      phrase: 'What do you do for a living?',
      translation: 'Bạn làm nghề gì?',
      tip: 'Nối âm "do" và "you" thành /dʒu/ khi đọc nhanh',
    ),
    PronunciationExercise(
      id: 'w_2',
      topicId: 'work',
      phrase: 'I work in marketing.',
      translation: 'Tôi làm trong ngành tiếp thị.',
      tip: 'Nhấn mạnh âm đầu của "marketing"',
    ),
    PronunciationExercise(
      id: 'w_3',
      topicId: 'work',
      phrase: 'We have a meeting at ten.',
      translation: 'Chúng ta có cuộc họp lúc 10 giờ.',
      tip: 'Nối âm "meeting" và "at"',
    ),
    PronunciationExercise(
      id: 'w_4',
      topicId: 'work',
      phrase: 'Could you send me the report?',
      translation: 'Bạn có thể gửi báo cáo cho tôi không?',
      tip: 'Lên giọng ở cuối câu hỏi',
    ),
    PronunciationExercise(
      id: 'w_5',
      topicId: 'work',
      phrase: 'I will be out of the office tomorrow.',
      translation: 'Ngày mai tôi sẽ không có ở văn phòng.',
      tip: 'Nối âm "out", "of" và "the"',
    ),
    PronunciationExercise(
      id: 'w_6',
      topicId: 'work',
      phrase: 'Can we reschedule our meeting?',
      translation: 'Chúng ta có thể dời lịch họp không?',
      tip: 'Nhấn mạnh từ "reschedule"',
    ),
    PronunciationExercise(
      id: 'w_7',
      topicId: 'work',
      phrase: 'Good job on the presentation.',
      translation: 'Bạn thuyết trình rất tốt.',
      tip: 'Phát âm rõ âm "j" trong "job"',
    ),
    PronunciationExercise(
      id: 'w_8',
      topicId: 'work',
      phrase: 'Let us discuss this further.',
      translation: 'Hãy thảo luận thêm về điều này.',
      tip: 'Âm "th" trong "further" và "this" đọc là /ð/',
    ),
    PronunciationExercise(
      id: 'w_9',
      topicId: 'work',
      phrase: 'When is the deadline?',
      translation: 'Hạn chót là khi nào?',
      tip: 'Nhấn mạnh âm đầu của "deadline"',
    ),
    PronunciationExercise(
      id: 'w_10',
      topicId: 'work',
      phrase: 'I am looking for a new job.',
      translation: 'Tôi đang tìm việc mới.',
      tip: 'Phát âm rõ âm "k" trong "looking"',
    ),

    // --- 6. Hobbies (10 câu) ---
    PronunciationExercise(
      id: 'h_1',
      topicId: 'hobbies',
      phrase: 'What do you do in your free time?',
      translation: 'Bạn làm gì vào thời gian rảnh?',
      tip: 'Nhấn mạnh "free time"',
    ),
    PronunciationExercise(
      id: 'h_2',
      topicId: 'hobbies',
      phrase: 'I enjoy reading books.',
      translation: 'Tôi thích đọc sách.',
      tip: 'Đừng quên âm "s" ở cuối "books"',
    ),
    PronunciationExercise(
      id: 'h_3',
      topicId: 'hobbies',
      phrase: 'Do you play any sports?',
      translation: 'Bạn có chơi môn thể thao nào không?',
      tip: 'Lên giọng ở cuối câu',
    ),
    PronunciationExercise(
      id: 'h_4',
      topicId: 'hobbies',
      phrase: 'I am a big fan of football.',
      translation: 'Tôi là một fan hâm mộ bóng đá.',
      tip: 'Nối âm "fan" và "of"',
    ),
    PronunciationExercise(
      id: 'h_5',
      topicId: 'hobbies',
      phrase: 'I like listening to music.',
      translation: 'Tôi thích nghe nhạc.',
      tip: 'Đọc âm "s" trong "listening" một cách nhẹ nhàng',
    ),
    PronunciationExercise(
      id: 'h_6',
      topicId: 'hobbies',
      phrase: 'Have you seen any good movies lately?',
      translation: 'Gần đây bạn có xem bộ phim nào hay không?',
      tip: 'Lên giọng ở cuối câu hỏi',
    ),
    PronunciationExercise(
      id: 'h_7',
      topicId: 'hobbies',
      phrase: 'I love traveling and exploring.',
      translation: 'Tôi yêu thích du lịch và khám phá.',
      tip: 'Phát âm đuôi "ing" rõ ràng',
    ),
    PronunciationExercise(
      id: 'h_8',
      topicId: 'hobbies',
      phrase: 'Photography is my passion.',
      translation: 'Nhiếp ảnh là đam mê của tôi.',
      tip: 'Trọng âm rơi vào âm tiết thứ hai của "Photography"',
    ),
    PronunciationExercise(
      id: 'h_9',
      topicId: 'hobbies',
      phrase: 'I go to the gym every day.',
      translation: 'Tôi đi tập gym mỗi ngày.',
      tip: 'Âm "g" trong "gym" đọc là /dʒ/',
    ),
    PronunciationExercise(
      id: 'h_10',
      topicId: 'hobbies',
      phrase: 'Are you interested in art?',
      translation: 'Bạn có hứng thú với nghệ thuật không?',
      tip: 'Nối âm "interested" và "in"',
    ),

    // --- 7. Health (10 câu) ---
    PronunciationExercise(
      id: 'm_1',
      topicId: 'health',
      phrase: 'I do not feel very well.',
      translation: 'Tôi cảm thấy không được khỏe.',
      tip: 'Nhấn mạnh từ "well"',
    ),
    PronunciationExercise(
      id: 'm_2',
      topicId: 'health',
      phrase: 'I have a headache.',
      translation: 'Tôi bị đau đầu.',
      tip: 'Nối âm "have" và "a"',
    ),
    PronunciationExercise(
      id: 'm_3',
      topicId: 'health',
      phrase: 'I need to see a doctor.',
      translation: 'Tôi cần đi khám bác sĩ.',
      tip: 'Ngắt nhịp nhẹ sau "doctor"',
    ),
    PronunciationExercise(
      id: 'm_4',
      topicId: 'health',
      phrase: 'My throat is sore.',
      translation: 'Cổ họng tôi bị đau.',
      tip: 'Âm "th" trong "throat" đọc là /θ/',
    ),
    PronunciationExercise(
      id: 'm_5',
      topicId: 'health',
      phrase: 'Do you have a fever?',
      translation: 'Bạn có bị sốt không?',
      tip: 'Lên giọng ở cuối câu hỏi',
    ),
    PronunciationExercise(
      id: 'm_6',
      topicId: 'health',
      phrase: 'I caught a cold.',
      translation: 'Tôi bị cảm lạnh.',
      tip: 'Phát âm rõ âm "d" trong "cold"',
    ),
    PronunciationExercise(
      id: 'm_7',
      topicId: 'health',
      phrase: 'Take this medicine twice a day.',
      translation: 'Uống thuốc này hai lần một ngày.',
      tip: 'Nhấn mạnh "twice a day"',
    ),
    PronunciationExercise(
      id: 'm_8',
      topicId: 'health',
      phrase: 'I am allergic to aspirin.',
      translation: 'Tôi bị dị ứng với aspirin.',
      tip: 'Trọng âm rơi vào âm tiết đầu của "aspirin"',
    ),
    PronunciationExercise(
      id: 'm_9',
      topicId: 'health',
      phrase: 'Drink plenty of water.',
      translation: 'Hãy uống nhiều nước.',
      tip: 'Nối âm "plenty" và "of"',
    ),
    PronunciationExercise(
      id: 'm_10',
      topicId: 'health',
      phrase: 'I hope you feel better soon.',
      translation: 'Mong bạn sớm khỏe lại.',
      tip: 'Âm "tt" trong "better" có thể đọc thành âm /d/ ở giọng Mỹ',
    ),

    // --- 8. Education (10 câu) ---
    PronunciationExercise(
      id: 'e_1',
      topicId: 'education',
      phrase: 'What is your major?',
      translation: 'Chuyên ngành của bạn là gì?',
      tip: 'Âm "j" trong "major" đọc là /dʒ/',
    ),
    PronunciationExercise(
      id: 'e_2',
      topicId: 'education',
      phrase: 'I am studying computer science.',
      translation: 'Tôi đang học khoa học máy tính.',
      tip: 'Nhấn mạnh từ "computer" và "science"',
    ),
    PronunciationExercise(
      id: 'e_3',
      topicId: 'education',
      phrase: 'When is the exam?',
      translation: 'Khi nào thi?',
      tip: 'Lên giọng ở cuối câu hỏi',
    ),
    PronunciationExercise(
      id: 'e_4',
      topicId: 'education',
      phrase: 'I need to go to the library.',
      translation: 'Tôi cần đến thư viện.',
      tip: 'Âm "r" trong "library" cần đọc rõ',
    ),
    PronunciationExercise(
      id: 'e_5',
      topicId: 'education',
      phrase: 'Did you finish the assignment?',
      translation: 'Bạn đã hoàn thành bài tập chưa?',
      tip: 'Lên giọng ở cuối câu hỏi',
    ),
    PronunciationExercise(
      id: 'e_6',
      topicId: 'education',
      phrase: 'The lecture was very interesting.',
      translation: 'Bài giảng rất thú vị.',
      tip: 'Âm "t" trong "lecture" đọc là /tʃ/',
    ),
    PronunciationExercise(
      id: 'e_7',
      topicId: 'education',
      phrase: 'Can you help me with this problem?',
      translation: 'Bạn có thể giúp tôi giải bài toán này không?',
      tip: 'Lên giọng ở cuối câu hỏi',
    ),
    PronunciationExercise(
      id: 'e_8',
      topicId: 'education',
      phrase: 'I got a good grade.',
      translation: 'Tôi đạt điểm cao.',
      tip: 'Nối âm "got" và "a"',
    ),
    PronunciationExercise(
      id: 'e_9',
      topicId: 'education',
      phrase: 'We have a group project.',
      translation: 'Chúng tôi có một bài tập nhóm.',
      tip: 'Phát âm rõ âm "p" trong "project"',
    ),
    PronunciationExercise(
      id: 'e_10',
      topicId: 'education',
      phrase: 'Graduation is next month.',
      translation: 'Tháng sau là lễ tốt nghiệp.',
      tip: 'Âm "d" trong "Graduation" đọc là /dʒ/',
    ),

    // --- 9. Family (10 câu) ---
    PronunciationExercise(
      id: 'f_1',
      topicId: 'family',
      phrase: 'How many people are there in your family?',
      translation: 'Gia đình bạn có bao nhiêu người?',
      tip: 'Nhấn mạnh "how many"',
    ),
    PronunciationExercise(
      id: 'f_2',
      topicId: 'family',
      phrase: 'I have one brother and one sister.',
      translation: 'Tôi có một anh trai và một chị gái.',
      tip: 'Âm "th" trong "brother" đọc là /ð/',
    ),
    PronunciationExercise(
      id: 'f_3',
      topicId: 'family',
      phrase: 'Do you live with your parents?',
      translation: 'Bạn có sống cùng bố mẹ không?',
      tip: 'Lên giọng ở cuối câu hỏi',
    ),
    PronunciationExercise(
      id: 'f_4',
      topicId: 'family',
      phrase: 'My mother is a teacher.',
      translation: 'Mẹ tôi là giáo viên.',
      tip: 'Âm "th" trong "mother" đọc là /ð/',
    ),
    PronunciationExercise(
      id: 'f_5',
      topicId: 'family',
      phrase: 'I am married and have two kids.',
      translation: 'Tôi đã kết hôn và có hai con.',
      tip: 'Đừng quên âm "s" ở cuối "kids"',
    ),
    PronunciationExercise(
      id: 'f_6',
      topicId: 'family',
      phrase: 'Are you the oldest child?',
      translation: 'Bạn có phải là con cả không?',
      tip: 'Lên giọng ở cuối câu hỏi',
    ),
    PronunciationExercise(
      id: 'f_7',
      topicId: 'family',
      phrase: 'We are very close.',
      translation: 'Chúng tôi rất thân thiết.',
      tip: 'Âm "s" trong "close" đọc là /s/, không phải /z/',
    ),
    PronunciationExercise(
      id: 'f_8',
      topicId: 'family',
      phrase: 'My grandparents live in the countryside.',
      translation: 'Ông bà tôi sống ở nông thôn.',
      tip: 'Đọc âm "s" trong "grandparents" một cách nhẹ nhàng',
    ),
    PronunciationExercise(
      id: 'f_9',
      topicId: 'family',
      phrase: 'Do you have any pets?',
      translation: 'Bạn có nuôi thú cưng không?',
      tip: 'Lên giọng ở cuối câu hỏi',
    ),
    PronunciationExercise(
      id: 'f_10',
      topicId: 'family',
      phrase: 'Family is the most important thing.',
      translation: 'Gia đình là điều quan trọng nhất.',
      tip: 'Âm "th" trong "thing" đọc là /θ/',
    ),

    // --- 10. Hotel (10 câu) ---
    PronunciationExercise(
      id: 'ho_1',
      topicId: 'hotel',
      phrase: 'I have a reservation.',
      translation: 'Tôi đã đặt phòng trước.',
      tip: 'Âm "s" trong "reservation" đọc là /z/',
    ),
    PronunciationExercise(
      id: 'ho_2',
      topicId: 'hotel',
      phrase: 'I would like to check in.',
      translation: 'Tôi muốn nhận phòng.',
      tip: 'Nối âm "check" và "in"',
    ),
    PronunciationExercise(
      id: 'ho_3',
      topicId: 'hotel',
      phrase: 'Can someone help me with my luggage?',
      translation: 'Có ai đó giúp tôi mang hành lý được không?',
      tip: 'Lên giọng ở cuối câu hỏi',
    ),
    PronunciationExercise(
      id: 'ho_4',
      topicId: 'hotel',
      phrase: 'What time is breakfast served?',
      translation: 'Bữa sáng được phục vụ lúc mấy giờ?',
      tip: 'Nhấn mạnh từ "breakfast"',
    ),
    PronunciationExercise(
      id: 'ho_5',
      topicId: 'hotel',
      phrase: 'Is there free Wi-Fi in the room?',
      translation: 'Trong phòng có Wi-Fi miễn phí không?',
      tip: 'Lên giọng ở cuối câu hỏi',
    ),
    PronunciationExercise(
      id: 'ho_6',
      topicId: 'hotel',
      phrase: 'The air conditioning is not working.',
      translation: 'Máy lạnh không hoạt động.',
      tip: 'Nhấn mạnh từ "conditioning"',
    ),
    PronunciationExercise(
      id: 'ho_7',
      topicId: 'hotel',
      phrase: 'Can I have some extra towels?',
      translation: 'Cho tôi thêm vài chiếc khăn tắm được không?',
      tip: 'Lên giọng ở cuối câu hỏi',
    ),
    PronunciationExercise(
      id: 'ho_8',
      topicId: 'hotel',
      phrase: 'What time is check out?',
      translation: 'Giờ trả phòng là mấy giờ?',
      tip: 'Nối âm "check" và "out"',
    ),
    PronunciationExercise(
      id: 'ho_9',
      topicId: 'hotel',
      phrase: 'I would like a wake-up call at seven.',
      translation: 'Tôi muốn được gọi báo thức lúc 7 giờ.',
      tip: 'Nhấn mạnh "wake-up call"',
    ),
    PronunciationExercise(
      id: 'ho_10',
      topicId: 'hotel',
      phrase: 'Can you call a taxi for me?',
      translation: 'Bạn có thể gọi giúp tôi một chiếc taxi không?',
      tip: 'Lên giọng ở cuối câu hỏi',
    ),
  ];
}
