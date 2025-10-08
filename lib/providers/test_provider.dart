// lib/providers/test_provider.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/test_models.dart';
import '../services/api_service.dart';

// --- ENUM FOR QUESTION STATUS ---
enum QuestionStatus {
  notVisited,
  notAnswered,
  answered,
  markedForReview,
  answeredAndMarkedForReview,
}

// --- TEST STATE CLASS (WITH MISSING PROPERTIES ADDED) ---
class TestState {
  final bool isLoading;
  final Test? test;
  final String? error;
  final Map<String, dynamic> responses;
  final Map<String, QuestionStatus> statuses;
  final int timeRemainingInSeconds;
  final int currentQuestionIndex;
  final int currentSectionIndex; // <-- ADDED THIS

  TestState({
    this.isLoading = true,
    this.test,
    this.error,
    this.responses = const {},
    this.statuses = const {},
    this.timeRemainingInSeconds = 0,
    this.currentQuestionIndex = 0,
    this.currentSectionIndex = 0, // <-- ADDED THIS
  });

  TestState copyWith({
    bool? isLoading,
    Test? test,
    String? error,
    Map<String, dynamic>? responses,
    Map<String, QuestionStatus>? statuses,
    int? timeRemainingInSeconds,
    int? currentQuestionIndex,
    int? currentSectionIndex, // <-- ADDED THIS
  }) {
    return TestState(
      isLoading: isLoading ?? this.isLoading,
      test: test ?? this.test,
      error: error ?? this.error,
      responses: responses ?? this.responses,
      statuses: statuses ?? this.statuses,
      timeRemainingInSeconds: timeRemainingInSeconds ?? this.timeRemainingInSeconds,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      currentSectionIndex: currentSectionIndex ?? this.currentSectionIndex, // <-- ADDED THIS
    );
  }
}

// --- TEST NOTIFIER CLASS (WITH MISSING METHODS ADDED) ---
class TestNotifier extends StateNotifier<TestState> {
  final ApiService _apiService;
  Timer? _timer;

  TestNotifier(this._apiService) : super(TestState()) {
    loadTest();
  }

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
      if (testData.sections.isNotEmpty && testData.sections.first.questions.isNotEmpty) {
        initialStatuses[testData.sections.first.questions.first.questionId] = QuestionStatus.notAnswered;
      }
      state = state.copyWith(
        isLoading: false,
        test: testData,
        timeRemainingInSeconds: testData.durationInSeconds,
        statuses: initialStatuses,
        responses: {},
      );
      _startTimer();
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
    final newStatuses = Map<String, QuestionStatus>.from(state.statuses);
    if (newStatuses[questionId] != QuestionStatus.answeredAndMarkedForReview) {
       newStatuses[questionId] = QuestionStatus.answered;
    }
    state = state.copyWith(responses: newResponses, statuses: newStatuses);
  }

  void goToQuestion(int index) {
    if (state.test == null) return;
    final allQuestions = state.test!.sections.expand((s) => s.questions).toList();
    if (index < 0 || index >= allQuestions.length) return;

    int newSectionIndex = 0;
    int questionCount = 0;
    for (int i = 0; i < state.test!.sections.length; i++) {
        final section = state.test!.sections[i];
        if(index < questionCount + section.questions.length){
            newSectionIndex = i;
            break;
        }
        questionCount += section.questions.length;
    }

    final newStatuses = Map<String, QuestionStatus>.from(state.statuses);
    final questionId = allQuestions[index].questionId;
    if (newStatuses[questionId] == QuestionStatus.notVisited) {
      newStatuses[questionId] = QuestionStatus.notAnswered;
    }
    
    state = state.copyWith(
        currentQuestionIndex: index, 
        currentSectionIndex: newSectionIndex, // Also update the section index
        statuses: newStatuses
    );
  }

  // --- ADDED THIS METHOD ---
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
    if (state.currentQuestionIndex < allQuestions.length - 1) {
      goToQuestion(state.currentQuestionIndex + 1);
    }
  }

  // --- ADDED THIS METHOD ---
  void markForReviewAndNext() {
    if (state.test == null) return;
    final allQuestions = state.test!.sections.expand((s) => s.questions).toList();
    final currentQuestionId = allQuestions[state.currentQuestionIndex].questionId;
    final newStatuses = Map<String, QuestionStatus>.from(state.statuses);
    final hasAnswer = state.responses.containsKey(currentQuestionId);

    if (hasAnswer) {
      newStatuses[currentQuestionId] = QuestionStatus.answeredAndMarkedForReview;
    } else {
      newStatuses[currentQuestionId] = QuestionStatus.markedForReview;
    }

    state = state.copyWith(statuses: newStatuses);
    // Move to next question after marking for review
    saveAndNext();
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
    _timer?.cancel();
    print('--- TEST SUBMITTED ---');
    print('Final Responses: ${state.responses}');
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

// --- RIVERPOD PROVIDERS (UNMODIFIED) ---
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

final testProvider = StateNotifierProvider<TestNotifier, TestState>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return TestNotifier(apiService);
});