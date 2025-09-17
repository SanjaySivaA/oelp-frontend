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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(testProvider.notifier).loadTest();
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

    ref.listen(testProvider.select((s) => s.currentQuestionIndex), (_, next) {
      if (_pageController.hasClients && _pageController.page?.round() != next) {
        _pageController.animateToPage(next,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut);
      }
    });

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
          // The PageView is the base layer and is STATIC. It no longer resizes.
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              ref.read(testProvider.notifier).goToQuestion(index);
            },
            itemCount: allQuestions.length,
            itemBuilder: (context, index) {
              final question = allQuestions[index];
              return QuestionDisplay(question: question);
            },
          ),
          
          // The slide-out panel
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            right: _isPanelVisible ? 0 : -panelWidth,
            top: 0,
            bottom: 0,
            child: const RightNavigationPanel(),
          ),

          // The collapse button
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            right: _isPanelVisible ? panelWidth : 0,
            top: (MediaQuery.of(context).size.height / 2) - 150, // Adjusted position
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