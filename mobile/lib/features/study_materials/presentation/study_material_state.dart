import 'package:equatable/equatable.dart';
import '../domain/study_material_model.dart';

enum StudyMaterialStatus { initial, loading, success, error }

class StudyMaterialState extends Equatable {
  final StudyMaterialStatus status;
  final List<StudyMaterial> materials;
  final String? errorMessage;
  final bool isUploading;

  const StudyMaterialState({
    this.status = StudyMaterialStatus.initial,
    this.materials = const [],
    this.errorMessage,
    this.isUploading = false,
  });

  StudyMaterialState copyWith({
    StudyMaterialStatus? status,
    List<StudyMaterial>? materials,
    String? errorMessage,
    bool? isUploading,
  }) {
    return StudyMaterialState(
      status: status ?? this.status,
      materials: materials ?? this.materials,
      errorMessage: errorMessage ?? this.errorMessage,
      isUploading: isUploading ?? this.isUploading,
    );
  }

  @override
  List<Object?> get props => [status, materials, errorMessage, isUploading];
}
