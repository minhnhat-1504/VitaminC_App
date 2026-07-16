# VitaminC - Ứng dụng học tiếng Anh thông minh tích hợp thuật toán SRS và AI Chatbot

VitaminC là ứng dụng hỗ trợ học tiếng Anh hiệu quả dành cho thiết bị Android, được thiết kế giúp người dùng ghi nhớ từ vựng lâu dài thông qua phương pháp lặp ngắt quãng và cải thiện phản xạ giao tiếp bằng chatbot trí tuệ nhân tạo.

## 1. Các tính năng chính

### Hệ thống học tập qua thẻ ghi nhớ (Flashcard)
- Áp dụng thuật toán lặp ngắt quãng SM-2 để tối ưu hóa tần suất ôn tập từ vựng dựa trên khả năng ghi nhớ của từng người dùng.
- Hỗ trợ các chế độ học tập và đánh giá mức độ thuộc từ bao gồm Khó, Tốt và Dễ.
- Hiệu ứng lật thẻ flashcard ba chiều trực quan giúp tăng tính tương tác.

### Tiện ích thông minh hỗ trợ học tập
- Chatbot giáo viên tiếng Anh được tích hợp công nghệ Google Gemini AI hỗ trợ giải đáp thắc mắc, dịch thuật và cung cấp ví dụ thực tế theo ngữ cảnh.
- Nhận diện ký tự quang học (OCR) cho phép người dùng quét văn bản từ camera hoặc hình ảnh để thêm nhanh từ vựng mới vào kho lưu trữ cá nhân.
- Tích hợp công nghệ chuyển văn bản thành giọng nói (Text-to-Speech) giúp nghe phát âm chuẩn của từ vựng.
- Kiểm tra và đánh giá phát âm thông qua công nghệ nhận diện giọng nói (Speech-to-Text) kết hợp thuật toán khoảng cách Levenshtein để đo lường độ chính xác theo tỷ lệ phần trăm.

### Tính năng thi đua và kết nối xã hội (Gamification)
- Phòng chat nhóm hỗ trợ đa phòng học (Multi-room Chat) khuyến khích giao tiếp bằng tiếng Anh. Hệ thống tự động phát hiện và cảnh báo khi người dùng nhập tiếng Việt để giữ môi trường giao tiếp hoàn toàn bằng tiếng Anh.
- Bảng xếp hạng học tập thời gian thực hiển thị danh sách người dùng có điểm kinh nghiệm (XP) cao nhất.
- Hệ thống nhiệm vụ cá nhân hằng ngày và nhiệm vụ đồng đội tuần để kích thích tinh thần tự học.
- Vòng quay may mắn hằng ngày giúp nhận thêm điểm thưởng kinh nghiệm sau khi hoàn thành số lượng thẻ quy định.
- Theo dõi chuỗi ngày học liên tục (Streak) và tặng huy hiệu thành tích để duy trì thói quen học tập.

### Hoạt động ngoại tuyến và đồng bộ dữ liệu (Offline-First)
- Lưu trữ dữ liệu cục bộ thông qua Isar Database, cho phép người dùng học tập và ôn thẻ ngay cả khi không có kết nối Internet.
- Tự động đẩy dữ liệu và đồng bộ hóa tiến độ lên Firebase Cloud Firestore ngay khi thiết bị kết nối mạng trở lại.

---

## 2. Công nghệ sử dụng

- Ngôn ngữ lập trình: Dart
- Framework phát triển: Flutter
- Quản lý trạng thái ứng dụng: Riverpod
- Quản lý điều hướng màn hình: GoRouter
- Cơ sở dữ liệu và xác thực người dùng: Firebase (Authentication, Cloud Firestore, Cloud Storage, Cloud Messaging)
- Cơ sở dữ liệu cục bộ: Isar Database
- Trí tuệ nhân tạo: Google Generative AI (Gemini 1.5 Flash)
- Thư viện xử lý hình ảnh và giọng nói: Google ML Kit Text Recognition, Speech-to-Text, Flutter TTS

---

## 3. Hướng dẫn cài đặt và cấu hình

### Yêu cầu hệ thống
- Flutter SDK từ phiên bản 3.10 trở lên.
- Java Development Kit (JDK) phiên bản 17.
- Thiết bị chạy hệ điều hành Android phiên bản 5.0 (API 21) trở lên.

### Các bước cài đặt

1. Tải mã nguồn dự án về máy:
   ```bash
   git clone https://github.com/minhnhat-1504/VitaminC_App.git
   cd vitaminc
   ```

2. Cài đặt các gói thư viện phụ thuộc:
   ```bash
   flutter pub get
   ```

3. Cấu hình Firebase cho Android:
   - Truy cập vào trang quản trị Firebase Console và tạo dự án mới.
   - Thêm ứng dụng Android vào dự án với mã gói (Package Name) trùng khớp với mã khai báo trong file `android/app/build.gradle`.
   - Cung cấp mã SHA-1 của thiết bị chạy thử nghiệm để hỗ trợ tính năng đăng nhập Google Sign-In.
   - Tải file cấu hình `google-services.json` từ Firebase và sao chép vào thư mục `android/app/`.
   - Bật tính năng Multidex trong file cấu hình gradle của ứng dụng bằng cách thêm dòng `multiDexEnabled true` vào mục `defaultConfig`.

4. Cấu hình khóa API cho Gemini AI:
   - Đăng ký và nhận API Key từ Google AI Studio.
   - Tạo file `.env` tại thư mục gốc của dự án và khai báo biến môi trường:
     ```text
     GEMINI_API_KEY=khóa_api_của_bạn
     ```

---

## 4. Hướng dẫn chạy dự án

Kết nối thiết bị thử nghiệm Android hoặc khởi chạy trình giả lập, sau đó thực hiện lệnh:
```bash
flutter run
```

Để định dạng và chuẩn hóa mã nguồn trước khi commit, chạy lệnh:
```bash
dart format .
```
