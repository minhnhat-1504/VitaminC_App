import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class DeckModel extends Equatable {
  final String id;
  final String title;
  final String description;
  final String? coverImageUrl;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  const DeckModel({
    required this.id,
    required this.title,
    this.description = '',
    this.coverImageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  DeckModel copyWith({
    String? id,
    String? title,
    String? description,
    String? coverImageUrl,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return DeckModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'coverImageUrl': coverImageUrl,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory DeckModel.fromMap(Map<String, dynamic> map, String docId) {
    return DeckModel(
      id: docId,
      title: map['title'] as String? ?? 'Untitled Deck',
      description: map['description'] as String? ?? '',
      coverImageUrl: map['coverImageUrl'] as String?,
      createdAt: map['createdAt'] as Timestamp? ?? Timestamp.now(),
      updatedAt: map['updatedAt'] as Timestamp? ?? Timestamp.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        coverImageUrl,
        createdAt,
        updatedAt,
      ];
}
