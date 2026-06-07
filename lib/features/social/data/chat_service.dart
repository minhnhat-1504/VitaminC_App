import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/firestore_collections.dart';
import 'package:vitaminc/core/utils/app_exception_handler.dart';
import 'dart:math';

/// Model đại diện cho 1 phòng chat
class ChatRoom {
  final String id;
  final String name;
  final String joinCode;
  final List<String> members;
  final String lastMessage;
  final DateTime? lastMessageTime;

  ChatRoom({
    required this.id,
    required this.name,
    required this.joinCode,
    required this.members,
    this.lastMessage = '',
    this.lastMessageTime,
  });

  factory ChatRoom.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final ts = data['lastMessageTime'] as Timestamp?;
    return ChatRoom(
      id: doc.id,
      name: data['name'] ?? 'Unnamed Room',
      joinCode: data['joinCode'] ?? '',
      members: List<String>.from(data['members'] ?? []),
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTime: ts?.toDate(),
    );
  }
}

/// Model đại diện cho 1 tin nhắn trong phòng chat
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

/// Service xử lý logic phòng chat và gửi/nhận tin nhắn
class ChatService {
  final FirebaseFirestore _firestore;

  ChatService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Sinh mã join phòng ngẫu nhiên 6 ký tự
  String _generateJoinCode() {
    // Đã loại bỏ các ký tự dễ gây nhầm lẫn khi đọc bằng mắt: O, 0, I, 1, L
    const chars = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
    final random = Random();
    return String.fromCharCodes(Iterable.generate(6, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }

  /// Tạo một phòng chat mới
  Future<String> createGroupRoom(String name, String creatorUid) async {
    try {
      final code = _generateJoinCode();
      final docRef = await _firestore.collection(FirestoreCollections.chatRooms).add({
        'name': name,
        'joinCode': code,
        'members': [creatorUid],
        'lastMessage': 'Phòng đã được tạo',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      throw AppExceptionHandler.handleException(e, 'Lỗi tạo phòng chat');
    }
  }

  /// Tham gia phòng chat bằng mã (Join Code)
  Future<String> joinRoomByCode(String code, String uid) async {
    try {
      final query = await _firestore.collection(FirestoreCollections.chatRooms)
          .where('joinCode', isEqualTo: code.toUpperCase())
          .limit(1)
          .get();
          
      if (query.docs.isEmpty) {
        throw Exception('Không tìm thấy phòng với mã này');
      }
      
      final roomId = query.docs.first.id;
      final members = List<String>.from(query.docs.first.data()['members'] ?? []);
      
      if (!members.contains(uid)) {
        await _firestore.collection(FirestoreCollections.chatRooms).doc(roomId).update({
          'members': FieldValue.arrayUnion([uid])
        });
      }
      
      return roomId;
    } catch (e) {
      throw AppExceptionHandler.handleException(e, 'Lỗi tham gia phòng');
    }
  }

  /// Lắng nghe danh sách phòng mà User đang tham gia
  Stream<List<ChatRoom>> getUserRooms(String uid) {
    return _firestore.collection(FirestoreCollections.chatRooms)
        .where('members', arrayContains: uid)
        // Bỏ .orderBy('lastMessageTime') để tránh lỗi Composite Index
        .snapshots()
        .map((snapshot) {
          final rooms = snapshot.docs.map((doc) => ChatRoom.fromDoc(doc)).toList();
          // Sắp xếp danh sách ngay trên máy client (mới nhất lên đầu)
          rooms.sort((a, b) {
            final timeA = a.lastMessageTime ?? DateTime.fromMillisecondsSinceEpoch(0);
            final timeB = b.lastMessageTime ?? DateTime.fromMillisecondsSinceEpoch(0);
            return timeB.compareTo(timeA); // descending
          });
          return rooms;
        });
  }

  /// Gửi tin nhắn vào một phòng cụ thể
  Future<void> sendMessage({
    required String roomId,
    required String uid,
    required String displayName,
    required String photoUrl,
    required String text,
  }) async {
    try {
      final batch = _firestore.batch();
      
      // 1. Thêm tin nhắn vào sub-collection `messages`
      final messageRef = _firestore.collection(FirestoreCollections.chatRooms)
          .doc(roomId)
          .collection('messages')
          .doc();
          
      batch.set(messageRef, {
        'senderId': uid,
        'senderName': displayName,
        'senderPhotoUrl': photoUrl,
        'message': text,
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      // 2. Cập nhật lastMessage cho phòng
      final roomRef = _firestore.collection(FirestoreCollections.chatRooms).doc(roomId);
      batch.update(roomRef, {
        'lastMessage': '$displayName: $text',
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
      
      await batch.commit();
    } catch (e) {
      throw AppExceptionHandler.handleException(e, 'Lỗi gửi tin nhắn');
    }
  }

  /// Lắng nghe tin nhắn của một phòng cụ thể
  Stream<List<ChatMessage>> getMessages(String roomId, {int limit = 30}) {
    return _firestore
        .collection(FirestoreCollections.chatRooms)
        .doc(roomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ChatMessage.fromDoc(doc)).toList());
  }

  /// Rời phòng chat (Nếu phòng không còn ai thì xóa luôn phòng đó)
  Future<void> leaveRoom(String roomId, String uid) async {
    try {
      final roomRef = _firestore.collection(FirestoreCollections.chatRooms).doc(roomId);
      final doc = await roomRef.get();
      
      if (!doc.exists) return;
      
      final members = List<String>.from(doc.data()?['members'] ?? []);
      members.remove(uid);
      
      if (members.isEmpty) {
        // Không còn ai trong phòng -> Xóa phòng
        // Lưu ý: Đáng lẽ cần xóa cả sub-collection 'messages' nhưng Firestore client không hỗ trợ xóa đệ quy. 
        // Tuy nhiên xóa doc cha thì doc cha sẽ biến mất khỏi query.
        await roomRef.delete();
      } else {
        // Vẫn còn người -> Cập nhật lại danh sách members
        await roomRef.update({'members': members});
      }
    } catch (e) {
      throw AppExceptionHandler.handleException(e, 'Lỗi rời phòng chat');
    }
  }
}
