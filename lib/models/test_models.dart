import 'dart:convert';

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
      sessionId: json['sessionId'],
      testId: json['testId'],
      testName: json['testName'],
      durationInSeconds: json['durationInSeconds'],
      sections: (json['sections'] as List)
          .map((sectionJson) => Section.fromJson(sectionJson))
          .toList(),
    );
  }
}

class Section {
  final String sectionId;
  final String sectionName;
  final List<Question> questions;

  Section({
    required this.sectionId,
    required this.sectionName,
    required this.questions,
  });

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      sectionId: json['sectionId'],
      sectionName: json['sectionName'],
      questions: (json['questions'] as List)
          .map((qJson) => Question.fromJson(qJson))
          .toList(),
    );
  }
}

class Question {
  final String questionId;
  final String questionText;
  final String? questionImageUrl;
  final String type; // "MCQ", "MSQ", "NUMERICAL"
  final int positiveMarks;
  final int negativeMarks;
  final List<Option> options;

  Question({
    required this.questionId,
    required this.questionText,
    this.questionImageUrl,
    required this.type,
    required this.positiveMarks,
    required this.negativeMarks,
    required this.options,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      questionId: json['questionId'],
      questionText: json['questionText'],
      questionImageUrl: json['questionImageUrl'],
      type: json['type'],
      positiveMarks: json['positiveMarks'],
      negativeMarks: json['negativeMarks'],
      options: (json['options'] as List)
          .map((optJson) => Option.fromJson(optJson))
          .toList(),
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
      optionId: json['optionId'],
      optionText: json['optionText'],
      optionImageUrl: json['optionImageUrl'],
    );
  }
}