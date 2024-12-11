import 'package:flutter/material.dart';

class OverallProgressScreen extends StatelessWidget {
  final int currentPageIndex; // Dodaj trenutni indeks strani

  OverallProgressScreen({required this.currentPageIndex});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 16),
        // Filter Buttons (All, Meditate, Morning Routine)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FilterButton(label: "All", isActive: true, color: Colors.green),
            FilterButton(label: "Meditate", isActive: false, color: Colors.yellow),
            FilterButton(label: "Morning Routine", isActive: false, color: Colors.blue),
          ],
        ),
        SizedBox(height: 24),
        // Circular Progress Bar
        CircularProgressIndicatorWithLabel(percentage: 50),
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
              ),
            ),
          ),
        ),
        SizedBox(height: 24),
        // Page Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            return AnimatedContainer(
              duration: Duration(milliseconds: 300),
              margin: EdgeInsets.symmetric(horizontal: 4),
              height: 10,
              width: currentPageIndex == index ? 12 : 8,
              decoration: BoxDecoration(
                color: currentPageIndex == index ? Colors.teal : Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            );
          }),
        ),
        SizedBox(height: 24),
      ],
    );
  }
}

// Custom Filter Button Widget
class FilterButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color color;

  FilterButton({
    required this.label,
    required this.isActive,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isActive ? color : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// Custom Circular Progress Indicator
class CircularProgressIndicatorWithLabel extends StatelessWidget {
  final int percentage;

  CircularProgressIndicatorWithLabel({required this.percentage});

  @override
  Widget build(BuildContext context) {
    return Stack(
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