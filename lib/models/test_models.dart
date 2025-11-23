// lib/models/test_models.dart

class Test {
  final String sessionId;
  final String testId;
  final String testName;
  final int durationInSeconds;
  final List<Section> sections;

  Test({
    required this.sessionId,
    required this.testId,
    required this.testName,
    required this.durationInSeconds,
    required this.sections,
  });

  factory Test.fromJson(Map<String, dynamic> json) {
    return Test(
      sessionId: json['sessionId'] ?? '',
      testId: json['testId'] ?? '',
      testName: json['testName'] ?? 'Unnamed Test',
      durationInSeconds: json['durationInSeconds'] ?? 0,
      sections: (json['sections'] as List? ?? [])
          .map((sectionJson) => Section.fromJson(sectionJson))
          .toList(),
    );
  }
}

class Section {
  final String sectionId;
  final String sectionName;
  final String questionType;
  //final int positiveMarks;
  //final int negativeMarks;
  final List<Question> questions;

  Section({
    required this.sectionId,
    required this.sectionName,
    required this.questionType,
    //required this.positiveMarks,
    //required this.negativeMarks,
    required this.questions,
  });

  factory Section.fromJson(Map<String, dynamic> json) {
    var questionsList = json['questions'] as List;
    List<Question> parsedQuestions = questionsList.map((i) => Question.fromJson(i)).toList();
    return Section(
      sectionId: json['sectionId'] ?? '',
      sectionName: json['sectionName'] ?? '',
      questionType: json['questionType'] ?? 'UNKNOWN',
      // positiveMarks: json['positiveMarks'] ?? 0,
      // negativeMarks: json['negativeMarks'] ?? 0,
      questions: (json['questions'] as List? ?? [])
          .map((qJson) => Question.fromJson(qJson))
          .toList(),
    );
  }
}

class Question {
  final String questionId;
  final String questionText;
  final String? questionImageUrl;
  final List<Option> options;
  final int positiveMarks;
  final int negativeMarks;

  Question({
    required this.questionId,
    required this.questionText,
    this.questionImageUrl,
    required this.options,
    required this.positiveMarks,
    required this.negativeMarks,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      // --- ADDED NULL CHECKS ---
      questionId: json['questionId'] ?? 'unknown_id',
      questionText: json['questionText'] ?? 'Error: Question text not found.',
      questionImageUrl: json['questionImageUrl'], // Already nullable, so it's safe
      options: (json['options'] as List? ?? [])
          .map((optJson) => Option.fromJson(optJson))
          .toList(),
      positiveMarks: json['positiveMarks'] ?? 0,
      negativeMarks: json['negativeMarks'] ?? 0,
    );
  }
}

class Option {
  final String optionId;
  final String optionText;
  final String? optionImageUrl;

  Option({
    required this.optionId,
    required this.optionText,
    this.optionImageUrl,
  });

  factory Option.fromJson(Map<String, dynamic> json) {
    return Option(
      // --- ADDED NULL CHECKS ---
      optionId: json['optionId'] ?? 'unknown_id',
      optionText: json['optionText'] ?? 'Error: Option text not found.',
      optionImageUrl: json['optionImageUrl'],
    );
  }
}