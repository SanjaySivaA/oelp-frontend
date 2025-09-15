import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/test_provider.dart';

// This is the custom AppBar widget for our test screen.
// It implements PreferredSizeWidget so it can be used in Scaffold's appBar property.
class TestHeader extends ConsumerWidget implements PreferredSizeWidget {
  const TestHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final testState = ref.watch(testProvider);
    final test = testState.test!; // widget only builds when test is not null.

    // HH:MM:SS
    final duration = Duration(seconds: testState.timeRemainingInSeconds);
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    final timeString = '$hours:$minutes:$seconds';

    return AppBar(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 1.0,
      title: Text(test.testName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      actions: [
        Center(
          child: Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Text(
              'Time Left: $timeString',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(50.0),
        child: Container(
          color: const Color(0xFFF5F5F5),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          alignment: Alignment.centerLeft,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: test.sections.map((section) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ActionChip(
                    label: Text(section.sectionName),
                    onPressed: () {
                      // TODO: Implement section navigation
                    },
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  // This is required by PreferredSizeWidget. It tells the Scaffold how tall the AppBar is.
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 58.0);
}
