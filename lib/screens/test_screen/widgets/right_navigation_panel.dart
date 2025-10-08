// lib/screens/test_screen/widgets/right_navigation_panel.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/test_models.dart';
import '../../../providers/test_provider.dart';

class PaletteStyle {
  final Color fillColor;
  final Color strokeColor;
  final Color fontColor;
  final bool hasShadow;

  const PaletteStyle({
    required this.fillColor,
    required this.strokeColor,
    required this.fontColor,
    this.hasShadow = false,
  });
}

class RightNavigationPanel extends ConsumerWidget {
  const RightNavigationPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final testState = ref.watch(testProvider);
    final test = testState.test!;

    final currentSectionIndex = testState.currentSectionIndex;
    final currentSection = test.sections[currentSectionIndex];
    final sectionQuestions = currentSection.questions;

    int globalIndexOffset = 0;
    for (int i = 0; i < currentSectionIndex; i++) {
      globalIndexOffset += test.sections[i].questions.length;
    }

    return Container(
      width: 275,
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
          // --- THE FIX IS HERE ---
          // Using the correct variable: currentSection.sectionName
          _buildSectionHeader(currentSection.sectionName),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.only(bottom: 12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5, crossAxisSpacing: 8, mainAxisSpacing: 8),
              itemCount: sectionQuestions.length,
              itemBuilder: (context, index) {
                final question = sectionQuestions[index];
                final status =
                    testState.statuses[question.questionId] ?? QuestionStatus.notVisited;
                return _QuestionPaletteButton(
                  label: '${index + 1}',
                  status: status,
                  onTap: () {
                    ref
                        .read(testProvider.notifier)
                        .goToQuestion(globalIndexOffset + index);
                  },
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
        _LegendItem(status: QuestionStatus.notVisited, text: 'Not Visited'),
        _LegendItem(status: QuestionStatus.notAnswered, text: 'Not Answered'),
        _LegendItem(status: QuestionStatus.answered, text: 'Answered'),
        _LegendItem(status: QuestionStatus.markedForReview, text: 'Marked for Review'),
        _LegendItem(status: QuestionStatus.answeredAndMarkedForReview, text: 'Answered & Marked'),
      ],
    );
  }
}

class _QuestionPaletteButton extends StatelessWidget {
  final String label;
  final QuestionStatus status;
  final VoidCallback onTap;

  const _QuestionPaletteButton(
      {required this.label, required this.status, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final style = _getPaletteStyle(status);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          color: style.fillColor,
          borderRadius: BorderRadius.circular(10),
          boxShadow: style.hasShadow
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              label,
              style:
                  TextStyle(color: style.fontColor, fontWeight: FontWeight.bold),
            ),
            if (status == QuestionStatus.answeredAndMarkedForReview)
              Positioned(
                right: 5,
                bottom: 5,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFF16A34A),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                ),
              ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: style.strokeColor, width: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final QuestionStatus status;
  final String text;
  const _LegendItem({required this.status, required this.text});

  @override
  Widget build(BuildContext context) {
    final style = _getPaletteStyle(status);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: style.fillColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              if (status == QuestionStatus.answeredAndMarkedForReview)
                Positioned(
                  right: 2,
                  bottom: 2,
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(0xFF16A34A),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: style.strokeColor, width: 1),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

PaletteStyle _getPaletteStyle(QuestionStatus status) {
  switch (status) {
    case QuestionStatus.notVisited:
      return const PaletteStyle(
        fillColor: Color(0xFFE3DADA),
        strokeColor: Colors.transparent,
        fontColor: Color(0xFF6E6E6E),
      );
    case QuestionStatus.notAnswered:
      return const PaletteStyle(
        fillColor: Color(0xFFFF2F2F),
        strokeColor: Colors.transparent,
        fontColor: Colors.white,
        hasShadow: true,
      );
    case QuestionStatus.answered:
      return const PaletteStyle(
        fillColor: Color(0xFF16A34A),
        strokeColor: Colors.transparent,
        fontColor: Colors.white,
        hasShadow: true,
      );
    case QuestionStatus.markedForReview:
    case QuestionStatus.answeredAndMarkedForReview:
      return const PaletteStyle(
        fillColor: Color(0xFF7C3AED),
        strokeColor: Colors.transparent,
        fontColor: Colors.white,
        hasShadow: true,
      );
  }
}