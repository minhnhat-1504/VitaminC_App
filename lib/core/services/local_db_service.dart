import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive_ce/hive.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:vitaminc/core/utils/firestore_collections.dart';
import 'package:vitaminc/features/library/data/models/vocab_model.dart';
import 'package:vitaminc/core/models/vocab_local.dart';
import 'package:vitaminc/core/models/sync_queue_item.dart';

class LocalDbService {
  final FirebaseFirestore _firestore;
  static const String _vocabsBoxName = 'vocabsBox';
  static const String _syncQueueBoxName = 'syncQueueBox';
  static const String _metaBoxName = 'metaBox';
  static const String _lastSyncTimeKey = 'lastSyncTime';

  LocalDbService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> init() async {
    await Hive.openBox<VocabLocal>(_vocabsBoxName);
    await Hive.openBox<SyncQueueItem>(_syncQueueBoxName);
    await Hive.openBox(_metaBoxName);
  }

  Box<VocabLocal> get _vocabsBox => Hive.box<VocabLocal>(_vocabsBoxName);
  Box<SyncQueueItem> get _syncQueueBox =>
      Hive.box<SyncQueueItem>(_syncQueueBoxName);
  Box get _metaBox => Hive.box(_metaBoxName);

  DateTime? getLastSyncTime() {
    final timeStr = _metaBox.get(_lastSyncTimeKey) as String?;
    if (timeStr != null) {
      return DateTime.parse(timeStr);
    }
    return null;
  }

  Future<void> setLastSyncTime(DateTime time) async {
    await _metaBox.put(_lastSyncTimeKey, time.toIso8601String());
  }

  /// Đồng bộ từ vựng từ Firestore về Local DB
  Future<void> syncVocabsFromFirestore(String uid) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    final isOffline = !connectivityResult.any(
      (r) => r != ConnectivityResult.none,
    );
    if (isOffline) {
      return; // Không có mạng
    }

    try {
      final lastSyncTime = getLastSyncTime();
      final collectionRef = _firestore
          .collection(FirestoreCollections.users)
          .doc(uid)
          .collection(FirestoreCollections.vocabs);

      QuerySnapshot snapshot;

      if (lastSyncTime == null) {
        // Full Sync
        snapshot = await collectionRef.get();
        await _vocabsBox.clear(); // Xóa sạch local nếu là lần đầu
      } else {
        // Delta Sync (Chỉ lấy các thay đổi từ Firestore)
        snapshot = await collectionRef
            .where('updatedAt', isGreaterThan: Timestamp.fromDate(lastSyncTime))
            .get();
      }

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final vocabModel = VocabModel.fromMap(data, doc.id);
        final vocabLocal = VocabLocal.fromVocabModel(vocabModel);

        // Cập nhật hoặc thêm mới
        await _vocabsBox.put(vocabLocal.id, vocabLocal);
      }

      // Lưu lại thời điểm sync
      await setLastSyncTime(DateTime.now());

