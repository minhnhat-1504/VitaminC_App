class FirestoreCollections {
  // Ngăn chặn việc khởi tạo class này (chỉ dùng các biến static)
  FirestoreCollections._();

  // --- ROOT COLLECTIONS (Thư mục gốc) ---
  static const String users = 'users';               // Lưu thông tin người dùng
  static const String globalDecks = 'global_decks';  // Lưu các bộ thẻ mẫu do Admin tạo

  // --- SUB-COLLECTIONS (Thư mục con bên trong Document của User) ---
  static const String userDecks = 'decks';           // Các bộ thẻ cá nhân của người dùng
  static const String vocabs = 'vocabs';             // Các từ vựng nằm trong bộ thẻ
}