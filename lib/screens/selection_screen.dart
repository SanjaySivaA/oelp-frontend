import 'package:flutter/material.dart';
import '../widgets/custom_navbar.dart';

class SelectionScreen extends StatelessWidget {
  const SelectionScreen({super.key});

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
            ListTile(
              title: const Text("Dashboard"),
              onTap: () => Navigator.pushReplacementNamed(context, '/analytics'),
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
            // ... (Hero Section remains the same) ...
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.lightBlueAccent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: const Column(
                children: [
                  Text(
                    "Pick your Exam",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Select from India's most competitive entrance examinations.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            LayoutBuilder(
              builder: (context, constraints) {
                // List of cards to render
                final cards = [
                  const TestCard(
                    examId: 1, // <--- JEE MAIN
                    icon: Icons.school,
                    title: "JEE Main",
                    description: "Joint Entrance Examination - Main for admission to NITs and IIITs.",
                    subjects: ["Physics", "Chemistry", "Mathematics"],
                    buttonText: "Select JEE Main",
                  ),
                  const SizedBox(width: 20, height: 20),
                  const TestCard(
                    examId: 3, // <--- JEE ADVANCED
                    icon: Icons.menu_book,
                    title: "JEE Advanced",
                    description: "Advanced level examination for admission to IITs.",
                    subjects: ["Physics", "Chemistry", "Mathematics"],
                    buttonText: "Select JEE Advanced",
                  ),
                  const SizedBox(width: 20, height: 20),
                  const TestCard(
                    examId: 2, // <--- NEET
                    icon: Icons.medical_services,
                    title: "NEET",
                    description: "National Eligibility cum Entrance Test for medical colleges.",
                    subjects: ["Physics", "Chemistry", "Biology"],
                    buttonText: "Select NEET",
                  ),
                ];

                if (constraints.maxWidth > 1000) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(child: cards[0]),
                      cards[1], // Spacer
                      Flexible(child: cards[2]),
                      cards[3], // Spacer
                      Flexible(child: cards[4]),
                    ],
                  );
                } else {
                  return Column(children: cards);
                }
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// -------- UPDATED TEST CARD -------- //
class TestCard extends StatefulWidget {
  final int examId; // <--- NEW FIELD
  final IconData icon;
  final String title;
  final String description;
  final List<String> subjects;
  final String buttonText;

  const TestCard({
    super.key,
    required this.examId, // <--- REQUIRED
    required this.icon,
    required this.title,
    required this.description,
    required this.subjects,
    required this.buttonText,
  });

  @override
  State<TestCard> createState() => _TestCardState();
}

class _TestCardState extends State<TestCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: _isHovered ? (Matrix4.identity()..scale(1.03)) : Matrix4.identity(),
        child: Card(
          elevation: _isHovered ? 8 : 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade300),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(widget.icon, size: 40, color: Colors.blue),
                const SizedBox(height: 16),
                Text(widget.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(widget.description, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: widget.subjects
                      .map((s) => Chip(label: Text(s), backgroundColor: Colors.grey.shade200))
                      .toList(),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  onPressed: () {
                    // Pass the Integer ID
                    Navigator.pushNamed(
                      context,
                      '/selection_v2',
                      arguments: widget.examId, 
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(widget.buttonText),
                      const Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}