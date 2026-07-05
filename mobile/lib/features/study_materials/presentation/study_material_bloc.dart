import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/study_material_repository.dart';
import 'study_material_event.dart';
import 'study_material_state.dart';

class StudyMaterialBloc extends Bloc<StudyMaterialEvent, StudyMaterialState> {
  final StudyMaterialRepository repository;

  StudyMaterialBloc({required this.repository}) : super(const StudyMaterialState()) {
    on<LoadMaterials>(_onLoadMaterials);
    on<UploadMaterial>(_onUploadMaterial);
    on<DeleteMaterial>(_onDeleteMaterial);
  }

  Future<void> _onLoadMaterials(LoadMaterials event, Emitter<StudyMaterialState> emit) async {
    emit(state.copyWith(status: StudyMaterialStatus.loading));
    try {
      final materials = await repository.getMaterials(course: event.course, query: event.query);
      emit(state.copyWith(status: StudyMaterialStatus.success, materials: materials));
    } catch (e) {
      emit(state.copyWith(status: StudyMaterialStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onUploadMaterial(UploadMaterial event, Emitter<StudyMaterialState> emit) async {
    emit(state.copyWith(isUploading: true));
    try {
      await repository.uploadMaterial(event.title, event.courseName, event.file);
      emit(state.copyWith(isUploading: false));
      add(const LoadMaterials());
    } catch (e) {
      emit(state.copyWith(isUploading: false, status: StudyMaterialStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onDeleteMaterial(DeleteMaterial event, Emitter<StudyMaterialState> emit) async {
    try {
      await repository.deleteMaterial(event.id);
      add(const LoadMaterials());
    } catch (e) {
      emit(state.copyWith(status: StudyMaterialStatus.error, errorMessage: e.toString()));
    }
  }
}