      // Xử lý đẩy hàng đợi local lên Firestore sau khi sync về máy xong
      await processSyncQueue(uid);
    } catch (e) {
      print('Lỗi đồng bộ từ vựng: $e');
    }
  }

  /// Lấy danh sách thẻ cần ôn tập trực tiếp từ Local DB
  List<VocabLocal> getLocalDueCards({String? deckId, bool forceStudy = false}) {
    final now = DateTime.now();

    var dueCards = _vocabsBox.values.where((vocab) {
      bool isDue =
          forceStudy ||
          vocab.nextReview.isBefore(now) ||
          vocab.nextReview.isAtSameMomentAs(now);
      if (deckId != null) {
        return isDue && vocab.deckId == deckId;
      }
      return isDue;
    }).toList();

    // Sắp xếp ưu tiên ngày xa nhất chưa ôn lên trước
    dueCards.sort((a, b) => a.nextReview.compareTo(b.nextReview));
    return dueCards;
  }

  /// Tìm bộ thẻ có thời gian ôn tập gần nhất (nếu không có thẻ nào due)
  Map<String, dynamic>? getNearestReviewDeck() {
    VocabLocal? nearestVocab;
    for (var vocab in _vocabsBox.values) {
      if (nearestVocab == null) {
        nearestVocab = vocab;
      } else {
        if (vocab.nextReview.isBefore(nearestVocab.nextReview)) {
          nearestVocab = vocab;
        }
      }
    }
    if (nearestVocab != null) {
      return {
        'deckId': nearestVocab.deckId,
        'nextReview': nearestVocab.nextReview,
        'updatedAt': nearestVocab.updatedAt,
      };
    }
    return null;
  }

  /// Cập nhật từ vựng trong Local DB và thêm vào hàng đợi (khi User ôn tập)
  Future<void> updateLocalVocab(VocabModel updatedVocab) async {
    final vocabLocal = VocabLocal.fromVocabModel(updatedVocab);
    await _vocabsBox.put(vocabLocal.id, vocabLocal);

    // Thêm vào queue để đồng bộ
    await addToSyncQueue(vocabLocal.id, 'update');
  }

  /// Thêm tác vụ vào hàng đợi đồng bộ
  Future<void> addToSyncQueue(String vocabId, String action) async {
    // Nếu trong queue đã có tác vụ cho vocabId này thì cập nhật
    final existingIndex = _syncQueueBox.values.toList().indexWhere(
      (item) => item.vocabId == vocabId,
    );

    final item = SyncQueueItem(
      vocabId: vocabId,
      action: action,
      createdAt: DateTime.now(),
    );

    if (existingIndex >= 0) {
      await _syncQueueBox.putAt(existingIndex, item);
    } else {
      await _syncQueueBox.add(item);
    }
  }

  /// Xử lý đẩy hàng đợi đồng bộ lên Firestore
  Future<void> processSyncQueue(String uid) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    final isOffline = !connectivityResult.any(
      (r) => r != ConnectivityResult.none,
    );
    if (isOffline) {
      return; // Không có mạng
    }

    if (_syncQueueBox.isEmpty) return;

    try {
      final collectionRef = _firestore
          .collection(FirestoreCollections.users)
          .doc(uid)
          .collection(FirestoreCollections.vocabs);

      final batch = _firestore.batch();
      final keysToDelete = <dynamic>[];

      for (var key in _syncQueueBox.keys) {
        final item = _syncQueueBox.get(key);
        if (item == null) continue;

        final docRef = collectionRef.doc(item.vocabId);

        if (item.action == 'update') {
          final vocabLocal = _vocabsBox.get(item.vocabId);
          if (vocabLocal != null) {
            batch.set(
              docRef,
              vocabLocal.toVocabModel().toMap(),
              SetOptions(merge: true),
            );
          }
        } else if (item.action == 'delete') {
          batch.delete(docRef);
        }

        keysToDelete.add(key);
      }

      await batch.commit();

      // Xóa thành công khỏi queue
      await _syncQueueBox.deleteAll(keysToDelete);
    } catch (e) {
      print('Lỗi processSyncQueue: $e');
    }
  }

  /// [DEV ONLY] Đưa tất cả thẻ về trạng thái cần ôn tập ngay lập tức
  Future<void> mockAllCardsDue() async {
    final now = DateTime.now().subtract(const Duration(days: 1));
    for (var vocab in _vocabsBox.values) {
      vocab.nextReview = now;
      vocab.repetition = 1; // Giả sử đã học ít nhất 1 lần để được tính XP
      await _vocabsBox.put(vocab.id, vocab);
      await addToSyncQueue(vocab.id, 'update');
    }
  }

  /// Xóa sạch dữ liệu (khi người dùng đăng xuất)
  Future<void> clearAllData() async {
    await _vocabsBox.clear();
    await _syncQueueBox.clear();
    await _metaBox.clear();
  }
}
