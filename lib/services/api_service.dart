// lib/services/api_service.dart

import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/test_models.dart';
import '../models/auth_models.dart';

class ApiService {
  static const _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );

  // ... (registerUser, loginUser, getMe remain the same) ...
  Future<RegisterResponse> registerUser({required String name, required String email, required String password}) async {
    final response = await http.post(Uri.parse('$_baseUrl/register'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'name': name, 'email': email, 'password': password}));
    if (response.statusCode == 200) return RegisterResponse.fromJson(jsonDecode(response.body));
    else throw Exception(jsonDecode(response.body)['detail'] ?? 'Failed to register');
  }

  Future<Token> loginUser({required String email, required String password}) async {
    final response = await http.post(Uri.parse('$_baseUrl/login'), headers: {'Content-Type': 'application/x-www-form-urlencoded'}, body: {'username': email, 'password': password});
    if (response.statusCode == 200) return Token.fromJson(jsonDecode(response.body));
    else throw Exception(jsonDecode(response.body)['detail'] ?? 'Failed to login');
  }

  Future<User> getMe(String token) async {
    final response = await http.get(Uri.parse('$_baseUrl/users/me'), headers: {'Authorization': 'Bearer $token'});
    if (response.statusCode == 200) return User.fromJson(jsonDecode(response.body));
    else throw Exception('Failed to fetch user data');
  }

  // --- EXISTING METHOD (For random tests) ---
  Future<Test> getTest(String authToken) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/getTest'),
      headers: {'Authorization': 'Bearer $authToken'},
    );
    if (response.statusCode == 200) {
      return Test.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load random test: ${response.body}');
    }
  }

  // --- NEW METHOD (For Chapterwise/Specific tests) ---
  Future<Test> getTestById(String authToken, String testId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/tests/$testId'),
      headers: {'Authorization': 'Bearer $authToken'},
    );

    if (response.statusCode == 200) {
      return Test.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load specific test: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> submitTest({
    required String authToken,
    required Test test,
    required Map<String, dynamic> responses,
  }) async {
    final List<Map<String, dynamic>> formattedAnswers = [];
    final allQuestions = test.sections.expand((s) => s.questions).toList();

    for (var question in allQuestions) {
      final dynamic responseForQuestion = responses[question.questionId];
      List<String> selectedOptionIds = [];
      if (responseForQuestion is List<String>) {
        selectedOptionIds = responseForQuestion;
      }
      formattedAnswers.add({'questionId': question.questionId, 'selectedOptionIds': selectedOptionIds});
    }
    
    final submissionPayload = {'sessionId': test.sessionId, 'answers': formattedAnswers};
    
    final response = await http.post(
      Uri.parse('$_baseUrl/tests/${test.testId}/submit'),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $authToken'},
      body: jsonEncode(submissionPayload),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to submit test. Status: ${response.statusCode}');
    }
  }
}

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});