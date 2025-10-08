import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert'; // Required for json.decode
import 'package:http/http.dart' as http; // Required for making API calls

// You would typically have these in separate files, but for this example, they are here.
import '../widgets/custom_navbar.dart'; 

// =================================================================================
// 1. DATA MODELS
// These Dart classes match the JSON structure from your FastAPI backend.
// This gives us type safety and makes the code much cleaner and less error-prone.
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
      username: json['username'],
      statsCards: List<StatsCardData>.from(
          json['stats_cards'].map((x) => StatsCardData.fromJson(x))),
      testScoreProgression:
          TestScoreProgressionData.fromJson(json['test_score_progression']),
      subjectPerformance: List<SubjectPerformanceData>.from(
          json['subject_performance']
              .map((x) => SubjectPerformanceData.fromJson(x))),
      recentTests: List<RecentTestData>.from(
          json['recent_tests'].map((x) => RecentTestData.fromJson(x))),
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
      title: json['title'],
      value: json['value'],
      change: json['change'],
      trendColor: json['trend_color'],
    );
  }
}

class TestScoreProgressionData {
  final List<FlSpot> spots;
  final List<String> dates;

  TestScoreProgressionData({required this.spots, required this.dates});

  factory TestScoreProgressionData.fromJson(Map<String, dynamic> json) {
    List<FlSpot> spotList = [];
    if (json['spots'] != null) {
      for (var spot in json['spots']) {
        spotList.add(FlSpot(spot['x'].toDouble(), spot['y'].toDouble()));
      }
    }
    return TestScoreProgressionData(
      spots: spotList,
      dates: List<String>.from(json['dates']),
    );
  }
}

class SubjectPerformanceData {
  final String subjectName;
  final double accuracy;

  SubjectPerformanceData({required this.subjectName, required this.accuracy});

  factory SubjectPerformanceData.fromJson(Map<String, dynamic> json) {
    return SubjectPerformanceData(
      subjectName: json['subject_name'],
      accuracy: json['accuracy'].toDouble(),
    );
  }
}

class RecentTestData {
  final String name;
  final String subject;
  final int score;
  final int maxScore;
  final String date;
  final String time;

  RecentTestData({
    required this.name,
    required this.subject,
    required this.score,
    required this.maxScore,
    required this.date,
    required this.time,
  });

  factory RecentTestData.fromJson(Map<String, dynamic> json) {
    return RecentTestData(
      name: json['name'],
      subject: json['subject'],
      score: json['score'],
      maxScore: json['max_score'],
      date: json['date'],
      time: json['time'],
    );
  }
}

// =================================================================================
// 2. API SERVICE
// A dedicated class to handle fetching data from your backend.
// =================================================================================

class ApiService {
  // IMPORTANT: Replace with your actual backend URL.
  static const String _baseUrl = "http://127.0.0.1:8000"; 

