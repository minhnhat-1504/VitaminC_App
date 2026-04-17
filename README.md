# 📘 VitaminC - Sổ tay phát triển (Project Log)
## 1. Tổng quan dự án
- **Tên ứng dụng:** VitaminC
- **Mô tả:** Ứng dụng học tiếng Anh tích hợp hệ thống lặp ngắt quãng (SRS) và Chatbot AI.
- **Đối tượng:** Người học tiếng Anh muốn ghi nhớ từ vựng lâu dài và luyện phản xạ giao tiếp.

---

## 2. Công nghệ & Thư viện (Tech Stack)
- **Ngôn ngữ:** Dart
- **Framework:** Flutter
- **Quản lý trạng thái:** Riverpod
- **Điều hướng:** GoRouter
- **Backend:** Firebase (Authentication, Firestore, Storage)
- **Dữ liệu cục bộ (Offline):** Isar hoặc Hive (Dự kiến)
- **Font chữ:** Lexend (Google Fonts)

### Danh sách Dependencies (`pubspec.yaml`)
- `flutter_riverpod`: Quản lý logic và dữ liệu.
- `google_fonts`: Font chữ Lexend.
- `go_router`: Điều hướng màn hình.
- `flutter_svg`: Hiển thị icon vector.
- `cached_network_image`: Tối ưu tải ảnh từ internet.
- `percent_indicator`: Biểu đồ tiến độ, Streak.
- `firebase_core`: Kết nối Google Cloud.

---

## 3. Kiến trúc thư mục (Feature-First)
```text
lib/
│
├── core/                       # LỚP NỀN TẢNG: Chứa tất cả những gì dùng chung toàn app
│   ├── constants/              # Cố định các giá trị (Màu sắc, kích thước, text)
│   ├── theme/                  # Quản lý giao diện Sáng/Tối (Light/Dark mode)
│   ├── utils/                  # Các hàm dùng chung (format thời gian) & Dữ liệu giả
│   └── shared_widgets/         # Các UI Component dùng lại nhiều lần
│
├── features/                   # LỚP TÍNH NĂNG: Khu vực làm việc độc lập của 4 người
│   ├── auth/                   # Tính năng: Đăng nhập / Đăng ký
│   ├── dashboard/              # Tính năng: Trang chủ & Thống kê
│   ├── library/                # Tính năng: Quản lý Bộ thẻ & Từ vựng
│   ├── study/                  # Tính năng: Học tập (Flashcard, Quiz)
│   └── social/                 # Tính năng: Xếp hạng, Streak, Thành tích
│
├── routing/                    # LỚP ĐIỀU HƯỚNG
│   └── app_router.dart         # File cấu hình GoRouter để chuyển trang
│
└── main.dart                   # File khởi chạy ứng dụng
```

---

## 4. Danh sách Chức năng
### Nhóm cốt lõi (Core)
- Hệ thống lặp ngắt quãng (SRS) - Thuật toán SM-2.
- Tạo/Quản lý bộ thẻ (Text, Hình ảnh, Âm thanh).
- Chế độ Học/Ôn tập theo cấp độ nhớ.
- Thống kê tiến độ & Chế độ Offline.
- Đánh giá phát âm (Speech-to-Text).

### Nhóm Mở rộng (Extended)
- AI Chatbot.
- OCR (Quét ảnh dịch từ vựng).
- Streak & Leaderboard (Thi đua nhóm).
- Widget màn hình chính (Vitamin kiến thức mỗi ngày).
- Chế độ Giáo viên - Học sinh.

---

## 5. Nhật ký Thiết lập (Setup Log)

### Bước 1: Khởi tạo & Cấu hình Android
- **Java Version:** Nâng cấp lên Java 17 trong `app/build.gradle`.
- **Developer Mode:** Phải kích hoạt để hỗ trợ Symlink.
- **Quyền truy cập (Permissions):** Đã khai báo trong `AndroidManifest.xml`:
    - `INTERNET`
    - `CAMERA`
    - `RECORD_AUDIO`
    - `READ_EXTERNAL_STORAGE` / `READ_MEDIA_IMAGES`

