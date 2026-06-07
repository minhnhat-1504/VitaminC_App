class QuestModel {
  final String id;
  final String title;
  final int target;
  final int current;
  final int rewardXp;
  final bool isClaimed;

  QuestModel({
    required this.id,
    required this.title,
    required this.target,
    this.current = 0,
    required this.rewardXp,
    this.isClaimed = false,
  });

  bool get isCompleted => current >= target;

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'target': target,
      'current': current,
      'rewardXp': rewardXp,
      'isClaimed': isClaimed,
    };
  }

  factory QuestModel.fromMap(Map<String, dynamic> map, String documentId) {
    return QuestModel(
      id: documentId,
      title: map['title'] ?? '',
      target: (map['target'] as num?)?.toInt() ?? 1,
      current: (map['current'] as num?)?.toInt() ?? 0,
      rewardXp: (map['rewardXp'] as num?)?.toInt() ?? 0,
      isClaimed: map['isClaimed'] ?? false,
    );
  }
}
