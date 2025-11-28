import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Ensure this import points to your actual TexText widget file
import '../widgets/tex_text.dart'; 

// Configuration
const String kBackendUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://127.0.0.1:8000');

// ==========================================
// 1. UPDATED DATA MODELS (With Sections)
// ==========================================

class ReviewTest {
  final String testName;
  final List<ReviewSection> sections;

  ReviewTest({required this.testName, required this.sections});

  // Helper to get a flat list of all questions for the PageView
  List<ReviewQuestion> get allQuestions => sections.expand((s) => s.questions).toList();

  factory ReviewTest.fromJson(Map<String, dynamic> json) {
    List<ReviewSection> sectionsList = [];
    if (json['sections'] != null) {
      for (var sec in json['sections']) {
        sectionsList.add(ReviewSection.fromJson(sec));
      }
    }
    return ReviewTest(
      testName: json['testName'] ?? 'Review',
      sections: sectionsList,
    );
  }
}

class ReviewSection {
  final String sectionName;
  final String questionType;
  final List<ReviewQuestion> questions;

  ReviewSection({
    required this.sectionName,
    required this.questionType,
    required this.questions,
  });

  factory ReviewSection.fromJson(Map<String, dynamic> json) {
    List<ReviewQuestion> qs = [];
    if (json['questions'] != null) {
      for (var q in json['questions']) {
        qs.add(ReviewQuestion.fromJson(q, json['questionType'] ?? 'UNKNOWN'));
      }
    }
    return ReviewSection(
      sectionName: json['sectionName'] ?? 'Section',
      questionType: json['questionType'] ?? '',
      questions: qs,
    );
  }
}

class ReviewQuestion {
  final String id;
  final String text;
  final String type;
  final List<ReviewOption> options;
  final double? userNumericalAnswer;
  final double? correctNumericalAnswer;
  final String status; // CORRECT, INCORRECT, UNATTEMPTED
  final int positiveMarks;
  final int negativeMarks;

  ReviewQuestion({
    required this.id, required this.text, required this.type,
    required this.options, this.userNumericalAnswer, this.correctNumericalAnswer,
    required this.status, required this.positiveMarks, required this.negativeMarks
  });

  factory ReviewQuestion.fromJson(Map<String, dynamic> json, String type) {
    return ReviewQuestion(
      id: json['questionId'],
      text: json['questionText'],
      type: type,
      status: (json['status'] == null || json['status'].toString().isEmpty) 
          ? 'UNATTEMPTED' 
          : json['status'],
      positiveMarks: json['positiveMarks'] ?? 4,
      negativeMarks: json['negativeMarks'] ?? 1,
      userNumericalAnswer: (json['userIntegerAnswer'] as num?)?.toDouble(),
      correctNumericalAnswer: (json['correctIntegerAnswer'] as num?)?.toDouble(),
      options: (json['options'] as List? ?? []).map((o) => ReviewOption.fromJson(o)).toList(),
    );
  }
}

class ReviewOption {
  final String text;
  final bool isCorrect;
  final bool isSelected;

  ReviewOption({required this.text, required this.isCorrect, required this.isSelected});

  factory ReviewOption.fromJson(Map<String, dynamic> json) {
    return ReviewOption(
      text: json['optionText'] ?? '',
      isCorrect: json['isCorrect'] ?? false,
      isSelected: json['isSelected'] ?? false,
    );
  }
}

// ==========================================
// 2. REVIEW SCREEN UI
// ==========================================

class ReviewScreen extends ConsumerStatefulWidget {
  final String testId;
  const ReviewScreen({super.key, required this.testId});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  late Future<ReviewTest> _reviewFuture;
  final PageController _pageController = PageController();
  final _storage = const FlutterSecureStorage();

  // State for Navigation
  int _currentGlobalIndex = 0;
  int _currentSectionIndex = 0;
  bool _isPanelVisible = true;

  @override
  void initState() {
    super.initState();
    _reviewFuture = _fetchReviewData();
  }

