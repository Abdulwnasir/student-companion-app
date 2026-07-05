import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mobile/features/ai_assistant/presentation/ai_bloc.dart';
import 'package:mobile/features/ai_assistant/presentation/ai_event.dart';
import 'package:mobile/features/ai_assistant/presentation/ai_state.dart';
import 'package:mobile/features/ai_assistant/data/ai_repository.dart';

class MockAIRepository extends Mock implements AIRepository {}

void main() {
  group('AIBloc', () {
    late AIRepository aiRepository;
    late AIBloc aiBloc;

    setUp(() {
      aiRepository = MockAIRepository();
      aiBloc = AIBloc(aiRepository: aiRepository);
    });

    test('initial state is AIState()', () {
      expect(aiBloc.state, const AIState());
    });

    // Test MessageSent
    blocTest<AIBloc, AIState>(
      'emits [loading, success] when MessageSent is successful',
      build: () {
        when(
          () => aiRepository.askAI(any()),
        ).thenAnswer((_) async => 'AI Response');
        return aiBloc;
      },
      act: (bloc) => bloc.add(const MessageSent(text: 'Hello')),
      expect: () => [
        predicate<AIState>(
          (state) =>
              state.status == AIStatus.loading &&
              state.messages.length == 1 &&
              state.messages.first.text == 'Hello',
        ),
        predicate<AIState>(
          (state) =>
              state.status == AIStatus.success &&
              state.messages.length == 2 &&
              state.messages.last.text == 'AI Response',
        ),
      ],
    );

    // Test LoadStudySuggestions
    blocTest<AIBloc, AIState>(
      'emits [loading, success] when LoadStudySuggestions is successful',
      build: () {
        when(
          () => aiRepository.getStudySuggestions(),
        ).thenAnswer((_) async => ['Suggestion 1']);
        return aiBloc;
      },
      act: (bloc) => bloc.add(LoadStudySuggestions()),
      expect: () => [
        const AIState(status: AIStatus.loading),
        const AIState(status: AIStatus.success, suggestions: ['Suggestion 1']),
      ],
    );

    // Test LoadAIInsights
    blocTest<AIBloc, AIState>(
      'emits [loading, success] when LoadAIInsights is successful',
      build: () {
        when(
          () => aiRepository.getWorkloadAnalysis(),
        ).thenAnswer((_) async => {'load': 'high'});
        when(
          () => aiRepository.getPrioritizedTasks(),
        ).thenAnswer((_) async => ['Task 1']);
        when(
          () => aiRepository.getSmartReminders(),
        ).thenAnswer((_) async => ['Reminder 1']);
        when(
          () => aiRepository.getStudySuggestions(),
        ).thenAnswer((_) async => ['Suggestion 1']);
        return aiBloc;
      },
      act: (bloc) => bloc.add(LoadAIInsights()),
      expect: () => [
        const AIState(status: AIStatus.loading),
        const AIState(
          status: AIStatus.success,
          workload: {'load': 'high'},
          prioritizedTasks: ['Task 1'],
          reminders: ['Reminder 1'],
          suggestions: ['Suggestion 1'],
        ),
      ],
    );
  });
}
