import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../../../../core/models/user_model.dart';

class AuthRepository {
  // Đổi thành public hoặc tạo getter để Provider truy cập được
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Lấy dữ liệu User kèm Role từ Firestore
  Future<UserModel?> getUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists) return UserModel.fromMap(doc.data()!);
    return null;
  }

  // Đăng nhập Email/Password
  Future<UserCredential> signInEmail(String email, String password) async {
    return await auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // Đăng ký Email/Password (Mặc định role là user)
  Future<void> signUpEmail(String email, String password, String name) async {
    UserCredential credential = await auth.createUserWithEmailAndPassword(email: email, password: password);
    UserModel newUser = UserModel(
      uid: credential.user!.uid,
      email: email,
      displayName: name,
      photoUrl: '',
      role: 'user',
    );
    await _firestore.collection('users').doc(newUser.uid).set(newUser.toMap());
  }

    // Cập nhật hàm Đăng nhập Google
  Future<void> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) return;
    
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // 1. Thực hiện đăng nhập
    UserCredential userCredential = await auth.signInWithCredential(credential);
    User? user = userCredential.user;

    if (user != null) {
      // 2. Kiểm tra và lưu thông tin vào Firestore nếu là lần đầu hoặc cập nhật
      await _updateUserInFirestore(user);
    }
  }

  // Cập nhật hàm Đăng nhập Facebook
  Future<void> signInWithFacebook() async {
    final LoginResult result = await FacebookAuth.instance.login();
    if (result.status == LoginStatus.success) {
      final OAuthCredential credential = FacebookAuthProvider.credential(result.accessToken!.tokenString);
      
      // 1. Thực hiện đăng nhập
      UserCredential userCredential = await auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        // 2. Kiểm tra và lưu thông tin vào Firestore
        await _updateUserInFirestore(user);
      }
    }
  }

    // Hàm phụ trợ để xử lý việc lưu dữ liệu vào Firestore
  Future<void> _updateUserInFirestore(User user) async {
    final doc = await _firestore.collection('users').doc(user.uid).get();
    
    // Nếu user chưa tồn tại trong Firestore thì mới tạo mới (để tránh ghi đè Role)
    if (!doc.exists) {
      UserModel newUser = UserModel(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? 'New User',
        photoUrl: user.photoURL ?? '',
        role: 'user', // Mặc định là user
      );
      await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
    }
  }

  // Đăng xuất
  Future<void> signOut() async {
    await GoogleSignIn().signOut(); // Đảm bảo thoát cả Google
    await FacebookAuth.instance.logOut(); // Thoát Facebook
    await auth.signOut();
  }
}