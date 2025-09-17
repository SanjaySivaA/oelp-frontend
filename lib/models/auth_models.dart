class User {
  final String userId;
  final String email;
  final String name;

  User({required this.userId, required this.email, required this.name});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
    );
  }
}

class Token {
  final String accessToken;
  final String tokenType;

  Token({required this.accessToken, required this.tokenType});

  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
      accessToken: json['access_token'] ?? '',
      tokenType: json['token_type'] ?? '',
    );
  }
}

// This class represents the successful response from the /register endpoint
class RegisterResponse {
  final User userInfo;
  final Token token;

  RegisterResponse({required this.userInfo, required this.token});

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      userInfo: User.fromJson(json['user_info'] ?? {}),
      token: Token.fromJson(json['token'] ?? {}),
    );
  }
}