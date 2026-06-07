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
4. **Không tự bấm Merge Pull Request của chính mình.** Phải có ít nhất 1 người khác đọc và duyệt code.

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

---

### 👨‍💻 Thành viên 1: Lead / Core

**Mục tiêu (Outcome):** Ứng dụng chạy mượt mà, chuyển trang qua lại giữa các Tab không lỗi vỡ layout. Hệ thống thư viện Component chung sẵn sàng để 3 người còn lại dùng.

| Task (Việc cần làm)                        | Vị trí file cần viết / tạo                 | Tên file                                            | Outcome chi tiết                                                                                                                                                               |
| :-------------------------------------------- | :---------------------------------------------- | :--------------------------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **1. Bottom Navigation Bar**            | `lib/core/shared_widgets/`                    | `bottom_nav_bar.dart`                              | Khung điều hướng dưới đáy màn hình với 5 icon (Home, Scan, Add, Social, User). Sử dụng Riverpod `StateProvider` cơ bản để giữ trạng thái Tab đang chọn. |
| **2. Cấu hình GoRouter**              | `lib/routing/`                                | `app_router.dart`                                  | Tạo các đường dẫn (`/`, `/login`, `/home`, `/study`, `/leaderboard`...) trỏ đến các màn hình trống do 3 người kia tạo.                                |
| **3. Custom AppBar**                    | `lib/core/shared_widgets/`                    | `custom_app_bar.dart`                              | Thanh tiêu đề trên cùng dùng chung, có thể nhận tham số truyền vào là tiêu đề màn hình và nút Back.                                                         |
| **4. Các Widget dùng chung**          | `lib/core/shared_widgets/`                    | `custom_button.dart<br>``custom_text_field.dart` | Nút bấm chuẩn có hiệu ứng nhấn. Ô nhập liệu (có viền, bo góc, hỗ trợ icon bên trong) theo đúng mockup.                                                        |
| **5. Cài đặt hệ thống (Settings)** | `lib/features/settings/presentation/screens/` | `settings_screen.dart`                             | Màn hình cài đặt (Mockup User Tab). Nút bật tắt Dark/Light mode, thông báo.                                                                                           |

---

### 👨‍💻 Thành viên 2: Auth & Dashboard

**Mục tiêu (Outcome):** Giao diện mượt mà từ lúc người dùng mở app đến lúc đăng nhập thành công và nhìn thấy tiến độ học tập hôm nay.

| Task (Việc cần làm)                  | Vị trí file cần viết / tạo                  | Tên file                                            | Outcome chi tiết                                                                                                                                                          |
| :-------------------------------------- | :----------------------------------------------- | :--------------------------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **1. Splash & Onboarding**        | `lib/features/auth/presentation/screens/`      | `splash_screen.dart<br>``onboarding_screen.dart` | Màn hình logo hiển thị 2 giây -\> Chuyển sang chuỗi 3 slide giới thiệu tính năng (Dùng `PageView`), có nút "Bắt đầu".                                   |
| **2. Form Đăng nhập**          | `lib/features/auth/presentation/screens/`      | `login_screen.dart`                                | Mockup 1. Giao diện đăng nhập với Email/Pass. Các nút "Đăng nhập với Google/Facebook". Bắt lỗi UI (vd: ô email trống thì viền đỏ).                      |
| **3. Form Đăng ký**            | `lib/features/auth/presentation/screens/`      | `register_screen.dart`                             | Giao diện đăng ký tài khoản (Nhập tên, Email, Pass, Confirm Pass). Nút quay lại Login.                                                                           |
| **4. Bảng điều khiển (Home)** | `lib/features/dashboard/presentation/screens/` | `home_screen.dart`                                 | Mockup 2. Trang chủ hiện tổng quan: Số thẻ đã học, Streak hiện tại. Dùng package `percent_indicator` vẽ biểu đồ tròn/ngang. Hiện 2-3 gợi ý bài học. |

---

### 👨‍💻 Thành viên 3: Library & Study

**Mục tiêu (Outcome):** Trải nghiệm lật thẻ (Flashcard) mượt mà, quản lý được thư viện từ vựng trực quan.

| Task (Việc cần làm)                  | Vị trí file cần viết / tạo                | Tên file                     | Outcome chi tiết                                                                                                                       |
| :-------------------------------------- | :--------------------------------------------- | :---------------------------- | :-------------------------------------------------------------------------------------------------------------------------------------- |
| **1. Danh sách Bộ thẻ**        | `lib/features/library/presentation/screens/` | `deck_list_screen.dart`     | Mockup 3. Hiển thị danh sách các Bộ thẻ (Decks) dạng Grid/List. Dùng vòng lặp gọi data từ `dummy_data.dart`.              |
| **2. Form Tạo/Sửa Từ vựng**   | `lib/features/library/presentation/screens/` | `add_vocab_screen.dart`     | Mockup 5. Form nhập từ, nghĩa, ví dụ. Nút Toggle để chọn Công khai/Riêng tư. Khung giả lập upload hình ảnh/âm thanh.   |
| **3. Giao diện Lật thẻ (SRS)** | `lib/features/study/presentation/screens/`   | `flashcard_screen.dart`     | Mockup 4. Thẻ từ vựng lớn ở giữa. Tap vào lật 3D sang mặt sau (nghĩa). 3 nút Hard/Good/Easy ở dưới. Animation mượt mà. |
| **4. Tổng kết buổi học**      | `lib/features/study/presentation/screens/`   | `study_summary_screen.dart` | Màn hình hiển thị sau khi học xong: Số từ đã ôn, điểm XP nhận được, nút "Về trang chủ".                              |

---

### 👨‍💻 Thành viên 4: Tiện ích & Gamification (Social & Tools)

**Mục tiêu (Outcome):** UI các tính năng thi đua và công cụ tương tác AI/Camera để người dùng thấy ứng dụng thú vị.

