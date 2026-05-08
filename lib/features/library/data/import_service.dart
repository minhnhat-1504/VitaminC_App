import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vitaminc/core/utils/firestore_collections.dart';
import 'package:vitaminc/features/library/data/models/vocab_model.dart';
import 'package:vitaminc/features/library/data/models/deck_model.dart';
import 'package:path/path.dart' as path;

class ImportService {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ImportService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Import từ vựng hàng loạt từ file Excel (.xlsx)
  /// Sẽ tự động tạo một Bộ Thẻ (Deck) mới lấy tên là tên file Excel
  /// Trả về DeckModel vừa tạo
  Future<DeckModel?> importExcel() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) {
        throw Exception('Vui lòng đăng nhập để thực hiện chức năng này.');
      }

      // 1. Chọn file Excel
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        withData: true, // Cực kỳ quan trọng: Ép hệ điều hành nạp thẳng file vào bộ nhớ
      );

      if (result == null || result.files.single.bytes == null) {
        return null; // Người dùng hủy chọn hoặc file bị lỗi
      }

      // Lấy thẳng byte data, tránh dùng đường dẫn vật lý (path) hay gây lỗi trên Android 13+
      final bytes = result.files.single.bytes!;
      final fileName = result.files.single.name.replaceAll(RegExp(r'\.xlsx?$'), ''); // Tên file bỏ đuôi
      
      // 2. Đọc file Excel từ bytes
      Excel excel;
      try {
        excel = Excel.decodeBytes(bytes);
      } catch (e) {
        throw Exception('File Excel không đúng định dạng (.xlsx chuẩn) hoặc bị hỏng.');
      }
      
      List<VocabModel> vocabsToImport = [];
      final now = Timestamp.now();

      // 3. TẠO MỘT BỘ THẺ (DECK) MỚI TRƯỚC KHI IMPORT TỪ VỰNG
      final deckRef = _firestore
          .collection(FirestoreCollections.users)
          .doc(uid)
          .collection(FirestoreCollections.userDecks)
          .doc();
      
      final String deckId = deckRef.id;
      
      // Tạo Deck Document
      final newDeck = DeckModel(
        id: deckId,
        title: 'Imported: $fileName', // Tên bộ thẻ = Tên file
        description: 'Được import tự động từ Excel',
        createdAt: now,
        updatedAt: now,
      );
      await deckRef.set(newDeck.toMap());

      // 4. Đọc dữ liệu từ Excel và map vào deckId vừa tạo
      for (var table in excel.tables.keys) {
        var sheet = excel.tables[table];
        if (sheet == null) continue;

        bool isFirstRow = true;

        for (var row in sheet.rows) {
          if (row.isEmpty) continue;

          // Bỏ qua header nếu dòng đầu tiên chứa chữ 'word'
          if (isFirstRow) {
            isFirstRow = false;
            final firstCell = row.isNotEmpty && row[0]?.value != null 
                ? row[0]!.value.toString().toLowerCase() 
                : '';
            if (firstCell.contains('word')) {
              continue; // Đây là dòng tiêu đề, bỏ qua
            }
          }

          try {
            final wordValue = row.length > 0 && row[0]?.value != null ? row[0]!.value.toString().trim() : '';
            final meaningValue = row.length > 1 && row[1]?.value != null ? row[1]!.value.toString().trim() : '';
            final exampleValue = row.length > 2 && row[2]?.value != null ? row[2]!.value.toString().trim() : null;

            if (wordValue.isEmpty || meaningValue.isEmpty) continue;

            final docRef = _firestore
                .collection(FirestoreCollections.users)
                .doc(uid)
                .collection(FirestoreCollections.vocabs)
                .doc();

            vocabsToImport.add(VocabModel(
              id: docRef.id,
              deckId: deckId, 
              word: wordValue,
              meaning: meaningValue,
              example: exampleValue?.isNotEmpty == true ? exampleValue : null,
              nextReview: now,
              createdAt: now,
              updatedAt: now,
            ));
          } catch (e) {
            // Bỏ qua dòng bị lỗi và tiếp tục đọc dòng khác
            continue;
          }
        }
      }

      if (vocabsToImport.isEmpty) {
        // Nếu không có từ nào hợp lệ, xóa Deck trống vừa tạo
        await deckRef.delete();
        throw Exception('Không tìm thấy dữ liệu hợp lệ trong file Excel.');
      }

      // 5. Lưu hàng loạt vào Firestore
      int totalImported = 0;
      final int batchSize = 500; 
      
      for (int i = 0; i < vocabsToImport.length; i += batchSize) {
        final batch = _firestore.batch();
        final chunk = vocabsToImport.skip(i).take(batchSize).toList();
        
        for (var vocab in chunk) {
          final docRef = _firestore
              .collection(FirestoreCollections.users)
              .doc(uid)
              .collection(FirestoreCollections.vocabs)
              .doc(vocab.id);
          
          batch.set(docRef, vocab.toMap());
        }
        
        await batch.commit();
        totalImported += chunk.length;
      }

      return newDeck;
    } catch (e) {
      throw Exception('Lỗi khi import Excel: ${e.toString()}');
    }
  }
}
