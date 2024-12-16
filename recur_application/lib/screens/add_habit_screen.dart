import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:recur_application/widgets/timer_picker_widget.dart';
import 'package:recur_application/widgets/icon_picker.dart';

class AddHabitScreen extends StatefulWidget {
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

  // Function to save habit to Firestore
  Future<void> _saveHabit() async {
    String habitName = habitNameController.text.trim();
    String description = descriptionController.text.trim();
    String goal = goalController.text.trim();
    String unit = selectedUnit == 'Custom' ? customUnitController.text.trim() : selectedUnit;
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
      // Add to Firestore collection with custom ID
      await FirebaseFirestore.instance.collection('habits').doc(uniqueId).set({
        'id': uniqueId,
        'name': habitName,
        'description': description,
        'goal': goal, // Goal stored as number
        'unit': unit, // Unit (Count, Time, or Custom)
        'frequency': frequency,
        'type': type,
        'reminderTime': reminderTime,
        'icon': icon != null ? icon.codePoint : null,
        'createdAt': Timestamp.now(),
      });

      // Success feedback
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