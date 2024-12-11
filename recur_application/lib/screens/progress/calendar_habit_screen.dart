import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarProgressScreen extends StatefulWidget {
  @override
  _CalendarProgressScreenState createState() => _CalendarProgressScreenState();
}

class _CalendarProgressScreenState extends State<CalendarProgressScreen> {
  late DateTime _focusedDay;
  late DateTime _selectedDay;

  // Dummy podatki o napredku za vsak dan v mesecu (dodajte več dni po potrebi)
  final Map<DateTime, int> dailyProgress = {
    DateTime(2024, 12, 1): 100, // 100% completed (green)
    DateTime(2024, 12, 2): 50,  // 50% completed (yellow)
    DateTime(2024, 12, 3): 0,   // 0% completed (red)
    DateTime(2024, 12, 4): 80,  // 80% completed (yellow)
    DateTime(2024, 12, 5): 100, // 100% completed (green)
    DateTime(2024, 12, 6): 100, // 100% completed (green)
    DateTime(2024, 12, 7): 20,  // 20% completed (yellow)
    DateTime(2024, 12, 8): 0,   // 0% completed (red)
    DateTime(2024, 12, 9): 90,  // 90% completed (yellow)
    DateTime(2024, 12, 10): 30, // 30% completed (yellow)
  };

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
  }

  // Funkcija za pridobivanje barve glede na napredek
  Color getDayColor(DateTime day) {
    if (dailyProgress.containsKey(day)) {
      int progress = dailyProgress[day]!;
      if (progress == 100) {
        return Colors.green; // Zeleni
      } else if (progress > 0 && progress < 100) {
        return Colors.yellow; // Rumeni
      } else {
        return Colors.red; // Rdeči
      }
    }
    return Colors.white; // Dnevi brez napredka
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Monthly Summary"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          // Table Calendar
          TableCalendar(
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2024, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
            eventLoader: (day) {
              if (dailyProgress.containsKey(day)) {
                int progress = dailyProgress[day]!;
                if (progress == 100) {
                  return [Colors.green]; // Zeleni
                } else if (progress > 0 && progress < 100) {
                  return [Colors.yellow]; // Rumeni
                } else {
                  return [Colors.red]; // Rdeči
                }
              } else {
                return [];
              }
            },
            calendarBuilders: CalendarBuilders(
              // Dodajemo obarvanost za vsak dan glede na napredek
              defaultBuilder: (context, day, focusedDay) {
                return Container(
                  margin: const EdgeInsets.all(4.0),
                  decoration: BoxDecoration(
                    color: getDayColor(day), // Uporabimo barvo glede na napredek
                    shape: BoxShape.circle,
                  ),
                  child: Center(child: Text("${day.day}")),
                );
              },
            ),
          ),
          SizedBox(height: 20),
          // Napredek za izbran mesec
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: Text("Progress for ${_selectedDay.toLocal()}"),
                subtitle: Text(
                    "Completed: ${dailyProgress[_selectedDay] ?? 0}%"),
                leading: Icon(Icons.calendar_today, color: Colors.blue),
              ),
            ),
          ),
        ],
      ),
    );
  }
}