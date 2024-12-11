import 'package:flutter/material.dart';

class AddHabitScreen extends StatefulWidget {
  @override
  _AddHabitScreenState createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final TextEditingController habitNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  String selectedFrequency = 'Daily'; // Privzeta vrednost za pogostost
  String selectedType = 'Morning routine'; // Privzeta vrednost za tip
  final List<String> frequencies = ['Daily', 'Weekly', 'Monthly'];
  final List<String> types = [
    'Morning routine',
    'Exercise',
    'Work',
    'Leisure',
    'Other'
  ];

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
                color: Colors.white, // Ozadje obrazca
                borderRadius: BorderRadius.circular(16.0), // Zaobljeni robovi
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1), // Rahla senca
                    blurRadius: 10,
                    offset: Offset(0, 5), // Položaj sence
                  ),
                ],
              ),
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Vnos za ime navade
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
                  // Vnos za opis navade
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
                  // Izbira frekvence
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
                  // Izbira tipa navade
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
                  // Vnos za čas opomnika
                  Text(
                    "Reminder Time",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Enter reminder time",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    keyboardType: TextInputType.datetime,
                  ),
                  SizedBox(height: 24),
                  // Gumb za shranjevanje navade
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Logika za shranjevanje navade
                        print("Habit Name: ${habitNameController.text}");
                        print("Description: ${descriptionController.text}");
                        print("Frequency: $selectedFrequency");
                        print("Type: $selectedType");

                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal, // Barva gumba
                        foregroundColor: Colors.white, // Barva besedila
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        padding: EdgeInsets.symmetric(
                          vertical: 12.0, // Višina gumba
                        ),
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