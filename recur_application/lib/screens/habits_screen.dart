import 'package:flutter/material.dart';
import 'package:recur_application/screens/progress/progress_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'bottom_navigation_bar.dart';
import 'custom_floating_button.dart';
import 'add_habit_screen.dart';
import 'habit_detail_screen.dart';

class HabitsScreen extends StatefulWidget {
  @override
  _HabitsScreenState createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  DateTime today = DateTime.now();
  late DateTime startOfWeek = today.subtract(Duration(days: today.weekday - 1)); // First day of the week

  int currentIndex = 0; // For bottom navigation

  Stream<QuerySnapshot> _fetchHabits() {
    return FirebaseFirestore.instance.collection('habits').snapshots();
  }


  void _onNavBarTap(int index) {
    if (index == 0) {
      setState(() {
        currentIndex = 0; // Stay on Home
      });
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProgressScreenMain()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Placeholder()), // Placeholder for Challenges
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Placeholder()), // Placeholder for Settings
      );
    }
  }

  void _moveWeek(int days) {
    setState(() {
      startOfWeek = startOfWeek.add(Duration(days: days)); // Move week
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
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          "Your Habits for Today",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date Selector
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            color: Colors.grey[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_left, size: 30),
                  onPressed: () {
                    _moveWeek(-7);
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
                    _moveWeek(7);
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 10),

          // Unified Habits Section
          Expanded(
            child: SingleChildScrollView(
              child: isLandscape
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildHabitSection(
                            title: "Ongoing Habits",
                            habitCards: [_buildOngoingHabits()],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHabitSection(
                                title: "Completed Habits",
                                habitCards: [
                                  _buildHabitCard(
                                    title: "Morning Run",
                                    subtitle: "Goal: 5 km",
                                    progress: 1.0,
                                    icon: Icons.directions_run,
                                    isCompleted: true,
                                  ),
                                ],
                              ),
                              _buildHabitSection(
                                title: "Failed Habits",
                                habitCards: [
                                  _buildHabitCard(
                                    title: "Go for a Walk",
                                    subtitle: "Missed",
                                    progress: 0.0,
                                    icon: Icons.directions_walk,
                                    isFailed: true,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        _buildHabitSection(
                          title: "Ongoing Habits",
                          habitCards: [_buildOngoingHabits()],
                        ),
                        _buildHabitSection(
                          title: "Completed Habits",
                          habitCards: [
                            _buildHabitCard(
                              title: "Morning Run",
                              subtitle: "Goal: 5 km",
                              progress: 1.0,
                              icon: Icons.directions_run,
                              isCompleted: true,
                            ),
                          ],
                        ),
                        _buildHabitSection(
                          title: "Failed Habits",
                          habitCards: [
                            _buildHabitCard(
                              title: "Go for a Walk",
                              subtitle: "Missed",
                              progress: 0.0,
                              icon: Icons.directions_walk,
                              isFailed: true,
                            ),
                          ],
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
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
        backgroundColor: Colors.teal,
        iconColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  String _getWeekdayName(int weekday) {
    return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][weekday - 1];
  }

  Widget _buildOngoingHabits() {
  return StreamBuilder<QuerySnapshot>(
    stream: _fetchHabits(),
    builder: (context, snapshot) {
      List<Widget> habitCards = [];

      // Hardcoded habits
      habitCards.addAll([
        _buildHabitCard(
          title: "Drink Water",
          subtitle: "Goal: 2L",
          progress: 0.45,
          icon: Icons.local_drink,
          onTap: () {
            // Navigate to details screen for hardcoded habit (optional handling)
            print("Details for hardcoded habit: Drink Water");
          },
        ),
        _buildHabitCard(
          title: "Read Book",
          subtitle: "Goal: 30 mins",
          progress: 0.30,
          icon: Icons.book,
          onTap: () {
            print("Details for hardcoded habit: Read Book");
          },
        ),
      ]);

      // Firestore habits
      if (snapshot.hasData) {
        final habits = snapshot.data!.docs;
        habitCards.addAll(habits.map((habit) {
          final data = habit.data() as Map<String, dynamic>;
          final habitId = habit.id; // ID dokumenta iz Firestore

          return _buildHabitCard(
            title: data['name'] ?? "Unnamed Habit",
            subtitle: "Goal: ${data['goal'] ?? "No Goal"}",
            progress: data['progress'] != null
                ? (data['progress'] as num).toDouble()
                : 0.0,
            icon: _getIconFromCodePoint(data['icon']),
            onTap: () {
              // Navigacija na HabitDetailScreen z ID-jem habit-a
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HabitDetailScreen(habitId: habitId),
                ),
              );
            },
          );
        }).toList());
      } else if (snapshot.hasError) {
        habitCards.add(Center(child: Text("Error: ${snapshot.error}")));
      }

      return Column(children: habitCards);
    },
  );
}

  Widget _buildHabitSection({
    required String title,
    required List<Widget> habitCards,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        ...habitCards,
      ],
    );
  }

  IconData _getIconFromCodePoint(int? codePoint) {
    return codePoint != null
        ? IconData(codePoint, fontFamily: 'MaterialIcons')
        : Icons.help_outline;
  }

  Widget _buildHabitCard({
    required String title,
    required String subtitle,
    required double progress,
    required IconData icon,
    bool isCompleted = false,
    bool isFailed = false,
    VoidCallback? onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: isCompleted ? Colors.green : isFailed ? Colors.red : Colors.blue),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: isCompleted
            ? Icon(Icons.check, color: Colors.green)
            : isFailed
                ? Icon(Icons.close, color: Colors.red)
                : SizedBox(
                width: 100,
                child: Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        backgroundColor: Colors.grey[300],
                        color: Colors.blue,
                        minHeight: 6,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
