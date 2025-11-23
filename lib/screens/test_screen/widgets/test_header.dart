// lib/screens/test_screen/widgets/test_header.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/test_models.dart';
import '../../../providers/test_provider.dart';

class TestHeader extends ConsumerWidget implements PreferredSizeWidget {
  final bool isPanelVisible;
  const TestHeader({super.key, required this.isPanelVisible});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final testState = ref.watch(testProvider);
    final test = testState.test;

    if (test == null) {
      return AppBar(title: const Text('Loading...'));
    }

    final allQuestions = test.sections.expand((s) => s.questions).toList();
    final currentQuestion = allQuestions[testState.currentQuestionIndex];
    final currentSection = test.sections[testState.currentSectionIndex];

    final timeRemaining = testState.timeRemainingInSeconds;
    final duration = Duration(seconds: timeRemaining);
    final timeString = '${duration.inHours.toString().padLeft(2, '0')}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';

    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 1.0,
      automaticallyImplyLeading: false,
      title: Text(test.testName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      actions: [
        Center(child: Text('Time Left: $timeString', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
        const VerticalDivider(indent: 12, endIndent: 12, thickness: 1, width: 32),
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Row(children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("User", style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text("Tests Taken: 15", style: TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
            const SizedBox(width: 16),
            const CircleAvatar(backgroundColor: Colors.pinkAccent, child: Text("U", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          ]),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(100.0),
        child: Column(
          children: [
            _buildSectionNavBar(context, ref, test, testState.currentSectionIndex),
            _buildQuestionDetailsBar(context, currentSection, currentQuestion),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionDetailsBar(BuildContext context, Section currentSection, Question currentQuestion) {
    const double panelWidth = 275;
    return AnimatedPadding(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: EdgeInsets.only(
        left: 0,
        right: isPanelVisible ? panelWidth  : 0,
        top: 8,
        bottom: 8,
      ),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Question Type: ${currentSection.questionType}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            RichText(
              text: TextSpan(
                // Default style for the plain text portions
                style: TextStyle(
                  fontFamily: 'Inter', // Ensures the font matches the rest of the app
                  color: Colors.grey[800], 
                  fontSize: 13,
                ),
                children: <TextSpan>[
                  const TextSpan(text: 'Marks: '),
                  // A separate TextSpan for the positive marks with a green color
                  TextSpan(
                    text: '+${currentQuestion.positiveMarks}',
                    style: const TextStyle(
                      color: Color(0xFF16A34A), // Green
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  const TextSpan(text: ' | Negative Marks: '),
                  // A separate TextSpan for the negative marks with a red color
                  TextSpan(
                    text: '${currentQuestion.negativeMarks}',
                    style: const TextStyle(
                      color: Color(0xFFEF5350), // Red
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSectionNavBar(BuildContext context, WidgetRef ref, Test test, int currentSectionIndex) {
    return Container(
      height: 58,
      color: const Color(0xFFF8F9FA),
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 12.0),
      alignment: Alignment.centerLeft,
      child: Row(children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: test.sections.asMap().entries.map((entry) {
                int sectionIndex = entry.key;
                Section section = entry.value;
                bool isActive = sectionIndex == currentSectionIndex;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ActionChip(
                    label: Text(section.sectionName),
                    backgroundColor: isActive ? Theme.of(context).primaryColor : Colors.grey[200],
                    labelStyle: TextStyle(color: isActive ? Colors.white : Colors.black87, fontWeight: isActive ? FontWeight.bold : FontWeight.normal),
                    onPressed: () {
                      ref.read(testProvider.notifier).changeSection(sectionIndex);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ]),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 100.0);
}