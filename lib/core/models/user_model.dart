class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String photoUrl;
  final String role; // 'admin' hoặc 'user'
  final int xp;
  final int rank;

  /// Danh sách ID các huy hiệu người dùng đã đạt được
  /// Ví dụ: ['first_blood', 'streak_7', 'streak_30']
  final List<String> earnedBadges;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.photoUrl,
    required this.role,
    this.xp = 0,
    this.rank = 0,
    this.earnedBadges = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'role': role,
      'xp': xp,
      'rank': rank,
      'earnedBadges': earnedBadges,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      role: map['role'] ?? 'user',
      xp: map['xp'] ?? 0,
      rank: map['rank'] ?? 0,
      earnedBadges: List<String>.from(map['earnedBadges'] ?? []),
    );
  }
}
