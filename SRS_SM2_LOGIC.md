# TÀI LIỆU KỸ THUẬT: THUẬT TOÁN SM-2 (SPACED REPETITION SYSTEM) TRONG VITAMINC

Tài liệu này giải thích chi tiết về luồng hoạt động, công thức toán học và cách thức lưu trữ dữ liệu của hệ thống Lặp ngắt quãng (SRS) - cốt lõi của tính năng học Flashcard trong ứng dụng VitaminC.

---

## 1. Cấu trúc dữ liệu trên Firebase (Cloud Firestore)

Để thuật toán có thể hoạt động theo thời gian thực (real-time) và đồng bộ giữa các thiết bị, mỗi từ vựng (`VocabModel`) được lưu trong Sub-collection `users/{uid}/vocabs/` sẽ chứa 4 trường dữ liệu (fields) bắt buộc sau đây:

*   **`repetition` (Số nguyên):** Số lần người dùng đã trả lời ĐÚNG liên tiếp từ vựng này. (Mặc định: 0).
*   **`interval` (Số nguyên):** Số ngày chờ cho đến lần ôn tập tiếp theo. (Mặc định: 0).
*   **`easinessFactor` (Số thập phân - EF):** Hệ số độ khó của từ vựng. Giá trị càng thấp, từ càng khó. (Mặc định: 2.5 - Mức trung bình).
*   **`nextReview` (Timestamp):** Mốc thời gian chính xác (Ngày, Giờ, Phút, Giây) mà hệ thống sẽ yêu cầu người dùng ôn lại từ này.

---

## 2. Logic & Công thức Thuật toán SM-2

Khi người dùng đang học Flashcard, sau khi xem nghĩa của từ, họ sẽ tự đánh giá mức độ ghi nhớ qua 3 nút bấm (Tương đương với chỉ số **Chất lượng - Quality** trong SM-2):

*   🔴 **Hard (Khó):** Quality = 1 (Gần như quên sạch, phải nhìn đáp án mới nhớ).
*   🟡 **Good (Khá):** Quality = 3 (Nhớ được nhưng mất nhiều thời gian suy nghĩ).
*   🟢 **Easy (Dễ):** Quality = 5 (Nhớ ra ngay lập tức, cực kỳ dễ).

### Bước 1: Xử lý Repetition (Số chu kỳ lặp)
*   Nếu `Quality < 3` (Bấm nút Hard): Trí nhớ đã bị đứt gãy. `repetition` bị reset về **0**.
*   Nếu `Quality >= 3` (Bấm Good hoặc Easy): Trí nhớ được củng cố. `repetition` được cộng thêm **1**.

### Bước 2: Tính toán Interval (Khoảng cách ngày ôn tập)
Dựa vào `repetition` vừa tính ở Bước 1, hệ thống tính ra khoảng cách ngày chờ (`interval`):
*   Nếu `repetition == 0`: Trả về `interval = 0` (Phải ôn lại ngay trong hôm nay hoặc ngày mai).
*   Nếu `repetition == 1`: Trả về `interval = 1` (Ôn lại sau 1 ngày).
*   Nếu `repetition == 2`: Trả về `interval = 6` (Ôn lại sau 6 ngày).
*   Nếu `repetition > 2`: `interval = interval_cũ * easinessFactor`. (Ví dụ: 6 * 2.5 = 15 ngày).

### Bước 3: Cập nhật Easiness Factor (EF)
Chỉ số EF thay đổi liên tục dựa trên phản ứng của người dùng, công thức chuẩn SM-2:
`EF_mới = EF_cũ + (0.1 - (5 - Quality) * (0.08 + (5 - Quality) * 0.02))`
*Lưu ý: EF không bao giờ được phép nhỏ hơn 1.3 (Mức tối thiểu để đảm bảo thẻ không bị lặp lại quá dày đặc).*

### Bước 4: Thiết lập Next Review
*   `nextReview` = Thời gian hiện tại (`Timestamp.now()`) + `interval` (tính bằng số ngày).

---

## 3. Vòng đời của 1 từ vựng (Ví dụ thực tế)

1. **Khởi tạo:** Người dùng Import file Excel chứa từ "Apple".
   *   `repetition = 0`, `interval = 0`, `EF = 2.5`.
   *   `nextReview = Ngày hôm nay`.
   *   👉 **Giao diện Library báo:** "1 thẻ cần học".
2. **Lần học đầu tiên:** Người dùng lật thẻ và bấm **Good**.
   *   `repetition` tăng lên 1.
   *   `interval` thành 1 ngày.
   *   `nextReview` dời sang **Ngày mai**.
   *   👉 Hệ thống gọi hàm `update()` lên Firebase. Thẻ "Apple" bị ẩn khỏi danh sách cần học.
   *   👉 **Giao diện Library báo:** "Đã học xong".
3. **Ngày hôm sau (Lần học 2):** Người dùng lật thẻ và bấm **Easy**.
   *   `repetition` tăng lên 2.
   *   `interval` thành 6 ngày.
   *   `EF` tăng lên 2.6.
   *   `nextReview` dời sang **6 ngày sau**.
4. **Nếu lỡ quên (Lần học 3):** Người dùng lật thẻ và bấm **Hard**.
   *   `repetition` bị reset về 0.
   *   `interval` bị reset về 1 ngày (Bắt học lại từ đầu).
   *   `EF` giảm xuống 2.1.
   *   `nextReview` dời sang **Ngày mai**.

---

## 4. Những Lưu Ý Quan Trọng Về Kỹ Thuật (Technical Notes)

### 4.1. Vấn đề truy vấn & Firebase Composite Index
*   Để đếm số thẻ cần học, App sử dụng lệnh: `.where('deckId', isEqualTo: deckId).where('nextReview', isLessThanOrEqualTo: Timestamp.now())`.
*   Vì query trên 2 trường khác nhau, Firebase yêu cầu **Composite Index**. Nếu chưa tạo Index, truy vấn sẽ bị crash.
*   **Giải pháp trong VitaminC:** Đã code sẵn hàm `_getDueCardsFallback()`. Nếu Firebase báo lỗi thiếu Index, App sẽ tự động kéo toàn bộ từ vựng của bộ thẻ đó về RAM điện thoại và dùng code Dart nội bộ để phân loại (`allCards.where(...)`), đảm bảo App không bao giờ bị lỗi hiển thị.

### 4.2. Quản lý trạng thái Real-time (Riverpod)
*   Do Firebase mất vài mili-giây để cập nhật `nextReview`, giao diện Thư viện (Library) có thể bị "lag nhịp" (Vẫn báo "Cần học" dù đã học xong).
*   **Giải pháp:** Trong `StudyController`, ngay khi thẻ cuối cùng được vuốt, hàm `ref.read(libraryControllerProvider.notifier).loadDecks()` được kích hoạt ngầm. Khi người dùng bấm "Hoàn thành" quay ra ngoài, danh sách Thư viện đã được vẽ lại (rebuild) chính xác.

### 4.3. Chế độ Học ép (Cram Mode)
*   Thuật toán SM-2 rất khắt khe: Thẻ chưa tới ngày thì dứt khoát không cho học.
*   **Giải pháp:** Tham số `forceStudy = true` được truyền vào `StudyService.getDueCards()`. Nếu `forceStudy` được bật, truy vấn Firebase sẽ tự động **bỏ qua điều kiện `nextReview`**, cho phép người dùng học lại toàn bộ bộ từ ngay trước kỳ thi mà không làm hỏng tiến độ của thuật toán.
