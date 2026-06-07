class FirestoreCollections {
  // Ngăn chặn việc khởi tạo class này (chỉ dùng các biến static)
  FirestoreCollections._();

  // --- ROOT COLLECTIONS (Thư mục gốc) ---
  static const String users = 'users'; // Lưu thông tin người dùng
  static const String globalDecks =
      'global_decks'; // Lưu các bộ thẻ mẫu do Admin tạo
  static const String globalChat = 'global_chat'; // Phòng chat nhóm toàn cục

  // --- SUB-COLLECTIONS (Thư mục con bên trong Document của User) ---
  static const String userDecks = 'decks'; // Các bộ thẻ cá nhân của người dùng
  static const String vocabs = 'vocabs'; // Các từ vựng nằm trong bộ thẻ
  static const String quests =
      'quests'; // Các nhiệm vụ hàng ngày của người dùng

  // --- SUB-COLLECTIONS / ROOT cho Chat ---
  static const String chatRooms = 'chat_rooms'; // Danh sách phòng chat
}
