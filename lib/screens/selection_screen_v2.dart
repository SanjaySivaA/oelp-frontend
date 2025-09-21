import 'package:flutter/material.dart';

// --- Theme Colors and other constants are the same ---
const Color kPrimaryColor = Color(0xFF299FE8);
const Color kDarkerSecondaryColor = Color(0xFF1F6F9D);
const Color kLighterSecondaryColor = Color(0xFF58B6F2);
const Color kBackgroundColor = Color(0xFFF8F9FA);
const Color kTextColor = Color(0xFF1A202C);

class TestSelectionScreen extends StatefulWidget {
  const TestSelectionScreen({super.key});

  @override
  State<TestSelectionScreen> createState() => _TestSelectionScreenState();
}

class _TestSelectionScreenState extends State<TestSelectionScreen>
    with TickerProviderStateMixin {
  String? selectedExam;
  String? selectedType;
  String? selectedSubject;

  final exams = ["JEE Main", "JEE Advanced", "NEET"];
  final types = ["Chapterwise", "Subjectwise", "Full Syllabus"];
  final subjects = ["Physics", "Chemistry", "Mathematics"];

  final suggestedTests = {
    "Physics": ["Mechanics", "Thermodynamics", "Waves and Sound", "Electricity and Magnetism", "Optics", "Modern Physics"],
    "Chemistry": ["Physical Chemistry", "Organic Chemistry", "Inorganic Chemistry"],
    "Mathematics": ["Algebra", "Calculus", "Coordinate Geometry", "Trigonometry"],
  };

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // We use a simple Column inside a SingleChildScrollView. This is more robust
    // than a CustomScrollView for this specific layout and avoids the blank screen issue.
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StaggeredFadeSlideTransition(
                animation: _controller,
                interval: const Interval(0.0, 0.2),
                child: const Text(
                  "Mock Test Platform",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: kTextColor),
                ),
              ),
              const SizedBox(height: 40),
              _SelectionStep(
                animation: _controller,
                interval: const Interval(0.1, 0.4),
                title: "Choose Your Exam",
                options: exams,
                selectedValue: selectedExam,
                onSelect: (val) => setState(() {
                  selectedExam = val;
                  selectedType = null;
                  selectedSubject = null;
                }),
              ),
              const SizedBox(height: 40),

              // Using AnimatedSwitcher for smooth appearance/disappearance
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: SizeTransition(sizeFactor: animation, axisAlignment: -1.0, child: child)),
                child: selectedExam != null
                    ? _SelectionStep(
                        key: const ValueKey('type_step'),
                        animation: _controller,
                        interval: const Interval(0.3, 0.6),
                        title: "Choose Test Type",
                        options: types,
                        selectedValue: selectedType,
                        onSelect: (val) => setState(() {
                          selectedType = val;
                          selectedSubject = null;
                        }),
                      )
                    : const SizedBox.shrink(key: ValueKey('empty_type')),
              ),
              if (selectedExam != null) const SizedBox(height: 40),

              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                 transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: SizeTransition(sizeFactor: animation, axisAlignment: -1.0, child: child)),
                child: selectedType != null
                    ? _SelectionStep(
                        key: const ValueKey('subject_step'),
                        animation: _controller,
                        interval: const Interval(0.5, 0.8),
                        title: "Select Subject",
                        options: subjects,
                        selectedValue: selectedSubject,
                        onSelect: (val) => setState(() => selectedSubject = val),
                      )
                    : const SizedBox.shrink(key: ValueKey('empty_subject')),
              ),
              if (selectedType != null) const SizedBox(height: 40),

              if (selectedSubject != null) ...[
                StaggeredFadeSlideTransition(
                  animation: _controller,
                  interval: const Interval(0.7, 1.0),
                  child: Text(
                    "Suggested $selectedSubject Tests",
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kTextColor),
                  ),
                ),
                const SizedBox(height: 16),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: suggestedTests[selectedSubject]!.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final testName = suggestedTests[selectedSubject]![index];
                    return StaggeredFadeSlideTransition(
                      animation: _controller,
                      interval: Interval(0.8 + (index * 0.05), 1.0, curve: Curves.easeOut),
                      child: _TestListItem(testName: testName),
                    );
                  },
                ),
                const SizedBox(height: 40),
                StaggeredFadeSlideTransition(
                   animation: _controller,
                   interval: const Interval(0.8, 1.0),
                   child: _RequestTestCard()
                 ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// --- REUSABLE WIDGETS ---

// A reusable widget for each selection step
class _SelectionStep extends StatelessWidget {
  final Animation<double> animation;
  final Interval interval;
  final String title;
  final List<String> options;
  final String? selectedValue;
  final ValueChanged<String> onSelect;

  const _SelectionStep({
    super.key,
    required this.animation,
    required this.interval,
    required this.title,
    required this.options,
    required this.selectedValue,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return StaggeredFadeSlideTransition(
      animation: animation,
      interval: interval,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kTextColor)),
          const SizedBox(height: 16),
          _TabRow(
            options: options,
            selected: selectedValue,
            onSelect: onSelect,
          ),
        ],
      ),
    );
  }
}

