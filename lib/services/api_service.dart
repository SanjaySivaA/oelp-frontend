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

  Future<RegisterResponse> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return RegisterResponse.fromJson(jsonDecode(response.body));
    } else {
      // Handle errors, e.g., email already registered
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['detail'] ?? 'Failed to register');
    }
  }

  // --- 3. ADD THE NEW loginUser METHOD ---
  Future<Token> loginUser({
    required String email,
    required String password,
  }) async {
    // IMPORTANT: Your backend's /login endpoint expects 'x-www-form-urlencoded' data,
    // not JSON. The http package handles this automatically when you pass a Map<String, String>
    // as the body without jsonEncode.
    final response = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'username': email, // The backend expects 'username' for the email
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      return Token.fromJson(jsonDecode(response.body));
    } else {
      // Handle errors, e.g., incorrect email or password
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['detail'] ?? 'Failed to login');
    }
  }

  Future<User> getMe(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/users/me'),
      // Send the token in the authorization header
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to fetch user data');
    }
  }


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

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});
