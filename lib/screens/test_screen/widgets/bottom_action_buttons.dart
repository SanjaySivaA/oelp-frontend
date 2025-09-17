// lib/screens/test_screen/widgets/bottom_action_buttons.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/test_provider.dart';
import '../../../widgets/custom_action_button.dart'; // <-- Make sure this import is correct

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
          // Use the secondary style for these buttons
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

          const Spacer(), // Spacer pushes the next items to the right end

          // Use the primary style for these buttons
          CustomActionButton(
            text: 'Save & Next',
            type: ButtonType.primary,
            onPressed: () {
              ref.read(testProvider.notifier).saveAndNext();
            },
          ),
          const SizedBox(width: 16),
          CustomActionButton(
            text: 'Submit',
            type: ButtonType.primary,
            onPressed: () {
              ref.read(testProvider.notifier).submitTest();
            },
          ),
        ],
      ),
    );
  }
}