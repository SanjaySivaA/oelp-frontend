// lib/screens/analytics_screen.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import your auth provider
import '../providers/auth_provider.dart';
import '../widgets/custom_navbar.dart';
// Import the Review Screen so we can navigate to it
import 'review_screen.dart'; 

// =================================================================================
// 1. DATA MODELS
// =================================================================================

class AnalyticsResponse {
  final String username;
  final List<StatsCardData> statsCards;
  final TestScoreProgressionData testScoreProgression;
  final List<SubjectPerformanceData> subjectPerformance;
  final List<RecentTestData> recentTests;

  AnalyticsResponse({
    required this.username,
    required this.statsCards,
    required this.testScoreProgression,
    required this.subjectPerformance,
    required this.recentTests,
  });

  factory AnalyticsResponse.fromJson(Map<String, dynamic> json) {
    return AnalyticsResponse(
      username: json['username'] ?? 'User',
      statsCards: List<StatsCardData>.from(
          (json['stats_cards'] as List? ?? []).map((x) => StatsCardData.fromJson(x))),
      testScoreProgression:
          TestScoreProgressionData.fromJson(json['test_score_progression'] ?? {}),
      subjectPerformance: List<SubjectPerformanceData>.from(
          (json['subject_performance'] as List? ?? [])
              .map((x) => SubjectPerformanceData.fromJson(x))),
      recentTests: List<RecentTestData>.from(
          (json['recent_tests'] as List? ?? []).map((x) => RecentTestData.fromJson(x))),
    );
  }
}

class StatsCardData {
  final String title;
  final String value;
  final String change;
  final String trendColor;

  StatsCardData({
    required this.title,
    required this.value,
    required this.change,
    required this.trendColor,
  });

  factory StatsCardData.fromJson(Map<String, dynamic> json) {
    return StatsCardData(
      title: json['title'] ?? '',
      value: json['value'] ?? '',
      change: json['change'] ?? '',
      trendColor: json['trend_color'] ?? 'grey',
    );
  }
}

class TestScoreProgressionData {
  final List<FlSpot> spots;
  final List<String> dates;

  TestScoreProgressionData({required this.spots, required this.dates});

  factory TestScoreProgressionData.fromJson(Map<String, dynamic> json) {
    List<FlSpot> spotList = [];
    if (json['spots'] != null && json['spots'] is List) {
      for (var spot in (json['spots'] as List)) {
        if (spot is Map && spot['x'] != null && spot['y'] != null) {
          num x = spot['x'];
          num y = spot['y'];
          spotList.add(FlSpot(x.toDouble(), y.toDouble()));
        }
      }
    }
    return TestScoreProgressionData(
      spots: spotList,
      dates: List<String>.from(json['dates'] ?? []),
    );
  }
}

class SubjectPerformanceData {
  final String subjectName;
  final double accuracy;

  SubjectPerformanceData({required this.subjectName, required this.accuracy});

  factory SubjectPerformanceData.fromJson(Map<String, dynamic> json) {
    num accuracyNum = json['accuracy'] ?? 0.0;
    return SubjectPerformanceData(
      subjectName: json['subject_name'] ?? '',
      accuracy: accuracyNum.toDouble(),
    );
  }
}

class RecentTestData {
  final String testId; // <--- NEW: Needed for Review Navigation
  final String name;
  final String subject;
  final int score;
  final int maxScore;
  final String status;
  final String date;
  final String time;

  RecentTestData({
    required this.testId,
    required this.name,
    required this.subject,
    required this.score,
    required this.maxScore,
    required this.status,
    required this.date,
    required this.time,
  });

  factory RecentTestData.fromJson(Map<String, dynamic> json) {
    int scoreInt = (json['score'] is num) ? (json['score'] as num).toInt() : 0;
    int maxScoreInt = (json['max_score'] is num) ? (json['max_score'] as num).toInt() : 0;
    
    // Fallback: if test_id isn't sent, try sessionId or empty string
    String id = (json['test_id'] ?? json['sessionId'] ?? '').toString();

    return RecentTestData(
      testId: id,
      name: json['name'] ?? '',
      subject: json['subject'] ?? '',
      score: scoreInt,
      maxScore: maxScoreInt,
      status: json['status'] ?? 'UNKNOWN',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
    );
  }
}

// =================================================================================
// 2. API SERVICE
// =================================================================================

class _AnalyticsApiService {
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );

  static Future<AnalyticsResponse> fetchAnalyticsData(String authToken) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/analytics'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
    );

    if (response.statusCode == 200) {
      return AnalyticsResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load analytics data.');
    }
  }
}

