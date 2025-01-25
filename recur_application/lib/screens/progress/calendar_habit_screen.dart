import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CalendarProgressScreen extends StatefulWidget {
  final String selectedFilter; // Selected filter to apply

  CalendarProgressScreen({Key? key, required this.selectedFilter}) : super(key: key);

  @override
  _CalendarProgressScreenState createState() => _CalendarProgressScreenState();
}

class _CalendarProgressScreenState extends State<CalendarProgressScreen> {
  String get selectedFilter => widget.selectedFilter;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, bool?> habitCompletion = {};
  List<Map<String, dynamic>> habits = [];
  Map<DateTime, Map<String, bool>> allHabitStatuses = {};

  @override
  void initState() {
    super.initState();
    _fetchHabitData(widget.selectedFilter);
  }

  @override
  void didUpdateWidget(covariant CalendarProgressScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if the filter has changed
    if (widget.selectedFilter != oldWidget.selectedFilter) {
      _fetchHabitData(widget.selectedFilter); // Reload data
    }
  }

  Future<void> _fetchHabitData(String selectedFilter) async {
    try {
      // Get the currently logged-in user
      final String? userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId == null) {
        print("User is not logged in.");
        return;
      }

      // Fetch habits for the current user from Firestore
      final snapshot = await FirebaseFirestore.instance
          .collection('habits')
          .where('userId', isEqualTo: userId) // Filter by userId
          .get();
      List<Map<String, dynamic>> allHabits = snapshot.docs.map((doc) => doc.data()).toList();

      Map<DateTime, Map<String, bool>> habitStatuses = {}; // Track individual habit statuses
      Map<DateTime, bool> completionData = {}; // For coloring the calendar

      // Filter habits based on the selected filter
      List<Map<String, dynamic>> filteredHabits = selectedFilter == "All"
          ? allHabits
          : allHabits.where((habit) => habit['type']?.toString().toLowerCase() == selectedFilter.toLowerCase()).toList();

      // Process filters
      for (var habit in filteredHabits) {
        final data = habit;
        final periods = data['periods'] as Map<String, dynamic>? ?? {};
        final frequency = (data['frequency'] ?? 'daily').toLowerCase();
        final createdAt = (data['createdAt'] as Timestamp).toDate();
        final habitName = data['name'] ?? 'Unnamed Habit';

        periods.forEach((key, value) {
          DateTime periodDate;

          // Convert period to DateTime
          switch (frequency) {
            case 'daily':
              if (key.length == 10) {
                periodDate = DateTime.parse(key); // Format: YYYY-MM-DD
              } else {
                return; // Skip invalid keys
              }
              break;

            case 'weekly':
              if (key.length == 10) {
                DateTime parsedDate = DateTime.parse(key); // Format: YYYY-MM-DD
                int daysSinceCreated = parsedDate.difference(createdAt).inDays;
                int weeksSinceCreated = (daysSinceCreated / 7).floor();
                periodDate = createdAt.add(Duration(days: weeksSinceCreated * 7));
              } else {
                return;
              }
              break;

            case 'monthly':
              if (key.length == 7) {
                DateTime firstDayOfMonth = DateTime.parse('$key-01'); // Format: YYYY-MM
                periodDate = firstDayOfMonth;
              } else {
                return;
              }
              break;

            case 'yearly':
              if (key.length == 4) {
                DateTime firstDayOfYear = DateTime(int.parse(key), 1, 1); // Format: YYYY
                periodDate = firstDayOfYear;
              } else {
                return;
              }
              break;

            default:
              return; // Skip unsupported frequencies
          }

          // Check status and convert to bool
          if (value is Map<String, dynamic> && value.containsKey('status')) {
            String status = value['status']; // e.g., "completed", "failed", "ongoing"
            bool isCompleted = (status == 'completed');

            // Add status for this date and habit
            habitStatuses.putIfAbsent(periodDate, () => {});
            habitStatuses[periodDate]![habitName] = isCompleted;
          }
        });
      }

      // Create `completionData` for the calendar (using theme colors)
      habitStatuses.forEach((date, habits) {
        bool allCompleted = habits.values.every((status) => status);
        completionData[date] = allCompleted;
      });

      // Update component state
      setState(() {
        allHabitStatuses = habitStatuses; // All statuses for individual habits
        habitCompletion = completionData; // Overall status for the calendar
      });
    } catch (e) {
      print("Error fetching habit data: $e");
    }
  }

  static DateTime _normalizeDate(DateTime date) => DateTime(date.year, date.month, date.day);

  Map<DateTime, bool?> _getFilteredHabitCompletion() => habitCompletion;

  @override
  Widget build(BuildContext context) {
    final filteredHabitCompletion = _getFilteredHabitCompletion();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text("Habit Tracking"),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 16),
            _buildCalendar(filteredHabitCompletion),
            if (_selectedDay != null) ...[
              _buildSelectedDaySummary(),
            ],
            _buildMonthlySummary(filteredHabitCompletion),
          ],
        ),
      ),
    );
  }

  // Build Calendar Widget
  Widget _buildCalendar(Map<DateTime, bool?> filteredHabitCompletion) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            DateTime normalizedDay = _normalizeDate(day);
            if (filteredHabitCompletion.containsKey(normalizedDay)) {
              bool? isCompleted = filteredHabitCompletion[normalizedDay];
              return Container(
                margin: const EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  color: isCompleted == true
                      ? Colors.green
                      : isCompleted == false
                          ? colorScheme.error
                          : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${day.day}',
                  style: TextStyle(
                    color: isCompleted != null ? Colors.white : colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }
            return null;
          },
        ),
        headerStyle: HeaderStyle(
          titleCentered: true,
          formatButtonVisible: false,
          titleTextStyle: TextStyle(
            color: colorScheme.onPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          decoration: BoxDecoration(
            color: colorScheme.primary,
          ),
          leftChevronIcon: Icon(
            Icons.chevron_left,
            color: colorScheme.onPrimary,
          ),
          rightChevronIcon: Icon(
            Icons.chevron_right,
            color: colorScheme.onPrimary,
          ),
        ),
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: colorScheme.secondary.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: colorScheme.primary,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedDaySummary() {
    if (_selectedDay == null) return SizedBox.shrink();

    // Normalize the selected day
    DateTime normalizedSelectedDay = _normalizeDate(_selectedDay!);

    // Get status data for the selected day
    final habitStatusesForDay = allHabitStatuses[normalizedSelectedDay] ?? {};

    // If no data, display a message
    if (habitStatusesForDay.isEmpty) {
      return Container(
        padding: EdgeInsets.all(16.0),
        margin: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Center(
          child: Text(
            "No habits scheduled for ${_formatDate(normalizedSelectedDay)}",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    // Create lists for completed and failed habits
    List<String> completedHabits = [];
    List<String> failedHabits = [];

    habitStatusesForDay.forEach((habitName, status) {
      if (status == true) {
        completedHabits.add(habitName); // Completed habits
      } else if (status == false) {
        failedHabits.add(habitName); // Failed habits
      }
    });

    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(16.0),
      margin: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Selected Day: ${_formatDate(normalizedSelectedDay)}",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 12),
          if (completedHabits.isNotEmpty) ...[
            _buildHabitSection("Completed Habits", completedHabits, Colors.green),
          ],
          if (failedHabits.isNotEmpty) ...[
            _buildHabitSection("Failed Habits", failedHabits, colorScheme.error),
          ],
        ],
      ),
    );
  }

  Widget _buildHabitSection(String title, List<String> habits, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
        ),
        SizedBox(height: 8),
        ...habits.map(
          (habit) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              children: [
                Icon(
                  Icons.circle,
                  color: color,
                  size: 12,
                ),
                SizedBox(width: 8),
                Text(
                  habit,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  // Build Monthly Summary
  Widget _buildMonthlySummary(Map<DateTime, bool?> filteredHabitCompletion) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(16.0),
      margin: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: colorScheme.background,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [BoxShadow(color: colorScheme.shadow.withOpacity(0.1), blurRadius: 4.0, spreadRadius: 2.0)],
      ),
      child: Column(
        children: [
          Text(
            'Monthly Summary (${widget.selectedFilter})',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryStat(Icons.check_circle, 'Completed', colorScheme.primary,
                  _fullyCompletedDays(filteredHabitCompletion).toString()),
              _buildSummaryStat(Icons.error, 'Incomplete', colorScheme.error,
                  (filteredHabitCompletion.length - _fullyCompletedDays(filteredHabitCompletion)).toString()),
              _buildSummaryStat(Icons.percent, 'Completion', colorScheme.secondary,
                  '${_calculateCompletionRate(filteredHabitCompletion)}%'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStat(IconData icon, String label, Color color, String value) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return "${date.day} ${months[date.month - 1]}";
  }

  int _fullyCompletedDays(Map<DateTime, bool?> habitCompletion) =>
      habitCompletion.values.where((value) => value == true).length;

  int _calculateCompletionRate(Map<DateTime, bool?> habitCompletion) {
    int completed = habitCompletion.values.where((value) => value == true).length;
    int totalScheduled = habitCompletion.values.where((value) => value != null).length;
    return totalScheduled == 0 ? 0 : ((completed / totalScheduled) * 100).round();
  }
}