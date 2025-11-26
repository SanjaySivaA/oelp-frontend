import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../widgets/custom_navbar.dart';

// --- Configuration ---
// Fetches from --dart-define=API_URL=... or defaults to localhost
const String kBackendUrl = String.fromEnvironment(
  'API_BASE_URL', 
  defaultValue: 'http://127.0.0.1:8000'
);

// --- Theme Colors ---
const Color kPrimaryColor = Color(0xFF299FE8);
const Color kDarkerSecondaryColor = Color(0xFF1F6F9D);
const Color kLighterSecondaryColor = Color(0xFF58B6F2);
const Color kBackgroundColor = Color(0xFFF8F9FA);
const Color kTextColor = Color(0xFF1A202C);

// --- Data Model ---
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

  factory TestModel.fromJson(Map<String, dynamic> json) {
    // Handles both Template response and Chapter response formats
    return TestModel(
      id: (json['chapterId'] ?? json['template_id'] ?? json['test_id'] ?? "").toString(),
      title: json['chapterName'] ?? json['template_name'] ?? json['test_name'] ?? "Unknown Test",
      questionCount: json['questionCount'] ?? json['question_count'] ?? 20,
      durationMins: json['durationMins'] ?? json['duration_minutes'] ?? 60,
    );
  }
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

  // Loading state
  bool isLoading = false;
  List<TestModel> displayedTests = [];

  final types = ["Chapterwise", "Subjectwise", "Full Syllabus", "For You"];
  final subjects = ["Physics", "Chemistry", "Mathematics"];

  late final AnimationController _controller;
  final _storage = const FlutterSecureStorage(); 

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

  String _getExamName(int id) {
    switch (id) {
      case 1: return "JEE Main";
      case 2: return "NEET";
      case 3: return "JEE Advanced";
      default: return "Entrance Exam";
    }
  }

  // --- MAIN FETCHING LOGIC ---
  Future<void> _fetchTests({required String type, String? subject, required int examId}) async {
    setState(() {
      isLoading = true;
      displayedTests = [];
    });

    List<TestModel> results = [];
    String? token = await _storage.read(key: 'auth_token');
    Map<String, String> headers = {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };

    try {
      // SCENARIO 1: Chapterwise Selection
      if (type == "Chapterwise" && subject != null) {
        final uri = Uri.parse("$kBackendUrl/subjects/$subject/chapters");
        print("📡 Fetching Chapters: $uri");
        
        final response = await http.get(uri, headers: headers);
        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          results = data.map((json) => TestModel.fromJson(json)).toList();
        } else {
          print("⚠️ Backend Error: ${response.statusCode}");
        }
      } 
      // SCENARIO 2: Placeholder for other types (Full Syllabus, etc.)
      else if (type == "Full Syllabus") {
         // Fallback logic for now
         await Future.delayed(const Duration(milliseconds: 500));
         results = [
           TestModel(id: "mock1", title: "JEE Main Mock 1", questionCount: 75, durationMins: 180),
           TestModel(id: "mock2", title: "JEE Main Mock 2", questionCount: 75, durationMins: 180),
         ];
      }
    } catch (e) {
      print("⚠️ Connection Failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error fetching data: $e")));
    }

    if (mounted) {
      setState(() {
        displayedTests = results;
        isLoading = false;
      });
    }
  }

  void _handleTypeSelection(String type, int examId) {
    setState(() {
      selectedType = type;
      selectedSubject = null;
      displayedTests = [];
    });

    bool requiresSubject = ["Chapterwise", "Subjectwise"].contains(type);

    if (!requiresSubject) {
      _fetchTests(type: type, examId: examId);
    }
  }

  void _handleSubjectSelection(String subject, int examId) {
    setState(() {
      selectedSubject = subject;
    });
    if (selectedType != null) {
      _fetchTests(type: selectedType!, subject: subject, examId: examId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final int examId = (args is int) ? args : 1;
    final String examName = _getExamName(examId);

    bool showSubjects = ["Chapterwise", "Subjectwise"].contains(selectedType);

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: const CustomNavBar(),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text("Menu", style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
            ListTile(
              title: const Text("Dashboard"),
              onTap: () => Navigator.pushReplacementNamed(context, '/analytics'),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
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
                  Text("$examName Preparation",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  const Text("Select a specific chapter or take a full length mock test.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Content Box
            Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 900),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Filter Tests", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kTextColor)),
                    const SizedBox(height: 24),

                    // Type Tabs
                    _SelectionStep(
                      animation: _controller,
                      interval: const Interval(0.1, 0.4),
                      options: types,
                      selectedValue: selectedType,
                      onSelect: (type) => _handleTypeSelection(type, examId),
                    ),

                    AnimatedSize(duration: const Duration(milliseconds: 300), child: SizedBox(height: selectedType != null ? 24 : 0)),

                    // Subject Tabs
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: SizeTransition(sizeFactor: animation, axisAlignment: -1.0, child: child),
                      ),
                      child: showSubjects
                          ? _SelectionStep(
                              key: const ValueKey('subject_step'),
                              animation: _controller,
                              interval: const Interval(0.3, 0.6),
                              options: subjects,
                              selectedValue: selectedSubject,
                              onSelect: (subject) => _handleSubjectSelection(subject, examId),
                            )
                          : const SizedBox.shrink(key: ValueKey('empty_subject')),
                    ),

                    const Divider(height: 40, color: Colors.black12),

                    // Results List
                    if (isLoading)
                      const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator(color: kPrimaryColor)))
                    else if (displayedTests.isNotEmpty) ...[
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: displayedTests.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final test = displayedTests[index];
                          return StaggeredFadeSlideTransition(
                            animation: _controller,
                            interval: Interval(0.0 + (index * 0.05).clamp(0.0, 0.4), 1.0, curve: Curves.easeOut),
                            child: _TestListItem(
                              test: test, 
                              selectedType: selectedType,
                              subject: selectedSubject, // Pass subject for starting test
                            ),
                          );
                        },
                      ),
                    ] else if (selectedType != null && !isLoading) ...[
                      const Center(child: Padding(padding: EdgeInsets.all(20.0), child: Text("No tests found. Select options to view.", style: TextStyle(color: Colors.grey))))
                    ],

                    const SizedBox(height: 30),
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

