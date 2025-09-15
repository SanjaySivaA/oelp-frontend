// lib/screens/test_screen/widgets/right_navigation_panel.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/test_provider.dart';

class RightNavigationPanel extends ConsumerWidget {
  const RightNavigationPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final testState = ref.watch(testProvider);
    final test = testState.test!;
    final currentSectionName = test.sections.isNotEmpty ? test.sections[0].sectionName : 'Questions';
    final allQuestions = test.sections.expand((section) => section.questions).toList();

    return Container(
      width: 275, // It now has a fixed, constant width.
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(left: BorderSide(color: Colors.grey.shade300)),
      ),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildLegend(),
          const Divider(height: 24),
          _buildSectionHeader(currentSectionName),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.only(bottom: 12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: allQuestions.length,
              itemBuilder: (context, index) {
                final question = allQuestions[index];
                final status = testState.statuses[question.questionId] ?? QuestionStatus.notVisited;
                final color = _getColorForStatus(status);
                return InkWell(
                  onTap: () { 
                    ref.read(testProvider.notifier).goToQuestion(index);
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    decoration: BoxDecoration(
                        color: color.backgroundColor,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.grey.shade300)),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                            color: color.foregroundColor,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String sectionName) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: const Color(0xFF0D47A1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Text(
            sectionName,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white),
          ),
          const SizedBox(height: 4),
          const Text(
            'Choose a question',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 16.0,
      runSpacing: 8.0,
      children: const [
        _LegendItem(color: Colors.white, text: 'Not Visited'),
        _LegendItem(color: Color(0xFFEF5350), text: 'Not Answered'),
        _LegendItem(color: Color(0xFF4CAF50), text: 'Answered'),
        _LegendItem(color: Color(0xFF8E24AA), text: 'Marked for Review'),
        _LegendItem(color: Color(0xFF5C6BC0), text: 'Answered and Marked for Review'),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String text;
  const _LegendItem({super.key, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
              color: color, border: Border.all(color: Colors.grey.shade400)),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(text, style: const TextStyle(fontSize: 12)),
        ),
      ],
    );
  }
}

typedef ButtonColors = ({Color backgroundColor, Color foregroundColor});
ButtonColors _getColorForStatus(QuestionStatus status) {
  switch (status) {
    case QuestionStatus.answered:
      return (backgroundColor: const Color(0xFF4CAF50), foregroundColor: Colors.white);
    case QuestionStatus.notAnswered:
      return (backgroundColor: const Color(0xFFEF5350), foregroundColor: Colors.white);
    case QuestionStatus.markedForReview:
      return (backgroundColor: const Color(0xFF8E24AA), foregroundColor: Colors.white);
    case QuestionStatus.answeredAndMarkedForReview:
      return (backgroundColor: const Color(0xFF5C6BC0), foregroundColor: Colors.white);
    case QuestionStatus.notVisited:
    default:
      return (backgroundColor: const Color(0xFFFFFFFF), foregroundColor: Colors.black87);
  }
}