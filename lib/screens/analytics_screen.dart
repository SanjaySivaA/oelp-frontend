// lib/screens/analytics_screen.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import your auth provider to access the user's token
import '../providers/auth_provider.dart';
import '../widgets/custom_navbar.dart'; // Assuming this exists

// =================================================================================
// 1. DATA MODELS (Local to this file)
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
    print("--- [FLUTTER DEBUG] Parsing AnalyticsResponse ---");
    try {
      return AnalyticsResponse(
        username: json['username'] ?? 'User',
        statsCards: List<StatsCardData>.from(
            (json['stats_cards'] as List? ?? []).map((x) {
              print("  Parsing StatsCardData: ${jsonEncode(x)}"); // DEBUG
              return StatsCardData.fromJson(x);
            })),
        testScoreProgression:
            TestScoreProgressionData.fromJson(json['test_score_progression'] ?? {}),
        subjectPerformance: List<SubjectPerformanceData>.from(
            (json['subject_performance'] as List? ?? [])
                .map((x) {
                   print("  Parsing SubjectPerformanceData: ${jsonEncode(x)}"); // DEBUG
                   return SubjectPerformanceData.fromJson(x);
                 })),
        recentTests: List<RecentTestData>.from(
            (json['recent_tests'] as List? ?? []).map((x) {
               print("  Parsing RecentTestData: ${jsonEncode(x)}"); // DEBUG
               return RecentTestData.fromJson(x);
            })),
      );
    } catch (e, stacktrace) { // Capture stacktrace
      print("--- [FLUTTER ERROR] Failed to parse AnalyticsResponse: $e");
      print("Stacktrace: $stacktrace"); // DEBUG: Print stacktrace
      rethrow;
    }
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
     try {
       return StatsCardData(
        title: json['title'] ?? '',
        value: json['value'] ?? '',
        change: json['change'] ?? '',
        trendColor: json['trend_color'] ?? 'grey',
      );
     } catch (e) {
       print("--- [FLUTTER ERROR] Failed to parse StatsCardData: $e. JSON: ${jsonEncode(json)}");
       rethrow;
     }
  }
}

class TestScoreProgressionData {
  final List<FlSpot> spots;
  final List<String> dates;

  TestScoreProgressionData({required this.spots, required this.dates});

  factory TestScoreProgressionData.fromJson(Map<String, dynamic> json) {
     try {
        List<FlSpot> spotList = [];
        if (json['spots'] != null && json['spots'] is List) {
          for (var spot in (json['spots'] as List)) {
             if (spot is Map && spot.containsKey('x') && spot.containsKey('y') && spot['x'] != null && spot['y'] != null) {
                // Ensure values are treated as numbers before calling toDouble()
                num x = spot['x'];
                num y = spot['y'];
                spotList.add(FlSpot(x.toDouble(), y.toDouble()));
             } else {
                print("  WARN: Skipping invalid spot data in TestScoreProgressionData: ${jsonEncode(spot)}");
             }
          }
        }
        return TestScoreProgressionData(
          spots: spotList,
          dates: List<String>.from(json['dates'] ?? []),
        );
     } catch (e) {
        print("--- [FLUTTER ERROR] Failed to parse TestScoreProgressionData: $e. JSON: ${jsonEncode(json)}");
        rethrow;
     }
  }
}

class SubjectPerformanceData {
  final String subjectName;
  final double accuracy;

  SubjectPerformanceData({required this.subjectName, required this.accuracy});

  factory SubjectPerformanceData.fromJson(Map<String, dynamic> json) {
     try {
        // Ensure accuracy is treated as a number before calling toDouble()
        num accuracyNum = json['accuracy'] ?? 0.0;
        return SubjectPerformanceData(
          subjectName: json['subject_name'] ?? '',
          accuracy: accuracyNum.toDouble(),
        );
     } catch (e) {
        print("--- [FLUTTER ERROR] Failed to parse SubjectPerformanceData: $e. JSON: ${jsonEncode(json)}");
        rethrow;
     }
  }
}

class RecentTestData {
  final String name;
  final String subject;
  final int score;
  final int maxScore;
  final String status;
  final String date;
  final String time;

  RecentTestData({
    required this.name,
    required this.subject,
    required this.score,
    required this.maxScore,
    required this.status,
    required this.date,
    required this.time,
  });

  factory RecentTestData.fromJson(Map<String, dynamic> json) {
     try {
       // Ensure numeric types are parsed safely
       int scoreInt = (json['score'] is num) ? (json['score'] as num).toInt() : 0;
       int maxScoreInt = (json['max_score'] is num) ? (json['max_score'] as num).toInt() : 0;
       return RecentTestData(
        name: json['name'] ?? '',
        subject: json['subject'] ?? '',
        score: scoreInt,
        maxScore: maxScoreInt,
        status: json['status'] ?? 'UNKNOWN',
        date: json['date'] ?? '',
        time: json['time'] ?? '',
      );
     } catch (e) {
        print("--- [FLUTTER ERROR] Failed to parse RecentTestData: $e. JSON: ${jsonEncode(json)}");
        rethrow;
     }
  }
}

