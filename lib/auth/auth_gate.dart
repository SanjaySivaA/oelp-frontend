// lib/auth/auth_gate.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'package:frontend/screens/selection_screen.dart';
import 'package:frontend/screens/welcome_screen.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We watch the authProvider to know the user's status
    final authState = ref.watch(authProvider);

    // We use a switch statement to decide which screen to show
    switch (authState.status) {
      case AuthStatus.authenticated:
        // If logged in, show the test selection screen
        return const SelectionScreen();
      case AuthStatus.unauthenticated:
        // If logged out, show the welcome/landing page
        return const LandingPage();
      case AuthStatus.loading:
      case AuthStatus.unknown:
      default:
        // While checking for a saved token or during a login, show a loading spinner
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
    }
  }
}