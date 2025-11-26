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
  await container.read(authNotifierProvider.notifier).checkInitialAuth();

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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MockTest Platform',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Inter',
      ),
      initialRoute: const String.fromEnvironment('START_ROUTE', defaultValue: '/'),
      
      // onGenerateRoute is our new, smart router and route guard
      onGenerateRoute: (settings) {
        // We read the latest auth state here
        final authState = ref.read(authProvider);

        // Define which routes require the user to be logged in
        final protectedRoutes = ['/selection', '/test', '/analytics'];
        final isProtectedRoute = protectedRoutes.contains(settings.name);

        // --- THE ROUTE GUARD LOGIC ---
        // If the user is not authenticated and tries to access a protected route...
        if (authState.status != AuthStatus.authenticated && isProtectedRoute) {
          // ...redirect them to the landing page.
          return MaterialPageRoute(builder: (context) => const LandingPage());
        }

        // If the user IS authenticated and tries to go to login/register...
        if (authState.status == AuthStatus.authenticated && (settings.name == '/login' || settings.name == '/register' || settings.name == '/')) {
           // ...redirect them to the selection screen.
          return MaterialPageRoute(builder: (context) => const SelectionScreen());
        }

        // --- THE ROUTER LOGIC ---
        // If the guard checks pass, build the correct page.
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (context) => const LandingPage());
          case '/login':
            return MaterialPageRoute(builder: (context) => const LoginScreen());
          case '/register':
            return MaterialPageRoute(builder: (context) => const RegisterScreen());
          case '/selection':
            return MaterialPageRoute(builder: (context) => const SelectionScreen());
          case '/selection_v2':
            return MaterialPageRoute(builder: (context) => const TestSelectionScreen(),
                                     settings: settings
                                    );
          case '/analytics':
            return MaterialPageRoute(builder: (context) => AnalyticsScreen());
          case '/test_screen': // Change from '/test' to match your pushNamed call
            return MaterialPageRoute(
              builder: (context) => const TestScreen(),
              settings: settings, // IMPORTANT: Pass settings so arguments (sessionId) reach the screen
            );
          case '/test':
            return MaterialPageRoute(builder: (context) => const TestScreen());
          default:
            // Optional: A 404 page
            return MaterialPageRoute(builder: (context) => const Scaffold(body: Center(child: Text('Page not found'))));
        }
      },
    );
  }
}