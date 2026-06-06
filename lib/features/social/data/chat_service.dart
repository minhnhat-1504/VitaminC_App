import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/firestore_collections.dart';

/// Model đại diện cho 1 tin nhắn trong phòng chat nhóm
class ChatMessage {
  final String id;
  final String uid;
  final String displayName;
  final String photoUrl;
  final String text;
  final DateTime? timestamp;

  ChatMessage({
    required this.id,
    required this.uid,
    required this.displayName,
    required this.photoUrl,
    required this.text,
    this.timestamp,
  });

  factory ChatMessage.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final ts = data['timestamp'] as Timestamp?;
    return ChatMessage(
      id: doc.id,
      uid: data['senderId'] ?? '',
      displayName: data['senderName'] ?? 'Anonymous',
      photoUrl: data['senderPhotoUrl'] ?? '',
      text: data['message'] ?? '',
      timestamp: ts?.toDate(),
    );
  }
}

/// Service xử lý logic gửi/nhận tin nhắn trong phòng chat nhóm toàn cục
class ChatService {
  final FirebaseFirestore _firestore;

  ChatService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Gửi tin nhắn lên Firestore
  /// [timestamp] luôn dùng serverTimestamp() để đảm bảo thứ tự chính xác
  Future<void> sendMessage({
    required String uid,
    required String displayName,
    required String photoUrl,
    required String text,
  }) async {
    await _firestore.collection(FirestoreCollections.globalChat).add({
      'senderId': uid,
      'senderName': displayName,
      'senderPhotoUrl': photoUrl,
      'message': text,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  /// Stream lắng nghe tin nhắn mới nhất (mặc định 30 tin)
  /// Gắn limit để tối ưu chi phí Read trên Firestore
  Stream<List<ChatMessage>> getMessages({int limit = 30}) {
    return _firestore
        .collection(FirestoreCollections.globalChat)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ChatMessage.fromDoc(doc)).toList());
  }
}