  Future<ReviewTest> _fetchReviewData() async {
    String? token = await _storage.read(key: 'auth_token');
    final response = await http.get(
      Uri.parse('$kBackendUrl/tests/${widget.testId}'),
      headers: {
        "Content-Type": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      return ReviewTest.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to load review data: ${response.body}");
    }
  }

  // Helper to jump to a specific section
  void _jumpToSection(ReviewTest test, int sectionIndex) {
    int targetGlobalIndex = 0;
    for (int i = 0; i < sectionIndex; i++) {
      targetGlobalIndex += test.sections[i].questions.length;
    }
    _pageController.jumpToPage(targetGlobalIndex);
    // State update happens in onPageChanged
  }

  // Handle page swipes to update section index
  void _onPageChanged(int index, ReviewTest test) {
    setState(() {
      _currentGlobalIndex = index;
    });

    // Determine which section this index belongs to
    int accumulated = 0;
    for (int i = 0; i < test.sections.length; i++) {
      int count = test.sections[i].questions.length;
      if (index < accumulated + count) {
        if (_currentSectionIndex != i) {
          setState(() => _currentSectionIndex = i);
        }
        break;
      }
      accumulated += count;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text("Test Review", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder<ReviewTest>(
        future: _reviewFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final test = snapshot.data!;
          final allQuestions = test.allQuestions;

          return Column(
            children: [
              // 1. Section Navigation Bar
              _buildSectionNavBar(test),

              // 2. Main Content Area
              Expanded(
                child: Stack(
                  children: [
                    // Questions PageView
                    PageView.builder(
                      controller: _pageController,
                      itemCount: allQuestions.length,
                      onPageChanged: (index) => _onPageChanged(index, test),
                      itemBuilder: (context, index) {
                        // Find section-relative index for display (e.g., "Question 1 of 20")
                        int relativeIndex = index;
                        int sectionTotal = 0;
                        for (var sec in test.sections) {
                          if (relativeIndex < sec.questions.length) {
                            sectionTotal = sec.questions.length;
                            break;
                          }
                          relativeIndex -= sec.questions.length;
                        }
                        
                        return _buildQuestionView(allQuestions[index], relativeIndex, sectionTotal);
                      },
                    ),

                    // Right Navigation Panel
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      right: _isPanelVisible ? 0 : -275,
                      top: 0, bottom: 0,
                      child: _buildReviewPanel(test),
                    ),

                    // Toggle Button
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      right: _isPanelVisible ? 275 : 0,
                      top: MediaQuery.of(context).size.height / 2 - 50,
                      child: GestureDetector(
                        onTap: () => setState(() => _isPanelVisible = !_isPanelVisible),
                        child: Container(
                          width: 24, height: 100,
                          decoration: const BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.horizontal(left: Radius.circular(12)),
                          ),
                          child: Icon(
                            _isPanelVisible ? Icons.arrow_forward_ios : Icons.arrow_back_ios,
                            color: Colors.white, size: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- WIDGET: Section Navigation Bar ---
  Widget _buildSectionNavBar(ReviewTest test) {
    return Container(
      height: 58,
      color: const Color(0xFFF8F9FA),
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 12.0),
      alignment: Alignment.centerLeft,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: test.sections.asMap().entries.map((entry) {
            int index = entry.key;
            ReviewSection section = entry.value;
            bool isActive = index == _currentSectionIndex;

            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ActionChip(
                label: Text(section.sectionName),
                backgroundColor: isActive ? Colors.blue : Colors.grey[200],
                labelStyle: TextStyle(
                  color: isActive ? Colors.white : Colors.black87,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
                onPressed: () => _jumpToSection(test, index),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // --- WIDGET: Question Display ---
  Widget _buildQuestionView(ReviewQuestion q, int relativeIndex, int sectionTotal) {
    String marksText = "0";
    Color marksColor = Colors.grey;
    if (q.status == "CORRECT") {
      marksText = "+${q.positiveMarks}";
      marksColor = Colors.green;
    } else if (q.status == "INCORRECT") {
      marksText = "-${q.negativeMarks}";
      marksColor = Colors.red;
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100), 
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Question ${relativeIndex + 1} of $sectionTotal", 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey)),
                  
                  Row(
                    children: [
                      Text("Marks: $marksText", 
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: marksColor)),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatusColor(q.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _getStatusColor(q.status)),
                        ),
                        child: Text(q.status, 
                          style: TextStyle(fontWeight: FontWeight.bold, color: _getStatusColor(q.status))),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Question Text
              TexText(
                q.text,
                style: const TextStyle(fontSize: 18, height: 1.5, fontFamily: 'Inter', color: Colors.black87),
              ),
              const SizedBox(height: 30),

              // Options
              if (q.type == "NUMERICAL")
                 _buildNumericalReview(q)
              else
                 ...q.options.map((opt) => _buildOptionReview(opt)).toList(),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumericalReview(ReviewQuestion q) {
    String formatNum(double? n) {
      if (n == null) return "N/A";
      if (n % 1 == 0) return n.toInt().toString(); 
      return n.toStringAsFixed(2);
    }
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Text("Your Answer: ", style: TextStyle(fontSize: 18)),
            Text(q.userNumericalAnswer == null ? 'Not Attempted' : formatNum(q.userNumericalAnswer),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: q.status == "CORRECT" ? Colors.green : (q.status == "UNATTEMPTED" ? Colors.grey : Colors.red))),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            const Text("Correct Answer: ", style: TextStyle(fontSize: 18)),
            Text(formatNum(q.correctNumericalAnswer), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
          ]),
        ],
      ),
    );
  }

  Widget _buildOptionReview(ReviewOption opt) {
    Color borderColor = Colors.grey.shade300;
    Color bgColor = Colors.transparent;
    IconData? icon;
    Color iconColor = Colors.transparent;

    if (opt.isCorrect) {
      borderColor = Colors.green;
      bgColor = Colors.green.withOpacity(0.1);
      icon = Icons.check_circle;
      iconColor = Colors.green;
    } else if (opt.isSelected && !opt.isCorrect) {
      borderColor = Colors.red;
      bgColor = Colors.red.withOpacity(0.1);
      icon = Icons.cancel;
      iconColor = Colors.red;
    } else if (opt.isSelected) {
      borderColor = Colors.blue;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(color: borderColor, width: (opt.isSelected || opt.isCorrect) ? 2 : 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2.0),
            child: icon != null 
              ? Icon(icon, color: iconColor, size: 22)
              : Icon(Icons.radio_button_unchecked, color: Colors.grey.shade400, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TexText(
              opt.text,
              style: const TextStyle(fontSize: 16, color: Colors.black87, fontFamily: 'Inter'),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET: Right Navigation Panel ---
  Widget _buildReviewPanel(ReviewTest test) {
    // Get visible questions for the current section
    final currentSection = test.sections[_currentSectionIndex];
    final sectionQuestions = currentSection.questions;
    
    // Calculate global offset for this section to enable jumping
    int globalOffset = 0;
    for (int i = 0; i < _currentSectionIndex; i++) {
      globalOffset += test.sections[i].questions.length;
    }

    return Container(
      width: 275,
      color: Colors.white,
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            color: Colors.blue.shade800,
            child: Column(
              children: [
                Text(currentSection.sectionName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const Text("Review Question Map", style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          
          // Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5, crossAxisSpacing: 8, mainAxisSpacing: 8,
              ),
              itemCount: sectionQuestions.length,
              itemBuilder: (context, index) {
                final q = sectionQuestions[index];
                final globalIndex = globalOffset + index;
                final isCurrent = globalIndex == _currentGlobalIndex;

                return GestureDetector(
                  onTap: () {
                    _pageController.jumpToPage(globalIndex);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: _getStatusColor(q.status),
                      border: isCurrent ? Border.all(color: Colors.black, width: 2) : null,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "${index + 1}",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              },
            ),
          ),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _legendItem("Correct", Colors.green),
          _legendItem("Incorrect", Colors.red),
          _legendItem("Unattempted", Colors.grey),
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          CircleAvatar(radius: 6, backgroundColor: color),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "CORRECT": return Colors.green;
      case "INCORRECT": return Colors.red;
      default: return Colors.grey;
    }
  }
}