| Task (Việc cần làm)            | Vị trí file cần viết / tạo               | Tên file                                              | Outcome chi tiết                                                                                                                                                           |
| :-------------------------------- | :-------------------------------------------- | :----------------------------------------------------- | :-------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **1. Leaderboard & Badges** | `lib/features/social/presentation/screens/` | `leaderboard_screen.dart<br>``badges_screen.dart`  | Mockup 6. Bảng xếp hạng Top (Có Tab chuyển đổi Tuần/Tháng). Màn hình lưới trưng bày huy hiệu (In đậm nếu đạt, mờ nếu chưa).                         |
| **2. Streak Celebration**   | `lib/features/social/presentation/widgets/` | `streak_popup.dart`                                  | Mockup 8. Một Custom Dialog hiện lên rực rỡ (màu cam/vàng) chúc mừng người dùng duy trì chuỗi học.                                                           |
| **3. Luyện phát âm**     | `lib/features/tools/presentation/screens/`  | `pronunciation_screen.dart`                          | Mockup 7. Giao diện nút thu âm. Cần vẽ UI giả lập sóng âm (`wave_animation`) khi đang thu âm. Hiển thị kết quả text xanh/đỏ.                             |
| **4. Camera OCR & Chatbot** | `lib/features/tools/presentation/screens/`  | `ocr_scanner_screen.dart<br>``chatbot_screen.dart` | OCR: Khung ngắm camera giả lập có viền quét góc.`<br>`Chatbot: Giao diện phòng chat (Tin nhắn user bong bóng xanh bên phải, Bot bong bóng xám bên trái). |

### Hướng dẫn thiết lập Firebase (Chỉ dành cho Android)

#### Bước 1: Dọn dẹp thư mục dư thừa

Vì nhóm chỉ phát triển trên nền tảng Android, hãy xóa các thư mục sau để tối ưu hóa dung lượng dự án:

* `ios/`
* `linux/`
* `macos/`
* `windows/`
* `web/`

#### Bước 2: Tạo dự án trên Firebase Console

