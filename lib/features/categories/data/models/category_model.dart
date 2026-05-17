import 'package:equatable/equatable.dart';

class CategoryModel extends Equatable {
  final String id;
  final String name;
  final int isSynced;
  final int isDeleted;

  const CategoryModel({
    required this.id,
    required this.name,
    this.isSynced = 0,
    this.isDeleted = 0,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'is_synced': isSynced,
        'is_deleted': isDeleted,
      };

  factory CategoryModel.fromMap(Map<String, dynamic> map) => CategoryModel(
        id: map['id'] as String,
        name: map['name'] as String,
        isSynced: map['is_synced'] as int? ?? 0,
        isDeleted: map['is_deleted'] as int? ?? 0,
      );

  @override
  List<Object?> get props => [id, name, isSynced, isDeleted];
}
