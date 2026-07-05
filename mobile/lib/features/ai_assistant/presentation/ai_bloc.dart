import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import '../domain/chat_message_model.dart';
import '../data/ai_repository.dart';

// Global navigator key for accessing context outside widgets
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// States
enum AIStatus { initial, loading, success, error }

class AIState extends Equatable {
  final List<ChatMessage> messages;
  final AIStatus status;
  final String? errorMessage;
  final Map<String, dynamic>? workload;
  final List<Map<String, String>> suggestions;
  final List<Map<String, dynamic>>? reminders;
  final List<Map<String, dynamic>>? studySessions;

  const AIState({
    this.messages = const [],
    this.status = AIStatus.initial,
    this.errorMessage,
    this.workload,
    this.suggestions = const [],
    this.reminders,
    this.studySessions,
  });

  AIState copyWith({
    List<ChatMessage>? messages,
    AIStatus? status,
    String? errorMessage,
    Map<String, dynamic>? workload,
    List<Map<String, String>>? suggestions,
    List<Map<String, dynamic>>? reminders,
    List<Map<String, dynamic>>? studySessions,
  }) {
    return AIState(
      messages: messages ?? this.messages,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      workload: workload ?? this.workload,
      suggestions: suggestions ?? this.suggestions,
      reminders: reminders ?? this.reminders,
      studySessions: studySessions ?? this.studySessions,
    );
  }

  @override
  List<Object?> get props => [messages, status, errorMessage, workload, suggestions, reminders, studySessions];
}

// Events
abstract class AIEvent extends Equatable {
  const AIEvent();
  @override
  List<Object?> get props => [];
}

class LoadAIInsights extends AIEvent {
  const LoadAIInsights();
}

class MessageSent extends AIEvent {
  final String text;
  const MessageSent({required this.text});
  
  @override
  List<Object?> get props => [text];
}

// BLoC
class AIBloc extends Bloc<AIEvent, AIState> {
  final AIRepository repository;

  AIBloc({required this.repository}) : super(const AIState()) {
    on<LoadAIInsights>(_onLoadAIInsights);
    on<MessageSent>(_onMessageSent);
  }

  Future<void> _onLoadAIInsights(LoadAIInsights event, Emitter<AIState> emit) async {
    emit(state.copyWith(status: AIStatus.loading));
    try {
      final workload = await repository.getWorkloadAnalysis();
      final remindersData = await repository.getSmartReminders();
      final suggestionsData = await repository.getStudySuggestions();
      final studySessionsData = await repository.getMySessions();

      final reminders = remindersData.map((r) => r as Map<String, dynamic>).toList();
      
      final suggestions = suggestionsData.map((s) {
        final Map<String, String> mapped = {};
        (s as Map<String, dynamic>).forEach((key, value) {
          mapped[key] = value.toString();
        });
        return mapped;
      }).toList();
      
      final studySessions = studySessionsData.map((s) {
        return {
          'id': s.id,
          'subject': s.subject,
          'date': s.dayOfWeek,
          'duration': '${s.startTime} - ${s.endTime}',
        };
      }).toList();

      emit(state.copyWith(
        workload: workload,
        reminders: reminders,
        studySessions: studySessions,
        suggestions: suggestions,
        status: AIStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(status: AIStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> _onMessageSent(MessageSent event, Emitter<AIState> emit) async {
    // Add user message
    final userMessage = ChatMessage(
      text: event.text,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
    );
    
    emit(state.copyWith(
      messages: [...state.messages, userMessage],
      status: AIStatus.loading,
    ));
    
    try {
      final aiResponseText = await repository.askAI(event.text);
      
      final aiMessage = ChatMessage(
        text: aiResponseText,
        sender: MessageSender.ai,
        timestamp: DateTime.now(),
      );
      
      emit(state.copyWith(
        messages: [...state.messages, aiMessage],
        status: AIStatus.success,
      ));
    } catch (e) {
      final errorMessage = ChatMessage(
        text: "Sorry, I couldn't process your request right now.",
        sender: MessageSender.ai,
        timestamp: DateTime.now(),
      );
      emit(state.copyWith(
        messages: [...state.messages, errorMessage],
        status: AIStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}
