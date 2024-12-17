import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'bottom_navigation_bar.dart';
import 'custom_floating_button.dart';
import 'add_habit_screen.dart';
import 'habit_detail_screen.dart';
import 'package:recur_application/screens/progress/progress_screen.dart';

class HabitsScreen extends StatefulWidget {
  @override
  _HabitsScreenState createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  DateTime today = DateTime.now();
  late DateTime startOfWeek = today.subtract(Duration(days: today.weekday - 1));
  String selectedFilter = "Daily";
  int currentIndex = 0; // For bottom navigation

  Stream<QuerySnapshot> _fetchHabits() {
    return FirebaseFirestore.instance.collection('habits').snapshots();
  }

  void _moveWeek(int days) {
    setState(() {
      startOfWeek = startOfWeek.add(Duration(days: days));
    });
  }

  List<DateTime> _generateWeekDates() {
    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
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

  @override
  Widget build(BuildContext context) {
    final weekDates = _generateWeekDates();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Your Habits for Today", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildDateSelector(weekDates),
          _buildFilters(),
          Expanded(child: _buildHabitSections()),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(currentIndex: currentIndex, onTap: _onNavBarTap,),
      floatingActionButton: CustomFloatingButton(
        icon: Icons.add,
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AddHabitScreen())),
        backgroundColor: Colors.teal,
        iconColor: Colors.white,
      ),
    );
  }

  Widget _buildDateSelector(List<DateTime> weekDates) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      color: Colors.grey[100],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(icon: Icon(Icons.arrow_left, size: 30), onPressed: () => _moveWeek(-7)),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: weekDates.map((date) {
                final isSelected = _isToday(date);
                return GestureDetector(
                  onTap: () => setState(() => today = date),
                  child: Column(
                    children: [
                      Text(_getWeekdayName(date.weekday),
                          style: TextStyle(color: isSelected ? Colors.blue : Colors.black, fontWeight: FontWeight.bold)),
                      Text("${date.day}", style: TextStyle(color: isSelected ? Colors.blue : Colors.black)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          IconButton(icon: Icon(Icons.arrow_right, size: 30), onPressed: () => _moveWeek(7)),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    const filters = ["Daily", "Weekly", "Monthly", "Yearly"];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: filters.map((filter) {
        final isSelected = selectedFilter == filter;
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ? Colors.blue : Colors.grey[200],
          ),
          onPressed: () => setState(() => selectedFilter = filter),
          child: Text(filter, style: TextStyle(color: isSelected ? Colors.white : Colors.black)),
        );
      }).toList(),
    );
  }

  Widget _buildHabitSections() {
  return StreamBuilder<QuerySnapshot>(
    stream: _fetchHabits(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

      final habits = snapshot.data!.docs;
      final ongoingHabits = <Widget>[];
      final completedHabits = <Widget>[];
      final failedHabits = <Widget>[];

      for (var habit in habits) {
        final data = habit.data() as Map<String, dynamic>;
        final String habitId = habit.id;
        final String frequency = data['frequency'] ?? "Daily";
        final days = data['days'] as Map<String, dynamic>? ?? {};

        // FILTRI: Preverjanje frekvence habit-a
        if (frequency.toLowerCase() != selectedFilter.toLowerCase()) continue;

        // Pridobimo podatke za izbran datum iz koledarja
        String selectedKey =
            "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
        final dayData = days[selectedKey] ??
            {"intakes": [], "progress": 0.0, "status": "ongoing"};
            

        // Pridobimo progress in status
        double progress = dayData['progress'] is int
            ? (dayData['progress'] as int).toDouble()
            : (dayData['progress'] ?? 0.0);

        String status = dayData['status'] ?? "ongoing";

        // Razvrščanje habitov glede na status
        if (status == "completed") {
          completedHabits.add(_buildHabitCard(
            {...data, 'progress': progress},
            isCompleted: true,
            habitId: habitId,
          ));
        } else if (status == "failed") {
          failedHabits.add(_buildHabitCard(
            {...data, 'progress': progress},
            isFailed: true,
            habitId: habitId,
          ));
        } else {
          ongoingHabits.add(_buildHabitCard(
            {...data, 'progress': progress},
            habitId: habitId,
          ));
        }
      }

      return SingleChildScrollView(
        child: Column(
          children: [
            _buildHabitSection("Ongoing Habits", ongoingHabits),
            _buildHabitSection("Completed Habits", completedHabits),
            _buildHabitSection("Failed Habits", failedHabits),
          ],
        ),
      );
    },
  );
}

// Preveri, če je datum včerajšnji
bool _isYesterday(DateTime date) {
  final yesterday = DateTime.now().subtract(Duration(days: 1));
  return date.year == yesterday.year &&
      date.month == yesterday.month &&
      date.day == yesterday.day;
}

  Widget _buildHabitSection(String title, List<Widget> habitCards) {
    if (habitCards.isEmpty) return SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ),
        ...habitCards,
      ],
    );
  }

  Widget _buildHabitCard(Map<String, dynamic> data,
    {bool isCompleted = false, bool isFailed = false, String? habitId}) {
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 2,
    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    child: ListTile(
      onTap: () {
        // Navigacija na HabitDetailScreen s habitId
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HabitDetailScreen(habitId: habitId!, selectedDate: today,),
          ),
        );
      },
      leading: Icon(
        _getIconFromCodePoint(data['icon']),
        color: isCompleted
            ? Colors.green
            : isFailed
                ? Colors.red
                : Colors.blue,
      ),
      title: Text(data['name'] ?? "Unnamed Habit",
          style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text("Goal: ${data['goal'] ?? ''}"),
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
                          value: (data['progress'] ?? 0.0).clamp(0.0, 1.0),
                          backgroundColor: Colors.grey[300],
                          color: Colors.blue,
                          minHeight: 6,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                          "${((data['progress'] ?? 0.0) * 100).toStringAsFixed(0)}%"),
                    ],
                  ),
                ),
    ),
  );
}


  DateTime _calculateNextDueDate(DateTime createdDate, String frequency) {
  DateTime now = DateTime.now();
  switch (frequency) {
    case 'daily':
      return DateTime(createdDate.year, createdDate.month, createdDate.day + 1);
    case 'weekly':
      return createdDate.add(Duration(days: 7));
    case 'monthly':
      return DateTime(createdDate.year, createdDate.month + 1, createdDate.day);
    default:
      return createdDate;
  }
}

