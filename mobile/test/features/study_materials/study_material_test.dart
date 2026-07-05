import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/features/study_materials/presentation/study_material_bloc.dart';
import 'package:mobile/features/study_materials/presentation/study_material_event.dart';
import 'package:mobile/features/study_materials/presentation/study_material_state.dart';
import 'package:mobile/features/study_materials/data/study_material_repository.dart';
import 'package:mobile/features/study_materials/domain/study_material_model.dart';

class MockStudyMaterialRepository extends Mock implements StudyMaterialRepository {}

void main() {
  group('StudyMaterialBloc', () {
    late StudyMaterialRepository repository;
    late StudyMaterialBloc studyMaterialBloc;

    setUp(() {
      repository = MockStudyMaterialRepository();
      studyMaterialBloc = StudyMaterialBloc(repository: repository);
    });

    final materials = [
      StudyMaterial(id: '1', title: 'Notes', courseName: 'CS101', fileUrl: 'url', fileType: 'pdf', createdAt: DateTime.now()),
    ];

    test('initial state is StudyMaterialState()', () {
      expect(studyMaterialBloc.state, const StudyMaterialState());
    });

    blocTest<StudyMaterialBloc, StudyMaterialState>(
      'emits [loading, success] when LoadMaterials is successful',
      build: () {
        when(() => repository.getMaterials(course: any(named: 'course'), query: any(named: 'query')))
            .thenAnswer((_) async => materials);
        return studyMaterialBloc;
      },
      act: (bloc) => bloc.add(const LoadMaterials()),
      expect: () => [
        const StudyMaterialState(status: StudyMaterialStatus.loading),
        StudyMaterialState(status: StudyMaterialStatus.success, materials: materials),
      ],
    );

    blocTest<StudyMaterialBloc, StudyMaterialState>(
      'emits [loading, success] when LoadMaterials with query is added',
      build: () {
        when(() => repository.getMaterials(course: any(named: 'course'), query: any(named: 'query')))
            .thenAnswer((_) async => materials);
        return studyMaterialBloc;
      },
      act: (bloc) => bloc.add(const LoadMaterials(query: 'notes')),
      expect: () => [
        const StudyMaterialState(status: StudyMaterialStatus.loading),
        StudyMaterialState(status: StudyMaterialStatus.success, materials: materials),
      ],
    );

    blocTest<StudyMaterialBloc, StudyMaterialState>(
      'emits [loading, success] when LoadMaterials with course is added',
      build: () {
        when(() => repository.getMaterials(course: any(named: 'course'), query: any(named: 'query')))
            .thenAnswer((_) async => materials);
        return studyMaterialBloc;
      },
      act: (bloc) => bloc.add(const LoadMaterials(course: 'CS101')),
      expect: () => [
        const StudyMaterialState(status: StudyMaterialStatus.loading),
        StudyMaterialState(status: StudyMaterialStatus.success, materials: materials),
      ],
    );
  });
}
