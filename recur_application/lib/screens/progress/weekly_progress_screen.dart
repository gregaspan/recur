import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class WeeklyProgressScreen extends StatefulWidget {
  @override
  _WeeklyProgressScreenState createState() => _WeeklyProgressScreenState();
}

class _WeeklyProgressScreenState extends State<WeeklyProgressScreen> {
  DateTime today = DateTime.now();
  late DateTime startOfWeek;
  late DateTime endOfWeek;

  @override
  void initState() {
    super.initState();
    _calculateWeekRange();
  }

  void _calculateWeekRange() {
    startOfWeek = today.subtract(Duration(days: today.weekday - 1)); // Monday
    endOfWeek = startOfWeek.add(Duration(days: 6)); // Sunday
  }

  void _moveWeek(int days) {
    setState(() {
      startOfWeek = startOfWeek.add(Duration(days: days)); // Move week
      endOfWeek = startOfWeek.add(Duration(days: 6)); // Update end date
    });
  }

  @override
  Widget build(BuildContext context) {
    // Generate data for the bar chart
    final data = List.generate(
      7,
      (index) {
        final date = startOfWeek.add(Duration(days: index));
        return {
          'day': date.day.toString(),
          'count': (index + 1) * 2, // Example progress data
          'isSelected': date.day == today.day,
        };
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 16),
        // Weekly Progress Title
        Text(
          "Weekly Progress Overview",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        SizedBox(height: 8),
        // Week Navigation
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_left),
              onPressed: () {
                _moveWeek(-7); // Move to previous week
              },
            ),
            Text(
              "${_formatDate(startOfWeek)} - ${_formatDate(endOfWeek)}",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: Icon(Icons.arrow_right),
              onPressed: () {
                _moveWeek(7); // Move to next week
              },
            ),
          ],
        ),
        SizedBox(height: 16),
        // Weekly Progress Bar Chart
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: BarChart(
              BarChartData(
                barGroups: data.map((entry) {
                  final isSelected = entry['isSelected'] as bool;
                  final count = entry['count'] as int? ?? 0;
                  return BarChartGroupData(
                    x: int.parse(entry['day'] as String),
                    barRods: [
                      BarChartRodData(
                        toY: count.toDouble(),
                        color: isSelected ? Colors.blue : Colors.blue.withOpacity(0.5),
                        width: 16,
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: 10, // Maximum value for the background bar
                        ),
                      ),
                    ],
                  );
                }).toList(),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, titleMeta) {
                        final index = value.toInt() - 1;
                        if (index >= 0 && index < 7) {
                          final date = startOfWeek.add(Duration(days: index));
                          return Text(_formatDate(date, short: true));
                        }
                        return Text("");
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 16),
        // Weekly and All-Time Progress
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ProgressCard(label: "This Week", percentage: 38),
              ProgressCard(label: "All Time", percentage: 50),
            ],
          ),
        ),
        SizedBox(height: 24),
      ],
    );
  }

  String _formatDate(DateTime date, {bool short = false}) {
    final month = short ? _getMonthName(date.month).substring(0, 3) : _getMonthName(date.month);
    return "${date.day} $month";
  }

  String _getMonthName(int month) {
    const months = [
      "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"
    ];
    return months[month - 1];
  }
}

// Reusable Progress Card Widget
class ProgressCard extends StatelessWidget {
  final String label;
  final int percentage;

  ProgressCard({required this.label, required this.percentage});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.lightBlue[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            SizedBox(height: 8),
            Text(
              "$percentage%",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.teal),
            ),
          ],
        ),
      ),
    );
  }
}