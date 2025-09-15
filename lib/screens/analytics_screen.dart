import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../widgets/custom_navbar.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

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
              child: Text(
                "Menu",
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
            ListTile(
              title: const Text("Dashboard"),
              onTap: () {},
            ),
            ListTile(
              title: const Text("Tests"),
              onTap: () {},
            ),
            ListTile(
              title: const Text("Practice"),
              onTap: () {},
            ),
            ListTile(
              title: const Text("Reports"),
              onTap: () {},
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1400), // reduce white gaps
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Welcome back, John!",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Here's your performance overview and recent test results.",
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),

                // Stats row
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: const [
                    StatsCard(
                      title: "Total Tests Completed",
                      value: "47",
                      change: "+12% from last month",
                      icon: Icons.emoji_events,
                      trendColor: Colors.green,
                    ),
                    StatsCard(
                      title: "Average Accuracy",
                      value: "84%",
                      change: "+5% from last month",
                      icon: Icons.track_changes,
                      trendColor: Colors.green,
                    ),
                    StatsCard(
                      title: "Study Time This Week",
                      value: "24.5h",
                      change: "-2% from last week",
                      icon: Icons.access_time,
                      trendColor: Colors.red,
                    ),
                    StatsCard(
                      title: "Overall Progress",
                      value: "92%",
                      change: "+8% from last month",
                      icon: Icons.trending_up,
                      trendColor: Colors.green,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Charts
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: const [
                    SizedBox(width: 650, height: 350, child: TestScoreChart()),
                    SizedBox(width: 650, height: 350, child: PerformanceChart()),
                  ],
                ),
                const SizedBox(height: 24),

                // Subject Accuracy + Recent Tests
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: const [
                    SizedBox(width: 450, child: SubjectAccuracyCard()),
                    SizedBox(width: 900, child: RecentTestsCard()),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ------------------ STATS CARD ------------------ //

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

// ------------------ TEST SCORE CHART ------------------ //

class TestScoreChart extends StatelessWidget {
  const TestScoreChart({super.key});

  @override
  Widget build(BuildContext context) {
    final dates = ["Jan 5", "Jan 12", "Jan 20", "Feb 1", "Feb 10", "Feb 20", "Mar 1"];

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
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index >= 0 && index < dates.length) {
                            return Text(dates[index]);
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      spots: const [
                        FlSpot(0, 75),
                        FlSpot(1, 82),
                        FlSpot(2, 78),
                        FlSpot(3, 85),
                        FlSpot(4, 88),
                        FlSpot(5, 92),
                        FlSpot(6, 79),
                      ],
                      color: Colors.blue,
                      barWidth: 4,
                      dotData: FlDotData(show: true),
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

// ------------------ PERFORMANCE CHART ------------------ //

class PerformanceChart extends StatelessWidget {
  const PerformanceChart({super.key});

  @override
  Widget build(BuildContext context) {
    final subjects = ["Math", "Physics", "Chemistry", "English", "Biology"];

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
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index >= 0 && index < subjects.length) {
                            return Text(subjects[index]);
                          }
                          return const SizedBox();
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  barGroups: [
                    BarChartGroupData(
                        x: 0, barRods: [BarChartRodData(toY: 85, color: Colors.blue, width: 28)]),
                    BarChartGroupData(
                        x: 1, barRods: [BarChartRodData(toY: 78, color: Colors.blue, width: 28)]),
                    BarChartGroupData(
                        x: 2, barRods: [BarChartRodData(toY: 92, color: Colors.blue, width: 28)]),
                    BarChartGroupData(
                        x: 3, barRods: [BarChartRodData(toY: 89, color: Colors.blue, width: 28)]),
                    BarChartGroupData(
                        x: 4, barRods: [BarChartRodData(toY: 76, color: Colors.blue, width: 28)]),
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

// ------------------ SUBJECT ACCURACY ------------------ //

class SubjectAccuracyCard extends StatelessWidget {
  const SubjectAccuracyCard({super.key});

  @override
  Widget build(BuildContext context) {
    final subjects = [
      {"name": "Mathematics", "accuracy": 85},
      {"name": "Physics", "accuracy": 78},
      {"name": "Chemistry", "accuracy": 92},
      {"name": "English", "accuracy": 89},
      {"name": "Biology", "accuracy": 76},
    ];

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
            ...subjects.map((s) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [Text(s["name"].toString()), Text("${s["accuracy"]}%")]),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(
                        value: (s["accuracy"] as int) / 100,
                        backgroundColor: Colors.grey[200],
                        color: (s["accuracy"] as int) >= 85
                            ? Colors.green
                            : (s["accuracy"] as int) >= 70
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

// ------------------ RECENT TESTS ------------------ //

class RecentTestsCard extends StatelessWidget {
  const RecentTestsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final tests = [
      {
        "name": "Algebra Fundamentals",
        "subject": "Mathematics",
        "score": 42,
        "max": 50,
        "status": "Completed",
        "date": "Jan 15, 2025",
        "time": "45 mins"
      },
      {
        "name": "Organic Chemistry",
        "subject": "Chemistry",
        "score": 38,
        "max": 40,
        "status": "Completed",
        "date": "Jan 20, 2025",
        "time": "50 mins"
      },
      {
        "name": "Physics Mechanics",
        "subject": "Physics",
        "score": 20,
        "max": 45,
        "status": "Completed",
        "date": "Feb 2, 2025",
        "time": "60 mins"
      },
      {
        "name": "Grammar Basics",
        "subject": "English",
        "score": 47,
        "max": 50,
        "status": "Completed",
        "date": "Feb 10, 2025",
        "time": "40 mins"
      },
    ];

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
            ...tests.map((t) {
              double percent = (t["score"] as int) / (t["max"] as int) * 100;
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
                            Text(t["name"].toString(),
                                style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text(t["subject"].toString(),
                                style: const TextStyle(color: Colors.grey)),
                            Text("Date: ${t["date"]} • Time: ${t["time"]}",
                                style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ]),
                    ),
                    Text("${t["score"]}/${t["max"]}",
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
  }
}
