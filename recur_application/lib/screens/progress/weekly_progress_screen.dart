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
    startOfWeek = today.subtract(Duration(days: today.weekday - 1)); // Ponedeljek
    endOfWeek = startOfWeek.add(Duration(days: 6)); // Nedelja
  }

  void _moveWeek(int days) {
    setState(() {
      startOfWeek = startOfWeek.add(Duration(days: days)); // Premik tedna
      endOfWeek = startOfWeek.add(Duration(days: 6)); // Posodobi končni datum
    });
  }

  @override
  Widget build(BuildContext context) {
    // Pripravi podatke za graf
    final data = List.generate(
      7,
      (index) {
        final date = startOfWeek.add(Duration(days: index));
        return {
          'day': date.day.toString(),
          'count': (index + 1) * 2, // Dummy podatki za napredek
          'isSelected': date.day == today.day,
        };
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Filter Buttons (All, Meditate, Morning Routine)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            FilterButton(label: "All", isActive: true, color: Colors.green),
            FilterButton(label: "Meditate", isActive: false, color: Colors.yellow),
            FilterButton(label: "Morning Routine", isActive: false, color: Colors.blue),
          ],
        ),
        SizedBox(height: 24),
        // Weekly Progress Title
        Text(
          "Weekly Progress Overview",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        SizedBox(height: 8),
        // Date Range Selector
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_left),
              onPressed: () {
                _moveWeek(-7); // Premik na prejšnji teden
              },
            ),
            Text(
              "${_formatDate(startOfWeek)} - ${_formatDate(endOfWeek)}",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: Icon(Icons.arrow_right),
              onPressed: () {
                _moveWeek(7); // Premik na naslednji teden
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
                        toY: count.toDouble(), // Nadomestite 'y' s 'toY'
                        color: isSelected ? Colors.blue : Colors.blue.withOpacity(0.5), // Nadomestite 'colors' s 'color'
                        width: 16,
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: 10,
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
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, titleMeta) {
                        return Text(value.toInt().toString());
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
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.lightBlue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "This Week",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "38%",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.teal),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.lightBlue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "All Time",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "50%",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.teal),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 24),
        // Page Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            return AnimatedContainer(
              duration: Duration(milliseconds: 300),
              margin: EdgeInsets.symmetric(horizontal: 4),
              height: 10,
              width: 10,
              decoration: BoxDecoration(
                color: index == 1 ? Colors.teal : Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            );
          }),
        ),
        SizedBox(height: 24),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day} ${_getMonthName(date.month)}";
  }

  String _getMonthName(int month) {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return months[month - 1];
  }
}

// Custom Filter Button Widget
class FilterButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color color;

  FilterButton({
    required this.label,
    required this.isActive,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isActive ? color : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}