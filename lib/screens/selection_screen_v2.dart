import 'package:flutter/material.dart';
import '../widgets/custom_navbar.dart'; // Ensure this path is correct

// --- Theme Colors ---
const Color kPrimaryColor = Color(0xFF299FE8);
const Color kDarkerSecondaryColor = Color(0xFF1F6F9D);
const Color kLighterSecondaryColor = Color(0xFF58B6F2);
const Color kBackgroundColor = Color(0xFFF8F9FA);
const Color kTextColor = Color(0xFF1A202C);

// --- Data Model (Mock) ---
class TestModel {
  final String id;
  final String title;
  final int questionCount;
  final int durationMins;

  TestModel({
    required this.id,
    required this.title,
    required this.questionCount,
    required this.durationMins,
  });
}

class TestSelectionScreen extends StatefulWidget {
  const TestSelectionScreen({super.key});

  @override
  State<TestSelectionScreen> createState() => _TestSelectionScreenState();
}

class _TestSelectionScreenState extends State<TestSelectionScreen>
    with TickerProviderStateMixin {
  String? selectedType;
  String? selectedSubject;

  // Loading state for the "API call"
  bool isLoading = false;
  List<TestModel> displayedTests = [];

  final types = ["Chapterwise", "Subjectwise", "Full Syllabus", "For You"];
  final subjects = ["Physics", "Chemistry", "Mathematics"];

  // Hardcoded Data Repository
  final Map<String, List<String>> _repoChapterwise = {
    "Physics": [
      "Mechanics",
      "Thermodynamics",
      "Waves and Sound",
      "Electricity and Magnetism",
      "Optics",
      "Modern Physics"
    ],
    "Chemistry": [
      "Physical Chemistry",
      "Organic Chemistry",
      "Inorganic Chemistry"
    ],
    "Mathematics": [
      "Algebra",
      "Calculus",
      "Coordinate Geometry",
      "Trigonometry"
    ],
  };

  final List<String> _repoFullSyllabus = [
    "Mock Test 1 (2024 Pattern)",
    "Mock Test 2 (2024 Pattern)",
    "Mock Test 3 (Previous Year)",
    "All India Open Test - 5"
  ];

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

  /// Helper to get Exam Name from ID
  String _getExamName(int id) {
    switch (id) {
      case 1: return "JEE Main";
      case 2: return "NEET";
      case 3: return "JEE Advanced";
      default: return "Entrance Exam";
    }
  }

  /// Simulates fetching data
  Future<void> _fetchTests({required String type, String? subject}) async {
    setState(() {
      isLoading = true;
      displayedTests = [];
    });

    // Simulate Network Delay
    await Future.delayed(const Duration(milliseconds: 600));

    List<TestModel> results = [];

    if (type == "Full Syllabus" || type == "For You") {
      results = _repoFullSyllabus
          .map((name) => TestModel(
              id: "test_${name.hashCode}",
              title: name,
              questionCount: 75,
              durationMins: 180))
          .toList();
    } else if (subject != null) {
      final rawNames = _repoChapterwise[subject] ?? [];
      results = rawNames
          .map((name) => TestModel(
              id: "test_${name.hashCode}",
              title: name,
              questionCount: 25,
              durationMins: 60))
          .toList();
    }

    if (mounted) {
      setState(() {
        displayedTests = results;
        isLoading = false;
      });
    }
  }

  void _handleTypeSelection(String type) {
    setState(() {
      selectedType = type;
      selectedSubject = null;
      displayedTests = [];
    });

    bool requiresSubject = ["Chapterwise", "Subjectwise"].contains(type);

    if (!requiresSubject) {
      _fetchTests(type: type);
    }
  }

  void _handleSubjectSelection(String subject) {
    setState(() {
      selectedSubject = subject;
    });
    if (selectedType != null) {
      _fetchTests(type: selectedType!, subject: subject);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Safely retrieve arguments
    final args = ModalRoute.of(context)?.settings.arguments;
    final int examId = (args is int) ? args : 1;
    final String examName = _getExamName(examId);

    // Helper to determine if we should show the subject row
    bool showSubjects = ["Chapterwise", "Subjectwise"].contains(selectedType);

    return Scaffold(
      backgroundColor: kBackgroundColor,
      // --- 1. Added Custom Navbar ---
      appBar: const CustomNavBar(),
      // --- 2. Added Drawer (Same as Selection Screen) ---
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text("Menu",
                  style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
            ListTile(
              title: const Text("Dashboard"),
              onTap: () =>
                  Navigator.pushReplacementNamed(context, '/analytics'),
            ),
            ListTile(
              title: const Text("Practice"),
              onTap: () => Navigator.pushReplacementNamed(context, '/test'),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- 3. Hero Section (Matched to Screen 1) ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.lightBlueAccent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    "$examName Preparation", // Dynamic Title
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Select a specific chapter, subject, or take a full length mock test.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // --- 4. The "Centred Box" Container ---
            Center(
              child: Container(
                // Max width ensures it looks like a card on web/tablet, 
                // but fills screen on mobile
                constraints: const BoxConstraints(maxWidth: 900),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Filter Tests",
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: kTextColor),
                    ),
                    const SizedBox(height: 24),

                    // Test Type Tabs
                    _SelectionStep(
                      animation: _controller,
                      interval: const Interval(0.1, 0.4),
                      options: types,
                      selectedValue: selectedType,
                      onSelect: _handleTypeSelection,
                    ),

                    AnimatedSize(
                      duration: const Duration(milliseconds: 300),
                      child: SizedBox(height: selectedType != null ? 24 : 0),
                    ),

                    // Subject Tabs (Conditionally Rendered)
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: SizeTransition(
                            sizeFactor: animation,
                            axisAlignment: -1.0,
                            child: child),
                      ),
                      child: showSubjects
                          ? _SelectionStep(
                              key: const ValueKey('subject_step'),
                              animation: _controller,
                              interval: const Interval(0.3, 0.6),
                              options: subjects,
                              selectedValue: selectedSubject,
                              onSelect: _handleSubjectSelection,
                            )
                          : const SizedBox.shrink(key: ValueKey('empty_subject')),
                    ),

                    const Divider(height: 40, color: Colors.black12),

                    // Test List
                    if (isLoading)
                      const Center(
                          child: CircularProgressIndicator(color: kPrimaryColor))
                    else if (displayedTests.isNotEmpty) ...[
                      ListView.separated(
                        shrinkWrap: true,
                        // Important: Disable scrolling here so the outer page scrolls
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: displayedTests.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final test = displayedTests[index];
                          return StaggeredFadeSlideTransition(
                            animation: _controller,
                            interval: Interval(
                                0.0 + (index * 0.05).clamp(0.0, 0.4), 1.0,
                                curve: Curves.easeOut),
                            child: _TestListItem(test: test),
                          );
                        },
                      ),
                    ] else if (selectedType != null && !isLoading) ...[
                      // Empty State
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text("Select options to view tests",
                              style: TextStyle(color: Colors.grey)),
                        ),
                      )
                    ],

                    const SizedBox(height: 30),
                    
                    // Request Card (Inside the main box now)
                    StaggeredFadeSlideTransition(
                      animation: _controller,
                      interval: const Interval(0.7, 1.0),
                      child: _RequestTestCard(),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}

// --- REUSABLE WIDGETS ---

class _SelectionStep extends StatelessWidget {
  final Animation<double> animation;
  final Interval interval;
  final List<String> options;
  final String? selectedValue;
  final ValueChanged<String> onSelect;

  const _SelectionStep({
    super.key,
    required this.animation,
    required this.interval,
    required this.options,
    required this.selectedValue,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return StaggeredFadeSlideTransition(
      animation: animation,
      interval: interval,
      child: _TabRow(
        options: options,
        selected: selectedValue,
        onSelect: onSelect,
      ),
    );
  }
}

class _TestListItem extends StatefulWidget {
  final TestModel test;
  const _TestListItem({required this.test});

  @override
  State<_TestListItem> createState() => _TestListItemState();
}

class _TestListItemState extends State<_TestListItem> {
  bool _isHovered = false;

  void _navigateToTest(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TestPlaceholderScreen(
            testId: widget.test.id, testTitle: widget.test.title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _navigateToTest(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: _isHovered ? Colors.blue.shade50 : kBackgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: _isHovered ? kPrimaryColor : Colors.grey.shade300),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.test.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _isHovered ? kDarkerSecondaryColor : kTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${widget.test.questionCount} Questions • ${widget.test.durationMins} mins",
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.play_circle_fill,
                size: 24,
                color: _isHovered ? kPrimaryColor : Colors.grey.shade300,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RequestTestCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kDarkerSecondaryColor,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Don't see what you're looking for?",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          const SizedBox(height: 8),
          const Text(
              "Request a custom chapter or topic-wise test and our AI will generate it for you.",
              style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: kLighterSecondaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text("Request Custom Test",
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

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
    return Wrap(
      spacing: 12,
      runSpacing: 12,
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? kPrimaryColor
                    : (isHovered ? Colors.grey.shade200 : Colors.transparent),
                borderRadius: BorderRadius.circular(20), // Rounded pills
                border: Border.all(
                    color: isSelected ? kPrimaryColor : Colors.grey.shade300,
                    width: 1),
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

// --- PLACEHOLDER TEST SCREEN ---
class TestPlaceholderScreen extends StatelessWidget {
  final String testId;
  final String testTitle;

  const TestPlaceholderScreen(
      {super.key, required this.testId, required this.testTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(testTitle)),
      body: Center(
        child: Text("Fetching Test Details for ID: $testId"),
      ),
    );
  }
}