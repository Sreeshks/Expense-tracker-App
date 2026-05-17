import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/category_repository.dart';
import 'category_event.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository _repo;

  CategoryBloc({CategoryRepository? repo})
      : _repo = repo ?? CategoryRepository(),
        super(const CategoryState()) {
    on<CategoriesLoadRequested>(_onLoad);
    on<CategoryAdded>(_onAdd);
    on<CategoryDeleted>(_onDelete);
    on<CategoriesReset>((event, emit) => emit(const CategoryState()));
  }

  Future<void> _onLoad(
    CategoriesLoadRequested event,
    Emitter<CategoryState> emit,
  ) async {
    emit(state.copyWith(status: CategoryStatus.loading));
    try {
      final cats = await _repo.getAll();
      emit(state.copyWith(status: CategoryStatus.loaded, categories: cats));
    } catch (e) {
      emit(state.copyWith(
        status: CategoryStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onAdd(
    CategoryAdded event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      await _repo.add(event.name);
      final cats = await _repo.getAll();
      emit(state.copyWith(status: CategoryStatus.loaded, categories: cats));
    } catch (e) {
      emit(state.copyWith(
        status: CategoryStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDelete(
    CategoryDeleted event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      await _repo.softDelete(event.id);
      final cats = await _repo.getAll();
      emit(state.copyWith(status: CategoryStatus.loaded, categories: cats));
    } catch (e) {
      emit(state.copyWith(
        status: CategoryStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
