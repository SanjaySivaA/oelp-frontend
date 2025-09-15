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
        child: Column(
          children: [
            // -------- HERO SECTION -------- //
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
              child: Column(
                children: const [
                  Text(
                    "Choose Your Test Type",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "Select from India's most competitive entrance examinations and start your journey towards academic excellence.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // -------- AVAILABLE TEST TYPES -------- //
            const Text(
              "Available Test Types",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Choose the examination that aligns with your career goals and academic aspirations.",
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 30),

            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 1000) {
                  // 3 cards in a row for wide screens
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Flexible(
                        child: TestCard(
                          icon: Icons.school,
                          title: "JEE Main",
                          description:
                              "Joint Entrance Examination - Main for admission to NITs, IIITs, and other centrally funded technical institutions.",
                          subjects: ["Physics", "Chemistry", "Mathematics"],
                          buttonText: "Select JEE Main",
                        ),
                      ),
                      SizedBox(width: 20),
                      Flexible(
                        child: TestCard(
                          icon: Icons.menu_book,
                          title: "JEE Advanced",
                          description:
                              "Advanced level examination for admission to Indian Institutes of Technology (IITs) and other prestigious engineering colleges.",
                          subjects: ["Physics", "Chemistry", "Mathematics"],
                          buttonText: "Select JEE Advanced",
                        ),
                      ),
                      SizedBox(width: 20),
                      Flexible(
                        child: TestCard(
                          icon: Icons.medical_services,
                          title: "NEET",
                          description:
                              "National Eligibility cum Entrance Test for admission to medical and dental colleges across India.",
                          subjects: ["Physics", "Chemistry", "Biology"],
                          buttonText: "Select NEET",
                        ),
                      ),
                    ],
                  );
                } else {
                  // stack vertically for mobile
                  return Column(
                    children: const [
                      TestCard(
                        icon: Icons.school,
                        title: "JEE Main",
                        description:
                            "Joint Entrance Examination - Main for admission to NITs, IIITs, and other centrally funded technical institutions.",
                        subjects: ["Physics", "Chemistry", "Mathematics"],
                        buttonText: "Select JEE Main",
                      ),
                      SizedBox(height: 20),
                      TestCard(
                        icon: Icons.menu_book,
                        title: "JEE Advanced",
                        description:
                            "Advanced level examination for admission to Indian Institutes of Technology (IITs) and other prestigious engineering colleges.",
                        subjects: ["Physics", "Chemistry", "Mathematics"],
                        buttonText: "Select JEE Advanced",
                      ),
                      SizedBox(height: 20),
                      TestCard(
                        icon: Icons.medical_services,
                        title: "NEET",
                        description:
                            "National Eligibility cum Entrance Test for admission to medical and dental colleges across India.",
                        subjects: ["Physics", "Chemistry", "Biology"],
                        buttonText: "Select NEET",
                      ),
                    ],
                  );
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

// -------- TEST CARD WIDGET -------- //
class TestCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String description;
  final List<String> subjects;
  final String buttonText;

  const TestCard({
    super.key,
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
        transform: _isHovered
            ? (Matrix4.identity()..scale(1.03))
            : Matrix4.identity(),
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
                Text(widget.title,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(widget.description,
                    style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: widget.subjects
                      .map((s) => Chip(
                            label: Text(s),
                            backgroundColor: Colors.grey.shade200,
                          ))
                      .toList(),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("${widget.title} selected")),
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
