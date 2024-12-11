import 'package:flutter/material.dart';
import 'package:recur_application/screens/progress/progress_screen.dart';
import 'bottom_navigation_bar.dart';
import 'custom_floating_button.dart';
import 'add_habit_screen.dart';

class HabitsScreen extends StatefulWidget {
  @override
  _HabitsScreenState createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  DateTime today = DateTime.now();
  late DateTime startOfWeek = today.subtract(Duration(days: today.weekday - 1)); // Prvi dan tedna

  int currentIndex = 0; // For bottom navigation

  void _onNavBarTap(int index) {
    if (index == 0) {
    setState(() {
      currentIndex = 0; // Ostani na Home
    });
  } else if (index == 1) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ProgressScreenMain()),
    );
  } else if (index == 2) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Placeholder()), // Placeholder za Challenges
    );
  } else if (index == 3) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Placeholder()), // Placeholder za Settings
    );
  }
  }

  @override
  void initState() {
    super.initState();
    startOfWeek = today.subtract(Duration(days: today.weekday - 1)); // Prvi dan tedna
  }

  void _moveWeek(int days) {
    setState(() {
      startOfWeek = startOfWeek.add(Duration(days: days)); // Premik tedna
    });
  }

  List<DateTime> _generateWeekDates() {
    return List.generate(
      7,
      (index) => startOfWeek.add(Duration(days: index)),
    );
  }


  @override
  Widget build(BuildContext context) {
    final weekDates = _generateWeekDates();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          "Your Habits for Today",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Selector
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            color: Colors.grey[100], // Ozadje za boljši kontrast
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_left, size: 30),
                  onPressed: () {
                    _moveWeek(-7); // Premik za en teden nazaj
                  },
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: weekDates.map((date) {
                      final isSelected = date.day == today.day &&
                          date.month == today.month &&
                          date.year == today.year;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            today = date;
                          });
                        },
                        child: Column(
                          children: [
                            Text(
                              _getWeekdayName(date.weekday),
                              style: TextStyle(
                                color: isSelected ? Colors.blue : Colors.black,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "${date.day}",
                              style: TextStyle(
                                color: isSelected ? Colors.blue : Colors.black,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_right, size: 30),
                  onPressed: () {
                    _moveWeek(7); // Premik za en teden naprej
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          // Ongoing Habits
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListView(
                children: [
                  Text(
                    "Ongoing Habits",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  _buildHabitCard(
                      title: "Drink Water",
                      subtitle: "Goal: 2L",
                      progress: 0.45,
                      icon: Icons.local_drink),
                  _buildHabitCard(
                      title: "Read Book",
                      subtitle: "Goal: 30 mins",
                      progress: 0.30,
                      icon: Icons.book),
                  SizedBox(height: 20),
                  Text(
                    "Completed Habits",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  _buildHabitCard(
                      title: "Morning Run",
                      subtitle: "Goal: 5 km",
                      progress: 1.0,
                      icon: Icons.directions_run,
                      isCompleted: true),
                  SizedBox(height: 20),
                  Text(
                    "Failed Habits",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  _buildHabitCard(
                      title: "Go for a Walk",
                      subtitle: "Missed",
                      progress: 0.0,
                      icon: Icons.directions_walk,
                      isFailed: true),
                ],
              ),
            ),
          ),
        ],
      ),
      // Bottom Navigation
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: currentIndex,
        onTap: _onNavBarTap,
      ),
      floatingActionButton: CustomFloatingButton(
        icon: Icons.add,
        onPressed: () {
         Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddHabitScreen()),
        );
        },
        backgroundColor: Colors.teal, // Barva gumba
        iconColor: Colors.white, // Barva ikone
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  String _getWeekdayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '';
    }
  }

  Widget _buildHabitCard({
    required String title,
    required String subtitle,
    required double progress,
    required IconData icon,
    bool isCompleted = false,
    bool isFailed = false,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Icon(
              icon,
              color: isCompleted
                  ? Colors.green
                  : isFailed
                      ? Colors.red
                      : Colors.blue,
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(subtitle),
                ],
              ),
            ),
            isCompleted
                ? Icon(Icons.check, color: Colors.green)
                : isFailed
                    ? Icon(Icons.close, color: Colors.red)
                    : SizedBox(
                        width: 100,
                        child: LinearProgressIndicator(
                          value: progress.clamp(0.0, 1.0),
                          backgroundColor: Colors.grey[300],
                          color: Colors.blue,
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}