// =================================================================================
// 2. LOCAL API SERVICE (Private to this file)
// =================================================================================

class _AnalyticsApiService {
  static const String _baseUrl = "http://127.0.0.1:8000";

  static Future<AnalyticsResponse> fetchAnalyticsData(String authToken) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/analytics'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
    );

    if (response.statusCode == 200) {
      print("--- [FLUTTER DEBUG] Raw JSON received from /analytics: ---");
      print(response.body);
      print("---------------------------------------------------------");
      return AnalyticsResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load analytics data. Status: ${response.statusCode}, Body: ${response.body}');
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
    print("--- [FLUTTER DEBUG] Fetching analytics data... Token exists: ${authToken != null} ---");
    if (authToken != null) {
      if (mounted) { // Check if widget is still mounted before calling setState
        setState(() {
          _analyticsDataFuture = _AnalyticsApiService.fetchAnalyticsData(authToken);
        });
      }
      return _analyticsDataFuture;
    } else {
       if (mounted) {
         setState(() {
           _analyticsDataFuture = Future.error('You must be logged in to view analytics.');
         });
       }
      return _analyticsDataFuture;
    }
  }

  @override
  Widget build(BuildContext context) {
    print("--- [FLUTTER DEBUG] Building AnalyticsScreen ---");
    return Scaffold(
      appBar: const CustomNavBar(), // Assuming CustomNavBar exists
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text("Menu", style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
            ListTile(title: const Text("Dashboard"), onTap: () { Navigator.pop(context); /* TODO: Navigate */}),
            ListTile(title: const Text("Tests"), onTap: () { Navigator.pop(context); /* TODO: Navigate */}),
            ListTile(title: const Text("Practice"), onTap: () { Navigator.pop(context); /* TODO: Navigate */}),
            ListTile(title: const Text("Reports"), onTap: () { Navigator.pop(context); /* TODO: Navigate */}),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: FutureBuilder<AnalyticsResponse>(
          future: _analyticsDataFuture,
          builder: (context, snapshot) {
            print("--- [FLUTTER DEBUG] FutureBuilder rebuilding. State: ${snapshot.connectionState} ---");
            if (snapshot.connectionState == ConnectionState.waiting) {
              print("--- [FLUTTER DEBUG] Showing Loading Indicator ---");
              return const Center(child: CircularProgressIndicator());
            }
            else if (snapshot.hasError) {
              print("--- [FLUTTER ERROR] FutureBuilder encountered error: ${snapshot.error} ---");
              if (snapshot.stackTrace != null) {
                 print("Stacktrace: ${snapshot.stackTrace}");
              }
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column( // Added Column for Try Again button
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       Text('An error occurred: ${snapshot.error}'),
                       const SizedBox(height: 20),
                       ElevatedButton(onPressed: _fetchData, child: const Text('Try Again'))
                     ],
                  ),
                )
              );
            }
            else if (snapshot.hasData) {
              final analyticsData = snapshot.data!;
              print("--- [FLUTTER DEBUG] FutureBuilder has data! Username: ${analyticsData.username} ---");
              print("    Stats Cards Count: ${analyticsData.statsCards.length}");
              print("    Progression Spots Count: ${analyticsData.testScoreProgression.spots.length}");
              print("    Subject Perf Count: ${analyticsData.subjectPerformance.length}");
              print("    Recent Tests Count: ${analyticsData.recentTests.length}");
              print("--- [FLUTTER DEBUG] Now attempting to build the main content UI... ---");

              // **Defensive Check:**
              if (analyticsData.statsCards.isEmpty && analyticsData.recentTests.isEmpty && analyticsData.subjectPerformance.isEmpty) {
                 print("--- [FLUTTER WARN] Data received, but lists are empty. Showing basic info only. ---");
                 // Make sure scrolling is still possible for pull-to-refresh
                 return LayoutBuilder(builder: (context, constraints) {
                    return SingleChildScrollView(
                       physics: const AlwaysScrollableScrollPhysics(),
                       child: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: constraints.maxHeight),
                          child: Center(child: Padding(
                             padding: const EdgeInsets.all(16.0),
                             child: Text("Welcome back, ${analyticsData.username}!\nNo analytics data yet."),
                          )),
                       ),
                    );
                 });
              }

              try {
                // Ensure SingleChildScrollView is always scrollable for RefreshIndicator
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
                          const Text(
                            "Here's your performance overview and recent test results.",
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 20),

                          // Stats row
                          Wrap(
                            spacing: 16, runSpacing: 16,
                            children: analyticsData.statsCards.map((cardData) {
                              print("  Building StatsCard for: ${cardData.title}"); // DEBUG
                              IconData icon;
                              switch (cardData.title) {
                                case "Total Tests Completed": icon = Icons.emoji_events; break;
                                case "Average Accuracy": icon = Icons.track_changes; break;
                                case "Study Time This Week": icon = Icons.access_time; break;
                                case "Overall Progress": icon = Icons.trending_up; break;
                                default: icon = Icons.help_outline;
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

                          // Subject Accuracy + Recent Tests
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
              } catch (e, stacktrace) {
                 print("--- [FLUTTER ERROR] Error occurred during UI build: $e");
                 print("Stacktrace: $stacktrace");
                 return Center(child: Text("An error occurred while building the UI: $e"));
              }
            }
            else {
              print("--- [FLUTTER DEBUG] FutureBuilder has no data and no error. Showing 'No data found.' ---");
              // Ensure scrolling is still possible for pull-to-refresh
              return LayoutBuilder(builder: (context, constraints) {
                 return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ConstrainedBox(
                       constraints: BoxConstraints(minHeight: constraints.maxHeight),
                       child: const Center(child: Text('No data found.')),
                    ),
                 );
              });
            }
          },
        ),
      ),
    );
  }
}


