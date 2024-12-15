import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarProgressScreen extends StatefulWidget {
  final String selectedFilter; // Selected filter to apply

  CalendarProgressScreen({Key? key, required this.selectedFilter}) : super(key: key);

  @override
  _CalendarProgressScreenState createState() => _CalendarProgressScreenState();
}

class _CalendarProgressScreenState extends State<CalendarProgressScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  final Map<DateTime, bool?> habitCompletion = {
    _normalizeDate(DateTime(2024, 12, 1)): true,
    _normalizeDate(DateTime(2024, 12, 2)): false,
    _normalizeDate(DateTime(2024, 12, 3)): true,
    _normalizeDate(DateTime(2024, 12, 5)): true,
    _normalizeDate(DateTime(2024, 12, 6)): false,
    _normalizeDate(DateTime(2024, 12, 8)): true,
    _normalizeDate(DateTime(2024, 12, 10)): false,
  };

  static DateTime _normalizeDate(DateTime date) => DateTime(date.year, date.month, date.day);

  Map<DateTime, bool?> _getFilteredHabitCompletion() => habitCompletion;

  @override
  Widget build(BuildContext context) {
    final filteredHabitCompletion = _getFilteredHabitCompletion();

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 16),
            Text(
              "Habit Tracking",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            SizedBox(height: 8),
            _buildCalendar(filteredHabitCompletion),
            if (_selectedDay != null) ...[
              _buildSelectedDaySummary(filteredHabitCompletion),
            ],
            _buildMonthlySummary(filteredHabitCompletion),
          ],
        ),
      ),
    );
  }

  // Build Calendar Widget
  Widget _buildCalendar(Map<DateTime, bool?> filteredHabitCompletion) {
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
                          ? Colors.red
                          : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '${day.day}',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              );
            }
            return null;
          },
        ),
        headerStyle: HeaderStyle(
          titleCentered: true,
          formatButtonVisible: false,
        ),
      ),
    );
  }

  // Build Selected Day Summary
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
      margin: EdgeInsets.all(8.0),
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

  // Build Monthly Summary
  Widget _buildMonthlySummary(Map<DateTime, bool?> filteredHabitCompletion) {
    return Container(
      padding: EdgeInsets.all(16.0),
      margin: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4.0, spreadRadius: 2.0)],
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
              _buildSummaryStat(Icons.check_circle, 'Completed', Colors.green,
                  _fullyCompletedDays(filteredHabitCompletion).toString()),
              _buildSummaryStat(Icons.error, 'Incomplete', Colors.red,
                  (filteredHabitCompletion.length - _fullyCompletedDays(filteredHabitCompletion)).toString()),
              _buildSummaryStat(Icons.percent, 'Completion', Colors.blue,
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