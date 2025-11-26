// lib/screens/test_screen/test_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/test_provider.dart';
import 'widgets/test_header.dart';
import 'widgets/right_navigation_panel.dart';
import 'widgets/bottom_action_buttons.dart';
import 'widgets/question_display.dart';

class TestScreen extends ConsumerStatefulWidget {
  const TestScreen({super.key});

  @override
  ConsumerState<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends ConsumerState<TestScreen> {
  bool _isPanelVisible = true;
  final double panelWidth = 275;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    // Use post frame callback to safely access context and provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 1. Extract the Session ID passed from Selection Screen
      final args = ModalRoute.of(context)?.settings.arguments;
      final String? sessionId = (args is String) ? args : null;

      // 2. Load that SPECIFIC test (or random if null)
      ref.read(testProvider.notifier).loadTest(testId: sessionId);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final testState = ref.watch(testProvider);

    // 1. EXISTING: Listen for Question Index changes to animate the page
    ref.listen(testProvider.select((s) => s.currentQuestionIndex), (_, next) {
      if (_pageController.hasClients && _pageController.page?.round() != next) {
        _pageController.animateToPage(next,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut);
      }
    });

    // ============================================================
    // 2. NEW: Listen for Submission Status to Navigate Away
    // ============================================================
    ref.listen<TestState>(testProvider, (previous, next) {
      // If we transitioned from NOT submitted to SUBMITTED
      if ((previous?.isSubmitted == false) && next.isSubmitted) {
        
        // Navigate to your analytics or home screen
        // Using pushReplacementNamed so the user can't go "back" to the test
        Navigator.of(context).pushReplacementNamed('/analytics'); 

        // Optional: Show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Test Submitted Successfully!"),
            backgroundColor: Colors.green,
          ),
        );
      }
      
      // Optional: Handle Submission Errors here too
      if (previous?.error != next.error && next.error != null) {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${next.error}"), backgroundColor: Colors.red),
        );
      }
    });
    // ============================================================


    if (testState.error != null) {
      return Scaffold(
          body: Center(child: Text('An error occurred: ${testState.error}')));
    }

    if (testState.isLoading || testState.test == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final allQuestions = testState.test!.sections.expand((s) => s.questions).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: TestHeader(isPanelVisible: _isPanelVisible),
      body: Stack(
        children: [
          PageView.builder(
            physics: const NeverScrollableScrollPhysics(), // Recommended: Disable swipe so users must use buttons
            controller: _pageController,
            onPageChanged: (index) {
              // Optional: Keep this if you want swipe enabled, otherwise remove
              // ref.read(testProvider.notifier).goToQuestion(index);
            },
            itemCount: allQuestions.length,
            itemBuilder: (context, index) {
              final question = allQuestions[index];
              return QuestionDisplay(question: question);
            },
          ),
          
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            right: _isPanelVisible ? 0 : -panelWidth,
            top: 0,
            bottom: 0,
            child: const RightNavigationPanel(),
          ),

          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            right: _isPanelVisible ? panelWidth : 0,
            top: (MediaQuery.of(context).size.height / 2) - 150,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isPanelVisible = !_isPanelVisible;
                });
              },
              child: Container(
                width: 24,
                height: 100,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: Icon(
                  _isPanelVisible
                      ? Icons.arrow_forward_ios_rounded
                      : Icons.arrow_back_ios_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomActionButtons(),
    );
  }
}