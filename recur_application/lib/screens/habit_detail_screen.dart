import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HabitDetailScreen extends StatefulWidget {
  final String habitId; // ID habit-a, ki ga kliknemo za podrobnosti
  final DateTime selectedDate; // Datum, ki ga posredujemo iz glavnega zaslona

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

  Future<void> _addIntake(double intake) async {
    try {
      String selectedKey =
          "${widget.selectedDate.year}-${widget.selectedDate.month}-${widget.selectedDate.day}";

      // Preberi obstoječe podatke za habit
      DocumentSnapshot habitSnapshot = await FirebaseFirestore.instance
          .collection('habits')
          .doc(widget.habitId)
          .get();

      final data = habitSnapshot.data() as Map<String, dynamic>;
      final days = data['days'] as Map<String, dynamic>? ?? {};
      final String goalString = data['goal'] ?? '0';
      final double goal = double.tryParse(goalString) ?? 0.0;

      final todayData = days[selectedKey] ??
          {"intakes": [], "progress": 0.0, "status": "ongoing"};
      final List<dynamic> intakes = todayData['intakes'] ?? [];

      intakes.add({
        'time': Timestamp.now(),
        'value': intake,
      });

      double totalIntake =
          intakes.fold(0.0, (sum, entry) => sum + (entry['value'] ?? 0.0));
      double progress = (goal > 0) ? (totalIntake / goal).clamp(0.0, 1.0) : 0.0;
      String status = progress >= 1.0 ? "completed" : "ongoing";

      days[selectedKey] = {
        "intakes": intakes,
        "progress": progress,
        "status": status,
      };

      await FirebaseFirestore.instance
          .collection('habits')
          .doc(widget.habitId)
          .update({'days': days});

      setState(() {
        habitData = habitSnapshot;
      });

      intakeController.clear();
      _fetchHabitDetails();
    } catch (e) {
      print("Error adding intake: $e");
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

    final days = data['days'] as Map<String, dynamic>? ?? {};
    String selectedKey =
        "${widget.selectedDate.year}-${widget.selectedDate.month}-${widget.selectedDate.day}";
    final todayData = days[selectedKey] ??
        {"intakes": [], "progress": 0.0, "status": "ongoing"};
    final List<dynamic> intakes = todayData['intakes'] ?? [];
    final double totalIntake =
        intakes.fold(0.0, (sum, intake) => sum + (intake['value'] ?? 0.0));

    return Scaffold(
      appBar: AppBar(
        title: Text("$name - ${widget.selectedDate.day}.${widget.selectedDate.month}.${widget.selectedDate.year}"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                value: (goal != '0' && totalIntake > 0)
                    ? (totalIntake / double.tryParse(goal)!).clamp(0.0, 1.0)
                    : 0.0,
                strokeWidth: 12,
                backgroundColor: Colors.grey[300],
                color: Colors.yellow[700],
              ),
              SizedBox(height: 10),
              Text(
                "${((totalIntake / double.tryParse(goal)!) * 100).toStringAsFixed(0)}%",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.yellow[800]),
              ),
              Text(
                "$totalIntake / $goal $unit",
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              ),
              SizedBox(height: 20),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Intake Log (${widget.selectedDate.day}.${widget.selectedDate.month}.${widget.selectedDate.year})",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ...intakes.map((intake) {
                final DateTime time = (intake['time'] as Timestamp).toDate();
                final String value = "${intake['value']} $unit";
                return ListTile(
                  title: Text(
                    "${time.hour}:${time.minute.toString().padLeft(2, '0')} - $value",
                  ),
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
              SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Edit functionality (odpri stran za urejanje)
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: Text("Edit Habit"),
                  ),
                  ElevatedButton(
                    onPressed: _deleteHabit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
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