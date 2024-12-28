import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:recur_application/widgets/timer_picker_widget.dart';
import 'package:recur_application/widgets/icon_picker.dart';

class AddHabitScreen extends StatefulWidget {
  final String? habitId; // Če habitId ni null, zaslon deluje v načinu urejanja

  const AddHabitScreen({Key? key, this.habitId}) : super(key: key);

  @override
  _AddHabitScreenState createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final TextEditingController habitNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController goalController = TextEditingController();
  final TextEditingController customUnitController = TextEditingController();
  String selectedUnit = 'Count'; // Default unit
  TimeOfDay? selectedReminderTime;
  String selectedFrequency = 'Daily'; // Default frequency
  String selectedType = 'Morning routine'; // Default type
  IconData? selectedIcon; // Selected icon for the habit
  bool isLoading = false;

  final List<String> units = ['Count', 'Time', 'Custom'];
  final List<String> frequencies = ['Daily', 'Weekly', 'Monthly', 'Yearly'];
  final List<String> types = [
    'Morning routine',
    'Exercise',
    'Work',
    'Leisure',
    'Other'
  ];


  // Function to open the TimePicker
  Future<void> _selectReminderTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() {
        selectedReminderTime = pickedTime;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.habitId != null) {
      _loadHabitData(); // Naloži podatke za urejanje, če habitId ni null
    }
  }

  Future<void> _loadHabitData() async {
    setState(() {
      isLoading = true;
    });
    try {
      DocumentSnapshot habitSnapshot = await FirebaseFirestore.instance
          .collection('habits')
          .doc(widget.habitId)
          .get();
      final data = habitSnapshot.data() as Map<String, dynamic>;

      setState(() {
        habitNameController.text = data['name'] ?? '';
        descriptionController.text = data['description'] ?? '';
        goalController.text = data['goal'] ?? '';
        selectedUnit = data['unit'] ?? 'Count';
        customUnitController.text = data['customUnit'] ?? '';
        selectedFrequency = data['frequency'] ?? 'Daily';
        selectedType = data['type'] ?? 'Morning routine';
        if (data['reminderTime'] != null && data['reminderTime'] != "No reminder set") {
          final timeParts = (data['reminderTime'] as String).split(":");
          selectedReminderTime = TimeOfDay(
            hour: int.parse(timeParts[0]),
            minute: int.parse(timeParts[1]),
          );
        }
        if (data['icon'] != null) {
          selectedIcon = IconData(data['icon'], fontFamily: 'MaterialIcons');
        }
        isLoading = false;
      });
    } catch (e) {
      print("Error loading habit data: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  // Function to save habit to Firestore
  Future<void> _saveHabit() async {
    String habitName = habitNameController.text.trim();
    String description = descriptionController.text.trim();
    String goal = goalController.text.trim();
    String unit = selectedUnit == 'Custom' ? 'Custom' : selectedUnit;
    String customUnit = selectedUnit == 'Custom' ? (customUnitController.text.trim()) : '';
    String frequency = selectedFrequency;
    String type = selectedType;
    String reminderTime = selectedReminderTime != null
        ? selectedReminderTime!.format(context)
        : "No reminder set";
    IconData? icon = selectedIcon;

    if (habitName.isEmpty || goal.isEmpty || unit.isEmpty) {
      // Validate habit name, goal, and unit
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Habit name, goal, and unit cannot be empty!")),
      );
      return;
    }

    // Generate unique ID
    String uniqueId = Uuid().v4();

   try {
    // Initialize the data structure for the selected frequency
    Map<String, dynamic> habitData = {
      'id': uniqueId,
      'name': habitName,
      'description': description,
      'goal': goal, // Convert goal to number
      'unit': unit,
      'customUnit': customUnit,
      'frequency': frequency,
      'type': type,
      'reminderTime': reminderTime,
      'icon': icon != null ? icon.codePoint : null,
      'createdAt': Timestamp.now(),
      'progressData': {},
    };

    // Initialize the progress data based on frequency
    DateTime now = DateTime.now();
    String startKey;
    switch (frequency.toLowerCase()) {
      case 'weekly':
        startKey = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
        habitData['progressData'] = {
          startKey: {
            'progress': 0.0,
            'intakes': [],
            'status': 'ongoing',
          },
        };
        break;

      case 'monthly':
        startKey = "${now.year}-${now.month.toString().padLeft(2, '0')}";
        habitData['progressData'] = {
          startKey: {
            'progress': 0.0,
            'intakes': [],
            'status': 'ongoing',
          },
        };
        break;

      case 'yearly':
        startKey = "${now.year}";
        habitData['progressData'] = {
          startKey: {
            'progress': 0.0,
            'intakes': [],
            'status': 'ongoing',
          },
        };
        break;

      default: // 'daily'
        startKey = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
        habitData['progressData'] = {
          startKey: {
            'progress': 0.0,
            'intakes': [],
            'status': 'ongoing',
          },
        };
    }

    if (widget.habitId == null) {
      // Dodajanje novega habit-a
      String uniqueId = Uuid().v4();
      habitData['id'] = uniqueId;
      habitData['createdAt'] = Timestamp.now();
      habitData['progressData'] = {};

      await FirebaseFirestore.instance.collection('habits').doc(uniqueId).set(habitData);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Habit successfully added!")),
      );
    } else {
      // Posodobitev obstoječega habit-a
      await FirebaseFirestore.instance
          .collection('habits')
          .doc(widget.habitId)
          .update(habitData);

      // Posodobimo progress za obstoječe obdobja
      await _updateProgressAfterGoalChange(widget.habitId, goal, unit);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Habit successfully updated!")),
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Habit successfully added!")),
    );

    Navigator.pop(context);
  } catch (e) {
    print("Error saving habit: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Failed to save habit!")),
    );
  }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(
        "Add New Habit",
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.black),
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon Selection at the top
            Center(
              child: Column(
                children: [
                  if (selectedIcon != null)
                    Icon(
                      selectedIcon,
                      size: 60,
                      color: Colors.teal,
                    )
                  else
                    Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.add, color: Colors.grey),
                    ),
                  SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => IconPicker(
                          onIconSelected: (icon) {
                            setState(() {
                              selectedIcon = icon;
                            });
                          },
                        ),
                      );
                    },
                    icon: Icon(Icons.edit),
                    label: Text("Choose Icon"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Habit Name
            _buildInputField("Habit Name", habitNameController, "Enter habit name"),
            SizedBox(height: 16),

            // Description
            _buildInputField(
                "Description", descriptionController, "Add a short description (optional)"),
            SizedBox(height: 16),

            // Goal and Unit
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Goal", style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          if (selectedUnit == 'Time') {
                            showDialog(
                              context: context,
                              builder: (context) => TimerPickerWidget(
                                onTimeSelected: (time) {
                                  setState(() {
                                    goalController.text = time;
                                  });
                                },
                              ),
                            );
                          }
                        },
                        child: AbsorbPointer(
                          absorbing: selectedUnit == 'Time',
                          child: TextField(
                            controller: goalController,
                            keyboardType: selectedUnit == 'Time'
                                ? TextInputType.text
                                : TextInputType.number,
                            decoration: InputDecoration(
                              hintText: selectedUnit == 'Time'
                                  ? "Tap to set duration"
                                  : "Enter your goal",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Unit", style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedUnit,
                        onChanged: (value) {
                          setState(() {
                            selectedUnit = value!;
                            if (selectedUnit != 'Time') {
                              goalController.clear();
                            }
                          });
                        },
                        items: units.map((unit) {
                          return DropdownMenuItem(
                            value: unit,
                            child: Text(unit),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Custom Unit Input
            if (selectedUnit == 'Custom')
              _buildInputField("Custom Unit", customUnitController, "Enter your custom unit"),
            SizedBox(height: 16),

            // Frequency
            _buildDropdownField("Frequency", frequencies, selectedFrequency, (value) {
              setState(() {
                selectedFrequency = value!;
              });
            }),
            SizedBox(height: 16),

            // Type
            _buildDropdownField("Type", types, selectedType, (value) {
              setState(() {
                selectedType = value!;
              });
            }),
            SizedBox(height: 16),

            // Reminder Time
            _buildTimePicker(),
            SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveHabit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: Text("Save Habit",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
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

  Future<void> _updateProgressAfterGoalChange(String? habitId, String newGoal, String unit) async {
  try {
    DocumentSnapshot habitSnapshot =
        await FirebaseFirestore.instance.collection('habits').doc(habitId).get();

    final data = habitSnapshot.data() as Map<String, dynamic>;
    final Map<String, dynamic> periods = data['periods'] as Map<String, dynamic>? ?? {};
    double goalValue;

    if (unit == "Time") {
      // Pretvori cilj iz časa (npr. "30 min") v število minut
      goalValue = _parseGoalToMinutes(newGoal);
    } else {
      // Pretvori cilj v število
      goalValue = double.tryParse(newGoal) ?? 0.0;
    }

    // Posodobi progress za vsako obdobje
    periods.forEach((key, periodData) {
      List<dynamic> intakes = periodData['intakes'] ?? [];
      double totalIntake = intakes.fold(0.0, (sum, entry) => sum + (entry['value'] ?? 0.0));

      // Izračun napredka
      double progress = (goalValue > 0) ? (totalIntake / goalValue).clamp(0.0, 1.0) : 0.0;
      String status = progress >= 1.0 ? "completed" : "ongoing";

      // Posodobimo podatke za to obdobje
      periods[key] = {
        ...periodData,
        "progress": progress,
        "status": status,
      };
    });

    // Posodobimo v bazi
    await FirebaseFirestore.instance.collection('habits').doc(habitId).update({
      'periods': periods,
    });
  } catch (e) {
    print("Error updating progress after goal change: $e");
  }
}

  Widget _buildInputField(String label, TextEditingController controller, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
          ),
        ),
      ],
    );
  }

  Widget _buildNumberInputField(String label, TextEditingController controller, String hint) {
    return _buildInputField(
      label,
      controller,
      hint,
    );
  }

  Widget _buildDropdownField(String label, List<String> items, String value, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      items: items.map((item) {
        return DropdownMenuItem(value: item, child: Text(item));
      }).toList(),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
      ),
    );
  }

  Widget _buildTimePicker() {
    return GestureDetector(
      onTap: _selectReminderTime,
      child: TextField(
        readOnly: true,
        onTap: _selectReminderTime,
        decoration: InputDecoration(
          labelText: "Reminder Time",
          hintText: selectedReminderTime != null
              ? selectedReminderTime!.format(context)
              : "Select reminder time",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
        ),
      ),
    );
  }
}