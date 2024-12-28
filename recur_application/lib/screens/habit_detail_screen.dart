import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:recur_application/widgets/timer_picker_widget.dart';
import 'add_habit_screen.dart';

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
  bool isCustomFieldVisible = false; 
  double? localProgress; // Shranjuje trenutni napredek

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

  Future<void> _markAsCompleted() async {
  try {
    final data = habitData.data() as Map<String, dynamic>;
    final String frequency = data['frequency'] ?? 'Daily';
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

    // Pridobimo obstoječe podatke obdobja
    final periodData = periods[periodKey] ?? {
      "intakes": [],
      "progress": 0.0,
      "status": "ongoing",
    };
    final List<dynamic> existingIntakes = periodData['intakes'] ?? [];
    final String goalString = data['goal'] ?? '0';

    // Izračunaj goal glede na enoto
    final double goal = (data['unit'] == "Time")
        ? _parseGoalToMinutes(goalString)
        : double.tryParse(goalString) ?? 0.0;

    // Izračunaj trenutni skupni vnos (totalIntake)
    double currentTotalIntake = existingIntakes.fold(
      0.0,
      (sum, intake) => sum + (intake['value'] ?? 0.0),
    );

    // Dodaj manjkajoči vnos, če je trenutni vnos manjši od cilja
    if (currentTotalIntake < goal) {
      final double remainingIntake = goal - currentTotalIntake;
      existingIntakes.add({
        'time': Timestamp.now(),
        'value': remainingIntake, // Manjkajoča vrednost za dosego cilja
      });
    }

    // Posodobi napredek in status
    periods[periodKey] = {
      "intakes": existingIntakes,
      "progress": 1.0, // Napredek na 100%
      "status": "completed",
    };

    // Posodobi podatke v bazi
    await FirebaseFirestore.instance
        .collection('habits')
        .doc(widget.habitId)
        .update({'periods': periods});

    // Preusmeri na domačo stran
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Marked as Completed!")),
    );
  } catch (e) {
    print("Error marking as completed: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to mark as completed!")),
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

  Future<void> _addTimeBasedIntake(String selectedTime) async {
  try {
    // Pretvori časovni niz (npr. "2 hr 30 min" ali "30 min") v število minut
    int totalMinutes = 0;

    // Preverimo, ali niz vsebuje ure
    final hourMatch = RegExp(r'(\d+)\s*hr').firstMatch(selectedTime);
    if (hourMatch != null) {
      totalMinutes += int.parse(hourMatch.group(1)!) * 60; // Pretvori ure v minute
    }

    // Preverimo, ali niz vsebuje minute
    final minuteMatch = RegExp(r'(\d+)\s*min').firstMatch(selectedTime);
    if (minuteMatch != null) {
      totalMinutes += int.parse(minuteMatch.group(1)!); // Dodamo minute
    }

    // Pretvorimo skupne minute v enoto vnosa (če je potrebno)
    double intakeValue = totalMinutes.toDouble();

    // Dodamo vnos z izračunano vrednostjo
    await _addIntake(intakeValue);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Intake added: $selectedTime ($intakeValue min)")),
    );
  } catch (e) {
    print("Error adding time-based intake: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to add intake. Please try again.")),
    );
  }
}

