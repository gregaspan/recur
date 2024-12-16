import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HabitDetailScreen extends StatefulWidget {
  final String habitId; // ID habit-a, ki ga kliknemo za podrobnosti

  const HabitDetailScreen({Key? key, required this.habitId}) : super(key: key);

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  final TextEditingController intakeController = TextEditingController(); // Kontroler za dodajanje vnosa
  late DocumentSnapshot habitData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHabitDetails();
  }

  @override
  void dispose() {
    intakeController.dispose(); // Čiščenje kontrolerja, da preprečimo memory leaks
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
      await FirebaseFirestore.instance
          .collection('habits')
          .doc(widget.habitId)
          .update({
        'intakes': FieldValue.arrayUnion([
          {
            'time': DateTime.now(),
            'value': intake,
          }
        ]),
      });

      // Po dodajanju osveži podatke
      _fetchHabitDetails();
      intakeController.clear();
    } catch (e) {
      print("Error adding intake: $e");
    }
  }

  double _calculateTotalIntake(List<dynamic> intakes) {
    return intakes.fold(0.0, (sum, intake) => sum + (intake['value'] ?? 0.0));
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
    final List<dynamic> intakes = data['intakes'] ?? [];
    final double totalIntake = _calculateTotalIntake(intakes);
    final double goalValue =
        double.tryParse(goal.replaceAll(RegExp(r'[^\d.]'), '')) ?? 0.0;
    final double progress = (goalValue > 0) ? totalIntake / goalValue : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(name),
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
              // Progress Circle
              CircularProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                strokeWidth: 12,
                backgroundColor: Colors.grey[300],
                color: Colors.yellow[700],
              ),
              SizedBox(height: 10),
              Text(
                "${(progress * 100).toStringAsFixed(0)}%",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.yellow[800]),
              ),
              Text(
                "${totalIntake.toStringAsFixed(1)}L / ${goalValue}L",
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
              ),
              SizedBox(height: 20),

              // Streak Info
              Text(
                "10-Day Streak! Great job!",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),

              // Intake Log
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Intake Log",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ...intakes.map((intake) {
                final DateTime time = (intake['time'] as Timestamp).toDate();
                final String value = intake['value'].toString();
                return ListTile(
                  title: Text(
                    "${time.hour}:${time.minute.toString().padLeft(2, '0')} - $value mL",
                  ),
                  trailing: Icon(Icons.delete, color: Colors.red),
                  onTap: () {}, // Add delete functionality if needed
                );
              }).toList(),

              SizedBox(height: 20),

              // Add Intake Section
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: intakeController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "Enter intake (e.g., 500 mL)",
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

              // Edit and Delete Habit Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Edit functionality
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: Text("Edit Habit"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Delete functionality
                    },
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