// Preveri, če je čas za reset napredka glede na zadnji intake
bool _shouldResetProgress(DateTime? lastIntakeDate, String frequency) {
  DateTime now = DateTime.now();
  if (lastIntakeDate == null) return true; // Če še ni vnosa, resetiramo progress

  switch (frequency.toLowerCase()) {
    case 'daily':
      return now.year > lastIntakeDate.year ||
             now.month > lastIntakeDate.month ||
             now.day > lastIntakeDate.day;
    case 'weekly':
      return now.difference(lastIntakeDate).inDays >= 7;
    case 'monthly':
      return now.year > lastIntakeDate.year || now.month > lastIntakeDate.month;
    case 'yearly':
      return now.year > lastIntakeDate.year;
    default:
      return false;
  }
}

Future<void> initializeDay(String habitId) async {
  try {
    DateTime today = DateTime.now();
    String todayKey = "${today.year}-${today.month}-${today.day}";

    // Pridobimo referenco na habit
    DocumentReference habitRef = FirebaseFirestore.instance.collection('habits').doc(habitId);
    DocumentSnapshot habitSnapshot = await habitRef.get();
    final data = habitSnapshot.data() as Map<String, dynamic>;
    final days = data['days'] as Map<String, dynamic>? ?? {};

    // Preverimo, če že obstaja današnji vnos
    if (!days.containsKey(todayKey)) {
      days[todayKey] = {
        "intakes": [],
        "progress": 0.0,
        "status": "ongoing"
      };

      // Posodobimo Firestore s privzetimi podatki za današnji dan
      await habitRef.update({"days": days});
    }
  } catch (e) {
    print("Error initializing today's entry: $e");
  }
}

  IconData _getIconFromCodePoint(int? codePoint) {
    return codePoint != null
        ? IconData(codePoint, fontFamily: 'MaterialIcons')
        : Icons.help_outline;
  }

  bool _isToday(DateTime date) => date.day == today.day && date.month == today.month && date.year == today.year;
  bool _isPastDay() => today.isBefore(DateTime.now().subtract(Duration(days: 1)));

  String _getWeekdayName(int weekday) => ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][weekday - 1];
}