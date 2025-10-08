import 'package:flutter/material.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      // This structure ensures the footer appears at the very bottom after all content has been scrolled past.
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TopNavBar(),
            HeroSection(),
            FeaturesSection(),
            StatsSection(),
            FooterSection(),
          ],
        ),
      ),
    );
  }
}

class TopNavBar extends StatelessWidget {
  const TopNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      // A faint line below the header to mark separation.
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 1.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.school, color: Color(0xFF299FE8), size: 30),
              const SizedBox(width: 10),
              const Text(
                "MockTestPlatform",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A202C),
                ),
              ),
            ],
          ),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: const Text(
                  "Login",
                  style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF299FE8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: const Text(
                  "Sign Up",
                  style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}

class HeroSection extends StatelessWidget {
  const HeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        // Background Image Layer
        Container(
          height: 500,
          decoration: const BoxDecoration(
            image: DecorationImage(
              // Using a reliable image URL from Pexels
              image: NetworkImage('https://images.pexels.com/photos/267885/pexels-photo-267885.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Gradient Overlay Layer (to make text readable)
        Container(
          height: 500,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black.withOpacity(0.6), Colors.transparent],
              begin: Alignment.centerLeft,
              end: Alignment.center,
            ),
          ),
        ),
        // Text Content Layer
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: SizedBox(
            width: 600, // Constrain the text width for better readability on wide screens
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: const TextSpan(
                    style: TextStyle(fontFamily: "Inter", fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white, height: 1.2),
                    children: <TextSpan>[
                      TextSpan(text: 'Master '),
                      TextSpan(text: 'JEE & NEET', style: TextStyle(color: Color(0xFF58B6F2))),
                      TextSpan(text: ' with '),
                      TextSpan(text: 'Confidence', style: TextStyle(color: Color(0xFF58B6F2))),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Join thousands of successful students who cracked their dream exams. Get access to mock tests, detailed analytics, and personalized study plans.",
                  style: TextStyle(fontSize: 18, color: Colors.white70, height: 1.5),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF299FE8),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("Start Free Trial", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(width: 16),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF58B6F2)),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text("View Sample Tests", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600)),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class FeaturesSection extends StatelessWidget {
  const FeaturesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> features = const [
      {"title": "Comprehensive Question Bank", "desc": "10,000+ curated questions with detailed solutions."},
      {"title": "Real-Time Mock Tests", "desc": "Simulate actual JEE & NEET exam conditions."},
      {"title": "Detailed Analytics", "desc": "Track your progress and identify strengths & weaknesses."},
      {"title": "Adaptive Learning", "desc": "AI-powered personalized study plans."},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
      color: const Color(0xFFF7FAFC),
      child: Column(
        children: [
          const Text(
            "Everything You Need to Succeed",
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF1A202C)),
          ),
          const SizedBox(height: 50),
          LayoutBuilder(
            builder: (context, constraints) {
              // This makes the cards responsive for smaller screens
              final double cardWidth = constraints.maxWidth > 720 ? 320 : constraints.maxWidth;
              return Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: features.map((f) {
                  return Container(
                    width: cardWidth,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(f["title"]!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF299FE8))),
                        const SizedBox(height: 8),
                        Text(f["desc"]!, style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4)),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class StatsSection extends StatelessWidget {
  const StatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = const [
      {"label": "Active Students", "value": "50K+"},
      {"label": "Success Rate", "value": "95%"},
      {"label": "Tests Taken", "value": "1M+"},
    ];
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 40),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: stats.map((s) {
          return Column(
            children: [
              Text(
                s["value"]!,
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Color(0xFF1F6F9D)),
              ),
              const SizedBox(height: 8),
              Text(
                s["label"]!,
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class FooterSection extends StatelessWidget {
  const FooterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 40),
      color: const Color(0xFF1A202C),
      child: const Center(
        child: Text(
          "© 2025 Oelp. All rights reserved.",
          style: TextStyle(fontSize: 14, color: Colors.white70),
        ),
      ),
    );
  }
}