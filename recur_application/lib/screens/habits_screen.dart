import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'bottom_navigation_bar.dart';
import 'custom_floating_button.dart';
import 'add_habit_screen.dart';
import 'habit_detail_screen.dart';
import 'package:recur_application/screens/progress/progress_screen.dart';

class HabitsScreen extends StatefulWidget {
  @override
  _HabitsScreenState createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  DateTime today = DateTime.now();
  late DateTime startOfWeek = today.subtract(Duration(days: today.weekday - 1));
  String selectedFilter = "Daily";
  int currentIndex = 0; // For bottom navigation

  Stream<QuerySnapshot> _fetchHabits() {
    return FirebaseFirestore.instance.collection('habits').snapshots();
  }

  void _moveWeek(int days) {
    setState(() {
      startOfWeek = startOfWeek.add(Duration(days: days));
    });
  }

  List<DateTime> _generateWeekDates() {
    return List.generate(7, (index) => startOfWeek.add(Duration(days: index)));
  }

   void _onNavBarTap(int index) {
    if (index == 0) {
      setState(() {
        currentIndex = 0; // Stay on Home
      });
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProgressScreenMain()),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Placeholder()), // Placeholder for Challenges
      );
    } else if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Placeholder()), // Placeholder for Settings
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final weekDates = _generateWeekDates();
    return FutureBuilder(
    future: _updateAllHabitsStatus(), // Posodobimo habite
    builder: (context, snapshot) {



    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text("Your Habits for Today", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildDateSelector(weekDates),
          _buildFilters(),
          Expanded(child: _buildHabitSections()),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(currentIndex: currentIndex, onTap: _onNavBarTap,),
      floatingActionButton: CustomFloatingButton(
        icon: Icons.add,
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AddHabitScreen())),
        backgroundColor: Colors.teal,
        iconColor: Colors.white,
      ),
    );
    },
    );
  }

  Widget _buildDateSelector(List<DateTime> weekDates) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      color: Colors.grey[100],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(icon: Icon(Icons.arrow_left, size: 30), onPressed: () => _moveWeek(-7)),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: weekDates.map((date) {
                final isSelected = _isToday(date);
                return GestureDetector(
                  onTap: () => setState(() => today = date),
                  child: Column(
                    children: [
                      Text(_getWeekdayName(date.weekday),
                          style: TextStyle(color: isSelected ? Colors.blue : Colors.black, fontWeight: FontWeight.bold)),
                      Text("${date.day}", style: TextStyle(color: isSelected ? Colors.blue : Colors.black)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          IconButton(icon: Icon(Icons.arrow_right, size: 30), onPressed: () => _moveWeek(7)),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    const filters = ["Daily", "Weekly", "Monthly", "Yearly"];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: filters.map((filter) {
        final isSelected = selectedFilter == filter;
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isSelected ? Colors.blue : Colors.grey[200],
          ),
          onPressed: () => setState(() => selectedFilter = filter),
          child: Text(filter, style: TextStyle(color: isSelected ? Colors.white : Colors.black)),
        );
      }).toList(),
    );
  }

  Widget _buildHabitSections() {
  return StreamBuilder<QuerySnapshot>(
    stream: _fetchHabits(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

      final habits = snapshot.data!.docs;
      final ongoingHabits = <Widget>[];
      final completedHabits = <Widget>[];
      final failedHabits = <Widget>[];

      for (var habit in habits) {
        final data = habit.data() as Map<String, dynamic>;
        final String habitId = habit.id;
        final String frequency = data['frequency'] ?? "Daily";
        final DateTime createdAt = (data['createdAt'] as Timestamp).toDate();
        final days = data['periods'] as Map<String, dynamic>? ?? {};

        DateTime createdAtDate = DateTime(createdAt.year, createdAt.month, createdAt.day);
        DateTime todayDate = DateTime(today.year, today.month, today.day);

        // FILTRI: Preverjanje frekvence habit-a
        if (frequency.toLowerCase() != selectedFilter.toLowerCase()) continue;

        if (createdAtDate.isAfter(todayDate)) {
          continue; // Skip habits created after today
        }

        String selectedKey = getSelectedKey(createdAtDate, todayDate, frequency);
        final periodData = days[selectedKey] ??
          {"intakes": [], "progress": 0.0, "status": "ongoing"};

            

        // Pridobimo progress in status
        double progress = periodData['progress'] is int
            ? (periodData['progress'] as int).toDouble()
            : (periodData['progress'] ?? 0.0);

        String status = periodData['status'] ?? "ongoing";

        // Razvrščanje habitov glede na status
        if (status == "completed") {
          completedHabits.add(_buildHabitCard(
            {...data, 'progress': progress},
            isCompleted: true,
            habitId: habitId,
          ));
        } else if (status == "failed") {
          failedHabits.add(_buildHabitCard(
            {...data, 'progress': progress},
            isFailed: true,
            habitId: habitId,
          ));
        } else {
          ongoingHabits.add(_buildHabitCard(
            {...data, 'progress': progress},
            habitId: habitId,
          ));
        }
      }

      return SingleChildScrollView(
        child: Column(
          children: [
            _buildHabitSection("Ongoing Habits", ongoingHabits),
            _buildHabitSection("Completed Habits", completedHabits),
            _buildHabitSection("Failed Habits", failedHabits),
          ],
        ),
      );
    },
  );
}

// Funkcija za izračun izbranega ključa na podlagi frekvence
String getSelectedKey(DateTime startDate, DateTime today, String frequency) {
  Duration difference = today.difference(startDate);

  switch (frequency) {
    case "Daily":
      return "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    case "Weekly":
      // Izračun tedna od začetka habit-a
      int weeksElapsed = (difference.inDays / 7).floor();
      DateTime weekStart = startDate.add(Duration(days: weeksElapsed * 7));
      return "${weekStart.year}-${weekStart.month.toString().padLeft(2, '0')}-${weekStart.day.toString().padLeft(2, '0')}";

    case "Monthly":
      // Izračunaj mesec od začetka habit-a
      int monthNumber = (difference.inDays / 30).floor();
      DateTime monthStart = DateTime(startDate.year, startDate.month + monthNumber, 1);
      return "${monthStart.year}-${monthStart.month.toString().padLeft(2, '0')}";

    case "Yearly":
      // Izračunaj leto od začetka habit-a
      int yearNumber = (difference.inDays / 365).floor();
      DateTime yearStart = DateTime(startDate.year + yearNumber, 1, 1);
      return "${yearStart.year}";

    default:
      throw ArgumentError("Nepodprta frekvenca: $frequency");
  }
}

Map<String, dynamic> getPeriodData(
    Map<String, dynamic> data, String frequency, DateTime today, DateTime startDate) {
  // Pridobimo ključ na podlagi začetnega datuma in trenutnega dne
  String selectedKey = getSelectedKey(startDate, today, frequency);
  
  // Preverimo, če za izračunani ključ obstajajo podatki; če ne, inicializiramo s privzetimi vrednostmi
  return data["periods"]?[selectedKey] ??
      {"intakes": [], "progress": 0.0, "status": "ongoing"};
}



  Widget _buildHabitSection(String title, List<Widget> habitCards) {
    if (habitCards.isEmpty) return SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ),
        ...habitCards,
      ],
    );
  }

  Widget _buildHabitCard(Map<String, dynamic> data,
    {bool isCompleted = false, bool isFailed = false, String? habitId}) {
  return Card(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    elevation: 2,
    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    child: ListTile(
      onTap: () {
        // Navigacija na HabitDetailScreen s habitId
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HabitDetailScreen(habitId: habitId!, selectedDate: today,),
          ),
        );
      },
      leading: Icon(
        _getIconFromCodePoint(data['icon']),
        color: isCompleted
            ? Colors.green
            : isFailed
                ? Colors.red
                : Colors.blue,
      ),
      title: Text(data['name'] ?? "Unnamed Habit",
          style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text("Goal: ${data['goal'] ?? ''}"),
      trailing: isCompleted
          ? Icon(Icons.check, color: Colors.green)
          : isFailed
              ? Icon(Icons.close, color: Colors.red)
              : SizedBox(
                  width: 100,
                  child: Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: (data['progress'] ?? 0.0).clamp(0.0, 1.0),
                          backgroundColor: Colors.grey[300],
                          color: Colors.blue,
                          minHeight: 6,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                          "${((data['progress'] ?? 0.0) * 100).toStringAsFixed(0)}%"),
                    ],
                  ),
                ),
    ),
  );
}

