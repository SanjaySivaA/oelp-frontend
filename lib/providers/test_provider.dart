import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/test_models.dart';
import '../services/api_service.dart';

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
  final String? sessionId;
  final String? error;
  final Map<String, dynamic> responses;
  final Map<String, QuestionStatus> statuses; // questionId -> status
  final int timeRemainingInSeconds;
  final int currentQuestionIndex;

  TestState({
    this.isLoading = true,
    this.test,
    this.sessionId,
    this.error,
    this.responses = const {},
    this.statuses = const {},
    this.timeRemainingInSeconds = 0,
    this.currentQuestionIndex = 0,
  });

  // A helper method to create a copy of the state with some values changed.
  TestState copyWith({
    bool? isLoading,
    Test? test,
    String? sessionId,
    String? error,
    Map<String, dynamic>? responses,
    Map<String, QuestionStatus>? statuses,
    int? timeRemainingInSeconds,
    int? currentQuestionIndex,
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
    );
  }
}


class TestNotifier extends StateNotifier<TestState> {
  final ApiService _apiService;
  Timer? _timer;

  TestNotifier(this._apiService) : super(TestState());

  Future<void> loadTest() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final testData = await _apiService.getTest();

      // Initialize statuses for all questions
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
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void goToQuestion(int index) {
    final allQuestions = state.test!.sections.expand((s) => s.questions).toList();
    if (index < 0 || index >= allQuestions.length) return;
    if (index == state.currentQuestionIndex) return; // No need to do anything

    final newStatuses = Map<String, QuestionStatus>.from(state.statuses);
    
    // --- NEW LOGIC: Update status of the question we are LEAVING ---
    final fromQuestionId = allQuestions[state.currentQuestionIndex].questionId;
    // If we are leaving a question that was "Not Visited", it now becomes "Not Answered"
    if (newStatuses[fromQuestionId] == QuestionStatus.notVisited) {
      newStatuses[fromQuestionId] = QuestionStatus.notAnswered;
    }
    // ----------------------------------------------------------------

    // --- EXISTING LOGIC: Update status of the question we are GOING TO ---
    final toQuestionId = allQuestions[index].questionId;
    if (newStatuses[toQuestionId] == QuestionStatus.notVisited) {
      newStatuses[toQuestionId] = QuestionStatus.notAnswered;
    }
    
    state = state.copyWith(
      currentQuestionIndex: index,
      statuses: newStatuses,
    );
  }


  void saveAndNext() {
    final allQuestions = state.test!.sections.expand((s) => s.questions).toList();
    if (state.currentQuestionIndex >= allQuestions.length) return;

    final currentQuestionId = allQuestions[state.currentQuestionIndex].questionId;
    final newStatuses = Map<String, QuestionStatus>.from(state.statuses);

    // --- THE FIX IS HERE ---
    // Check if an answer for the current question actually exists and is not empty.
    final currentResponse = state.responses[currentQuestionId];
    bool hasAnswer = false;
    if (currentResponse != null) {
      if (currentResponse is List) {
        hasAnswer = currentResponse.isNotEmpty;
      } else if (currentResponse is String) {
        hasAnswer = currentResponse.isNotEmpty;
      }
    }

    // Only update the status to 'Answered' if an answer has been provided.
    if (hasAnswer) {
      newStatuses[currentQuestionId] = QuestionStatus.answered;
      state = state.copyWith(statuses: newStatuses); // Update state with new status
    }
    
    // Always navigate to the next question, regardless of whether it was answered.
    goToQuestion(state.currentQuestionIndex + 1);
  }

  void _startTimer() {
    _timer?.cancel(); // Cancel any existing timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.timeRemainingInSeconds > 0) {
        state = state.copyWith(timeRemainingInSeconds: state.timeRemainingInSeconds - 1);
      } else {
        timer.cancel();
        // TODO: Implement auto-submit logic
      }
    });
  }
  
  void answerQuestion(String questionId, dynamic answer) {
    final newResponses = Map<String, dynamic>.from(state.responses);
    newResponses[questionId] = answer;

    state = state.copyWith(responses: newResponses);
  }

  // TODO: Implement other methods like clearResponse, markForReview, etc.
  void markForReview(String questionId) {
     final newStatuses = Map<String, QuestionStatus>.from(state.statuses);
     // Logic to check if it's already answered or not
     newStatuses[questionId] = QuestionStatus.markedForReview;
     state = state.copyWith(statuses: newStatuses);
  }

  void markForReviewAndNext() {
    final allQuestions = state.test!.sections.expand((s) => s.questions).toList();
    if (state.currentQuestionIndex >= allQuestions.length) return;

    final currentQuestionId = allQuestions[state.currentQuestionIndex].questionId;
    final newStatuses = Map<String, QuestionStatus>.from(state.statuses);

    // Check if the question has an answer already
    final hasAnswer = state.responses[currentQuestionId] != null && (state.responses[currentQuestionId] as List).isNotEmpty;

    if (hasAnswer) {
      newStatuses[currentQuestionId] = QuestionStatus.answeredAndMarkedForReview;
    } else {
      newStatuses[currentQuestionId] = QuestionStatus.markedForReview;
    }

    state = state.copyWith(statuses: newStatuses);
    goToQuestion(state.currentQuestionIndex + 1);
  }

  void clearResponse() {
    final allQuestions = state.test!.sections.expand((s) => s.questions).toList();
    if (state.currentQuestionIndex >= allQuestions.length) return;
    
    final currentQuestionId = allQuestions[state.currentQuestionIndex].questionId;

    final newResponses = Map<String, dynamic>.from(state.responses);
    newResponses.remove(currentQuestionId); // Remove the answer

    final newStatuses = Map<String, QuestionStatus>.from(state.statuses);
    // Set status back to Not Answered (red), since they've visited it but cleared the answer
    newStatuses[currentQuestionId] = QuestionStatus.notAnswered;

    state = state.copyWith(responses: newResponses, statuses: newStatuses);
  }

  void submitTest() {
    // For now, this is a placeholder.
    // In a real app, you would show a confirmation dialog,
    // then call the ApiService to send the final responses to the backend.
    print('--- TEST SUBMITTED ---');
    print(state.responses);
    // TODO: Show a confirmation dialog
    // TODO: Call ApiService to submit
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

final testProvider = StateNotifierProvider<TestNotifier, TestState>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return TestNotifier(apiService);
});