// lib/screens/test_screen/widgets/question_display.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'package:frontend/models/test_models.dart';
import 'package:frontend/providers/test_provider.dart';

class QuestionDisplay extends ConsumerWidget {
  final Question question;
  final int questionIndex;

  const QuestionDisplay({
    super.key, 
    required this.question,
    required this.questionIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      // Reduced horizontal padding for a more compact look
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
      children: [
        // The new header now contains all the necessary info
        _buildQuestionHeader(),
        const Divider(height: 24.0, thickness: 1.0),

        // Question Text
        MarkdownBody(
          data: question.questionText,
          styleSheet: MarkdownStyleSheet(
            p: const TextStyle(fontSize: 18, height: 1.5), // Styles the main paragraph text
            // You can add more styles for h1, h2, code, etc. if needed
          ),
        ),
        const SizedBox(height: 32),

        // Options
        _buildOptions(context, ref),
      ],
    );
  }

  // --- THIS WIDGET HAS BEEN REBUILT ---
  Widget _buildQuestionHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left side with Question Type and Number
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Question Type: ${question.type}',
                style: TextStyle(color: Colors.grey[800], fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                'Question No. ${questionIndex + 1}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          // Right side with Marks
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Marks for correct answer: +${question.positiveMarks}',
                style: TextStyle(color: Colors.green[800], fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                'Negative Marks: ${question.negativeMarks}',
                style: TextStyle(color: Colors.red[800], fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptions(BuildContext context, WidgetRef ref) {
    final responses = ref.watch(testProvider.select((state) => state.responses));
    final currentResponse = responses[question.questionId];

    switch (question.type) {
      case "MCQ":
        return _buildMcqOptions(ref, currentResponse as List<String>? ?? []);
      case "NUMERICAL":
        return _buildNumericalInput(ref, currentResponse as String? ?? '');
      default:
        return const Text("Unsupported question type");
    }
  }

  // ... [_buildMcqOptions and _buildNumericalInput remain the same]
   Widget _buildMcqOptions(WidgetRef ref, List<String> currentSelections) {
    // ...
     return Column(
      children: question.options.map((option) {
        return RadioListTile<String>(
          title: MarkdownBody(
            data: option.optionText,
            styleSheet: MarkdownStyleSheet(p: const TextStyle(fontSize: 16)),
          ),
          value: option.optionId,
          groupValue: currentSelections.isNotEmpty ? currentSelections.first : null,
          onChanged: (newValue) {
            if (newValue != null) {
              ref.read(testProvider.notifier).answerQuestion(question.questionId, [newValue]);
            }
          },
        );
      }).toList(),
    );
   }

   Widget _buildNumericalInput(WidgetRef ref, String currentAnswer) {
    // ...
     final controller = TextEditingController(text: currentAnswer);
    
    controller.addListener(() {
      ref.read(testProvider.notifier).answerQuestion(question.questionId, controller.text);
    });

    return Column(
      children: [
        SizedBox(
          width: 200,
          child: TextField(
            controller: controller,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Your Answer',
            ),
            readOnly: true, 
          ),
        ),
        const SizedBox(height: 24),
        Align(
          alignment: const Alignment(-0.7, 0),
          child: _OnScreenKeyboard(controller: controller),
        ),
      ],
    );
   }
}

// ... [_OnScreenKeyboard widget remains the same]
class _OnScreenKeyboard extends StatelessWidget {
  final TextEditingController controller;
  const _OnScreenKeyboard({required this.controller});
  //...
   @override
  Widget build(BuildContext context) {
    const List<List<String>> keys = [
      ['7', '8', '9'],
      ['4', '5', '6'],
      ['1', '2', '3'],
      ['0', '.', '-'],
    ];

    return SizedBox(
      width: 220,
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 40,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.backspace_outlined, size: 18),
              label: const Text('Backspace'),
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  controller.text = controller.text.substring(0, controller.text.length - 1);
                }
              },
            ),
          ),
          const SizedBox(height: 6),
          ...keys.map((row) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: row.map((key) => _buildKey(key)).toList(),
            );
          }),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: OutlinedButton(
              onPressed: () => controller.clear(),
              child: const Text('Clear All'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKey(String value) {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: SizedBox(
        width: 60,
        height: 45,
        child: OutlinedButton(
          onPressed: () {
            if (value == '.' && controller.text.contains('.')) return;
            if (value == '-' && controller.text.isNotEmpty) return;
            controller.text += value;
          },
          child: Text(value, style: const TextStyle(fontSize: 20)),
        ),
      ),
    );
  }
}