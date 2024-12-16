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
    // Preberi obstoječe podatke za habit
    DocumentSnapshot habitSnapshot = await FirebaseFirestore.instance
        .collection('habits')
        .doc(widget.habitId)
        .get();

    // Pridobi podatke iz baze
    final data = habitSnapshot.data() as Map<String, dynamic>;
    final List<dynamic> intakes = data['intakes'] ?? [];
    final String goalString = data['goal'] ?? '0';
    final double goal = double.tryParse(goalString) ?? 0.0;

    // Dodaj nov vnos
    intakes.add({
      'time': Timestamp.now(),
      'value': intake,
    });

    // Izračunaj skupni vnos
    double totalIntake = intakes.fold(0.0, (sum, entry) => sum + (entry['value'] ?? 0.0));

    // Izračunaj progress (procentualno)
    double progress = (goal > 0) ? totalIntake / goal : 0.0;

    // Posodobi habit v Firestore
    await FirebaseFirestore.instance
        .collection('habits')
        .doc(widget.habitId)
        .update({
      'intakes': intakes,        // Posodobljena lista vnosov
      'progress': progress,      // Dinamično izračunan progress
    });

    // Osveži podatke in počisti vnosno polje
    _fetchHabitDetails();
    intakeController.clear();

    // Obvestilo uporabniku
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Intake successfully added and progress updated!")),
    );
  } catch (e) {
    print("Error adding intake: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to add intake! Please try again.")),
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
    final String goal = data['goal'] ?? '0'; // Ciljna vrednost kot string
    final String unit = data['unit'] ?? ''; // Unit iz baze
    final List<dynamic> intakes = data['intakes'] ?? [];
    final double totalIntake = intakes.fold(0.0, (sum, intake) => sum + (intake['value'] ?? 0.0));

    // Funkcija za formatiranje vnosa in cilja z enoto, če je "Custom"
    String formatWithUnit(String value, String unit) {
      return unit == 'Custom' ? "$value $unit" : value;
    }

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
                value: (goal != '0' && totalIntake > 0)
                    ? (totalIntake / double.tryParse(goal.replaceAll(RegExp(r'[^\d.]'), ''))!)
                        .clamp(0.0, 1.0)
                    : 0.0,
                strokeWidth: 12,
                backgroundColor: Colors.grey[300],
                color: Colors.yellow[700],
              ),
              SizedBox(height: 10),
              Text(
                "${(goal != '0' ? ((totalIntake / double.tryParse(goal.replaceAll(RegExp(r'[^\d.]'), ''))!) * 100).toStringAsFixed(0) : '0')}%",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.yellow[800]),
              ),
              Text(
                "${formatWithUnit(totalIntake.toStringAsFixed(1), unit)} / ${formatWithUnit(goal, unit)}",
                style: TextStyle(fontSize: 18, color: Colors.grey[700]),
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
                final String value = formatWithUnit(intake['value'].toString(), unit);
                return ListTile(
                  title: Text(
                    "${time.hour}:${time.minute.toString().padLeft(2, '0')} - $value",
                  ),
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
                        hintText: "Enter intake (e.g., ${unit == 'Custom' ? '500 $unit' : '10'})",
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