1. Truy cập [Firebase Console](https://console.firebase.google.com/).
2. Nhấn **Add Project**, đặt tên dự án là `VitaminC`.
3. Bật **Google Analytics** (khuyên dùng để theo dõi người dùng).

#### Bước 3: Đăng ký ứng dụng Android

1. Tại giao diện dự án, chọn biểu tượng **Android**.
2. **Android package name:** Mở file `android/app/build.gradle`, tìm dòng `applicationId` (thường là `com.example.vitaminc`). Copy và dán vào Firebase.
3. **App nickname:** `VitaminC_Android`.
4. **SHA-1 certificate:** Mở Terminal trong thư mục dự án, chạy lệnh:
   ```bash
   cd android
   ./gradlew signingReport
   ```

   Copy mã SHA-1 (trong phần `debug`) dán vào Firebase để hỗ trợ Google Sign-In.
5. Tải file **`google-services.json`** và chép vào thư mục: `android/app/`.

#### Bước 4: Cấu hình Gradle (Android)

1. **File `android/build.gradle` (Project level):**
   Thêm dòng sau vào khối `dependencies`:
   ```gradle
   dependencies {
       classpath 'com.google.gms:google-services:4.4.0'
   }
   ```
2. **File `android/app/build.gradle` (App level):**
   Thêm dòng này vào cuối file:
   ```gradle
   apply plugin: 'com.google.gms.google-services'
   ```

   Đồng thời, đảm bảo `minSdkVersion` tối thiểu là **21** (hoặc 23 nếu dùng các tính năng AI phức tạp).

#### Bước 5: Cấu hình Flutter & .gitignore

1. Thêm thư viện vào `pubspec.yaml`:
   ```yaml
   dependencies:
     firebase_core: ^3.1.0
     firebase_auth: ^5.1.0
     cloud_firestore: ^5.0.1
     firebase_storage: ^12.0.1
   ```
2. **Bảo mật:** Mở file `.gitignore`, thêm dòng sau để không push file cấu hình lên GitHub:
   ```text
   android/app/google-services.json
   ```

---

### Sprint 2: Kết nối Backend & Logic nghiệp vụ (Firebase & SRS)

**Quy tắc chung cho toàn SPRINT 2:**

* **Dữ liệu:** Chuyển từ `dummy_data.dart` sang `FirebaseFirestore`.
* **Phân quyền:** Sử dụng trường `role` (admin/user) trong Document người dùng trên Firestore để điều hướng UI và phân quyền API.
* **Bảo mật:** Thiết lập **Firebase Security Rules** để Admin có quyền ghi mọi nơi, User chỉ có quyền ghi vào data cá nhân.

---

### 👨‍💻 Thành viên 1: Authentication & Role-Based Routing

**Mục tiêu:** Quản lý đăng nhập và điều hướng người dùng dựa trên chức vụ (Role).

| Task (Việc cần làm)           | Vị trí file cần viết / tạo     | Tên file                | Outcome chi tiết                                                                                            |
| :------------------------------- | :---------------------------------- | :----------------------- | :----------------------------------------------------------------------------------------------------------- |
| **1. Auth Repository**     | `lib/features/auth/data/`         | `auth_repository.dart` | Hàm đăng nhập trả về thông tin User kèm theo `role` từ Firestore.                                 |
| **2. Auth Provider**       | `lib/features/auth/presentation/` | `auth_provider.dart`   | Quản lý trạng thái `currentUser` để các màn hình biết đang là Admin hay User.                  |
| **3. Role-Based Redirect** | `lib/routing/`                    | `app_router.dart`      | Nếu `role == 'admin'` -> vào màn hình Quản trị. Nếu `role == 'user'` -> vào Dashboard học tập. |

---

#### 👨‍💻 Thành viên 2: User Profile & Dashboard Logic (Dữ liệu cá nhân)

**Mục tiêu:** Chuyển toàn bộ màn hình Home và Profile từ dữ liệu giả sang dữ liệu thật từ Firestore, đồng thời xây dựng logic tính toán tiến độ học tập (Streak).

| Task (Việc cần làm)                       | Vị trí file                                                    | Outcome chi tiết                                                                                                                                                                                                                                                                                      |
| :------------------------------------------- | :--------------------------------------------------------------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **1. User Stats Logic (Thống kê)**   | `lib/features/dashboard/data/dashboard_service.dart`           | Viết hàm gọi lệnh `count()` trực tiếp trên collection `users/{uid}/vocabs` từ Firestore để đếm tổng số thẻ mà không cần tải toàn bộ dữ liệu về máy. Trả về kết quả để hiển thị "Số từ đã học".                                                               |
| **2. Xây dựng logic tính Streak**   | `lib/features/dashboard/data/streak_service.dart`              | Tạo hàm `updateStreak()`. Lưu trường `last_study_date` (dạng Timestamp) và `streak_count` (int) trong Document của User. Thuật toán: Lấy ngày hiện tại so sánh với `last_study_date`. Nếu chênh lệch 1 ngày -> `streak_count++`. Nếu > 1 ngày -> `streak_count = 0`. |
| **3. Cập nhật Profile (Đồng bộ)** | `lib/features/auth/data/user_service.dart`                     | Viết hàm `updateUserProfile()`. Sử dụng `FirebaseAuth.instance.currentUser?.updateDisplayName()` để đổi tên trên hệ thống Auth, sau đó gọi lệnh `update()` để sửa lại trường `displayName` và `photoUrl` tương ứng trong document của User trên Firestore.       |
| **4. Home Data Binding**               | `lib/features/dashboard/presentation/screens/home_screen.dart` | Kết nối giao diện Home với các Service trên thông qua Riverpod (`FutureProvider`). Nếu số lượng thẻ trả về = 0, hiển thị Empty State với nút kêu gọi hành động: "Bắt đầu thêm từ vựng ngay!".                                                                           |

---

#### 👨‍💻 Thành viên 3: Library & SRS Core (Trái tim của App)

**Mục tiêu:** Xây dựng hệ thống lưu trữ từ vựng cá nhân, xử lý việc nhập dữ liệu hàng loạt và cài đặt thuật toán lặp ngắt quãng (SM-2).

| Task (Việc cần làm)                            | Vị trí file                                      | Outcome chi tiết                                                                                                                                                                                                                                                                                            |
| :------------------------------------------------ | :------------------------------------------------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **1. Nhập từ vựng hàng loạt (Import)** | `lib/features/library/data/import_service.dart`  | Tích hợp package `file_picker` (chọn file) và `csv` (đọc file). Viết logic parse từng dòng CSV thành danh sách Object `VocabModel`. Dùng `FirebaseFirestore.instance.batch()` (WriteBatch) để đẩy danh sách này lên collection `users/{uid}/vocabs` nhằm tránh quá tải API. |
| **2. Cài đặt thuật toán SM-2 (SRS)**   | `lib/features/study/data/srs_engine.dart`        | Định nghĩa 3 trường cho mỗi thẻ:`easinessFactor` (float, mặc định 2.5), `interval` (int), `repetition` (int). Viết hàm tính toán trả về ngày `nextReview` mới dựa trên điểm số đánh giá của user: 1 (Hard), 2 (Good), 3 (Easy).                                           |
| **3. Truy vấn danh sách ôn tập**        | `lib/features/study/data/study_service.dart`     | Viết hàm `getDueCards()`. Sử dụng Firestore Query với điều kiện: `where('nextReview', isLessThanOrEqualTo: Timestamp.now())` để giới hạn chỉ tải về máy các thẻ đã đến hạn cần ôn tập hôm nay.                                                                                |
| **4. Quản lý thẻ cá nhân (CRUD)**      | `lib/features/library/data/library_service.dart` | Viết các hàm cơ bản để Thêm/Sửa/Xóa từng từ vựng riêng lẻ trong sub-collection `users/{uid}/vocabs`.                                                                                                                                                                                        |

---

#### 👨‍💻 Thành viên 4: AI Assistant, Speech-to-Text & Security (Tính năng đột phá)

**Mục tiêu:** Tích hợp trí tuệ nhân tạo (Gemini) làm Chatbot giáo viên, chấm điểm phát âm bằng giọng nói và chốt hạ hệ thống bảo mật Database.

| Task (Việc cần làm)                                | Vị trí file                                   | Outcome chi tiết                                                                                                                                                                                                                                                                                      |
| :---------------------------------------------------- | :---------------------------------------------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **1. Cấu hình AI Gemini**                     | `lib/features/tools/data/ai_service.dart`     | Truy cập Google AI Studio lấy API Key. Cài đặt package `google_generative_ai`. Khởi tạo đối tượng `GenerativeModel` (dùng model `gemini-1.5-flash`). Viết hàm `askTeacher(String prompt)` gửi câu hỏi và đợi trả về text.                                                |
| **2. Thiết lập Luật cho AI (System Prompt)** | `lib/features/tools/data/ai_service.dart`     | Trong phần cấu hình model, thiết lập `systemInstruction`: "Bạn là một giáo viên tiếng Anh nhiệt tình. Chỉ trả lời các câu hỏi liên quan đến tiếng Anh. Bắt buộc phải cung cấp ít nhất 2 câu ví dụ cho mỗi từ vựng. Trả lời ngắn gọn bằng tiếng Việt.".     |
| **3. Kiểm tra phát âm (STT)**                | `lib/features/tools/data/speech_service.dart` | Cài đặt package `permission_handler`. Viết hàm xin quyền `RECORD_AUDIO`. Dùng `speech_to_text` bắt giọng nói user chuyển thành String. Viết logic so sánh chuỗi (dùng thuật toán khoảng cách Levenshtein) giữa từ user đọc và từ gốc để tính ra số % chính xác. |
| **4. Firestore Security Rules**                 | Trên Firebase Console (`firestore.rules`)    | Truy cập tab Rules, thiết lập luật bảo vệ dữ liệu cấp độ User:`<br>match /users/{userId}/vocabs/{document=**} {` `<br>` `allow read, write: if request.auth != null && request.auth.uid == userId;` `<br>}` (Chặn tuyệt đối User này sửa/xóa từ vựng của User khác).     |

---

### LƯU Ý SPRINT 2. Quy chuẩn giao tiếp với Database (Firestore)

**TUYỆT ĐỐI KHÔNG gõ trực tiếp tên collection vào code.**

Việc gõ chay các chuỗi văn bản như `'users'`, `'vocabs'` rải rác ở nhiều file rất dễ gây ra lỗi sai chính tả (nhầm chữ hoa/chữ thường, thiếu chữ "s"). Điều này sẽ khiến Firestore tạo ra các thư mục rác, gây phân mảnh và làm mất dữ liệu của người dùng.

**Quy tắc bắt buộc:**
Tất cả các lệnh gọi đến Firestore phải sử dụng các biến static đã được định nghĩa sẵn tại file `lib/core/utils/firestore_collections.dart`.

**❌ Code Sai (Sẽ bị từ chối khi Review PR):**

```dart
// Gõ trực tiếp chuỗi 'users' và 'vocabs'
await _firestore.collection('users').doc(uid).collection('vocabs').get();
```

**✅ Code Đúng:**

```dart
import 'package:vitaminc/core/utils/firestore_collections.dart';

// Gọi thông qua class FirestoreCollections
await _firestore.collection(FirestoreCollections.users)
                .doc(uid)
                .collection(FirestoreCollections.vocabs)
                .get();
```

**📌 Quy trình khi cần thêm Collection mới:**
Nếu task của bạn yêu cầu tạo một bảng/collection mới trên Firebase, bạn phải tuân thủ 2 bước:

1. Mở file `firestore_collections.dart` và khai báo thêm 1 biến `static const String` mới.
2. Nhắn tin thông báo vào group chat của nhóm để mọi người cùng cập nhật, sau đó mới được sử dụng biến đó vào code của mình.

---

### Sprint 3: Tính năng nâng cao, Chế độ Offline & Giữ chân người dùng (Retention)

**Mục tiêu cốt lõi:** Đưa ứng dụng từ "bản nháp trực tuyến" thành sản phẩm thực tế, có thể sử dụng mượt mà ngay cả khi không có mạng và bổ sung các tính năng đột phá (AI, TTS, OCR) để giữ chân người dùng.

#### ⚠️ LƯU Ý QUAN TRỌNG CHO SPRINT 3 (TẤT CẢ THÀNH VIÊN CẦN ĐỌC KỸ)

**1. Chiến lược "Offline-First" (Đồng bộ dữ liệu)**

* Bắt đầu từ Sprint này, giao diện học tập (`flashcard_screen.dart`) **chỉ đọc và ghi dữ liệu từ Local DB** (Isar/Hive).
* Firestore lúc này lùi về sau làm "Máy chủ sao lưu" (Backup Server).
* Nguyên tắc đồng bộ: Khi người dùng lật thẻ, cập nhật Local DB ngay lập tức (UI phản hồi 0.1s) -> Đưa thẻ đó vào hàng đợi (Queue) -> Chạy tiến trình ngầm đẩy lên Firestore. Không có mạng thì giữ trong máy, có mạng đẩy bù.

**2. Cấu hình Native & Cơn ác mộng Multidex**

* Nhóm sẽ cài thêm rất nhiều thư viện nặng (FCM, ML Kit, TTS), chắc chắn sẽ làm ứng dụng vượt giới hạn 64K phương thức của Android.
* **Bắt buộc:** Mở file `android/app/build.gradle` và thêm `multiDexEnabled true` vào khối `defaultConfig`.
* Việc khai báo thêm Service trong `AndroidManifest.xml` cực kỳ nhạy cảm. Cần test kỹ, sai một dòng là ứng dụng crash ngay lúc khởi động.

**3. Tối ưu "Hóa đơn" Firebase (Giới hạn Read/Write)**

* Tính năng Leaderboard Real-time rất dễ ngốn sạch hạn mức miễn phí (Spark Tier) của Firebase.
* Tuyệt đối không dùng `StreamProvider` lắng nghe toàn bộ Collection. **Bắt buộc** phải gắn thêm `.limit(50)` hoặc `.limit(100)` vào cuối các lệnh Query hiển thị danh sách.

**4. Quản trị Quyền truy cập (Permissions)**

* Ứng dụng hiện tại đụng chạm đến quyền riêng tư sâu: Camera (quét chữ), Micro (phát âm) và Push Notification.
* Bắt buộc phải dùng package `permission_handler`. Nên có một popup giải thích (*"VitaminC cần quyền truy cập Camera để quét từ vựng trên giấy..."*) trước khi hiện bảng xin quyền mặc định của máy.

**5. Trách nhiệm Clear Cache khi Đăng xuất (Đặc biệt cho Thành viên 3)**

* Tại nút Đăng xuất (`settings_screen.dart`), Thành viên 1 đã thiết lập sẵn bộ khung clear cache an toàn.
* Đối với các Provider được làm sau (Ví dụ: `localDbProvider` của Thành viên 3), Thành viên 1 đã đặt sẵn `// TODO`.
* **YÊU CẦU:** Khi Thành viên 3 (hoặc bất kỳ ai tạo thêm Provider lưu trữ trạng thái) hoàn thành code của mình, **phải TỰ CHỦ ĐỘNG** vào `settings_screen.dart` mở comment và gắn `ref.invalidate(...)` tương ứng. Không được quên và không cần đợi Thành viên 1 làm hộ.

---

#### 👨‍💻 Phân công nhiệm vụ chi tiết

**Thành viên 1 (Lead): Hoàn thiện luồng User, Thông báo & Phân quyền**

| Task (Việc cần làm)                              | Vị trí file                                                   | Hướng dẫn triển khai chi tiết                                                                                                                                                                                                                                                        |
| :-------------------------------------------------- | :-------------------------------------------------------------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **1. Nối luồng Đăng xuất & Clear Cache** | `features/settings/presentation/screens/settings_screen.dart` | Gắn sự kiện `onTap` cho menu Đăng xuất. Gọi hàm `signOut()`. **Quan trọng:** Gọi thêm `ref.invalidate()` toàn bộ các Provider giữ trạng thái (đặc biệt là Local DB) để bảo mật dữ liệu giữa các User trên cùng 1 máy.                         |
| **2. Tích hợp Thông báo (FCM)**           | `core/services/notification_service.dart`                     | Cài đặt `firebase_messaging` và `flutter_local_notifications`. Đặt lịch cố định vào 11:00 hoặc 20:00 mỗi ngày kiểm tra biến `last_study_date`. Nếu hôm nay chưa học -> Bắn thông báo: *"Streak của bạn đang gặp nguy hiểm! Học ngay 5 thẻ nhé!"*. |
| **3. Mở khóa Admin Mode**                   | `features/library/data/global_deck_service.dart`              | Nếu `currentUser.role == 'admin'`, cho phép hiện nút "Tạo bộ thẻ mẫu" (ghi vào collection `global_decks`). User thường chỉ thấy nút "Tải về" để nhân bản bộ thẻ này vào collection cá nhân.                                                                 |
| **4. Xử lý Exception toàn hệ thống**     | Toàn bộ dự án                                               | Bọc `try-catch` cho tất cả call API/Firestore. Bắt các lỗi rớt mạng, từ chối quyền, API lỗi để hiển thị `SnackBar` hoặc Dialog thân thiện.                                                                                                                         |

<br>

**Thành viên 2: Social Thực tế & Dữ liệu Tổng kết**

| Task (Việc cần làm)                       | Vị trí file                                                     | Hướng dẫn triển khai chi tiết                                                                                                                                                                                                   |
| :------------------------------------------- | :---------------------------------------------------------------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **1. Leaderboard Real-time**           | `features/social/presentation/screens/leaderboard_screen.dart`  | Xóa `dummy_data.dart`. Dùng `StreamProvider` lắng nghe collection `users` với Query: `orderBy('xp', descending: true).limit(50)`. Map dữ liệu vào 3 vị trí Podium và danh sách.                                   |
| **2. Xử lý Badges (Huy hiệu)**      | `features/social/presentation/screens/badges_screen.dart`       | Thêm mảng `earnedBadges: ['first_blood', 'streak_7']` vào `UserModel`. Viết logic: Khi `streak == 7`, thêm ID huy hiệu vào mảng. Giao diện Badges tự động đổi trạng thái từ Locked (mờ) sang Earned (sáng). |
| **3. Tổng kết buổi học (Summary)** | `features/study/presentation/screens/study_summary_screen.dart` | Xóa dữ liệu tĩnh (20 words, +50 XP). Nhận tham số từ `StudyController` hiển thị đúng số thẻ User vừa học, sau đó tự động gọi API cộng `xp` vào Firestore.                                                 |

<br>

**Thành viên 3: Chế độ Offline & Tối ưu luồng thẻ (SRS)**

| Task (Việc cần làm)               | Vị trí file                              | Hướng dẫn triển khai chi tiết                                                                                                                                                                                                                                           |
| :----------------------------------- | :----------------------------------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **1. Cấu hình Local DB**     | `core/services/local_db_service.dart`    | Cài đặt `isar`. Viết hàm `syncVocabsToLocal()`: Khi mở app có mạng, tải (hoặc đối chiếu) toàn bộ sub-collection `vocabs` của User về máy để khởi tạo database cục bộ.                                                                          |
| **2. Logic Flashcard Offline** | `features/study/data/study_service.dart` | Sửa `loadDueCards()`: Query trực tiếp trên Local DB (không gọi Firebase) để UX lật thẻ siêu tốc. Khi đánh giá (Hard/Good/Easy), update Local DB ngay, sau đó lưu ID thẻ vào Queue để tiến trình ngầm (Background Task) đồng bộ lên Firestore. |
| **3. Bẫy lỗi CRUD Library**  | `features/library/`                      | Hiển thị `SnackBar` báo lỗi "Không có kết nối mạng" nếu User đang cố tạo/sửa bộ thẻ hoặc Import file Excel (hàm `importExcel()`) trong lúc mất mạng.                                                                                                |

<br>

**Thành viên 4: Tính năng Thông minh (OCR, TTS & Memory AI)**

| Task (Việc cần làm)                   | Vị trí file                                                   | Hướng dẫn triển khai chi tiết                                                                                                                                                                                                                                             |
| :--------------------------------------- | :-------------------------------------------------------------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **1. Phát âm (Text-to-Speech)**  | `features/tools/data/tts_service.dart`                        | Cài đặt `flutter_tts`. Khởi tạo config: ngôn ngữ (en-US), tốc độ đọc (0.5). Gắn hàm `speak(word)` vào icon loa trên `flashcard_screen.dart` và `pronunciation_screen.dart`.                                                                           |
| **2. Quét chữ từ Ảnh (OCR)**   | `features/tools/presentation/screens/ocr_scanner_screen.dart` | Cài đặt `google_mlkit_text_recognition` và `image_picker`. Cho phép chụp ảnh tài liệu, ML Kit trả về Text Block. Viết logic: User chạm vào từ nào trong Text Block đó, tự động chuyển sang form `add_vocab_screen.dart` và điền sẵn từ vựng. |
| **3. Trí nhớ cho Chatbot**       | `features/tools/data/ai_service.dart`                         | Lưu lịch sử mảng tin nhắn (History) của lớp `ChatSession` xuống Local DB. Khi user mở lại `chatbot_screen.dart`, nạp History này vào để Gemini AI vẫn nhớ bối cảnh cuộc trò chuyện trước đó.                                                     |
| **4. Trigger Animation Thực tế** | `features/social/presentation/widgets/streak_popup.dart`      | Kết nối Popup với Riverpod. Viết logic chặn: Popup ăn mừng Streak CHỈ được hiển thị 1 lần duy nhất trong ngày, đúng vào khoảnh khắc User hoàn thành thẻ học khiến biến `streak_count` nhảy số.                                                  |
---

### Sprint 4: Tương tác Xã hội & Kích thích Học tập (Social & Gamification)

**Mục tiêu cốt lõi:** Nâng cấp VitaminC bằng các tính năng "Low Effort - High Impact", tập trung vào Gamification (Trò chơi hóa) và Tương tác xã hội để giữ chân người dùng (Retention), tạo động lực học tập mỗi ngày và tạo hiệu ứng lan truyền (Viral) tự nhiên cho ứng dụng.

#### ⚠️ LƯU Ý QUAN TRỌNG CHO SPRINT 4 (TẤT CẢ THÀNH VIÊN CẦN ĐỌC KỸ)

**1. Tận dụng Thư viện UI (Package Utilization)**
Tuyệt đối không tự code từ đầu các logic vật lý phức tạp (như vuốt thả thẻ, vòng quay may mắn). Bắt buộc sử dụng triệt để các package đã được kiểm chứng trên pub.dev (như `flutter_card_swiper`, `flutter_fortune_wheel`, `share_plus`) để tiết kiệm thời gian và đảm bảo hiệu năng mượt mà.

**2. Xác thực Dữ liệu phía Client (Client-side Validation)**
Tính năng "Cảnh sát ngôn ngữ" phải được xử lý ngay trên thiết bị của người dùng (dùng Regex). Không gọi API lên server hay Firebase để kiểm tra tiếng Việt nhằm tránh độ trễ (latency) và phản hồi lỗi (Error Handling) ngay lập tức cho người dùng.

**3. Bảo toàn Core Logic (Thuật toán SRS)**
Khi thay đổi giao diện học tập thành dạng quẹt thẻ (Tinder-style), phải hết sức cẩn thận để không làm đứt gãy luồng cập nhật dữ liệu của thuật toán lặp ngắt quãng. Giao diện thay đổi, nhưng dữ liệu đẩy xuống Local DB và Firebase phải giữ nguyên chuẩn cũ.

**4. Tối ưu Chi phí Database**
Phòng chat nhóm có thể sinh ra lượng Read/Write khổng lồ. Tuyệt đối không dùng `StreamProvider` lắng nghe toàn bộ collection Chat. **Bắt buộc** gắn `.orderBy('timestamp', descending: true).limit(30)` để chỉ tải những tin nhắn mới nhất.

---

#### 👨‍💻 Phân công nhiệm vụ chi tiết

**Thành viên 1 (Lead): Hạ tầng Chat & Kích thích Học tập tự động**

| Task (Việc cần làm) | Vị trí file | Hướng dẫn triển khai chi tiết |
| --- | --- | --- |
| **1. Cảnh sát Ngôn ngữ (English-Only)** | `core/utils/language_validator.dart` | Viết hàm `isVietnamese(String text)`. Sử dụng Regex kiểm tra chuỗi có chứa ký tự tiếng Việt có dấu (ă, â, đ, ê, ô, ơ, ư...) hay không. Trả về `true` hoặc `false` để UI sử dụng. |
| **2. Học bị động qua FCM** | `core/services/notification_service.dart` | Nâng cấp hàm gửi thông báo. Thay vì lời nhắc cố định, truy vấn ngẫu nhiên 1 từ vựng từ Local DB, nhét từ vựng + nghĩa + ví dụ vào nội dung thông báo đẩy ra màn hình khóa. |
| **3. Core Logic Phòng Chat** | `features/social/data/chat_service.dart` | Khởi tạo collection `global_chat`. Viết hàm `sendMessage()`. Đặc biệt lưu ý chèn thêm `timestamp: FieldValue.serverTimestamp()` để đảm bảo thứ tự tin nhắn không bị lệch. |

**Thành viên 2: Social UI & Viral Loop**

| Task (Việc cần làm) | Vị trí file | Hướng dẫn triển khai chi tiết |
| --- | --- | --- |
| **1. Khoe thành tích "Sống ảo"** | `features/social/presentation/widgets/streak_popup.dart` | Cài package `share_plus`. Dùng `RepaintBoundary` chụp ảnh Widget chúc mừng Streak thành file ảnh. Gắn vào nút "Chia sẻ" để gọi menu Share mặc định của điện thoại (lên FB/IG Story). |
| **2. UI Phòng Chat Nhóm** | `features/social/presentation/screens/group_chat_screen.dart` | Dựng UI chat bằng `StreamBuilder`. Tích hợp hàm `isVietnamese()`. Nếu user gõ tiếng Việt và bấm gửi, chặn lại ngay và hiện SnackBar cảnh báo: "Khu vực English-Only, hãy thử lại bằng tiếng Anh nhé!". |
| **3. Nhiệm vụ Đồng đội (Co-op)** | `features/social/presentation/screens/coop_quest_screen.dart` | Thiết kế một UI thanh tiến độ (Progress bar) hiển thị "Nhiệm vụ tuần: Lật 500 thẻ". Gọi dữ liệu tổng hợp từ Firestore để hiển thị phần trăm hoàn thành của cả hệ thống. |

**Thành viên 3: Trải nghiệm Học tập Vuốt chạm (Flashcard)**

| Task (Việc cần làm) | Vị trí file | Hướng dẫn triển khai chi tiết |
| --- | --- | --- |
| **1. Tích hợp Quẹt thẻ (Tinder-style)** | `features/study/presentation/screens/flashcard_screen.dart` | Cài đặt package `flutter_card_swiper`. Bọc Widget thẻ từ vựng hiện tại vào Swiper. Đảm bảo hiệu ứng vuốt trái/phải mượt mà, không bị khựng hình. |
| **2. Nối luồng Logic SRS** | `features/study/presentation/screens/flashcard_screen.dart` | Map thao tác vuốt với logic cũ: Bắt sự kiện quẹt trái (chưa thuộc) để gọi hàm đánh giá Hard; quẹt phải (đã thuộc) để gọi hàm đánh giá Easy. Ẩn/xóa các nút bấm Hard/Good/Easy cũ ở dưới đáy màn hình. |
| **3. Hiệu ứng Feedback Hình ảnh** | `features/study/presentation/widgets/swipe_overlay.dart` | Bổ sung hiệu ứng mờ (Overlay): Khi ngón tay kéo thẻ sang phải, phủ một lớp màu Xanh lá nhạt chữ "EASY"; kéo sang trái phủ màu Đỏ nhạt chữ "HARD" để tăng trải nghiệm xúc giác. |

**Thành viên 4: Gamification & Vòng quay may mắn**

| Task (Việc cần làm) | Vị trí file | Hướng dẫn triển khai chi tiết |
| --- | --- | --- |
| **1. Giao diện Daily Gacha** | `features/social/presentation/screens/lucky_spin_screen.dart` | Cài package `flutter_fortune_wheel`. Thiết kế màn hình hiển thị vòng quay với các ô phần thưởng (ví dụ: +10 XP, +50 XP, Huy hiệu bí ẩn). |
| **2. Logic Kích hoạt Vòng quay** | `features/study/presentation/screens/study_summary_screen.dart` | Viết logic điều kiện: Vòng quay chỉ hiện ra dưới dạng Dialog (hoặc chuyển trang) đúng 1 lần trong ngày sau khi người dùng hoàn thành 20 thẻ ôn tập đầu tiên. |
| **3. Xử lý Trả thưởng** | `features/dashboard/data/dashboard_service.dart` | Nhận kết quả từ vòng quay ngẫu nhiên. Gọi hàm `update()` lên Firestore kèm lệnh `FieldValue.increment()` để tự động cộng chính xác số điểm XP đó vào tài khoản người dùng. |
---
### Sprint 4 Nâng cao: Nâng cấp Gamification & Hệ thống Chat Đa phòng

**Mục tiêu cốt lõi:** Nâng cấp trải nghiệm học tập và tương tác cộng đồng bằng cách xây dựng hệ thống điểm XP động, mục tiêu học tập hàng ngày, các nhiệm vụ hàng ngày/đồng đội phong phú và nâng cấp phòng chat đơn lẻ thành hệ thống chat đa phòng (Multi-room Chat) linh hoạt.

#### ⚠️ LƯU Ý QUAN TRỌNG CHO SPRINT 4 NÂNG CAO (TẤT CẢ THÀNH VIÊN CẦN ĐỌC KỸ)

**1. Đồng bộ và Tránh xung đột State**
Khi thực hiện cộng điểm XP động và cập nhật trạng thái nhiệm vụ, phải đảm bảo đồng bộ hóa tức thì từ Firestore về giao diện (qua Riverpod StreamProvider) và xử lý ép kiểu số an toàn tránh lỗi crash khi nhận số thực.

**2. Độc lập Phòng Chat**
Khi phân tách phòng chat thành các phòng riêng biệt, các phòng phải hoạt động hoàn toàn độc lập, sử dụng collection phòng chat con và bảo mật dữ liệu theo mã phòng.

#### 👨‍💻 Phân công nhiệm vụ chi tiết

**Thành viên 1 (Lead): Nền tảng XP, Trạm Reset & Core Chat Đa phòng**

| Task (Việc cần làm) | Vị trí file | Hướng dẫn triển khai chi tiết |
| --- | --- | --- |
| **1. Trạm kiểm tra & Reset ngày mới** | `lib/features/auth/data/user_service.dart`<br>`lib/features/auth/presentation/providers/auth_provider.dart` | Triển khai hàm `checkAndResetDailyXp` tự động reset `dailyXp` về `0` khi người dùng mở app ở ngày mới. Gọi hàm bất đồng bộ trong `currentUserProvider`. |
| **2. Tích hợp điểm XP kép** | `lib/features/auth/data/user_service.dart` | Nâng cấp hàm `addXP` để tăng song song cả `xp` (tổng) và `dailyXp` (trong ngày) trên Firestore. |
| **3. Phân quyền và tạo phòng chat** | `lib/features/social/data/chat_service.dart` | Viết hàm tạo phòng chat mới ngẫu nhiên (hoặc bằng code nhập vào), lưu trữ ID phòng và danh sách thành viên tham gia. |

**Thành viên 2: Quản lý Nhiệm vụ & Đồng hành**

| Task (Việc cần làm) | Vị trí file | Hướng dẫn triển khai chi tiết |
| --- | --- | --- |
| **1. UI Mục tiêu ngày năng động** | `lib/features/dashboard/presentation/screens/home_screen.dart` | Thay đổi toàn bộ các chỉ số mục tiêu ngày tĩnh trên màn hình Home sang đọc dữ liệu động từ `currentUserProvider`. |
| **2. Thiết kế Quest Model & Service** | `lib/features/social/data/quest_service.dart` (Tạo mới) | Xây dựng cấu trúc nhiệm vụ cá nhân (Personal Quests) gồm tên nhiệm vụ, tiến độ, mốc hoàn thành, số XP thưởng, trạng thái nhận thưởng. |
| **3. Bảng Nhiệm vụ tuần Co-op đa mốc** | `lib/features/social/presentation/screens/coop_quest_screen.dart` | Nâng cấp thanh tiến độ Co-op đơn thành hiển thị nhiều cột mốc phần thưởng (Milestones/Tiers) để tăng động lực. |

**Thành viên 3: Tối ưu Trải nghiệm quay thưởng & Đồng bộ phòng Chat**

| Task (Việc cần làm) | Vị trí file | Hướng dẫn triển khai chi tiết |
| --- | --- | --- |
| **1. UI/UX Vòng quay mượt mà** | `lib/features/social/presentation/screens/lucky_spin_screen.dart` | Kết nối hành động quay thành công với lệnh invalidate provider để màn hình trang chủ phản ánh ngay XP mới nhất không bị trễ. |
| **2. Tham gia phòng Chat bằng mã** | `lib/features/social/presentation/screens/chat_room_list_screen.dart` (Tạo mới) | Xây dựng giao diện danh sách phòng chat hiện tại kèm theo hộp thoại nhập Code phòng để tham gia phòng chat bất kỳ. |

**Thành viên 4: Logic Nhiệm vụ & Chi tiết Phòng Chat**

| Task (Việc cần làm) | Vị trí file | Hướng dẫn triển khai chi tiết |
| --- | --- | --- |
| **1. Danh sách Nhiệm vụ cá nhân** | `lib/features/dashboard/presentation/screens/home_screen.dart` | Dựng danh sách nhiệm vụ cá nhân hôm nay (ví dụ: Học 5 từ, Quay vòng quay, Đạt 20 XP) và cho phép bấm nhận thưởng trực tiếp. |
| **2. Giao diện Phòng Chat Độc lập** | `lib/features/social/presentation/screens/chat_room_screen.dart` | Cập nhật màn hình chat nhóm cũ để lấy tin nhắn theo ID phòng chat cụ thể thay vì dùng chung phòng Global. |
---

### Sprint 5: Hoàn thiện, Tối ưu Hiệu năng & Trải nghiệm Người dùng (Polishing)

**Mục tiêu cốt lõi:** Liên kết toàn bộ ứng dụng thành một khối thống nhất, bít kín các lỗ hổng tính năng (như quên mật khẩu, trạng thái rỗng), tối ưu hóa hiệu năng bộ nhớ trên thiết bị Android và chuẩn hóa hệ thống thông báo lỗi (Error Handling) để giao tiếp thân thiện với người dùng.

#### ⚠️ LƯU Ý QUAN TRỌNG CHO SPRINT 5 (TẤT CẢ THÀNH VIÊN CẦN ĐỌC KỸ)

**1. Chuẩn hóa Thông điệp Lỗi (User-centric Error Handling)**
Tuyệt đối không hiển thị các mã lỗi hệ thống tiếng Anh (ví dụ: `Exception: timeout`, `null pointer`) ra màn hình cho người dùng cuối.
Trong các hệ thống hiện đại, một "Failure" (sự cố ngưng hoạt động) rất nhiều lúc xảy ra do đường truyền mạng hoặc dịch vụ bên thứ 3 (như Firebase, Gemini) bị sập, chứ không hoàn toàn do Bug trong code của nhóm. Do đó, các thông báo lỗi phải được bắt (catch) và dịch sang tiếng Việt thân thiện, ví dụ: *"Đường truyền mạng đang gặp sự cố, vui lòng kiểm tra lại kết nối"* hoặc *"Máy chủ đang bận, xin thử lại sau"*.

**2. Tối ưu Bộ nhớ (Memory Leak Prevention)**
Việc sử dụng Local DB (Isar), Text-to-Speech, Camera OCR và Animation tạo ra gánh nặng rất lớn cho RAM của điện thoại Android.
**Yêu cầu bắt buộc:** Tất cả các màn hình có sử dụng Controller (`TextEditingController`, `AnimationController`) hoặc các stream lắng nghe dữ liệu liên tục đều phải được gọi lệnh `dispose()` khi đóng màn hình để giải phóng bộ nhớ.

**3. Xử lý Trạng thái Rỗng (Empty States & Loading)**
Không được để một màn hình trắng tinh khi dữ liệu đang tải hoặc khi người dùng chưa có dữ liệu nào.
Phải luôn có `CircularProgressIndicator` (hoặc hiệu ứng Shimmer) khi chờ API. Nếu danh sách từ vựng trống, phải hiển thị hình ảnh minh họa và nút kêu gọi hành động: *"Bạn chưa có thẻ nào, hãy tạo ngay nhé!"*.

**4. Dọn dẹp Codebase & Chuẩn bị Đóng gói Android**
Vì nhóm chỉ tập trung build cho Android, hãy kiểm tra lại file `android/app/build.gradle`. Xóa bỏ toàn bộ các thư viện (dependencies) thừa không sử dụng trong `pubspec.yaml` để giảm thiểu dung lượng file APK cuối cùng.

---

#### 👨‍💻 Phân công nhiệm vụ chi tiết

**Thành viên 1 (Lead): Quản trị Lỗi trung tâm, Bảo mật & Automation Testing**

| Task (Việc cần làm) | Vị trí file | Hướng dẫn triển khai chi tiết |
| --- | --- | --- |
| **1. Trạm xử lý lỗi trung tâm** | `core/utils/app_exception_handler.dart` | Nâng cấp class này. Gom tất cả mã lỗi của Firebase (`user-not-found`, `network-request-failed`) và Isar lại. Viết hàm chuyển đổi (switch-case) các mã này thành một chuỗi String tiếng Việt chuẩn xác để UI gọi và hiển thị lên `SnackBar`. |
| **2. Bổ sung Quên mật khẩu** | `features/auth/presentation/screens/login_screen.dart` | Nối logic cho nút "Quên mật khẩu?". Mở một Dialog yêu cầu nhập Email. Gọi hàm `FirebaseAuth.instance.sendPasswordResetEmail(email)`. Hiển thị thông báo: *"Link đặt lại mật khẩu đã được gửi đến email của bạn"*. |
| **3. Khung Kiểm thử (Automation Test)** | `integration_test/app_test.dart` (Tạo mới) | Thiết lập kịch bản kiểm thử tự động (Integration Test) cho luồng quan trọng nhất: Mở app -> Đăng nhập -> Vào thư viện -> Bấm lật 1 thẻ. Đảm bảo luồng xương sống này không bao giờ bị gãy khi nhóm đẩy code mới lên. |
| **4. Xử lý Token hết hạn** | `features/auth/data/auth_repository.dart` | Viết thêm logic lắng nghe sự kiện user bị khóa hoặc token hết hạn. Nếu xảy ra, tự động kích hoạt hàm `signOut()` và đẩy người dùng văng ra ngoài màn hình Login với thông báo: *"Phiên đăng nhập đã hết hạn"*. |

**Thành viên 2: Tối ưu UI/UX, Hiệu ứng & Liên kết Điều hướng**

| Task (Việc cần làm) | Vị trí file | Hướng dẫn triển khai chi tiết |
| --- | --- | --- |
| **1. Empty States & Loading UI** | Toàn bộ thư mục `features/` | Rà soát tất cả các màn hình (Dashboard, Library, Leaderboard). Bổ sung widget `EmptyStateWidget` (kèm icon và text hướng dẫn) khi mảng dữ liệu trả về rỗng. Thay thế các màn hình chờ bằng hiệu ứng Shimmer (khung xám nhấp nháy) cho chuyên nghiệp. |
| **2. Deep Link Thông báo (FCM)** | `routing/app_router.dart` & `notification_service.dart` | Cấu hình để khi người dùng đang ở ngoài màn hình chính của điện thoại, bấm vào thông báo nhắc nhở học tập (FCM), ứng dụng sẽ mở lên và tự động nhảy thẳng vào trang `/study` (Flashcard) thay vì chỉ mở trang chủ chung chung. |
| **3. Xử lý UX Bàn phím ảo** | `features/library/presentation/screens/add_vocab_screen.dart` | Bọc các form nhập liệu bằng `SingleChildScrollView` và cấu hình `resizeToAvoidBottomInset = true` trong `Scaffold`. Đảm bảo khi bàn phím ảo của Android bật lên không bị che khuất nút "Lưu" hoặc báo lỗi vỡ layout sọc vàng đen. |

**Thành viên 3: Khớp nối Đồng bộ, Tối ưu RAM & Xung đột Dữ liệu**

| Task (Việc cần làm) | Vị trí file | Hướng dẫn triển khai chi tiết |
| --- | --- | --- |
| **1. Quét dọn Memory (Dispose)** | Toàn bộ dự án | Kiểm tra lại toàn bộ các `StatefulWidget`. Đảm bảo các `TextEditingController`, `AnimationController`, và đặc biệt là stream kết nối với Isar/Firestore phải được hủy (close/dispose) trong hàm `dispose()` để tránh tràn RAM gây giật lag app. |
| **2. Nút Đồng bộ thủ công (Force Sync)** | `features/settings/presentation/screens/settings_screen.dart` | Thêm nút "Đồng bộ dữ liệu" ở mục Cài đặt. Khi bấm vào, kích hoạt lệnh đẩy toàn bộ hàng đợi (Queue) từ Local Isar lên Firestore ngay lập tức (hiện loading vòng xoay). Dành cho trường hợp tiến trình ngầm bị hệ điều hành Android kill mất. |
| **3. Xử lý Xung đột Đồng bộ** | `core/services/local_db_service.dart` | Khi kéo dữ liệu từ Firestore về đè lên Local DB, viết logic so sánh biến `updatedAt` (Timestamp). Thẻ nào có thời gian cập nhật mới hơn thì giữ lại thẻ đó, tránh việc đồng bộ ngược làm mất dữ liệu học Offline của người dùng. |

**Thành viên 4: Hoàn thiện Tools, Analytics & Đóng gói APK**

| Task (Việc cần làm) | Vị trí file | Hướng dẫn triển khai chi tiết |
| --- | --- | --- |
| **1. Theo dõi Ứng dụng (Analytics)** | `main.dart` | Cài đặt `firebase_analytics` và `firebase_crashlytics`. Gắn các lệnh log event khi user thực hiện hành động quan trọng (VD: Hoàn thành 1 thẻ, Quét OCR thành công). Crashlytics sẽ tự bắt các lỗi crash Native Android gửi về Firebase Console. |
| **2. Bẫy lỗi Công cụ Thông minh** | `features/tools/presentation/screens/` | Xử lý các góc chết của AI/OCR: Thêm vòng xoay loading khi đang đợi Gemini rep. Báo lỗi *"Không tìm thấy chữ trong ảnh"* nếu OCR ML Kit trả về rỗng. Tự ngắt micro thu âm nếu user im lặng quá 5 giây (tránh treo app). |
| **3. Đóng gói & Tối ưu APK** | `android/app/build.gradle` & `android/app/src/main/` | Đổi tên ứng dụng chính thức trong `AndroidManifest.xml`. Cập nhật file logo (Icon) chuẩn của VitaminC vào thư mục `res/mipmap`. Bật cấu hình `minifyEnabled true` và `shrinkResources true` trong bản build release để nén giảm dung lượng file APK. |

---

