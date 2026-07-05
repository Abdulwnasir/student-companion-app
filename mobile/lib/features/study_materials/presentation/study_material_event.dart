import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class StudyMaterialEvent extends Equatable {
  const StudyMaterialEvent();
  @override
  List<Object?> get props => [];
}

class LoadMaterials extends StudyMaterialEvent {
  final String? course;
  final String? query;
  const LoadMaterials({this.course, this.query});
  @override
  List<Object?> get props => [course, query];
}

class UploadMaterial extends StudyMaterialEvent {
  final String title;
  final String courseName;
  final File file;
  const UploadMaterial(this.title, this.courseName, this.file);
  @override
  List<Object?> get props => [title, courseName, file];
}

class DeleteMaterial extends StudyMaterialEvent {
  final String id;
  const DeleteMaterial(this.id);
  @override
  List<Object?> get props => [id];
}