### Bước 2: Xây dựng Base Code
- **Màu sắc:** Đã định nghĩa `AppColors.primary` (#0da2e7) và các màu trạng thái.
- **Dữ liệu giả:** Đã tạo `DummyData` để hiển thị UI mẫu.
- **Routing:** Đã setup `GoRouter` cơ bản kết nối `main.dart`.

---

## 6. Quy trình làm việc nhóm (Team Workflow)

Để đảm bảo hiệu suất và tránh xung đột mã nguồn (Merge Conflict) cho nhóm 4 người, toàn bộ thành viên cần tuân thủ nghiêm ngặt quy trình dưới đây.

### 6.1. Quy tắc đặt tên (Naming Conventions)
Thống nhất cách đặt tên giúp mọi người nhìn vào là biết ai đang làm gì và commit đó có ý nghĩa gì.

**1. Đặt tên Nhánh (Branch):**
Luôn viết chữ thường, không dấu, dùng dấu gạch ngang `-` để nối từ.
* Tính năng mới: `feature/ten-tinh-nang` (VD: `feature/login-ui`, `feature/flashcard-logic`)
* Sửa lỗi: `bugfix/ten-loi` (VD: `bugfix/button-khong-bam-duoc`)
* Cấu hình hệ thống: `config/ten-cau-hinh` (VD: `config/add-firebase`)

**2. Viết lời nhắn Commit (Commit Message):**
Bắt đầu bằng một tiền tố để phân loại, sau đó là mô tả ngắn gọn (có thể viết tiếng Việt có dấu).
* `feat:` Thêm tính năng/giao diện mới. (VD: `feat: Hoàn thành UI màn hình Đăng ký`)
* `fix:` Sửa lỗi. (VD: `fix: Sửa lỗi tràn màn hình ở form Đăng nhập`)
* `ui:` Cập nhật màu sắc, font chữ, căn chỉnh layout. (VD: `ui: Đổi màu nút primary sang xanh dương`)
* `refactor:` Viết lại code cho gọn gàng hơn, không làm thay đổi chức năng.


### 6.2. Vòng lặp công việc hàng ngày (Daily Routine)

Mỗi khi ngồi vào bàn làm việc, các thành viên thực hiện đúng 4 bước sau:

**Bước 1: Đồng bộ code (CỰC KỲ QUAN TRỌNG)**
Luôn luôn lấy code mới nhất từ nhóm trước khi code cái mới của mình.
```bash
git checkout develop
git pull origin develop
```

**Bước 2: Tạo nhánh cá nhân để code**
```bash
git checkout -b feature/ten-task-cua-ban
```

**Bước 3: Code và kiểm tra liên tục**
* Chỉ sử dụng các widget, màu sắc đã khai báo trong `lib/core/`.
* Thường xuyên bấm `Ctrl + S` và kiểm tra giao diện trên máy ảo.
* **Quy tắc Vàng:** Code bị lỗi đỏ màn hình thì tuyệt đối chưa được commit.

**Bước 4: Lưu và Đẩy code lên cuối ngày**
```bash
git add .
git commit -m "feat: Mô tả công việc đã làm hôm nay"
git push -u origin feature/ten-task-cua-ban
```

---

### 6.3. Quy trình Review và ghép code (Pull Request)

Khi một thành viên đã làm xong task (ví dụ: xong toàn bộ UI màn hình Study), người đó sẽ làm thủ tục "Nộp bài" qua tính năng Pull Request (PR) trên GitHub.

1. **Người code:** Lên trang chủ GitHub, tạo Pull Request từ nhánh `feature/...` của mình hướng vào nhánh `develop`.
2. **Thông báo:** Nhắn tin vào group chat của nhóm: *"Tôi đã tạo PR cho màn hình Study, nhờ 1 bạn vào review giúp!"*.
3. **Người Review (Thành viên khác):**
    * Vào xem các file code đã thay đổi.
    * Chạy thử nhánh đó trên máy của mình (nếu cần).
    * Kiểm tra xem code có đúng chuẩn Design không, có bị dư thừa file nào không.
    * Nếu ổn: Bấm **Approve** và **Merge pull request**.
    * Nếu chưa ổn: Comment yêu cầu sửa lại.
4.  **Không tự bấm Merge Pull Request của chính mình.** Phải có ít nhất 1 người khác đọc và duyệt code.

---

### 6.4. Xử lý sự cố (Merge Conflict)

**Merge Conflict là gì?** Là khi 2 người cùng sửa vào 1 dòng code trong cùng 1 file (Ví dụ: 2 người cùng thêm code vào file `main.dart` hoặc `pubspec.yaml`). Git sẽ không biết phải lấy đoạn code của ai và báo lỗi Conflict.

**Cách xử lý:**
1. **Không xóa file hay xóa nhánh**.
2. **Báo cáo:** Nhắn ngay vào group: *"Tôi bị conflict file ... với bạn ..."*.
3. **Giải quyết:**
    * Bạn và bạn Y sẽ cùng mở file đó ra trên máy.
    * VS Code sẽ bôi màu các đoạn code bị trùng (Hiện nút *Accept Current Change* hoặc *Accept Incoming Change*).
    * Hai bạn thảo luận xem nên giữ đoạn code nào, hay là giữ cả hai.
    * Bấm chọn, sau đó lưu file lại.
    * Chạy lại lệnh `git commit` và `git push`.

---

### 6.5. Tiêu chuẩn hoàn thành một Task (Definition of Done)
Một tính năng chỉ được coi là "Đã xong" và cho phép tạo PR khi thỏa mãn:
- [ ] Ứng dụng chạy mượt mà, không có lỗi (Error) ở Terminal.
- [ ] UI không bị vỡ (overflow) khi hiển thị bàn phím ảo.
- [ ] Giao diện tuân thủ đúng `AppColors` và `GoogleFonts.lexend`.
- [ ] Đã dọn dẹp các đoạn code rác, code comment không dùng đến.
- [ ] Đã chạy lệnh `dart format .` để format code gọn gàng.

---

### Sprint 1: Xây dựng Giao diện người dùng (UI) - "VitaminC Base Frame"

**Quy tắc chung cho toàn SPRINT:**

  * **TUYỆT ĐỐI KHÔNG** sử dụng Firebase, Riverpod logic phức tạp hay API bên thứ 3 trong Sprint này.
  * **Mọi dữ liệu** hiển thị trên UI đều gọi từ `lib/core/utils/dummy_data.dart`.
  * **Mọi màu sắc, text style** đều gọi từ `lib/core/constants/app_colors.dart` và `app_text_styles.dart`.
  * **Code lỗi** đỏ màn hình KHÔNG được push.

-----

### 👨‍💻 Thành viên 1: Lead / Core

**Mục tiêu (Outcome):** Ứng dụng chạy mượt mà, chuyển trang qua lại giữa các Tab không lỗi vỡ layout. Hệ thống thư viện Component chung sẵn sàng để 3 người còn lại dùng.

| Task (Việc cần làm) | Vị trí file cần viết / tạo | Tên file | Outcome chi tiết |
| :--- | :--- | :--- | :--- |
| **1. Bottom Navigation Bar** | `lib/core/shared_widgets/` | `bottom_nav_bar.dart` | Khung điều hướng dưới đáy màn hình với 5 icon (Home, Scan, Add, Social, User). Sử dụng Riverpod `StateProvider` cơ bản để giữ trạng thái Tab đang chọn. |
| **2. Cấu hình GoRouter** | `lib/routing/` | `app_router.dart` | Tạo các đường dẫn (`/`, `/login`, `/home`, `/study`, `/leaderboard`...) trỏ đến các màn hình trống do 3 người kia tạo. |
| **3. Custom AppBar** | `lib/core/shared_widgets/` | `custom_app_bar.dart` | Thanh tiêu đề trên cùng dùng chung, có thể nhận tham số truyền vào là tiêu đề màn hình và nút Back. |
| **4. Các Widget dùng chung** | `lib/core/shared_widgets/` | `custom_button.dart`<br>`custom_text_field.dart` | Nút bấm chuẩn có hiệu ứng nhấn. Ô nhập liệu (có viền, bo góc, hỗ trợ icon bên trong) theo đúng mockup. |
| **5. Cài đặt hệ thống (Settings)** | `lib/features/settings/presentation/screens/` | `settings_screen.dart` | Màn hình cài đặt (Mockup User Tab). Nút bật tắt Dark/Light mode, thông báo. |

-----

### 👨‍💻 Thành viên 2: Auth & Dashboard

**Mục tiêu (Outcome):** Giao diện mượt mà từ lúc người dùng mở app đến lúc đăng nhập thành công và nhìn thấy tiến độ học tập hôm nay.

| Task (Việc cần làm) | Vị trí file cần viết / tạo | Tên file | Outcome chi tiết |
| :--- | :--- | :--- | :--- |
| **1. Splash & Onboarding** | `lib/features/auth/presentation/screens/` | `splash_screen.dart`<br>`onboarding_screen.dart` | Màn hình logo hiển thị 2 giây -\> Chuyển sang chuỗi 3 slide giới thiệu tính năng (Dùng `PageView`), có nút "Bắt đầu". |
| **2. Form Đăng nhập** | `lib/features/auth/presentation/screens/` | `login_screen.dart` | Mockup 1. Giao diện đăng nhập với Email/Pass. Các nút "Đăng nhập với Google/Facebook". Bắt lỗi UI (vd: ô email trống thì viền đỏ). |
| **3. Form Đăng ký** | `lib/features/auth/presentation/screens/` | `register_screen.dart` | Giao diện đăng ký tài khoản (Nhập tên, Email, Pass, Confirm Pass). Nút quay lại Login. |
| **4. Bảng điều khiển (Home)** | `lib/features/dashboard/presentation/screens/` | `home_screen.dart` | Mockup 2. Trang chủ hiện tổng quan: Số thẻ đã học, Streak hiện tại. Dùng package `percent_indicator` vẽ biểu đồ tròn/ngang. Hiện 2-3 gợi ý bài học. |

-----

### 👨‍💻 Thành viên 3: Library & Study

**Mục tiêu (Outcome):** Trải nghiệm lật thẻ (Flashcard) mượt mà, quản lý được thư viện từ vựng trực quan.

| Task (Việc cần làm) | Vị trí file cần viết / tạo | Tên file | Outcome chi tiết |
| :--- | :--- | :--- | :--- |
| **1. Danh sách Bộ thẻ** | `lib/features/library/presentation/screens/` | `deck_list_screen.dart` | Mockup 3. Hiển thị danh sách các Bộ thẻ (Decks) dạng Grid/List. Dùng vòng lặp gọi data từ `dummy_data.dart`. |
| **2. Form Tạo/Sửa Từ vựng** | `lib/features/library/presentation/screens/` | `add_vocab_screen.dart` | Mockup 5. Form nhập từ, nghĩa, ví dụ. Nút Toggle để chọn Công khai/Riêng tư. Khung giả lập upload hình ảnh/âm thanh. |
| **3. Giao diện Lật thẻ (SRS)** | `lib/features/study/presentation/screens/` | `flashcard_screen.dart` | Mockup 4. Thẻ từ vựng lớn ở giữa. Tap vào lật 3D sang mặt sau (nghĩa). 3 nút Hard/Good/Easy ở dưới. Animation mượt mà. |
| **4. Tổng kết buổi học** | `lib/features/study/presentation/screens/` | `study_summary_screen.dart` | Màn hình hiển thị sau khi học xong: Số từ đã ôn, điểm XP nhận được, nút "Về trang chủ". |

-----

### 👨‍💻 Thành viên 4: Tiện ích & Gamification (Social & Tools)

**Mục tiêu (Outcome):** UI các tính năng thi đua và công cụ tương tác AI/Camera để người dùng thấy ứng dụng thú vị.

| Task (Việc cần làm) | Vị trí file cần viết / tạo | Tên file | Outcome chi tiết |
| :--- | :--- | :--- | :--- |
| **1. Leaderboard & Badges** | `lib/features/social/presentation/screens/` | `leaderboard_screen.dart`<br>`badges_screen.dart` | Mockup 6. Bảng xếp hạng Top (Có Tab chuyển đổi Tuần/Tháng). Màn hình lưới trưng bày huy hiệu (In đậm nếu đạt, mờ nếu chưa). |
| **2. Streak Celebration** | `lib/features/social/presentation/widgets/` | `streak_popup.dart` | Mockup 8. Một Custom Dialog hiện lên rực rỡ (màu cam/vàng) chúc mừng người dùng duy trì chuỗi học. |
| **3. Luyện phát âm** | `lib/features/tools/presentation/screens/` | `pronunciation_screen.dart` | Mockup 7. Giao diện nút thu âm. Cần vẽ UI giả lập sóng âm (`wave_animation`) khi đang thu âm. Hiển thị kết quả text xanh/đỏ. |
| **4. Camera OCR & Chatbot** | `lib/features/tools/presentation/screens/` | `ocr_scanner_screen.dart`<br>`chatbot_screen.dart` | OCR: Khung ngắm camera giả lập có viền quét góc. <br>Chatbot: Giao diện phòng chat (Tin nhắn user bong bóng xanh bên phải, Bot bong bóng xám bên trái). |
