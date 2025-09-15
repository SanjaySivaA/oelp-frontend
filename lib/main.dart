import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/selection_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/test_screen/test_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Auth Page',
      theme: ThemeData(primarySwatch: Colors.blue),

      initialRoute: '/test',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/selection': (context) => const SelectionScreen(),
        '/analytics': (context) => AnalyticsScreen(),
        '/test': (context) => const TestScreen(),
      },
    );
  }
}
