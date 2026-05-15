import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vitaminc/core/utils/firestore_collections.dart';
import 'package:vitaminc/features/library/data/models/deck_model.dart';
import 'package:vitaminc/features/library/data/models/vocab_model.dart';
import 'package:vitaminc/core/utils/app_exception_handler.dart';

class GlobalDeckService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  GlobalDeckService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw AppException('Yêu cầu đăng nhập!');
    }
    return uid;
  }

  /// Lấy danh sách các bộ thẻ mẫu
  Future<List<DeckModel>> getGlobalDecks() async {
    try {
      final snapshot = await _firestore
          .collection(FirestoreCollections.globalDecks)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => DeckModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw AppExceptionHandler.handleException(e, 'Lỗi khi tải danh sách bộ thẻ mẫu');
    }
  }

  /// Tải về (Clone) một bộ thẻ mẫu vào thư viện cá nhân
  Future<DeckModel> cloneToPersonal(DeckModel globalDeck) async {
    try {
      final batch = _firestore.batch();
      
      // 1. Lấy tất cả từ vựng của global deck này
      final vocabsSnapshot = await _firestore
          .collection(FirestoreCollections.globalDecks)
          .doc(globalDeck.id)
          .collection(FirestoreCollections.vocabs)
          .get();

      // 2. Tạo một Deck cá nhân mới
      final newDeckRef = _firestore
          .collection(FirestoreCollections.users)
          .doc(_uid)
          .collection(FirestoreCollections.userDecks)
          .doc();
          
      final personalDeck = globalDeck.copyWith(
        id: newDeckRef.id,
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
      );
      batch.set(newDeckRef, personalDeck.toMap());

      // 3. Clone các từ vựng vào personal vocabs
      for (var doc in vocabsSnapshot.docs) {
        final globalVocab = VocabModel.fromMap(doc.data(), doc.id);
        
        final newVocabRef = _firestore
            .collection(FirestoreCollections.users)
            .doc(_uid)
            .collection(FirestoreCollections.vocabs)
            .doc();
            
        final personalVocab = globalVocab.copyWith(
          id: newVocabRef.id,
          deckId: newDeckRef.id, // trỏ tới personal deck mới
          createdAt: Timestamp.now(),
          updatedAt: Timestamp.now(),
          // reset SRS info về mặc định cho thẻ mới
          easinessFactor: 2.5,
          interval: 1,
          repetition: 0,
          nextReview: Timestamp.now(),
        );
        batch.set(newVocabRef, personalVocab.toMap());
      }

      await batch.commit();
      return personalDeck;
    } catch (e) {
      throw AppExceptionHandler.handleException(e, 'Lỗi khi nhân bản bộ thẻ mẫu');
    }
  }

  /// Admin: Xuất bản bộ thẻ cá nhân thành bộ thẻ mẫu
  Future<void> publishToGlobal(DeckModel personalDeck) async {
    try {
      final batch = _firestore.batch();
      
      // 1. Tạo document trong global_decks
      final globalDeckRef = _firestore
          .collection(FirestoreCollections.globalDecks)
          .doc();
          
      final globalDeck = personalDeck.copyWith(
        id: globalDeckRef.id,
        createdAt: Timestamp.now(),
        updatedAt: Timestamp.now(),
      );
      batch.set(globalDeckRef, globalDeck.toMap());

      // 2. Lấy tất cả từ vựng cá nhân thuộc deck này
      final vocabsSnapshot = await _firestore
          .collection(FirestoreCollections.users)
          .doc(_uid)
          .collection(FirestoreCollections.vocabs)
          .where('deckId', isEqualTo: personalDeck.id)
          .get();

      // 3. Đưa vào sub-collection vocabs của global_decks
      for (var doc in vocabsSnapshot.docs) {
        final personalVocab = VocabModel.fromMap(doc.data(), doc.id);
        
        final newGlobalVocabRef = globalDeckRef
            .collection(FirestoreCollections.vocabs)
            .doc();
            
        final globalVocab = personalVocab.copyWith(
          id: newGlobalVocabRef.id,
          deckId: globalDeckRef.id,
          createdAt: Timestamp.now(),
          updatedAt: Timestamp.now(),
        );
        batch.set(newGlobalVocabRef, globalVocab.toMap());
      }

      await batch.commit();
    } catch (e) {
      throw AppExceptionHandler.handleException(e, 'Lỗi khi xuất bản bộ thẻ mẫu');
    }
  }
}
