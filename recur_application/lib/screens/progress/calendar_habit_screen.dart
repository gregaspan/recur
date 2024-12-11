import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarProgressScreen extends StatefulWidget {
  final String selectedFilter; // Selected filter to apply (e.g., "All", "Meditate", "Morning Routine")

  CalendarProgressScreen({
    Key? key,
    required this.selectedFilter,
  }) : super(key: key);

  @override
  _CalendarProgressScreenState createState() => _CalendarProgressScreenState();
}

class _CalendarProgressScreenState extends State<CalendarProgressScreen> {
  DateTime _focusedDay = DateTime.now(); // Currently focused month
  DateTime? _selectedDay; // Selected day in the calendar

  // Hardcoded habit completion data
  final Map<DateTime, bool?> habitCompletion = {
    _normalizeDate(DateTime(2024, 12, 1)): true,
    _normalizeDate(DateTime(2024, 12, 2)): false,
    _normalizeDate(DateTime(2024, 12, 3)): true,
    _normalizeDate(DateTime(2024, 12, 5)): true,
    _normalizeDate(DateTime(2024, 12, 6)): false,
    _normalizeDate(DateTime(2024, 12, 8)): true,
    _normalizeDate(DateTime(2024, 12, 10)): false,
  };

  // Normalize a DateTime to only include the date (no time)
  static DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  Map<DateTime, bool?> _getFilteredHabitCompletion() {
    if (widget.selectedFilter == "All") {
      return habitCompletion;
    }

    // Example: Add filter logic for specific categories
    // For simplicity, this example does not differentiate habit data by filter.
    // Replace this with real filtering logic based on widget.selectedFilter.
    return habitCompletion; // In practice, filter this map based on widget.selectedFilter.
  }

  @override
  Widget build(BuildContext context) {
    final filteredHabitCompletion = _getFilteredHabitCompletion();

    return Scaffold(
      body: Column(
        children: [
          Text(
            "Habit tracking",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          // Calendar
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
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
                    margin: const EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                      color: isCompleted == true
                          ? Colors.green
                          : isCompleted == false
                              ? Colors.red
                              : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }
                return null;
              },
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),

          // Selected Day Summary
          if (_selectedDay != null) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildSelectedDaySummary(filteredHabitCompletion),
            ),
          ],

          Spacer(),

          // Monthly Summary
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4.0,
                    spreadRadius: 2.0,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'Monthly Summary (${widget.selectedFilter})',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSummaryStat(
                        icon: Icons.check_circle,
                        label: '${_fullyCompletedDays(filteredHabitCompletion)} Days Completed',
                        color: Colors.green,
                      ),
                      _buildSummaryStat(
                        icon: Icons.error,
                        label: '${filteredHabitCompletion.length - _fullyCompletedDays(filteredHabitCompletion)} Days Incomplete',
                        color: Colors.red,
                      ),
                      _buildSummaryStat(
                        icon: Icons.percent,
                        label: '${_calculateCompletionRate(filteredHabitCompletion)}% Done',
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedDaySummary(Map<DateTime, bool?> filteredHabitCompletion) {
    DateTime normalizedSelectedDay = _normalizeDate(_selectedDay!);
    bool? status = filteredHabitCompletion[normalizedSelectedDay];
    String statusText = status == true
        ? "Habit Completed"
        : status == false
            ? "Habit Not Completed"
            : "No Habit Scheduled";

    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Selected Day: ${_formatDate(normalizedSelectedDay)}",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            statusText,
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStat({required IconData icon, required String label, required Color color}) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return "${date.day} ${months[date.month - 1]}";
  }

  int _fullyCompletedDays(Map<DateTime, bool?> habitCompletion) {
    return habitCompletion.values.where((value) => value == true).length;
  }

  int _calculateCompletionRate(Map<DateTime, bool?> habitCompletion) {
    int completed = habitCompletion.values.where((value) => value == true).length;
    int totalScheduled = habitCompletion.values.where((value) => value != null).length;

    if (totalScheduled == 0) return 0;
    return ((completed / totalScheduled) * 100).round();
  }
}