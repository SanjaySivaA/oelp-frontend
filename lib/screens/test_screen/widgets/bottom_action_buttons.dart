// lib/screens/test_screen/widgets/bottom_action_buttons.dart

// THE FIX IS IN THIS IMPORT LINE (package: instead of package.)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/test_provider.dart';

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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left-side buttons
          Row(
            children: [
              OutlinedButton(
                onPressed: () {
                  ref.read(testProvider.notifier).markForReviewAndNext();
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text('Mark for Review & Next'),
              ),
              const SizedBox(width: 16),
              TextButton(
                onPressed: () {
                  ref.read(testProvider.notifier).clearResponse();
                },
                child: const Text('Clear Response'),
              ),
            ],
          ),

          // Right-side buttons
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  ref.read(testProvider.notifier).saveAndNext();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                ),
                child: const Text('Save & Next'),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: () {
                  ref.read(testProvider.notifier).submitTest();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text('Submit'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}