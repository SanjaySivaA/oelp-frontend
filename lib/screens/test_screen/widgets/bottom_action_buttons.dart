// lib/screens/test_screen/widgets/bottom_action_buttons.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/test_provider.dart';
import '../../../widgets/custom_action_button.dart'; // Your custom button import

class BottomActionButtons extends ConsumerWidget {
  const BottomActionButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE0E0E0))),
      ),
      child: Row(
        children: [
          CustomActionButton(
            text: 'Mark for Review & Next',
            type: ButtonType.secondary,
            onPressed: () {
              ref.read(testProvider.notifier).markForReviewAndNext();
            },
          ),
          const SizedBox(width: 16),
          CustomActionButton(
            text: 'Clear Response',
            type: ButtonType.secondary,
            onPressed: () {
              ref.read(testProvider.notifier).clearResponse();
            },
          ),

          const Spacer(),

          CustomActionButton(
            text: 'Save & Next',
            type: ButtonType.primary,
            onPressed: () {
              ref.read(testProvider.notifier).saveAndNext();
            },
          ),
          const SizedBox(width: 16),

          // =======================================================================
          // MODIFIED SUBMIT BUTTON LOGIC
          // =======================================================================
          CustomActionButton(
            text: 'Submit',
            type: ButtonType.primary,
            onPressed: () {
              // 1. Show a confirmation dialog to prevent accidental submission.
              showDialog(
                context: context,
                builder: (BuildContext dialogContext) => AlertDialog(
                  title: const Text('Submit Test'),
                  content: const Text('Are you sure you want to end the test? This action cannot be undone.'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(), // Just close the dialog
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      // 2. Make the callback async to await the submission.
                      onPressed: () async { 
                        Navigator.of(dialogContext).pop(); // Close the dialog first

                        // 3. Await the submission. The app will wait here until the backend responds.
                        await ref.read(testProvider.notifier).submitTest();

                        // 4. Best practice: Check if the widget is still mounted before navigating.
                        if (context.mounted) {
                          // 5. Navigate to the analytics screen AFTER submission is complete.
                          Navigator.pushReplacementNamed(context, '/analytics');
                        }
                      },
                      child: const Text('Submit'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}