// --- SUB-WIDGETS ---

class _TestListItem extends StatefulWidget {
  final TestModel test;
  final String? selectedType;
  final String? subject;

  const _TestListItem({required this.test, this.selectedType, this.subject});

  @override
  State<_TestListItem> createState() => _TestListItemState();
}

class _TestListItemState extends State<_TestListItem> {
  bool _isHovered = false;
  bool _isStarting = false;

  Future<void> _startAndNavigate(BuildContext context) async {
    setState(() => _isStarting = true);
    final storage = const FlutterSecureStorage();

    try {
      String? token = await storage.read(key: 'auth_token');
      Map<String, String> headers = {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      };

      // LOGIC 1: START CHAPTER TEST
      if (widget.selectedType == "Chapterwise") {
        final url = Uri.parse('$kBackendUrl/tests/start/chapter');
        final body = jsonEncode({
          "chapterId": int.parse(widget.test.id), // Ensure ID is int
          "questionCount": widget.test.questionCount
        });

        final response = await http.post(url, headers: headers, body: body);

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          // Assuming backend returns { "sessionId": "..." }
          // Or if it returns the full test object, extract the ID.
          final sessionId = data['sessionId'] ?? data['testId']; 
          
          if (mounted) {
            // Navigate to Test Screen, passing the new Session ID
            Navigator.pushNamed(context, '/test_screen', arguments: sessionId);
          }
        } else {
          _showError("Failed to start test: ${response.body}");
        }
      } 
      // LOGIC 2: START REGULAR TEST (Placeholder)
      else {
         // Implement logic for full mock tests here later
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mock Test logic not connected yet.")));
      }

    } catch (e) {
      _showError("Error connecting to server: $e");
    } finally {
      if (mounted) setState(() => _isStarting = false);
    }
  }

  void _showError(String msg) {
    if(!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _isStarting ? null : () => _startAndNavigate(context),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            color: _isHovered ? Colors.blue.shade50 : kBackgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _isHovered ? kPrimaryColor : Colors.grey.shade300),
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
              _isStarting
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                : Icon(Icons.play_circle_fill, size: 24, color: _isHovered ? kPrimaryColor : Colors.grey.shade300),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectionStep extends StatelessWidget {
  final Animation<double> animation;
  final Interval interval;
  final List<String> options;
  final String? selectedValue;
  final ValueChanged<String> onSelect;

  const _SelectionStep({
    super.key, required this.animation, required this.interval, required this.options, required this.selectedValue, required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return StaggeredFadeSlideTransition(
      animation: animation,
      interval: interval,
      child: Wrap(
        spacing: 12, runSpacing: 12,
        children: options.map((option) {
          final isSelected = option == selectedValue;
          return MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => onSelect(option),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? kPrimaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isSelected ? kPrimaryColor : Colors.grey.shade300, width: 1),
                ),
                child: Text(option,
                  style: TextStyle(fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500, color: isSelected ? Colors.white : kTextColor),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class StaggeredFadeSlideTransition extends StatelessWidget {
  final Animation<double> animation;
  final Interval interval;
  final Widget child;
  const StaggeredFadeSlideTransition({super.key, required this.animation, required this.interval, required this.child});
  
  @override
  Widget build(BuildContext context) {
    final curvedAnimation = CurvedAnimation(parent: animation, curve: interval);
    return FadeTransition(opacity: curvedAnimation, child: SlideTransition(position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(curvedAnimation), child: child));
  }
}