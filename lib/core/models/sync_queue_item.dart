import 'package:hive_ce/hive.dart';

part 'sync_queue_item.g.dart';

@HiveType(typeId: 1)
class SyncQueueItem extends HiveObject {
  @HiveField(0)
  String vocabId;

  @HiveField(1)
  String action; // 'update' or 'delete'

  @HiveField(2)
  DateTime createdAt;

  SyncQueueItem({
    required this.vocabId,
    required this.action,
    required this.createdAt,
  });
}
