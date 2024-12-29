import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OverallProgressScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('habits').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        // Pridobimo podatke iz baze
        final habits = snapshot.data!.docs;
        int notDoneCount = 0;
        int streakDays = 0;
        String bestHabitName = "No Data";
        double bestHabitCompletion = 0.0;
        int bestHabitCheckIns = 0;
        final int totalHabits = habits.length; // Skupno število habitov
        int completedCount = 0;
        int failedCount = 0; 

        // Iteriramo skozi vse habite, da izračunamo statistike
        for (var habit in habits) {
          final data = habit.data() as Map<String, dynamic>;
          final periods = data['periods'] as Map<String, dynamic>? ?? {};
          final String name = data['name'] ?? 'Unnamed Habit';

          bool isCompleted = periods.values.any((period) => period['status'] == 'completed');
          bool isFailed = periods.values.any((period) => period['status'] == 'failed');
          
          if (isCompleted) {
            completedCount++;
          } else if (isFailed) {
            failedCount++;
          }

          // Izračunamo napredek na podlagi trenutnega obdobja
          for (var periodKey in periods.keys) {
            final periodData = periods[periodKey];

            // Najdemo habit z največjim napredkom
            final progress = periodData['progress'] ?? 0.0;
            if (progress > bestHabitCompletion) {
              bestHabitName = name;
              bestHabitCompletion = progress * 100; // Pretvorimo v odstotke
              bestHabitCheckIns = (periodData['intakes'] as List<dynamic>?)?.length ?? 0;
            }

            // Določimo streak, če je na voljo
            final streak = periodData['streak'] ?? 0;
            if (streak > streakDays) streakDays = streak;
          }
        }

        
        // Izračunamo napredek tako, da zmanjšamo vpliv "failed" habitov
        final overallCompletion = totalHabits > 0
          ? (((completedCount - failedCount).clamp(0, totalHabits) / totalHabits) * 100).toInt()
          : 0;
        

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: isLandscape
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left Section: Circular Progress Bar
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Dashboard",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                            SizedBox(height: 16),
                            CircularProgressIndicatorWithLabel(
                              percentage: overallCompletion,
                              description: "Overall Progress",
                            ),
                          ],
                        ),
                      ),
                      // Right Section: Summary and Highlights
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Status Summary
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                SummaryStat(
                                  icon: Icons.check_circle,
                                  color: Colors.green,
                                  label: "$completedCount Completed",
                                ),
                                SummaryStat(
                                  icon: Icons.emoji_events,
                                  color: Colors.orange,
                                  label: "$streakDays Days Streak",
                                ),
                                SummaryStat(
                                  icon: Icons.error,
                                  color: Colors.red,
                                  label: "$notDoneCount Not Done",
                                ),
                              ],
                            ),
                            SizedBox(height: 24),
                            // Best Habit Highlight
                            _buildBestHabitHighlight(
                              name: bestHabitName,
                              completion: bestHabitCompletion,
                              checkIns: bestHabitCheckIns,
                              streak: streakDays,
                            ),
                            SizedBox(height: 24),
                            // Motivational Quote
                            _buildMotivationalQuote(),
                          ],
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Dashboard Title
                      Text(
                        "Dashboard",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      SizedBox(height: 16),
                      // Circular Progress Bar
                      CircularProgressIndicatorWithLabel(
                        percentage: overallCompletion,
                        description: "Overall Progress",
                      ),
                      SizedBox(height: 24),
                      // Status Summary
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          SummaryStat(
                            icon: Icons.check_circle,
                            color: Colors.green,
                            label: "$completedCount Completed",
                          ),
                          SummaryStat(
                            icon: Icons.emoji_events,
                            color: Colors.orange,
                            label: "$streakDays Days Streak",
                          ),
                          SummaryStat(
                            icon: Icons.error,
                            color: Colors.red,
                            label: "$notDoneCount Not Done",
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      // Best Habit Highlight
                      _buildBestHabitHighlight(
                        name: bestHabitName,
                        completion: bestHabitCompletion,
                        checkIns: bestHabitCheckIns,
                        streak: streakDays,
                      ),
                      SizedBox(height: 24),
                      // Motivational Quote
                      _buildMotivationalQuote(),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildBestHabitHighlight({
    required String name,
    required double completion,
    required int checkIns,
    required int streak,
  }) {
    return Container(
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
                  "$name: ${completion.toStringAsFixed(1)}% Completed",
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
              Text("$checkIns Check-ins"),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.local_fire_department, color: Colors.orange),
              SizedBox(width: 8),
              Text("$streak-Day Streak"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMotivationalQuote() {
    return Container(
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