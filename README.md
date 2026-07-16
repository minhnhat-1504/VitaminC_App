# VitaminC - Ung dung hoc tieng Anh thong minh

VitaminC la ung dung hoc tieng anh tich hop he thong lap ngat quang (SRS) giup nguoi dung ghi nho tu vung lau dai, ket hop cung tro ly ao AI ho tro luyen phan xa giao tiep. Du an duoc phat trien tren nen tang Flutter cho thiet bi Android.

## 1. Cac tinh nang chinh

### Hoc tap thong minh qua the ghi nho (Flashcard)
- Ung dung thuat toan lap ngat quang SM-2 de toi uu hoa thoi gian on tap tu vung cua tung ca nhan.
- Che do hoc va on tap tu vung linh hoat theo cac muc do nho khac nhau (Kho, Tot, De).
- Ho tro hieu ung lat the flashcard 3D muot ma de tang trai nghiem hoc tap.

### Tich hop tri tue nhan tao va tien ich thong minh
- Chatbot giao vien tieng Anh duoc phat trien tren nen tang Google Gemini AI ho tro giai dap thac mac va tao cac vi du thuc te.
- Cong nghe nhan dien ky tu quang hoc (OCR) cho phep quet va nhan dien tu vung tu hinh anh de them vao kho tu nhanh chong.
- Tinh nang Text-to-Speech (TTS) giup phat am chuan xac cac tu vung tieng Anh.
- Tinh nang Speech-to-Text (STT) ho tro nguoi dung luyen phat am va tu dong cham diem do chinh xac theo thang do tu dong.

### Ket noi va thi dua (Gamification)
- Phong chat nhom da phong hoc (Multi-room Chat) giup nguoi dung trao doi truc tuyen bang tieng Anh. He thong tu dong phat hien va nhac nho khi nguoi dung nhap ky tu tieng Viet de dam bao moi truong tieng Anh hoan toan.
- Bang xep hang hoc tap thoi gian thuc dua tren diem kinh nghiem (XP) tich luy.
- He thong nhiem vu hang ngay va nhiem vu dong doi de duy tri dong luc hoc tap.
- Vong quay may man hang ngay thuong diem kinh nghiem hoac phan qua ngau nhien khi hoan thanh muc tieu hoc.
- Tinh nang theo doi Streak ghi nhan so ngay hoc lien tuc cua nguoi dung.

### Ho tro che do ngoai tuyen (Offline-First)
- Toi uu hoa luu tru cuc bo thong qua co so du lieu Isar Database.
- Cho phap hoc va lam viec voi flashcard ma khong can ket noi mang.
- Tu dong dong bo hoa du lieu len may chu Firebase khi thiet bi co ket noi Internet tro lai.

---

## 2. Cong nghe su dung

- Ngon ngu lap trinh: Dart
- Framework: Flutter
- Quan ly trang thai: Flutter Riverpod
- Dieu huong (Routing): GoRouter
- Co so du lieu thoi gian thuc va xac thuc: Firebase (Auth, Firestore, Storage, Cloud Messaging)
- Co so du lieu cuc bo (Offline): Isar Database
- Trí tue nhan tao: Google Generative AI (Gemini 1.5 Flash)
- Thu vien OCR va STT: Google ML Kit Text Recognition, Speech-to-Text, Flutter TTS

---

## 3. Huong dan cai dat va cau hinh

### Yeu cau he thong
- Flutter SDK phien ban tu 3.10 tro len.
- Java Development Kit (JDK) phien ban 17.
- Thiet bi Android hoac trinh gia lap chay Android API 21 tro len (yeu cau Android API 23 cho mot so tinh nang AI).

### Buoc 1: Tai ma nguon ve may cuc bo
```bash
git clone https://github.com/minhnhat-1504/VitaminC_App.git
cd vitaminc
```

### Buoc 2: Cai dat cac thu vien phu thuoc (Dependencies)
Chay lenh sau tai thu muc goc cua du an de tai ve tat ca cac thu vien can thiet:
```bash
flutter pub get
```

### Buoc 3: Cau hinh Firebase cho Android
1. Truy cap Firebase Console va tao mot du an moi dat ten la VitaminC.
2. Them ung dung Android vao du an voi ten goi Package Name trung khop voi cau hinh trong file `android/app/build.gradle` (vi du: `com.minhnhat.vitaminc`).
3. Lay thong tin chung thu SHA-1 cua thiet bi phat trien va nhap vao cau hinh Firebase de cho phep dang nhap bang Google.
4. Tai xuong file `google-services.json` va luu vao thu muc `android/app/`.
5. Mo file `android/app/build.gradle` de dam bao tuy chon `multiDexEnabled true` da duoc thiet lap.

### Buoc 4: Thiet lap API Key cho Gemini
Dang ky mot API Key tai Google AI Studio va cau hinh vao file moi truong (`.env`) tai thu muc goc cua ung dung voi noi dung sau:
```text
GEMINI_API_KEY=YOUR_GEMINI_API_KEY
```

---

## 4. Huong dan chay ung dung

Sau khi hoan thanh cac buoc cai dat va cau hinh tren, ket noi thiet bi Android hoac bat trinh gia lap len, sau do chay lenh sau trong terminal:

```bash
flutter run
```

De kiem tra va dinh dang lai ma nguon theo dung tieu chuan, ban co the chay lenh:
```bash
dart format .
```
