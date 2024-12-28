import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HabitDetailScreen extends StatefulWidget {
  final String habitId;
  final DateTime selectedDate;

  const HabitDetailScreen({
    Key? key,
    required this.habitId,
    required this.selectedDate,
  }) : super(key: key);

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  final TextEditingController intakeController = TextEditingController();
  late DocumentSnapshot habitData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHabitDetails();
  }

  @override
  void dispose() {
    intakeController.dispose();
    super.dispose();
  }

  Future<void> _fetchHabitDetails() async {
    try {
      DocumentSnapshot habitSnapshot = await FirebaseFirestore.instance
          .collection('habits')
          .doc(widget.habitId)
          .get();
      setState(() {
        habitData = habitSnapshot;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching habit details: $e");
    }
  }

  Future<void> _deleteHabit() async {
    try {
      await FirebaseFirestore.instance
          .collection('habits')
          .doc(widget.habitId)
          .delete();

      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Habit successfully deleted!")),
      );
    } catch (e) {
      print("Error deleting habit: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete habit. Please try again.")),
      );
    }
  }

  List<dynamic> _getIntakesForFrequency(
      Map<String, dynamic> days,
      String frequency,
      DateTime selectedDate,
      DateTime createdAt) {
    List<dynamic> allIntakes = [];
    DateTime startDate, endDate;

    if (frequency.toLowerCase() == "weekly") {
      int daysSinceCreated = selectedDate.difference(createdAt).inDays % 7;
      startDate = selectedDate.subtract(Duration(days: daysSinceCreated));
      endDate = startDate.add(Duration(days: 6));
    } else if (frequency.toLowerCase() == "monthly") {
      startDate = DateTime(selectedDate.year, selectedDate.month, createdAt.day);
      endDate = DateTime(startDate.year, startDate.month + 1, 0);
    } else if (frequency.toLowerCase() == "yearly") {
      startDate = DateTime(selectedDate.year, createdAt.month, createdAt.day);
      endDate = DateTime(startDate.year + 1, createdAt.month, createdAt.day);
    } else {
      startDate = selectedDate;
      endDate = selectedDate;
    }

    for (DateTime date = startDate;
        date.isBefore(endDate) || date.isAtSameMomentAs(endDate);
        date = date.add(Duration(days: 1))) {
      String key =
          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      final dayData = days[key];
      if (dayData != null && dayData['intakes'] != null) {
        allIntakes.addAll(dayData['intakes']);
      }
    }

    return allIntakes;
  }

  Future<void> _addIntake(double intake) async {
  try {
    DocumentSnapshot habitSnapshot = await FirebaseFirestore.instance
        .collection('habits')
        .doc(widget.habitId)
        .get();

    final data = habitSnapshot.data() as Map<String, dynamic>;
    final String frequency = data['frequency'] ?? 'Daily';
    final String goalString = data['goal'] ?? '0';
    final double goal = double.tryParse(goalString) ?? 0.0;

    Map<String, dynamic> periods = data['periods'] as Map<String, dynamic>? ?? {};

    DateTime now = DateTime.now();
    String periodKey;

    if (frequency.toLowerCase() == "daily") {
      periodKey =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    } else if (frequency.toLowerCase() == "weekly") {
      int daysSinceStart = now.difference((data['createdAt'] as Timestamp).toDate()).inDays;
      int currentWeek = daysSinceStart ~/ 7;
      DateTime weekStart = (data['createdAt'] as Timestamp).toDate().add(Duration(days: currentWeek * 7));
      periodKey =
          "${weekStart.year}-${weekStart.month.toString().padLeft(2, '0')}-${weekStart.day.toString().padLeft(2, '0')}";
    } else if (frequency.toLowerCase() == "monthly") {
      periodKey = "${now.year}-${now.month.toString().padLeft(2, '0')}";
    } else if (frequency.toLowerCase() == "yearly") {
      periodKey = "${now.year}";
    } else {
      throw Exception("Unknown frequency: $frequency");
    }

    // Pridobimo obstoječe podatke za obdobje ali inicializiramo novo
    Map<String, dynamic> periodData = periods[periodKey] ?? {
      "intakes": [],
      "progress": 0.0,
      "status": "ongoing",
    };

    List<dynamic> intakes = periodData['intakes'] ?? [];

    // Dodamo nov vnos
    intakes.add({
      'time': Timestamp.now(),
      'value': intake,
    });

    // Izračunamo skupni vnos in napredek
    double totalIntake = intakes.fold(0.0, (sum, entry) => sum + (entry['value'] ?? 0.0));
    double progress = (goal > 0) ? (totalIntake / goal).clamp(0.0, 1.0) : 0.0;
    String status = progress >= 1.0 ? "completed" : "ongoing";

    // Posodobimo podatke za obdobje
    periods[periodKey] = {
      "intakes": intakes,
      "progress": progress,
      "status": status,
    };

    // Posodobimo habit v bazi
    await FirebaseFirestore.instance
        .collection('habits')
        .doc(widget.habitId)
        .update({'periods': periods});

    // Osvežimo podatke in počistimo polje za vnos
    setState(() {
      habitData = habitSnapshot;
    });

    intakeController.clear();
    _fetchHabitDetails();

    // Uspešno obvestilo
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Intake successfully added!")),
    );
  } catch (e) {
    print("Error adding intake: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to add intake. Please try again.")),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final data = habitData.data() as Map<String, dynamic>;
    final String name = data['name'] ?? 'Unnamed Habit';
    final String goal = data['goal'] ?? '0';
    final String unit = data['unit'] ?? '';
    final String frequency = data['frequency'] ?? 'Daily';
    final DateTime createdAt = (data['createdAt'] as Timestamp).toDate();

    final days = data['periods'] as Map<String, dynamic>? ?? {};
    final List<dynamic> intakes =
        _getIntakesForFrequency(days, frequency, widget.selectedDate, createdAt);
    final double totalIntake = intakes.fold(0.0, (sum, intake) => sum + (intake['value'] ?? 0.0));
    final double progress = (goal != '0') ? (totalIntake / double.parse(goal)).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text("$name - ${frequency.toUpperCase()}"),
        centerTitle: true,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              CircularProgressIndicator(
              value: progress,
              strokeWidth: 12,
              backgroundColor: Colors.grey[300],
              color: Colors.yellow[700],
            ),
              SizedBox(height: 10),
              Text(
                "${(progress * 100).toStringAsFixed(0)}%",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 28),
              ),
              Text("$totalIntake / $goal $unit"),
              SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Intake Log (${frequency.toUpperCase()})",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
              SizedBox(height: 10),
              ...intakes.map((intake) {
                final DateTime time = (intake['time'] as Timestamp).toDate();
                return ListTile(
                  title: Text("${time.day}.${time.month}.${time.year} - ${intake['value']} $unit"),
                );
              }).toList(),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: intakeController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "Enter intake ($unit)",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () {
                      final double? intake =
                          double.tryParse(intakeController.text.trim());
                      if (intake != null) {
                        _addIntake(intake);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: Text("+ Add"),
                ),
              ],
            ),

            SizedBox(height: 30),

            // Gumbi Edit in Delete Habit
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Funkcionalnost za urejanje habit-a
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Edit Habit functionality not implemented")),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  ),
                  child: Text("Edit Habit"),
                ),
                ElevatedButton(
                  onPressed: _deleteHabit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  ),
                  child: Text("Delete Habit"),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
}