// =================================================================================
// 3. MAIN SCREEN WIDGET
// =================================================================================

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  late Future<AnalyticsResponse> _analyticsDataFuture;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() {
    final authToken = ref.read(authProvider).token;
    if (authToken != null) {
      if (mounted) {
        setState(() {
          _analyticsDataFuture = _AnalyticsApiService.fetchAnalyticsData(authToken);
        });
      }
      return _analyticsDataFuture;
    } else {
      if (mounted) {
        setState(() {
          _analyticsDataFuture = Future.error('You must be logged in.');
        });
      }
      return _analyticsDataFuture;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomNavBar(),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text("Menu", style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
            ListTile(title: const Text("Dashboard"), onTap: () => Navigator.pop(context)),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: FutureBuilder<AnalyticsResponse>(
          future: _analyticsDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${snapshot.error}'),
                    const SizedBox(height: 10),
                    ElevatedButton(onPressed: _fetchData, child: const Text('Retry'))
                  ],
                ),
              );
            } else if (snapshot.hasData) {
              final analyticsData = snapshot.data!;
              
              if (analyticsData.statsCards.isEmpty && analyticsData.recentTests.isEmpty) {
                 return const Center(child: Text("No analytics data available yet. Take a test!"));
              }

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1400),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome back, ${analyticsData.username}!",
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        const Text("Here's your performance overview.", style: TextStyle(color: Colors.grey)),
                        const SizedBox(height: 20),

                        // Stats
                        Wrap(
                          spacing: 16, runSpacing: 16,
                          children: analyticsData.statsCards.map((cardData) {
                            IconData icon;
                            switch (cardData.title) {
                              case "Tests Completed": icon = Icons.emoji_events; break;
                              case "Avg Accuracy": icon = Icons.track_changes; break;
                              default: icon = Icons.analytics;
                            }
                            return StatsCard(
                              title: cardData.title, value: cardData.value,
                              change: cardData.change, icon: icon,
                              trendColor: cardData.trendColor == 'green' ? Colors.green : Colors.red,
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),

                        // Charts
                        Wrap(
                          spacing: 16, runSpacing: 16,
                          children: [
                            SizedBox(width: 650, height: 350, child: TestScoreChart(scoreData: analyticsData.testScoreProgression)),
                            SizedBox(width: 650, height: 350, child: PerformanceChart(performanceData: analyticsData.subjectPerformance)),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Bottom Section
                        Wrap(
                          spacing: 16, runSpacing: 16,
                          children: [
                            SizedBox(width: 450, child: SubjectAccuracyCard(accuracyData: analyticsData.subjectPerformance)),
                            SizedBox(width: 900, child: RecentTestsCard(tests: analyticsData.recentTests)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}

// =================================================================================
// 4. CHILD WIDGETS
// =================================================================================

class StatsCard extends StatelessWidget {
  final String title, value, change;
  final IconData icon;
  final Color trendColor;

  const StatsCard({super.key, required this.title, required this.value, required this.change, required this.icon, required this.trendColor});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(side: const BorderSide(color: Colors.grey, width: 0.5), borderRadius: BorderRadius.circular(8)),
      child: Container(
        width: 300, padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.grey),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 6),
            Text(change, style: TextStyle(color: trendColor, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class TestScoreChart extends StatelessWidget {
  final TestScoreProgressionData scoreData;
  const TestScoreChart({super.key, required this.scoreData});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(side: const BorderSide(color: Colors.grey, width: 0.5), borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("Score Progression", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (val, meta) {
                          int index = val.toInt();
                          if (index >= 0 && index < scoreData.dates.length) {
                            return Padding(padding: const EdgeInsets.only(top: 8.0), child: Text(scoreData.dates[index]));
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: scoreData.spots, isCurved: true, color: Colors.blue, barWidth: 4, dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.1)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PerformanceChart extends StatelessWidget {
  final List<SubjectPerformanceData> performanceData;
  const PerformanceChart({super.key, required this.performanceData});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(side: const BorderSide(color: Colors.grey, width: 0.5), borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("Performance Overview", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: BarChart(
                BarChartData(
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (val, meta) {
                          int index = val.toInt();
                          if (index >= 0 && index < performanceData.length) {
                            String name = performanceData[index].subjectName;
                            return Padding(padding: const EdgeInsets.only(top: 8.0), child: Text(name.length > 3 ? name.substring(0,3) : name));
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  barGroups: performanceData.asMap().entries.map((e) {
                    return BarChartGroupData(x: e.key, barRods: [BarChartRodData(toY: e.value.accuracy, color: Colors.blue, width: 28, borderRadius: BorderRadius.circular(4))]);
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SubjectAccuracyCard extends StatelessWidget {
  final List<SubjectPerformanceData> accuracyData;
  const SubjectAccuracyCard({super.key, required this.accuracyData});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(side: const BorderSide(color: Colors.grey, width: 0.5), borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Subject Accuracy", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...accuracyData.map((data) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(data.subjectName), Text("${data.accuracy.toStringAsFixed(1)}%")]),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(value: data.accuracy / 100, backgroundColor: Colors.grey[200], minHeight: 8, color: data.accuracy >= 80 ? Colors.green : (data.accuracy >= 50 ? Colors.orange : Colors.red)),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class RecentTestsCard extends StatelessWidget {
  final List<RecentTestData> tests;
  const RecentTestsCard({super.key, required this.tests});

  Color getScoreColor(double percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 50) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(side: const BorderSide(color: Colors.grey, width: 0.5), borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("Recent Tests", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (tests.isEmpty) const Text("No tests taken yet.", style: TextStyle(color: Colors.grey)),
            ...tests.map((test) {
              double percent = test.maxScore > 0 ? (test.score / test.maxScore) * 100 : 0;
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(6)),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(test.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(test.subject, style: const TextStyle(color: Colors.grey)),
                          Text("Date: ${test.date} • Time: ${test.time}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                    Text("${test.score}/${test.maxScore}", style: TextStyle(fontWeight: FontWeight.bold, color: getScoreColor(percent))),
                    const SizedBox(width: 8),
                    
                    // ===============================================
                    // THE REVIEW BUTTON (NAVIGATES TO REVIEW SCREEN)
                    // ===============================================
                    IconButton(
                      icon: const Icon(Icons.remove_red_eye, size: 20),
                      onPressed: () {
                         Navigator.push(
                           context, 
                           MaterialPageRoute(
                             builder: (context) => ReviewScreen(testId: test.testId)
                           )
                         );
                      },
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}