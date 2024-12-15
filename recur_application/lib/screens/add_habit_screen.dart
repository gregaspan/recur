import 'package:flutter/material.dart';

class AddHabitScreen extends StatefulWidget {
  @override
  _AddHabitScreenState createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final TextEditingController habitNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController goalController = TextEditingController();
  TimeOfDay? selectedReminderTime;
  String selectedFrequency = 'Daily'; // Default frequency
  String selectedType = 'Morning routine'; // Default type
  IconData? selectedIcon; // Selected icon for the habit

  final List<String> frequencies = ['Daily', 'Weekly', 'Monthly'];
  final List<String> types = [
    'Morning routine',
    'Exercise',
    'Work',
    'Leisure',
    'Other'
  ];

  // Predefined icons for selection
  final List<IconData> habitIcons = [
    Icons.fitness_center,
    Icons.local_drink,
    Icons.book,
    Icons.directions_run,
    Icons.work,
    Icons.music_note,
    Icons.brush,
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
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Habit Name
                  Text(
                    "Habit Name",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: habitNameController,
                    decoration: InputDecoration(
                      hintText: "Enter habit name",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Description
                  Text(
                    "Description",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      hintText: "Add a short description (optional)",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Goal
                  Text(
                    "Goal",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: goalController,
                    decoration: InputDecoration(
                      hintText: "Enter your goal (e.g., 2L, 30 mins)",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Frequency
                  Text(
                    "Frequency",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedFrequency,
                    onChanged: (value) {
                      setState(() {
                        selectedFrequency = value!;
                      });
                    },
                    items: frequencies.map((frequency) {
                      return DropdownMenuItem(
                        value: frequency,
                        child: Text(frequency),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Type
                  Text(
                    "Type",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    onChanged: (value) {
                      setState(() {
                        selectedType = value!;
                      });
                    },
                    items: types.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Reminder Time
                  Text(
                    "Reminder Time",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  GestureDetector(
                    onTap: _selectReminderTime,
                    child: TextField(
                      readOnly: true,
                      onTap: _selectReminderTime,
                      decoration: InputDecoration(
                        hintText: selectedReminderTime != null
                            ? selectedReminderTime!.format(context)
                            : "Select reminder time",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Icon Selection
                  Text(
                    "Habit Icon",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: habitIcons.map((icon) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedIcon = icon;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: selectedIcon == icon
                                ? Colors.teal
                                : Colors.grey[200],
                            shape: BoxShape.circle,
                          ),
                          padding: EdgeInsets.all(12.0),
                          child: Icon(
                            icon,
                            color: selectedIcon == icon
                                ? Colors.white
                                : Colors.grey[800],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 24),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Save Habit Logic
                        print("Habit Name: ${habitNameController.text}");
                        print("Description: ${descriptionController.text}");
                        print("Goal: ${goalController.text}");
                        print("Frequency: $selectedFrequency");
                        print("Type: $selectedType");
                        print("Selected Icon: $selectedIcon");
                        print("Reminder Time: ${selectedReminderTime?.format(context)}");

                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 14.0),
                      ),
                      child: Text(
                        "Save Habit",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}