int calculateStreak(Map<String, dynamic> periods, String frequency, DateTime today) {
  List<String> sortedKeys = periods.keys.toList()..sort(); // Razvrsti obdobja po ključih
  int streak = 0;

  // Preverimo, ali so obdobja zaporedna in `completed`
  for (int i = sortedKeys.length - 1; i >= 0; i--) {
    String key = sortedKeys[i];
    Map<String, dynamic> periodData = periods[key];

    if (periodData['status'] == "completed") {
      streak++;
    } else {
      break; // Prekini, če ni `completed`
    }
  }

  return streak;
}

  Future<void> _addIntake(double intake) async {
  try {
    // Preberi podatke iz baze
    DocumentSnapshot habitSnapshot = await FirebaseFirestore.instance
        .collection('habits')
        .doc(widget.habitId)
        .get();

    final data = habitSnapshot.data() as Map<String, dynamic>;
    final String frequency = data['frequency'] ?? 'Daily';
    final String goalString = data['goal'] ?? '0';
    final double goal = (data['unit'] == "Time")
        ? _parseGoalToMinutes(goalString) // Pretvorimo "30 min" v število minut
        : double.tryParse(goalString) ?? 0.0;

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
      "progress": progress, // Posodobimo napredek
      "status": status, // Posodobimo status
    };

    // Posodobimo habit v bazi
    await FirebaseFirestore.instance
        .collection('habits')
        .doc(widget.habitId)
        .update({'periods': periods});

    await _fetchHabitDetails();

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
  double _parseGoalToMinutes(String goal) {
  try {
    // Razčleni ure
    final hourMatch = RegExp(r'(\d+)\s*hr').firstMatch(goal);
    final int hours = hourMatch != null ? int.parse(hourMatch.group(1)!) : 0;

    // Razčleni minute
    final minuteMatch = RegExp(r'(\d+)\s*min').firstMatch(goal);
    final int minutes = minuteMatch != null ? int.parse(minuteMatch.group(1)!) : 0;

    // Pretvori v minute
    return (hours * 60 + minutes).toDouble();
  } catch (e) {
    print("Error parsing goal to minutes: $e");
    return 0.0; // Če pride do napake, vrnemo 0.0
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
    final String goalString = data['goal'] ?? '0';
    final String unit = data['unit'] ?? '';
    final String frequency = data['frequency'] ?? 'Daily';
    final DateTime createdAt = (data['createdAt'] as Timestamp).toDate();
    final Map<String, dynamic> periods = data['periods'] as Map<String, dynamic>? ?? {};

    // Pridobimo ključ trenutnega obdobja
  DateTime now = DateTime.now();
  String periodKey;
  if (frequency.toLowerCase() == "daily") {
    periodKey =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  } else if (frequency.toLowerCase() == "weekly") {
    int daysSinceStart = now.difference(createdAt).inDays;
    int currentWeek = daysSinceStart ~/ 7;
    DateTime weekStart = createdAt.add(Duration(days: currentWeek * 7));
    periodKey =
        "${weekStart.year}-${weekStart.month.toString().padLeft(2, '0')}-${weekStart.day.toString().padLeft(2, '0')}";
  } else if (frequency.toLowerCase() == "monthly") {
    periodKey = "${now.year}-${now.month.toString().padLeft(2, '0')}";
  } else if (frequency.toLowerCase() == "yearly") {
    periodKey = "${now.year}";
  } else {
    throw Exception("Unknown frequency: $frequency");
  }

  // Preberemo napredek iz trenutnega obdobja
  final periodData = periods[periodKey] ?? {"progress": 0.0};
  final double progress = periodData["progress"] ?? 0.0;


    final double goal = (unit == "Time")
      ? _parseGoalToMinutes(goalString) // Pretvori v minute, če je "time"
      : double.tryParse(goalString) ?? 0.0; // Poskusi pretvoriti v število za druge enote

    final int streak = calculateStreak(periods, frequency, widget.selectedDate);

    final days = data['periods'] as Map<String, dynamic>? ?? {};
    final List<dynamic> intakes =
      _getIntakesForFrequency(days, frequency, widget.selectedDate, createdAt);
    final double totalIntake = intakes.fold(0.0, (sum, intake) => sum + (intake['value'] ?? 0.0));

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
              Text("$totalIntake / $goal",
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 20),
            
            // Gumbi za dodajanje vnosa in Mark as Completed
            if (unit == "Count") ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => _addIntake(1.0),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: Text("+ Add 1 Unit"),
                  ),
                  ElevatedButton(
                    onPressed: _markAsCompleted,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: Text("Mark as Completed"),
                  ),
                ],
              ),
            ] else if (unit == "Time") ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return TimerPickerWidget(
                            onTimeSelected: (String selectedTime) async {
                              await _addTimeBasedIntake(selectedTime);
                            },
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: Text("+ Add Time Intake"),
                  ),
                  ElevatedButton(
                    onPressed: _markAsCompleted,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: Text("Mark as Completed"),
                  ),
                ],
              ),
            ] else if (unit == "Custom") ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isCustomFieldVisible = !isCustomFieldVisible;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(isCustomFieldVisible ? "Hide Input" : "+ Add Intake"),
                  ),
                  ElevatedButton(
                    onPressed: _markAsCompleted,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: Text("Mark as Completed"),
                  ),
                ],
              ),
              if (isCustomFieldVisible)
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: intakeController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: "Enter custom intake",
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
            SizedBox(height: 20),

            if (streak >= 3)
              Text(
                "$streak-Day Streak! Great job!",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal),
              ),
            ],
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
            SizedBox(height: 30),

            // Gumbi Edit in Delete Habit
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final updatedHabitId = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddHabitScreen(habitId: widget.habitId),
                      ),
                    );

                    if (updatedHabitId != null) {
                      // Ponovno naloži podatke za habit
                      _fetchHabitDetails();
                    }
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