Future<void> updateHabitStatus(List<DocumentReference> habitRefs, DateTime today) async {
  for (var habitRef in habitRefs) {
    final habitSnapshot = await habitRef.get();
    final habit = habitSnapshot.data() as Map<String, dynamic>;

    final String frequency = habit['frequency'] ?? "Daily";
    final Map<String, dynamic> periods = habit['periods'] ?? {};
    final DateTime createdAt = (habit['createdAt'] as Timestamp).toDate();

    DateTime currentDate = createdAt;

    while (!currentDate.isAfter(today)) {
      // Izračun ključa za obdobje
      String selectedKey = getSelectedKey(createdAt, currentDate, frequency);

      // Izračun konca obdobja
      DateTime periodEndDate = getPeriodEndDateFromStart(createdAt, currentDate, frequency);

      // Če trenutni datum spada v trenutno obdobje, nastavimo na "ongoing"
      if (!today.isAfter(periodEndDate)) {
        if (!periods.containsKey(selectedKey)) {
          periods[selectedKey] = {
            "progress": 0.0,
            "status": "ongoing",
            "intakes": [],
          };
        }
        break; // Prekinemo, ker smo pri trenutnem obdobju
      }

      // Preverimo, ali obdobje obstaja in ga posodobimo
      if (!periods.containsKey(selectedKey)) {
        periods[selectedKey] = {
          "progress": 0.0,
          "status": "failed",
          "intakes": [],
        };
      } else {
        final periodData = periods[selectedKey];
        double progress = periodData['progress'] ?? 0.0;

        if (currentDate.isAfter(periodEndDate) && progress < 1.0) {
          // Označimo trenutno obdobje kot "failed"
          periods[selectedKey]['status'] = "failed";

          // Pridobimo naslednji ključ
          DateTime nextPeriodStartDate = periodEndDate.add(Duration(seconds: 1));
          String nextKey = getSelectedKey(createdAt, nextPeriodStartDate, frequency);

          // Če naslednje obdobje še ne obstaja, ga inicializiramo
          if (!periods.containsKey(nextKey)) {
            periods[nextKey] = {
              "progress": 0.0,
              "status": "ongoing",
              "intakes": [],
            };
          }
        }
      }

      // Premaknemo na naslednji dan/teden/mesec/leto glede na frekvenco
      switch (frequency) {
        case "Daily":
          currentDate = currentDate.add(Duration(days: 1));
          break;
        case "Weekly":
          currentDate = currentDate.add(Duration(days: 7));
          break;
        case "Monthly":
          currentDate = DateTime(currentDate.year, currentDate.month + 1, currentDate.day);
          break;
        case "Yearly":
          currentDate = DateTime(currentDate.year + 1, currentDate.month, currentDate.day);
          break;
        default:
          throw ArgumentError("Nepodprta frekvenca: $frequency");
      }
    }

    // Posodobimo bazo z novimi/posodobljenimi podatki o obdobjih
    await habitRef.update({"periods": periods});
  }
}