// A dedicated stateful widget for the list items to manage their own hover state
class _TestListItem extends StatefulWidget {
  final String testName;
  const _TestListItem({required this.testName});

  @override
  State<_TestListItem> createState() => _TestListItemState();
}

class _TestListItemState extends State<_TestListItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          // TODO: Navigate to test screen
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: _isHovered ? Colors.white : kBackgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _isHovered ? kPrimaryColor : Colors.grey.shade300),
            boxShadow: _isHovered ? [
              BoxShadow(
                color: kPrimaryColor.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ] : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.testName,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _isHovered ? kDarkerSecondaryColor : kTextColor),
                  ),
                  const SizedBox(height: 4),
                  const Text("20 Questions • 60 mins", style: TextStyle(fontSize: 13, color: Colors.grey)),
                ],
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: _isHovered ? kPrimaryColor : Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// The custom-styled "Request a Test" card
class _RequestTestCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kDarkerSecondaryColor,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Don't see what you're looking for?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                SizedBox(height: 8),
                Text("Request a custom chapter or topic-wise test and our AI will generate it for you.", style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          const SizedBox(width: 24),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: kLighterSecondaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Request Test", style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// --- HELPER WIDGETS ---

// The tab row widget, with improved styling
class _TabRow extends StatefulWidget {
  final List<String> options;
  final String? selected;
  final Function(String) onSelect;
  const _TabRow({required this.options, this.selected, required this.onSelect});

  @override
  State<_TabRow> createState() => _TabRowState();
}

class _TabRowState extends State<_TabRow> {
  String? _hoveredTab;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: widget.options.map((option) {
        final isSelected = option == widget.selected;
        final isHovered = option == _hoveredTab;
        return MouseRegion(
          onEnter: (_) => setState(() => _hoveredTab = option),
          onExit: (_) => setState(() => _hoveredTab = null),
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => widget.onSelect(option),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                // --- THE FIX IS HERE ---
                // Changed the incorrect _isHovered to the correct isHovered
                color: isSelected ? kPrimaryColor : (isHovered ? Colors.grey.shade200 : Colors.transparent),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                option,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.white : kTextColor,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}


// A reusable animation wrapper
class StaggeredFadeSlideTransition extends StatelessWidget {
  final Animation<double> animation;
  final Interval interval;
  final Widget child;

  const StaggeredFadeSlideTransition({
    super.key,
    required this.animation,
    required this.interval,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final curvedAnimation = CurvedAnimation(parent: animation, curve: interval);
    return FadeTransition(
      opacity: curvedAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(curvedAnimation),
        child: child,
      ),
    );
  }
}