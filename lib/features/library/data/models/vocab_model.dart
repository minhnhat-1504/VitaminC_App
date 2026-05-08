import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class VocabModel extends Equatable {
  final String id;
  final String deckId; // Bổ sung deckId để phân nhóm từ vựng
  final String word;
  final String meaning;
  final String? example;
  final String? imageUrl;
  final String? audioUrl;
  
  // SRS Fields
  final double easinessFactor;
  final int interval;
  final int repetition;
  final Timestamp nextReview;
  
  // Metadata
  final Timestamp createdAt;
  final Timestamp updatedAt;

  const VocabModel({
    required this.id,
    required this.deckId,
    required this.word,
    required this.meaning,
    this.example,
    this.imageUrl,
    this.audioUrl,
    this.easinessFactor = 2.5,
    this.interval = 1,
    this.repetition = 0,
    required this.nextReview,
    required this.createdAt,
    required this.updatedAt,
  });

  VocabModel copyWith({
    String? id,
    String? deckId,
    String? word,
    String? meaning,
    String? example,
    String? imageUrl,
    String? audioUrl,
    double? easinessFactor,
    int? interval,
    int? repetition,
    Timestamp? nextReview,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return VocabModel(
      id: id ?? this.id,
      deckId: deckId ?? this.deckId,
      word: word ?? this.word,
      meaning: meaning ?? this.meaning,
      example: example ?? this.example,
      imageUrl: imageUrl ?? this.imageUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      easinessFactor: easinessFactor ?? this.easinessFactor,
      interval: interval ?? this.interval,
      repetition: repetition ?? this.repetition,
      nextReview: nextReview ?? this.nextReview,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'deckId': deckId,
      'word': word,
      'meaning': meaning,
      'example': example,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'easinessFactor': easinessFactor,
      'interval': interval,
      'repetition': repetition,
      'nextReview': nextReview,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory VocabModel.fromMap(Map<String, dynamic> map, String docId) {
    return VocabModel(
      id: docId,
      deckId: map['deckId'] as String? ?? '',
      word: map['word'] as String? ?? '',
      meaning: map['meaning'] as String? ?? '',
      example: map['example'] as String?,
      imageUrl: map['imageUrl'] as String?,
      audioUrl: map['audioUrl'] as String?,
      easinessFactor: (map['easinessFactor'] as num?)?.toDouble() ?? 2.5,
      interval: (map['interval'] as num?)?.toInt() ?? 1,
      repetition: (map['repetition'] as num?)?.toInt() ?? 0,
      nextReview: map['nextReview'] as Timestamp? ?? Timestamp.now(),
      createdAt: map['createdAt'] as Timestamp? ?? Timestamp.now(),
      updatedAt: map['updatedAt'] as Timestamp? ?? Timestamp.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        deckId,
        word,
        meaning,
        example,
        imageUrl,
        audioUrl,
        easinessFactor,
        interval,
        repetition,
        nextReview,
        createdAt,
        updatedAt,
      ];
}
