// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/selection_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/test_screen/test_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/selection_screen_v2.dart';

void main() async {
  // This ensures our app is initialized correctly before we run it
  WidgetsFlutterBinding.ensureInitialized();
  
  // This container allows us to check auth state before the app UI runs
  final container = ProviderContainer();
  await container.read(authProvider.notifier).checkInitialAuth();

  runApp(UncontrolledProviderScope(
    container: container,
    child: const MyApp(),
  ));
}

// MyApp is a ConsumerWidget to access the ref object
class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // --- 1. CRITICAL FIX: Use ref.watch to make the router reactive ---
    final authState = ref.watch(authProvider);
    const String startRoute = String.fromEnvironment('START_ROUTE', defaultValue: '/');

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MockTest Platform',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Inter',
      ),
      initialRoute: startRoute,
      onGenerateRoute: (settings) {
        // Define protected routes (add the new screen here too)
        final protectedRoutes = ['/selection', '/test', '/analytics'];
        final isProtectedRoute = protectedRoutes.contains(settings.name);

        // If not authenticated and trying to access a protected route, redirect to login
        if (authState.status != AuthStatus.authenticated && isProtectedRoute) {
          return MaterialPageRoute(builder: (context) => const LoginScreen());
        }

        // If authenticated and trying to access a public-only route, redirect to the main selection screen
        if (authState.status == AuthStatus.authenticated && (settings.name == '/login' || settings.name == '/register' || settings.name == '/')) {
           // --- 2. IMPROVEMENT: Make the new screen the default for logged-in users ---
          return MaterialPageRoute(builder: (context) => const TestSelectionScreen());
        }

        // If guard checks pass, build the correct page
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (context) => const LandingPage());
          case '/login':
            return MaterialPageRoute(builder: (context) => const LoginScreen());
          case '/register':
            return MaterialPageRoute(builder: (context) => const RegisterScreen());
          case '/selection': // The old, simple selection screen
            return MaterialPageRoute(builder: (context) => const SelectionScreen());
          
          // --- 3. ADDED: The route for your new, animated selection screen ---
          case '/selection_v2':
            return MaterialPageRoute(builder: (context) => const TestSelectionScreen());

          case '/analytics':
            return MaterialPageRoute(builder: (context) => AnalyticsScreen());
          case '/test':
            return MaterialPageRoute(builder: (context) => const TestScreen());
          default:
            return MaterialPageRoute(builder: (context) => const Scaffold(body: Center(child: Text('Page not found'))));
        }
      },
    );
  }
}