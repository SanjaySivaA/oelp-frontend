// lib/providers/test_provider.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/test_models.dart';
import '../services/api_service.dart';
import 'auth_provider.dart';

enum QuestionStatus {
  notVisited,
  notAnswered,
  answered,
  markedForReview,
  answeredAndMarkedForReview,
}

class TestState {
  final bool isLoading;
  final Test? test;
  final String? error;
  final Map<String, dynamic> responses;
  final Map<String, QuestionStatus> statuses;
  final int timeRemainingInSeconds;
  final int currentQuestionIndex;
  final int currentSectionIndex;
  
  // NEW: Add this flag
  final bool isSubmitted; 

  TestState({
    this.isLoading = true,
    this.test,
    this.error,
    this.responses = const {},
    this.statuses = const {},
    this.timeRemainingInSeconds = 0,
    this.currentQuestionIndex = 0,
    this.currentSectionIndex = 0,
    this.isSubmitted = false, // Default to false
  });

  TestState copyWith({
    bool? isLoading,
    Test? test,
    String? error,
    Map<String, dynamic>? responses,
    Map<String, QuestionStatus>? statuses,
    int? timeRemainingInSeconds,
    int? currentQuestionIndex,
    int? currentSectionIndex,
    bool? isSubmitted, // Add here
  }) {
    return TestState(
      isLoading: isLoading ?? this.isLoading,
      test: test ?? this.test,
      error: error ?? this.error,
      responses: responses ?? this.responses,
      statuses: statuses ?? this.statuses,
      timeRemainingInSeconds: timeRemainingInSeconds ?? this.timeRemainingInSeconds,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      currentSectionIndex: currentSectionIndex ?? this.currentSectionIndex,
      isSubmitted: isSubmitted ?? this.isSubmitted, // Add here
    );
  }
}

class TestNotifier extends StateNotifier<TestState> {
  final ApiService _apiService;
  final Ref _ref;
  Timer? _timer;

  TestNotifier(this._apiService, this._ref) : super(TestState());

  Future<void> loadTest() async {
    try {
      // Reset isSubmitted to false when loading a new test
      state = state.copyWith(isLoading: true, error: null, isSubmitted: false);

      final authToken = _ref.read(authProvider).token;
      if (authToken == null) {
        throw Exception('User is not authenticated.');
      }

      final testData = await _apiService.getTest(authToken);

      final initialStatuses = <String, QuestionStatus>{};
      final allQuestions = testData.sections.expand((s) => s.questions).toList();
      for (var question in allQuestions) {
        initialStatuses[question.questionId] = QuestionStatus.notVisited;
      }
      if (allQuestions.isNotEmpty) {
        initialStatuses[allQuestions.first.questionId] = QuestionStatus.notAnswered;
      }

      final Map<String, dynamic> initialResponses = { for (var q in allQuestions) q.questionId: null };

      state = state.copyWith(
        isLoading: false,
        test: testData,
        timeRemainingInSeconds: testData.durationInSeconds,
        statuses: initialStatuses,
        responses: initialResponses,
        currentQuestionIndex: 0,
        currentSectionIndex: 0,
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
        // --- TIMER HIT 0: AUTO SUBMIT ---
        timer.cancel();
        submitTest(); 
      }
    });
  }

  // ... (answerQuestion, goToQuestion, changeSection, saveAndNext, markForReviewAndNext, clearResponse remain the same) ...
  
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
        currentSectionIndex: newSectionIndex,
        statuses: newStatuses
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
    if (state.currentQuestionIndex < allQuestions.length - 1) {
      goToQuestion(state.currentQuestionIndex + 1);
    }
  }

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

  Future<void> submitTest() async {
    _timer?.cancel();
    if (state.test == null) return;
    
    // Prevent double submission
    if (state.isLoading) return; 
    
    state = state.copyWith(isLoading: true); // Show loading spinner

    try {
      final authToken = _ref.read(authProvider).token;
      if (authToken == null) throw Exception("User not authenticated.");

      await _apiService.submitTest(
        authToken: authToken,
        test: state.test!,
        responses: state.responses,
      );

      // --- SUCCESS: SET FLAG TO TRUE ---
      state = state.copyWith(isLoading: false, isSubmitted: true);

    } catch (e) {
      print('--- SUBMISSION FAILED ---');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final testProvider = StateNotifierProvider<TestNotifier, TestState>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return TestNotifier(apiService, ref);
});