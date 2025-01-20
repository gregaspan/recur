import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OverallProgressScreen extends StatefulWidget {
  final String selectedFilter; // Filter, ki je izbran v ProgressScreen

  OverallProgressScreen({required this.selectedFilter});

  @override
  _OverallProgressScreenState createState() => _OverallProgressScreenState();
}

class _OverallProgressScreenState extends State<OverallProgressScreen> {
  List<String> completedHabits = []; // Seznam zaključenih habitov
  int completedPeriods = 0; // Skupno število zaključenih obdobij
  int totalPeriods = 0; // Skupno število vseh obdobij
  Map<String, int> streaks = {}; // Za shranjevanje streakov za vsak habit

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    // Pridobite userId prijavljenega uporabnika
  final String? userId = FirebaseAuth.instance.currentUser?.uid;

  if (userId == null) {
    return Center(child: Text("User is not logged in."));
  }

  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('habits')
        .where('userId', isEqualTo: userId) // Filtriraj habite po userId
        .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final habits = snapshot.data!.docs;
        int streakDays = 0;
        String bestHabitName = "No Data";
        double bestHabitCompletion = 0.0;
        int bestHabitCheckIns = 0;
        int bestHabitStreak = 0; // Dodajemo streak za najboljši habit

        completedHabits.clear();
        completedPeriods = 0;
        totalPeriods = 0;

        // Filtriranje habitov glede na selectedFilter
        for (var habit in habits) {
          final data = habit.data() as Map<String, dynamic>;
          final periods = data['periods'] as Map<String, dynamic>? ?? {};
          final String name = data['name'] ?? 'Unnamed Habit';
          final String type = data['type'] ?? ''; // Filter tip habit-a

          // Preverimo, ali ta habit ustreza izbranemu filtru
          if (widget.selectedFilter != "All" && widget.selectedFilter != type) {
            continue; // Če ne ustreza, preskočimo ta habit
          }

          int habitCompletedPeriods = 0;
          int habitStreak = 0;

          for (var periodKey in periods.keys) {
            final periodData = periods[periodKey];
            final status = periodData['status'] ?? "ongoing";

            if (status == "completed") {
              habitCompletedPeriods++;
              completedPeriods++;
            }
            totalPeriods++;

            final progress = periodData['progress'] ?? 0.0;
            if (progress > bestHabitCompletion) {
              bestHabitName = name;
              bestHabitCompletion = progress * 100;
              bestHabitCheckIns =
                  (periodData['intakes'] as List<dynamic>?)?.length ?? 0;
            }

            final streak = periodData['streak'] ?? 0;
            if (streak > habitStreak) {
              habitStreak = streak; // Najdi največji streak za ta habit
            }

            if (streak > streakDays) streakDays = streak;
          }

          if (habitCompletedPeriods > 0) {
            completedHabits
                .add("$name: $habitCompletedPeriods periods completed");
            streaks[name] = habitStreak; // Dodaj streak za ta habit
          }

          if (habitStreak > bestHabitStreak) {
            bestHabitStreak = habitStreak; // Nastavimo najboljši streak
          }
        }

        final overallCompletion = totalPeriods > 0
            ? ((completedPeriods / totalPeriods) * 100).toInt()
            : 0;

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: isLandscape
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("Dashboard",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20)),
                            SizedBox(height: 16),
                            CircularProgressIndicatorWithLabel(
                              percentage: overallCompletion,
                              description: "Overall Progress",
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                GestureDetector(
                                  onTap: () => _showHabitList(),
                                  child: SummaryStat(
                                    icon: Icons.check_circle,
                                    color: Colors.green,
                                    label: "$completedPeriods Completed",
                                  ),
                                ),
                                SummaryStat(
                                  icon: Icons.emoji_events,
                                  color: Colors.orange,
                                  label: "$streakDays Days Streak",
                                ),
                              ],
                            ),
                            SizedBox(height: 24),
                            _buildBestHabitHighlight(
                              name: bestHabitName,
                              completion: bestHabitCompletion,
                              checkIns: bestHabitCheckIns,
                              streak: streakDays,
                            ),
                            SizedBox(height: 24),
                            _buildMotivationalQuote(overallCompletion),
                          ],
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("Dashboard",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20)),
                      SizedBox(height: 16),
                      CircularProgressIndicatorWithLabel(
                        percentage: overallCompletion,
                        description: "Overall Progress",
                      ),
                      SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                            onTap: () => _showHabitList(),
                            child: SummaryStat(
                              icon: Icons.check_circle,
                              color: Colors.green,
                              label: "$completedPeriods Completed",
                            ),
                          ),
                          SummaryStat(
                            icon: Icons.emoji_events,
                            color: Colors.orange,
                            label: "$streakDays Days Streak",
                          ),
                        ],
                      ),
                      SizedBox(height: 24),
                      _buildBestHabitHighlight(
                        name: bestHabitName,
                        completion: bestHabitCompletion,
                        checkIns: bestHabitCheckIns,
                        streak: streakDays,
                      ),
                      SizedBox(height: 24),
                      _buildMotivationalQuote(overallCompletion),
                    ],
                  ),
          ),
        );
      },
    );
  }

  void _showHabitList() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Completed Habits"),
          content: completedHabits.isNotEmpty
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children:
                      completedHabits.map((habit) => Text(habit)).toList(),
                )
              : Text("No habits found."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Close"),
            ),
          ],
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
          Text("Best Habit Highlight",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
              Text(
                  "$streak-Day Streak"), // Dodajemo streak v Best Habit Highlight
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMotivationalQuote(int overallCompletion) {
    String message;
    if (overallCompletion == 100) {
      message = "Amazing! You've completed everything!";
    } else if (overallCompletion >= 75) {
      message = "Great job! You're almost there!";
    } else if (overallCompletion >= 50) {
      message = "You're halfway through! Keep going!";
    } else {
      message = "Don't give up! Start small and keep progressing!";
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.yellow[100],
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.all(16.0),
      child: Center(
        child: Text(
          message,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class CircularProgressIndicatorWithLabel extends StatelessWidget {
  final int percentage;
  final String description;

  CircularProgressIndicatorWithLabel(
      {required this.percentage, required this.description});

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
            Text("$percentage%",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
        SizedBox(height: 8),
        Text(description,
            style: TextStyle(fontSize: 16, color: Colors.black54)),
      ],
    );
  }
}

class SummaryStat extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  SummaryStat({required this.icon, required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 36),
        SizedBox(height: 8),
        Text(label,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
