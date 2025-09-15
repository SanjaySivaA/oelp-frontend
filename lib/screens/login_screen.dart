import 'package:flutter/material.dart';
import '../widgets/custom_textfield.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 800;

        return Scaffold(
          body: Row(
            children: [
              // Left panel (hidden on mobile)
              if (!isMobile)
                Expanded(
                  flex: 1,
                  child: Container(color: Colors.grey[200]),
                ),

              // Right panel (login form)
              Expanded(
                flex: 1,
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(32.0),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Login",
                              style: TextStyle(
                                  fontSize: 28, fontWeight: FontWeight.bold)),

                          const SizedBox(height: 24),
                          const Text("Email address"),
                          const SizedBox(height: 8),
                          const CustomTextField(hint: "Enter your email"),

                          const SizedBox(height: 16),
                          const Text("Password"),
                          const SizedBox(height: 8),
                          const CustomTextField(
                              hint: "Enter your password", obscure: true),

                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Checkbox(value: false, onChanged: (val) {}),
                              const Text("Remember Me"),
                            ],
                          ),

                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () {},
                              child: const Text("Login",
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white)),
                            ),
                          ),

                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Don’t have an account? "),
                              GestureDetector(
                                onTap: () {},
                                child: const Text(
                                  "Sign up",
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold),
                                ),
                              )
                            ],
                          ),

                          const SizedBox(height: 16),
                          Row(children: const [
                            Expanded(child: Divider()),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text("or"),
                            ),
                            Expanded(child: Divider()),
                          ]),

                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              icon: Image.network(
                                "https://cdn-icons-png.flaticon.com/512/281/281764.png",
                                height: 20,
                              ),
                              label: const Text("Sign in with Google"),
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