Future<void> _updateAllHabitsStatus() async {
  final habitCollection = FirebaseFirestore.instance.collection('habits');
  final habitDocs = await habitCollection.get();

  // Pridobimo vse reference na habite
  List<DocumentReference> habitRefs = habitDocs.docs.map((doc) => doc.reference).toList();

  // Posodobimo statuse vseh habitov
  await updateHabitStatus(habitRefs, DateTime.now());
}

DateTime getPeriodEndDateFromStart(DateTime startDate, DateTime today, String frequency) {
  Duration difference = today.difference(startDate);

  switch (frequency) {
    case "Daily":
      // Konec naslednjega dne od začetka habit-a
      return startDate.add(Duration(days: 1)).subtract(Duration(seconds: 1));
    case "Weekly":
      // Tedensko obdobje od začetka habit-a (7 dni)
      int weeksElapsed = (difference.inDays / 7).floor();
      DateTime weekStart = startDate.add(Duration(days: weeksElapsed * 7));
      return weekStart.add(Duration(days: 6, hours: 23, minutes: 59, seconds: 59)); // 7 dni od začetka
    case "Monthly":
      // Mesečno obdobje od začetka habit-a
      int monthsElapsed = (difference.inDays / 30).floor();
      DateTime nextMonth = DateTime(startDate.year, startDate.month + monthsElapsed + 1, startDate.day);
      return nextMonth.subtract(Duration(seconds: 1));
    case "Yearly":
      // Letno obdobje od začetka habit-a
      int yearsElapsed = (difference.inDays / 365).floor();
      DateTime nextYear = DateTime(startDate.year + yearsElapsed + 1, startDate.month, startDate.day);
      return nextYear.subtract(Duration(seconds: 1));
    default:
      throw ArgumentError("Nepodprta frekvenca: $frequency");
  }
}

  IconData _getIconFromCodePoint(int? codePoint) {
    return codePoint != null
        ? IconData(codePoint, fontFamily: 'MaterialIcons')
        : Icons.help_outline;
  }

  bool _isToday(DateTime date) => date.day == today.day && date.month == today.month && date.year == today.year;

  String _getWeekdayName(int weekday) => ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][weekday - 1];
}