import 'package:uuid/uuid.dart';

import 'note_item.dart';

class AdjustmentNote {
  final String id;
  final String recipeId;
  final String recipeName;
  final String title;
  final List<NoteItem> items;
  final double ratio;
  final String memo;
  final DateTime createdAt;

  const AdjustmentNote({
    required this.id,
    required this.recipeId,
    required this.recipeName,
    this.title = '調整メモ',
    required this.items,
    required this.ratio,
    this.memo = '',
    required this.createdAt,
  });

  factory AdjustmentNote.create({
    required String recipeId,
    required String recipeName,
    String title = '',
    required List<NoteItem> items,
    required double ratio,
    String memo = '',
  }) {
    return AdjustmentNote(
      id: const Uuid().v4(),
      recipeId: recipeId,
      recipeName: recipeName,
      title: title.isEmpty ? '調整メモ' : title,
      items: items,
      ratio: ratio,
      memo: memo,
      createdAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'recipeId': recipeId,
        'recipeName': recipeName,
        'title': title,
        'items': items.map((i) => i.toJson()).toList(),
        'ratio': ratio,
        'memo': memo,
        'createdAt': createdAt.toIso8601String(),
      };

  factory AdjustmentNote.fromJson(Map<String, dynamic> json) {
    final itemsList = json['items'] as List? ?? json['adjustedIngredients'] as List;
    return AdjustmentNote(
      id: json['id'] as String,
      recipeId: json['recipeId'] as String,
      recipeName: json['recipeName'] as String,
      title: json['title'] as String? ?? '調整メモ',
      items: itemsList
          .map((i) => NoteItem.fromJson(i as Map<String, dynamic>))
          .toList(),
      ratio: (json['ratio'] as num).toDouble(),
      memo: json['memo'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
