// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_markdown/flutter_markdown.dart';
// import 'dart:async';

// import '../../../models/test_models.dart';
// import '../../../providers/test_provider.dart';
// import '../../../utils/markdown_helpers.dart';
// import '../../../widgets/tex_text.dart';

// // -----------------------------------------------------------------------------
// // MAIN WIDGET: QuestionDisplay
// // This is a stateful widget to manage the ScrollController for image rendering.
// // -----------------------------------------------------------------------------
// class QuestionDisplay extends ConsumerStatefulWidget {
//   final Question question;
//   const QuestionDisplay({super.key, required this.question});

//   @override
//   ConsumerState<QuestionDisplay> createState() => _QuestionDisplayState();
// }

// class _QuestionDisplayState extends ConsumerState<QuestionDisplay> {
//   late final ScrollController _scrollController;

//   @override
//   void initState() {
//     super.initState();
//     _scrollController = ScrollController();
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ListView(
//       controller: _scrollController,
//       padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 24.0),
//       children: [
//         MarkdownBody(
//           data: widget.question.questionText,
//           imageBuilder: markdownImageBuilder,
//           styleSheet: MarkdownStyleSheet(
//             p: const TextStyle(fontSize: 18, height: 1.5, fontFamily: 'Inter'),
//           ),
//         ),
//         const SizedBox(height: 32),
//         _buildOptions(context, ref),
//       ],
//     );
//   }

//   // This is the core logic that decides which options UI to show.
//   // It now safely checks the type of the response before using it.
//   Widget _buildOptions(BuildContext context, WidgetRef ref) {
//     final testState = ref.watch(testProvider);
//     final currentResponse = testState.responses[widget.question.questionId];
//     final section = testState.test!.sections[testState.currentSectionIndex];
//     print("DEBUG: Received questionType ->'${section.questionType}'<-");

//     switch (section.questionType) {
//       case "MCSC":
//         final selections = (currentResponse is List<String>) ? currentResponse : <String>[];
//         return _buildMcqOptions(ref, selections);

//       case "MCMC":
//         final selections = (currentResponse is List<String>) ? currentResponse : <String>[];
//         return _buildMsqOptions(ref, selections);

//       case "NUMERICAL":
//         final answer = (currentResponse is String) ? currentResponse : '';
//         return Align( // The parent Align widget
//           // --- FIX #2: Move it further left ---
//           // Changed from -0.7 to -0.9 to push it almost to the edge.
//           alignment: const Alignment(-0.9, 0),
//           child: _NumericalInputPad(
//             key: ValueKey(widget.question.questionId),
//             questionId: widget.question.questionId,
//             initialAnswer: answer,
//           ),
//         );

//       default:
//         return Text("Unsupported question type: ${section.questionType}");
//     }
//   }

//   // Builds the UI for Single-Choice Questions
//   Widget _buildMcqOptions(WidgetRef ref, List<String> currentSelections) {
//     final currentlySelectedId = currentSelections.isNotEmpty ? currentSelections.first : null;
//     return Column(
//       children: widget.question.options.map((option) {
//         return _OptionWidget(
//           optionText: option.optionText,
//           isSelected: currentlySelectedId == option.optionId,
//           onTap: () {
//             ref.read(testProvider.notifier).answerQuestion(widget.question.questionId, [option.optionId]);
//           },
//         );
//       }).toList(),
//     );
//   }

//   // Builds the UI for Multiple-Choice Questions
//   Widget _buildMsqOptions(WidgetRef ref, List<String> currentSelections) {
//     return Column(
//       children: widget.question.options.map((option) {
//         final isSelected = currentSelections.contains(option.optionId);
//         return _MsqOptionWidget(
//           optionText: option.optionText,
//           isSelected: isSelected,
//           onTap: (bool? newValue) {
//             final newSelections = List<String>.from(currentSelections);
//             if (newValue == true) {
//               if (!newSelections.contains(option.optionId)) {
//                 newSelections.add(option.optionId);
//               }
//             } else {
//               newSelections.remove(option.optionId);
//             }
//             ref.read(testProvider.notifier).answerQuestion(widget.question.questionId, newSelections);
//           },
//         );
//       }).toList(),
//     );
//   }
// }

// // -----------------------------------------------------------------------------
// // HELPER WIDGET: _OptionWidget (for MCQs)
// // The clean, borderless style for radio buttons.
// // -----------------------------------------------------------------------------
// class _OptionWidget extends StatelessWidget {
//   final String optionText;
//   final bool isSelected;
//   final VoidCallback onTap;

//   const _OptionWidget({
//     required this.optionText,
//     required this.isSelected,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.transparent,
//       borderRadius: BorderRadius.circular(8.0),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(8.0),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
//           child: Row(
//             children: [
//               Icon(
//                 isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
//                 color: isSelected ? Colors.blue.shade700 : Colors.grey.shade600,
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: MarkdownBody(
//                   data: optionText,
//                   styleSheet: MarkdownStyleSheet(
//                     p: TextStyle(
//                       fontSize: 16,
//                       color: Colors.black87,
//                       fontFamily: 'Inter',
//                       fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // -----------------------------------------------------------------------------
// // HELPER WIDGET: _MsqOptionWidget (for MSQs)
// // A new custom widget for checkboxes to match the MCQ style.
// // -----------------------------------------------------------------------------
// class _MsqOptionWidget extends StatelessWidget {
//   final String optionText;
//   final bool isSelected;
//   final ValueChanged<bool?> onTap;

//   const _MsqOptionWidget({
//     required this.optionText,
//     required this.isSelected,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.transparent,
//       borderRadius: BorderRadius.circular(8.0),
//       child: InkWell(
//         onTap: () => onTap(!isSelected),
//         borderRadius: BorderRadius.circular(8.0),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
//           child: Row(
//             children: [
//               Checkbox(
//                 value: isSelected,
//                 onChanged: onTap,
//                 activeColor: Colors.blue.shade700,
//                 checkColor: Colors.white,
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: MarkdownBody(
//                   data: optionText,
//                   styleSheet: MarkdownStyleSheet(
//                     p: TextStyle(
//                       fontSize: 16,
//                       color: Colors.black87,
//                       fontFamily: 'Inter',
//                       fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // -----------------------------------------------------------------------------
// // HELPER WIDGET: _NumericalInputWidget
// // A dedicated stateful widget to safely manage the text controller.
// // -----------------------------------------------------------------------------

// class _NumericalInputPad extends ConsumerStatefulWidget {
//   final String questionId;
//   final String initialAnswer;
//   const _NumericalInputPad({super.key, required this.questionId, required this.initialAnswer});

//   @override
//   ConsumerState<_NumericalInputPad> createState() => _NumericalInputPadState();
// }

// class _NumericalInputPadState extends ConsumerState<_NumericalInputPad> {
//   late final TextEditingController _controller;
//   Timer? _debounce;

//   @override
//   void initState() {
//     super.initState();
//     _controller = TextEditingController(text: widget.initialAnswer);

//     _controller.addListener(() {
//       if (_debounce?.isActive ?? false) _debounce!.cancel();
//       _debounce = Timer(const Duration(milliseconds: 300), () {
//         if (mounted) {
//           ref.read(testProvider.notifier).answerQuestion(widget.questionId, _controller.text);
//         }
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _debounce?.cancel();
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     const List<List<String>> keys = [
//       ['7', '8', '9'], ['4', '5', '6'], ['1', '2', '3'], ['.', '0', '-']
//     ];

//     return SizedBox(
//       // --- FIX #1: Make the whole component smaller ---
//       width: 180, 
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           SizedBox(
//             width: 200, // Keep the text field slightly wider
//             child: TextField(
//               controller: _controller,
//               textAlign: TextAlign.center,
//               style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
//               decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Your Answer'),
//             ),
//           ),
//           // --- FIX #3: Reduce padding ---
//           const SizedBox(height: 8),
          
//           // This Row will now be 180px wide
//           Row(children: [Expanded(child: _buildKey('Backspace'))]),
//           const SizedBox(height: 4),

//           ...keys.map((row) {
//             return Row(
//               children: row.map((key) => Expanded(child: _buildKey(key))).toList(),
//             );
//           }),
//           const SizedBox(height: 4),
          
//           Row(children: [Expanded(child: _buildKey('Clear All'))]),
//         ],
//       ),
//     );
//   }

//   // _buildKey is now simpler and more robust, using Expanded and AspectRatio
//   Widget _buildKey(String value) {
//     return Padding(
//       padding: const EdgeInsets.all(2.0),
//       child: AspectRatio(
//         aspectRatio: value.length > 1 ? 3 / 1 : 1 / 1, // Wider for long-text buttons
//         child: OutlinedButton(
//           onPressed: () {
//             if (value == 'Backspace') {
//               if (_controller.text.isNotEmpty) {
//                 _controller.text = _controller.text.substring(0, _controller.text.length - 1);
//               }
//             } else if (value == 'Clear All') {
//               _controller.clear();
//             } else {
//               if (value == '.' && _controller.text.contains('.')) return;
//               if (value == '-' && _controller.text.isNotEmpty) return;
//               _controller.text += value;
//             }
//           },
//           style: OutlinedButton.styleFrom(
//             foregroundColor: Colors.black,
//             side: const BorderSide(color: Colors.black87, width: 1),
//             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
//           ),
//           child: Text(
//             value,
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: value.length > 1 ? 14 : 18,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

import '../../../models/test_models.dart';
import '../../../providers/test_provider.dart';
// IMPORTANT: Ensure this file exists in your project
import '../../../widgets/tex_text.dart'; 

// -----------------------------------------------------------------------------
// MAIN WIDGET: QuestionDisplay
// -----------------------------------------------------------------------------
class QuestionDisplay extends ConsumerStatefulWidget {
  final Question question;
  const QuestionDisplay({super.key, required this.question});

  @override
  ConsumerState<QuestionDisplay> createState() => _QuestionDisplayState();
}

class _QuestionDisplayState extends ConsumerState<QuestionDisplay> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 24.0),
      children: [
        // CHANGE 1: Use TexText for the main question text
        TexText(
          widget.question.questionText,
          style: const TextStyle(
            fontSize: 18, 
            height: 1.5, 
            fontFamily: 'Inter', 
            color: Colors.black87
          ),
        ),
        const SizedBox(height: 32),
        _buildOptions(context, ref),
      ],
    );
  }

  Widget _buildOptions(BuildContext context, WidgetRef ref) {
    final testState = ref.watch(testProvider);
    final currentResponse = testState.responses[widget.question.questionId];
    final section = testState.test!.sections[testState.currentSectionIndex];

    switch (section.questionType.toUpperCase()) { // Added toUpperCase for safety
      case "MCSC":
        final selections = (currentResponse is List<String>) ? currentResponse : <String>[];
        return _buildMcqOptions(ref, selections);

      case "MCMC":
        final selections = (currentResponse is List<String>) ? currentResponse : <String>[];
        return _buildMsqOptions(ref, selections);

      case "NUMERICAL":
      case "INT":
        final answer = (currentResponse is String) ? currentResponse : '';
        return Align(
          alignment: const Alignment(-0.9, 0),
          child: _NumericalInputPad(
            key: ValueKey(widget.question.questionId),
            questionId: widget.question.questionId,
            initialAnswer: answer,
          ),
        );

      default:
        return Text("Unsupported question type: ${section.questionType}");
    }
  }

  Widget _buildMcqOptions(WidgetRef ref, List<String> currentSelections) {
    final currentlySelectedId = currentSelections.isNotEmpty ? currentSelections.first : null;
    return Column(
      children: widget.question.options.map((option) {
        return _OptionWidget(
          optionText: option.optionText,
          isSelected: currentlySelectedId == option.optionId,
          onTap: () {
            ref.read(testProvider.notifier).answerQuestion(widget.question.questionId, [option.optionId]);
          },
        );
      }).toList(),
    );
  }

  Widget _buildMsqOptions(WidgetRef ref, List<String> currentSelections) {
    return Column(
      children: widget.question.options.map((option) {
        final isSelected = currentSelections.contains(option.optionId);
        return _MsqOptionWidget(
          optionText: option.optionText,
          isSelected: isSelected,
          onTap: (bool? newValue) {
            final newSelections = List<String>.from(currentSelections);
            if (newValue == true) {
              if (!newSelections.contains(option.optionId)) {
                newSelections.add(option.optionId);
              }
            } else {
              newSelections.remove(option.optionId);
            }
            ref.read(testProvider.notifier).answerQuestion(widget.question.questionId, newSelections);
          },
        );
      }).toList(),
    );
  }
}

// -----------------------------------------------------------------------------
// HELPER WIDGET: _OptionWidget
// -----------------------------------------------------------------------------
class _OptionWidget extends StatelessWidget {
  final String optionText;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionWidget({
    required this.optionText,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start, // Align top for better math rendering
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: isSelected ? Colors.blue.shade700 : Colors.grey.shade600,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                // CHANGE 2: Use TexText for MCQ options
                child: TexText(
                  optionText,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontFamily: 'Inter',
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// HELPER WIDGET: _MsqOptionWidget
// -----------------------------------------------------------------------------
class _MsqOptionWidget extends StatelessWidget {
  final String optionText;
  final bool isSelected;
  final ValueChanged<bool?> onTap;

  const _MsqOptionWidget({
    required this.optionText,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(8.0),
      child: InkWell(
        onTap: () => onTap(!isSelected),
        borderRadius: BorderRadius.circular(8.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start, // Align top for better math rendering
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: isSelected,
                  onChanged: onTap,
                  activeColor: Colors.blue.shade700,
                  checkColor: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                // CHANGE 3: Use TexText for MSQ options
                child: TexText(
                  optionText,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontFamily: 'Inter',
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// HELPER WIDGET: _NumericalInputPad
// (This remains unchanged)
// -----------------------------------------------------------------------------
class _NumericalInputPad extends ConsumerStatefulWidget {
  final String questionId;
  final String initialAnswer;
  const _NumericalInputPad({super.key, required this.questionId, required this.initialAnswer});

  @override
  ConsumerState<_NumericalInputPad> createState() => _NumericalInputPadState();
}

class _NumericalInputPadState extends ConsumerState<_NumericalInputPad> {
  late final TextEditingController _controller;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialAnswer);

    _controller.addListener(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 300), () {
        if (mounted) {
          ref.read(testProvider.notifier).answerQuestion(widget.questionId, _controller.text);
        }
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const List<List<String>> keys = [
      ['7', '8', '9'], ['4', '5', '6'], ['1', '2', '3'], ['.', '0', '-']
    ];

    return SizedBox(
      width: 180, 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 200,
            child: TextField(
              controller: _controller,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
              decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Your Answer'),
            ),
          ),
          const SizedBox(height: 8),
          Row(children: [Expanded(child: _buildKey('Backspace'))]),
          const SizedBox(height: 4),
          ...keys.map((row) {
            return Row(
              children: row.map((key) => Expanded(child: _buildKey(key))).toList(),
            );
          }),
          const SizedBox(height: 4),
          Row(children: [Expanded(child: _buildKey('Clear All'))]),
        ],
      ),
    );
  }

  Widget _buildKey(String value) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: AspectRatio(
        aspectRatio: value.length > 1 ? 3 / 1 : 1 / 1,
        child: OutlinedButton(
          onPressed: () {
            if (value == 'Backspace') {
              if (_controller.text.isNotEmpty) {
                _controller.text = _controller.text.substring(0, _controller.text.length - 1);
              }
            } else if (value == 'Clear All') {
              _controller.clear();
            } else {
              if (value == '.' && _controller.text.contains('.')) return;
              if (value == '-' && _controller.text.isNotEmpty) return;
              _controller.text += value;
            }
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.black,
            side: const BorderSide(color: Colors.black87, width: 1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: value.length > 1 ? 14 : 18,
            ),
          ),
        ),
      ),
    );
  }
}