  static Future<AnalyticsResponse> fetchAnalyticsData() async {
    // IMPORTANT: You must replace this with your actual token retrieval logic.
    // e.g., from secure storage or your state management solution.
    const String authToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJ0ZXN0QGV4YW1wbGUuY29tIiwiZXhwIjoxNzU5OTUwNzQ3fQ.HGdz1qN5DVixAcyDNJU6NHAN-FKgBocnccCfNNKOiw8"; 

    final response = await http.get(
      Uri.parse('$_baseUrl/analytics'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
    );

    if (response.statusCode == 200) {
      // If the server returns a 200 OK response, parse the JSON.
      return AnalyticsResponse.fromJson(json.decode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // throw an exception that the UI can catch.
      throw Exception('Failed to load analytics data: ${response.body}');
    }
  }
}


// =================================================================================
// 3. MAIN SCREEN WIDGET (STATEFUL)
// Converted to a StatefulWidget to manage the asynchronous data fetching process.
// =================================================================================

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  // This Future will hold our analytics data.
  late Future<AnalyticsResponse> _analyticsDataFuture;

  @override
  void initState() {
    super.initState();
    // Start fetching the data as soon as the widget is created.
    _analyticsDataFuture = ApiService.fetchAnalyticsData();
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
              child: Text( "Menu", style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
            ListTile(title: const Text("Dashboard"), onTap: () {}),
            ListTile(title: const Text("Tests"), onTap: () {}),
            ListTile(title: const Text("Practice"), onTap: () {}),
            ListTile(title: const Text("Reports"), onTap: () {}),
          ],
        ),
      ),
      // FutureBuilder is the key to handling async data. It rebuilds the UI
      // based on the state of the Future: loading, has data, or has error.
      body: FutureBuilder<AnalyticsResponse>(
        future: _analyticsDataFuture,
        builder: (context, snapshot) {
          // --- State 1: LOADING ---
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // --- State 2: ERROR ---
          else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          // --- State 3: SUCCESS (HAS DATA) ---
          else if (snapshot.hasData) {
            final analyticsData = snapshot.data!;
            return SingleChildScrollView(
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
                      const Text(
                        "Here's your performance overview and recent test results.",
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 20),

                      // Stats row - now built dynamically from the API response
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: analyticsData.statsCards.map((cardData) {
                          // Determine icon based on title
                          IconData icon;
                          switch (cardData.title) {
                            case "Total Tests Completed": icon = Icons.emoji_events; break;
                            case "Average Accuracy": icon = Icons.track_changes; break;
                            case "Study Time This Week": icon = Icons.access_time; break;
                            case "Overall Progress": icon = Icons.trending_up; break;
                            default: icon = Icons.help_outline;
                          }
                          return StatsCard(
                            title: cardData.title,
                            value: cardData.value,
                            change: cardData.change,
                            icon: icon,
                            trendColor: cardData.trendColor == 'green' ? Colors.green : Colors.red,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // Charts - now receive data from the API
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          SizedBox(
                            width: 650, 
                            height: 350, 
                            child: TestScoreChart(scoreData: analyticsData.testScoreProgression)
                          ),
                          SizedBox(
                            width: 650, 
                            height: 350, 
                            child: PerformanceChart(performanceData: analyticsData.subjectPerformance)
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Subject Accuracy + Recent Tests - now receive data
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          SizedBox(
                            width: 450, 
                            child: SubjectAccuracyCard(accuracyData: analyticsData.subjectPerformance)
                          ),
                          SizedBox(
                            width: 900, 
                            child: RecentTestsCard(tests: analyticsData.recentTests)
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          // Fallback state
          else {
            return const Center(child: Text('No data found.'));
          }
        },
      ),
    );
  }
}


// =================================================================================
// 4. UPDATED CHILD WIDGETS
// These widgets are now leaner. They just receive data and display it.
// =================================================================================

// StatsCard remains the same as it was already well-parameterized.
class StatsCard extends StatelessWidget {
  final String title;
  final String value;
  final String change;
  final IconData icon;
  final Color trendColor;

  const StatsCard({
    super.key,
    required this.title,
    required this.value,
    required this.change,
    required this.icon,
    required this.trendColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.grey, width: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Container(
        width: 300,
        padding: const EdgeInsets.all(16),
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
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.grey, width: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("Test Score Progression",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index >= 0 && index < scoreData.dates.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(scoreData.dates[index]),
                            );
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
                      isCurved: true,
                      spots: scoreData.spots.isEmpty ? [const FlSpot(0,0)] : scoreData.spots, // Use API data
                      color: Colors.blue,
                      barWidth: 4,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.1),
                      ),
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
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.grey, width: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("Performance Overview",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Expanded(
              child: BarChart(
                BarChartData(
                  gridData: const FlGridData(show: false),
                   titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index >= 0 && index < performanceData.length) {
                             return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(performanceData[index].subjectName.substring(0,3)),
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  // Use API data to generate BarChartGroupData dynamically
                  barGroups: performanceData.asMap().entries.map((entry) {
                    int index = entry.key;
                    SubjectPerformanceData data = entry.value;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: data.accuracy,
                          color: Colors.blue,
                          width: 28,
                          borderRadius: BorderRadius.circular(4)
                        )
                      ],
                    );
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
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.grey, width: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Subject-wise Accuracy",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            // Use API data to build the list of progress bars
            ...accuracyData.map((data) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(data.subjectName),
                          Text("${data.accuracy.toStringAsFixed(1)}%")
                        ],
                      ),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(
                        value: data.accuracy / 100,
                        backgroundColor: Colors.grey[200],
                        color: data.accuracy >= 85
                            ? Colors.green
                            : data.accuracy >= 70
                                ? Colors.orange
                                : Colors.red,
                        minHeight: 8,
                      ),
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

  @override
  Widget build(BuildContext context) {
    Color getScoreColor(double percentage) {
      if (percentage >= 80) return Colors.green;
      if (percentage >= 50) return Colors.orange;
      return Colors.red;
    }

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Colors.grey, width: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("Recent Tests",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            // Use API data to build the list of recent tests
            ...tests.map((test) {
              double percent = (test.score / test.maxScore) * 100;
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(test.name,
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(test.subject,
                              style: const TextStyle(color: Colors.grey)),
                          Text("Date: ${test.date} • Time: ${test.time}",
                              style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                    Text("${test.score}/${test.maxScore}",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: getScoreColor(percent))),
                    const SizedBox(width: 8),
                    // This could later navigate to a detailed report screen
                    const Icon(Icons.remove_red_eye, size: 20),
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
