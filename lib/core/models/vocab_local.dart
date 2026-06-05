import 'package:hive_ce/hive.dart';
import 'package:vitaminc/features/library/data/models/vocab_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'vocab_local.g.dart';

@HiveType(typeId: 0)
class VocabLocal extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String deckId;

  @HiveField(2)
  String word;

  @HiveField(3)
  String meaning;

  @HiveField(4)
  String? example;

  @HiveField(5)
  String? imageUrl;

  @HiveField(6)
  String? audioUrl;

  @HiveField(7)
  double easinessFactor;

  @HiveField(8)
  int interval;

  @HiveField(9)
  int repetition;

  @HiveField(10)
  DateTime nextReview;

  @HiveField(11)
  DateTime createdAt;

  @HiveField(12)
  DateTime updatedAt;

  VocabLocal({
    required this.id,
    required this.deckId,
    required this.word,
    required this.meaning,
    this.example,
    this.imageUrl,
    this.audioUrl,
    required this.easinessFactor,
    required this.interval,
    required this.repetition,
    required this.nextReview,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VocabLocal.fromVocabModel(VocabModel model) {
    return VocabLocal(
      id: model.id,
      deckId: model.deckId,
      word: model.word,
      meaning: model.meaning,
      example: model.example,
      imageUrl: model.imageUrl,
      audioUrl: model.audioUrl,
      easinessFactor: model.easinessFactor,
      interval: model.interval,
      repetition: model.repetition,
      nextReview: model.nextReview.toDate(),
      createdAt: model.createdAt.toDate(),
      updatedAt: model.updatedAt.toDate(),
    );
  }

  VocabModel toVocabModel() {
    return VocabModel(
      id: id,
      deckId: deckId,
      word: word,
      meaning: meaning,
      example: example,
      imageUrl: imageUrl,
      audioUrl: audioUrl,
      easinessFactor: easinessFactor,
      interval: interval,
      repetition: repetition,
      nextReview: Timestamp.fromDate(nextReview),
      createdAt: Timestamp.fromDate(createdAt),
      updatedAt: Timestamp.fromDate(updatedAt),
    );
  }
}
