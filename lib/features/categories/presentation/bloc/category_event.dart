import 'package:equatable/equatable.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();
  @override
  List<Object?> get props => [];
}

class CategoriesLoadRequested extends CategoryEvent {}

class CategoryAdded extends CategoryEvent {
  final String name;
  const CategoryAdded(this.name);
  @override
  List<Object?> get props => [name];
}

class CategoryDeleted extends CategoryEvent {
  final String id;
  const CategoryDeleted(this.id);
  @override
  List<Object?> get props => [id];
}

class CategoriesReset extends CategoryEvent {}
