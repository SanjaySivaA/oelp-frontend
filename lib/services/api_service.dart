import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/test_models.dart';

class ApiService {
  final String _baseUrl = "http://localhost:8000"; // placeholder

  Future<Test> getTest() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/getTest'));

      if (response.statusCode == 200) {
        return Test.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load test. Status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to connect to the server: $e');
    }
  }

  // TODO: Implement save progress method
  Future<void> saveProgress(String sessionId, Map<String, dynamic> responses) async {
    // This will send the data to POST /api/sessions/{sessionId}/progress
  }

  // TODO: Implement submit test method
  Future<void> submitTest(String sessionId, Map<String, dynamic> responses) async {
    // This will send the data to POST /api/sessions/{sessionId}/submit
  }
}