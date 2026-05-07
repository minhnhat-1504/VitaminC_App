import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/repositories/auth_repository.dart'; 
import '../../../../core/models/user_model.dart';

// Provider cung cấp Repository cho toàn bộ app
final authRepositoryProvider = Provider((ref) => AuthRepository());

// StreamProvider theo dõi trạng thái đăng nhập (User có null hay không) từ Firebase
final authStateProvider = StreamProvider<User?>((ref) {
  // Truy cập vào biến auth công khai từ Repository
  return ref.watch(authRepositoryProvider).auth.authStateChanges();
});

// FutureProvider lấy thông tin chi tiết User (bao gồm Role) từ Firestore
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final user = ref.watch(authStateProvider).value;
  if (user != null) {
    return ref.watch(authRepositoryProvider).getUserData(user.uid);
  }
  return null;
});