// =================================================================================
// 4. CHILD WIDGETS (With Added Diagnostics)
// =================================================================================

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
    print("--- [FLUTTER DEBUG] Building StatsCard: ${title} ---");
    try {
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
    } catch (e, stacktrace) {
       print("--- [FLUTTER ERROR] Error building StatsCard '$title': $e");
       print("Stacktrace: $stacktrace");
       return Center(child: Text("Error: $e"));
    }
  }
}

class TestScoreChart extends StatelessWidget {
  final TestScoreProgressionData scoreData;

  const TestScoreChart({super.key, required this.scoreData});

  @override
  Widget build(BuildContext context) {
    print("--- [FLUTTER DEBUG] Building TestScoreChart. Spots: ${scoreData.spots.length}, Dates: ${scoreData.dates.length} ---");
    try {
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
    } catch (e, stacktrace) {
      print("--- [FLUTTER ERROR] Error building TestScoreChart: $e");
      print("Stacktrace: $stacktrace");
      return Center(child: Text("Error building score chart: $e"));
    }
  }
}

class PerformanceChart extends StatelessWidget {
  final List<SubjectPerformanceData> performanceData;

  const PerformanceChart({super.key, required this.performanceData});

  @override
  Widget build(BuildContext context) {
    print("--- [FLUTTER DEBUG] Building PerformanceChart. Data count: ${performanceData.length} ---");
     try {
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
                               // Safe substring
                               String name = performanceData[index].subjectName;
                               String shortName = name.length > 3 ? name.substring(0,3) : name;
                               return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(shortName),
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
     } catch (e, stacktrace) {
        print("--- [FLUTTER ERROR] Error building PerformanceChart: $e");
        print("Stacktrace: $stacktrace");
        return Center(child: Text("Error building performance chart: $e"));
     }
  }
}

class SubjectAccuracyCard extends StatelessWidget {
  final List<SubjectPerformanceData> accuracyData;

  const SubjectAccuracyCard({super.key, required this.accuracyData});

  @override
  Widget build(BuildContext context) {
    print("--- [FLUTTER DEBUG] Building SubjectAccuracyCard. Data count: ${accuracyData.length} ---");
    try {
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
              ...accuracyData.map((data) {
                 print("  Building accuracy bar for: ${data.subjectName}"); // DEBUG
                 return Padding(
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
                  );
                }),
            ],
          ),
        ),
      );
    } catch (e, stacktrace) {
        print("--- [FLUTTER ERROR] Error building SubjectAccuracyCard: $e");
        print("Stacktrace: $stacktrace");
        return Center(child: Text("Error building accuracy card: $e"));
    }
  }
}

class RecentTestsCard extends StatelessWidget {
  final List<RecentTestData> tests;

  const RecentTestsCard({super.key, required this.tests});

  @override
  Widget build(BuildContext context) {
    print("--- [FLUTTER DEBUG] Building RecentTestsCard. Tests count: ${tests.length} ---");
    Color getScoreColor(double percentage) {
      if (percentage >= 80) return Colors.green;
      if (percentage >= 50) return Colors.orange;
      return Colors.red;
    }

    try {
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
              ...tests.map((test) {
                print("  Building recent test item for: ${test.name}"); // DEBUG
                double percent = test.maxScore > 0 ? (test.score / test.maxScore) * 100 : 0;
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
                      const Icon(Icons.remove_red_eye, size: 20),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      );
    } catch (e, stacktrace) {
        print("--- [FLUTTER ERROR] Error building RecentTestsCard: $e");
        print("Stacktrace: $stacktrace");
        return Center(child: Text("Error building recent tests card: $e"));
    }
  }
}