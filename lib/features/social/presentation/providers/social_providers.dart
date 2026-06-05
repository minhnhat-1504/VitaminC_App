import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/firestore_collections.dart';
import '../../../../core/models/user_model.dart';

/// StreamProvider lắng nghe CSDL Firestore danh sách 50 người dùng có XP cao nhất
final leaderboardProvider = StreamProvider.autoDispose<List<UserModel>>((ref) {
  return FirebaseFirestore.instance
      .collection(FirestoreCollections.users)
      .orderBy('xp', descending: true)
      .limit(50)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs
            .map((doc) => UserModel.fromMap(doc.data()))
            .toList();
      });
});
