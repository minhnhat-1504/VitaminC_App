import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vitaminc/core/utils/firestore_collections.dart';
import 'package:vitaminc/features/library/data/models/deck_model.dart';
import 'package:vitaminc/features/library/data/models/vocab_model.dart';

class LibraryService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  LibraryService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception('Yêu cầu đăng nhập để thực hiện chức năng này!');
    }
    return uid;
  }

  // ==========================================
  // PHẦN 1: QUẢN LÝ BỘ THẺ (DECKS)
  // ==========================================

  /// Thêm một bộ thẻ mới
  Future<DeckModel> addDeck(String title, {String description = ''}) async {
    try {
      final docRef = _firestore
          .collection(FirestoreCollections.users)
          .doc(_uid)
          .collection(FirestoreCollections.userDecks) // Sửa lại: userDecks thay vì vocabs
          .doc();

      final newDeck = DeckModel(
        id: docRef.id,
        title: title,
        description: description,
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
      );

      await docRef.set(newDeck.toMap());
      return newDeck;
    } catch (e) {
      throw Exception('Lỗi khi tạo bộ thẻ: $e');
    }
  }

  /// Lấy danh sách các bộ thẻ của User
  Future<List<DeckModel>> getDecks() async {
    try {
      final snapshot = await _firestore
          .collection(FirestoreCollections.users)
          .doc(_uid)
          .collection(FirestoreCollections.userDecks)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => DeckModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Lỗi khi tải danh sách bộ thẻ: $e');
    }
  }

  /// Đếm số thẻ cần học hôm nay của một bộ thẻ
  Future<int> getDueCount(String deckId) async {
    try {
      final aggregateQuery = await _firestore
          .collection(FirestoreCollections.users)
          .doc(_uid)
          .collection(FirestoreCollections.vocabs)
          .where('deckId', isEqualTo: deckId)
          .where('nextReview', isLessThanOrEqualTo: Timestamp.now())
          .count()
          .get();
      return aggregateQuery.count ?? 0;
    } catch (e) {
      // Fallback an toàn nếu Firebase yêu cầu Composite Index mà chưa được tạo
      try {
        final snapshot = await _firestore
            .collection(FirestoreCollections.users)
            .doc(_uid)
            .collection(FirestoreCollections.vocabs)
            .where('deckId', isEqualTo: deckId)
            .get();
        
        final now = Timestamp.now();
        int count = 0;
        for (var doc in snapshot.docs) {
          final data = doc.data();
          if (data['nextReview'] != null && (data['nextReview'] as Timestamp).compareTo(now) <= 0) {
            count++;
          }
        }
        return count;
      } catch (innerE) {
        return 0; 
      }
    }
  }

  /// Cập nhật thông tin Bộ thẻ
  Future<void> updateDeck(DeckModel deck) async {
    try {
      final updatedDeck = deck.copyWith(
        updatedAt: Timestamp.now(),
      );
      await _firestore
          .collection(FirestoreCollections.users)
          .doc(_uid)
          .collection(FirestoreCollections.userDecks)
          .doc(deck.id)
          .update(updatedDeck.toMap());
    } catch (e) {
      throw Exception('Lỗi khi cập nhật bộ thẻ: $e');
    }
  }

  /// Xóa bộ thẻ (Sẽ xóa luôn các từ vựng bên trong)
  Future<void> deleteDeck(String deckId) async {
    try {
      // 1. Xóa tất cả các thẻ nằm trong Deck này
      final vocabsSnapshot = await _firestore
          .collection(FirestoreCollections.users)
          .doc(_uid)
          .collection(FirestoreCollections.vocabs)
          .where('deckId', isEqualTo: deckId)
          .get();
      
      final batch = _firestore.batch();
      for (var doc in vocabsSnapshot.docs) {
        batch.delete(doc.reference);
      }
      
      // 2. Xóa Deck
      final deckRef = _firestore
          .collection(FirestoreCollections.users)
          .doc(_uid)
          .collection(FirestoreCollections.userDecks)
          .doc(deckId);
      batch.delete(deckRef);

      await batch.commit();
    } catch (e) {
      throw Exception('Lỗi khi xóa bộ thẻ: $e');
    }
  }

  // ==========================================
  // PHẦN 2: QUẢN LÝ TỪ VỰNG (VOCABS)
  // ==========================================

  /// Thêm một từ vựng mới vào bộ thẻ
  Future<void> addVocab(VocabModel vocab) async {
    try {
      final docRef = _firestore
          .collection(FirestoreCollections.users)
          .doc(_uid)
          .collection(FirestoreCollections.vocabs)
          .doc(); 

      final newVocab = vocab.copyWith(
        id: docRef.id,
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
      );

      await docRef.set(newVocab.toMap());
    } catch (e) {
      throw Exception('Lỗi khi thêm từ vựng: $e');
    }
  }

  /// Cập nhật từ vựng
  Future<void> updateVocab(VocabModel vocab) async {
    try {
      final updatedVocab = vocab.copyWith(
        updatedAt: Timestamp.now(),
      );

      await _firestore
          .collection(FirestoreCollections.users)
          .doc(_uid)
          .collection(FirestoreCollections.vocabs)
          .doc(vocab.id)
          .update(updatedVocab.toMap());
    } catch (e) {
      throw Exception('Lỗi khi cập nhật từ vựng: $e');
    }
  }

  /// Xóa từ vựng
  Future<void> deleteVocab(String vocabId) async {
    try {
      await _firestore
          .collection(FirestoreCollections.users)
          .doc(_uid)
          .collection(FirestoreCollections.vocabs)
          .doc(vocabId)
          .delete();
    } catch (e) {
      throw Exception('Lỗi khi xóa từ vựng: $e');
    }
  }

  /// Lấy toàn bộ từ vựng của 1 BỘ THẺ CỤ THỂ
  Future<List<VocabModel>> getVocabsByDeck(String deckId) async {
    try {
      final snapshot = await _firestore
          .collection(FirestoreCollections.users)
          .doc(_uid)
          .collection(FirestoreCollections.vocabs)
          .where('deckId', isEqualTo: deckId)
          .get();

      final vocabs = snapshot.docs
          .map((doc) => VocabModel.fromMap(doc.data(), doc.id))
          .toList();
          
      // Sort bằng Dart để tránh lỗi thiếu Firebase Composite Index (deckId + createdAt)
      vocabs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return vocabs;
    } catch (e) {
      throw Exception('Lỗi khi tải danh sách từ vựng: $e');
    }
  }

  /// Đếm tổng số thẻ trong một bộ thẻ
  Future<int> getTotalCount(String deckId) async {
    try {
      final aggregateQuery = await _firestore
          .collection(FirestoreCollections.users)
          .doc(_uid)
          .collection(FirestoreCollections.vocabs)
          .where('deckId', isEqualTo: deckId)
          .count()
          .get();
      return aggregateQuery.count ?? 0;
    } catch (e) {
      return 0; 
    }
  }
}
