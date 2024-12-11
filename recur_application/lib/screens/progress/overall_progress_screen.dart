import 'package:flutter/material.dart';

class OverallProgressScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        SizedBox(height: 16),
        // Circular Progress Bar
        CircularProgressIndicatorWithLabel(percentage: 50, description: ""),
        SizedBox(height: 24),
        // Status Summary (Completed, Streak, Not Done)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SummaryStat(icon: Icons.check_circle, color: Colors.green, label: "25 Completed"),
              SummaryStat(icon: Icons.emoji_events, color: Colors.orange, label: "7 Days Streak"),
              SummaryStat(icon: Icons.error, color: Colors.red, label: "5 Not Done"),
            ],
          ),
        ),
        SizedBox(height: 24),
        // Best Habit Highlight
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Best Habit Highlight",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Icon(Icons.directions_run, color: Colors.blue),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Do Morning Vacuum: 70% Completed",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today, color: Colors.purple),
                    SizedBox(width: 8),
                    Text("17 Check-ins"),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.local_fire_department, color: Colors.orange),
                    SizedBox(width: 8),
                    Text("5-Day Streak"),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 24),
        // Motivational Quote
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.yellow[100],
              borderRadius: BorderRadius.circular(12),
            ),
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                "“Keep up the great work!”",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Custom Circular Progress Indicator
class CircularProgressIndicatorWithLabel extends StatelessWidget {
  final int percentage;
  final String description;

  CircularProgressIndicatorWithLabel({required this.percentage, required this.description});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 120,
              width: 120,
              child: CircularProgressIndicator(
                value: percentage / 100,
                strokeWidth: 8.0,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
            Text(
              "$percentage%",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          description,
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ],
    );
  }
}

// Custom Summary Stat Widget
class SummaryStat extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  SummaryStat({
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 36),
        SizedBox(height: 8),
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}