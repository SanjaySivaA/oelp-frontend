// lib/providers/test_provider.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/test_models.dart';
import '../services/api_service.dart';

// --- ENUM & API SERVICE PROVIDER (UNMODIFIED) ---
enum QuestionStatus {
  notVisited,
  notAnswered,
  answered,
  markedForReview,
  answeredAndMarkedForReview,
}

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});


// --- TEST STATE CLASS (UNMODIFIED) ---
class TestState {
  final bool isLoading;
  final Test? test;
  final String? sessionId;
  final String? error;
  final Map<String, dynamic> responses;
  final Map<String, QuestionStatus> statuses;
  final int timeRemainingInSeconds;
  final int currentQuestionIndex;
  final int currentSectionIndex;

  TestState({
    this.isLoading = true,
    this.test,
    this.sessionId,
    this.error,
    this.responses = const {},
    this.statuses = const {},
    this.timeRemainingInSeconds = 0,
    this.currentQuestionIndex = 0,
    this.currentSectionIndex = 0,
  });

  TestState copyWith({
    bool? isLoading,
    Test? test,
    String? sessionId,
    String? error,
    Map<String, dynamic>? responses,
    Map<String, QuestionStatus>? statuses,
    int? timeRemainingInSeconds,
    int? currentQuestionIndex,
    int? currentSectionIndex,
  }) {
    return TestState(
      isLoading: isLoading ?? this.isLoading,
      test: test ?? this.test,
      sessionId: sessionId ?? this.sessionId,
      error: error ?? this.error,
      responses: responses ?? this.responses,
      statuses: statuses ?? this.statuses,
      timeRemainingInSeconds: timeRemainingInSeconds ?? this.timeRemainingInSeconds,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      currentSectionIndex: currentSectionIndex ?? this.currentSectionIndex,
    );
  }
}


// --- TEST NOTIFIER CLASS (COMPLETE & CORRECTED) ---
class TestNotifier extends StateNotifier<TestState> {
  final ApiService _apiService;
  Timer? _timer;

  TestNotifier(this._apiService) : super(TestState());

  Future<void> loadTest() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final testData = await _apiService.getTest();

      final initialStatuses = <String, QuestionStatus>{};
      for (var section in testData.sections) {
        for (var question in section.questions) {
          initialStatuses[question.questionId] = QuestionStatus.notVisited;
        }
      }

      state = state.copyWith(
        isLoading: false,
        test: testData,
        sessionId: testData.sessionId,
        timeRemainingInSeconds: testData.durationInSeconds,
        statuses: initialStatuses,
        responses: {},
      );
      _startTimer();
      // Mark the very first question as visited
      goToQuestion(0);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.timeRemainingInSeconds > 0) {
        state = state.copyWith(timeRemainingInSeconds: state.timeRemainingInSeconds - 1);
      } else {
        timer.cancel();
        submitTest();
      }
    });
  }

  void answerQuestion(String questionId, dynamic answer) {
    final newResponses = Map<String, dynamic>.from(state.responses);
    newResponses[questionId] = answer;
    state = state.copyWith(responses: newResponses);
  }
  
  void goToQuestion(int index) {
    if (state.test == null) return;
    final allQuestions = state.test!.sections.expand((s) => s.questions).toList();
    if (index < 0 || index >= allQuestions.length) return;
    
    int newSectionIndex = state.currentSectionIndex;
    if (index != state.currentQuestionIndex) {
      int questionCount = 0;
      for (int i = 0; i < state.test!.sections.length; i++) {
        questionCount += state.test!.sections[i].questions.length;
        if (index < questionCount) {
          newSectionIndex = i;
          break;
        }
      }
    }
    
    final newStatuses = Map<String, QuestionStatus>.from(state.statuses);
    final fromQuestionId = allQuestions[state.currentQuestionIndex].questionId;
    if (newStatuses[fromQuestionId] == QuestionStatus.notVisited) {
      newStatuses[fromQuestionId] = QuestionStatus.notAnswered;
    }
    final toQuestionId = allQuestions[index].questionId;
    if (newStatuses[toQuestionId] == QuestionStatus.notVisited) {
      newStatuses[toQuestionId] = QuestionStatus.notAnswered;
    }
    
    state = state.copyWith(
      currentQuestionIndex: index,
      currentSectionIndex: newSectionIndex,
      statuses: newStatuses,
    );
  }
  
  void changeSection(int newSectionIndex) {
    if (state.test == null || newSectionIndex < 0 || newSectionIndex >= state.test!.sections.length) {
      return;
    }
    int globalQuestionIndex = 0;
    for (int i = 0; i < newSectionIndex; i++) {
      globalQuestionIndex += state.test!.sections[i].questions.length;
    }
    goToQuestion(globalQuestionIndex);
  }

  void saveAndNext() {
    if (state.test == null) return;
    final allQuestions = state.test!.sections.expand((s) => s.questions).toList();
    final currentQuestionId = allQuestions[state.currentQuestionIndex].questionId;

    final currentResponse = state.responses[currentQuestionId];
    bool hasAnswer = false;
    if (currentResponse != null) {
      if (currentResponse is List) {
        hasAnswer = currentResponse.isNotEmpty;
      } else if (currentResponse is String) {
        hasAnswer = currentResponse.isNotEmpty;
      }
    }

    if (hasAnswer) {
      final newStatuses = Map<String, QuestionStatus>.from(state.statuses);
      newStatuses[currentQuestionId] = QuestionStatus.answered;
      state = state.copyWith(statuses: newStatuses);
    }
    
    goToQuestion(state.currentQuestionIndex + 1);
  }

  void markForReviewAndNext() {
    if (state.test == null) return;
    final allQuestions = state.test!.sections.expand((s) => s.questions).toList();
    final currentQuestionId = allQuestions[state.currentQuestionIndex].questionId;
    final newStatuses = Map<String, QuestionStatus>.from(state.statuses);

    final hasAnswer = state.responses[currentQuestionId] != null &&
        (state.responses[currentQuestionId] is List ? (state.responses[currentQuestionId] as List).isNotEmpty : (state.responses[currentQuestionId] as String).isNotEmpty);

    if (hasAnswer) {
      newStatuses[currentQuestionId] = QuestionStatus.answeredAndMarkedForReview;
    } else {
      newStatuses[currentQuestionId] = QuestionStatus.markedForReview;
    }

    state = state.copyWith(statuses: newStatuses);
    goToQuestion(state.currentQuestionIndex + 1);
  }

  void clearResponse() {
    if (state.test == null) return;
    final allQuestions = state.test!.sections.expand((s) => s.questions).toList();
    final currentQuestionId = allQuestions[state.currentQuestionIndex].questionId;
    final newResponses = Map<String, dynamic>.from(state.responses);
    newResponses.remove(currentQuestionId);
    final newStatuses = Map<String, QuestionStatus>.from(state.statuses);
    newStatuses[currentQuestionId] = QuestionStatus.notAnswered;
    state = state.copyWith(responses: newResponses, statuses: newStatuses);
  }

  void submitTest() {
    print('--- TEST SUBMITTED ---');
    print(state.responses);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

// --- GLOBAL PROVIDER (UNMODIFIED) ---
final testProvider = StateNotifierProvider<TestNotifier, TestState>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return TestNotifier(apiService);
});