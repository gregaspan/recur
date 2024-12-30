import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class WeeklyProgressScreen extends StatefulWidget {
  final String selectedFilter;

  WeeklyProgressScreen({required this.selectedFilter});

  @override
  _WeeklyProgressScreenState createState() => _WeeklyProgressScreenState();
}

class _WeeklyProgressScreenState extends State<WeeklyProgressScreen> {
  DateTime today = DateTime.now();
  late DateTime startOfWeek;
  late DateTime endOfWeek;

  Map<String, int> dailyCompletedHabits = {};
  Map<String, double> weeklyCompletionRates = {};
  Map<String, double> monthlyCompletionRates = {};
  int totalHabitsPlannedThisWeek = 0;

  @override
  void initState() {
    super.initState();
    _calculateWeekRange();
    _fetchData();
  }

  void _calculateWeekRange() {
    startOfWeek = today.subtract(Duration(days: today.weekday - 1)); // Monday
    endOfWeek = startOfWeek.add(Duration(days: 6)); // Sunday
  }

  void _moveWeek(int days) {
    setState(() {
      startOfWeek = startOfWeek.add(Duration(days: days));
      endOfWeek = startOfWeek.add(Duration(days: 6));
      _fetchData();
    });
  }

  Future<void> _fetchData() async {
  try {
    final snapshot = await FirebaseFirestore.instance.collection('habits').get();

    final Map<String, int> tempDailyCompleted = {};
    final Map<String, List<double>> tempWeeklyCompletion = {};
    final Map<String, List<double>> tempMonthlyCompletion = {};
    int tempTotalHabitsPlannedThisWeek = 0;

    for (var habitDoc in snapshot.docs) {
      final habitData = habitDoc.data();
      final periods = habitData['periods'] as Map<String, dynamic>? ?? {};
      final type = habitData['type'] ?? "All";
      final frequency = habitData['frequency'] ?? "Unknown";

      if (widget.selectedFilter != "All" && widget.selectedFilter != type) {
        continue;
      }

      tempTotalHabitsPlannedThisWeek++;

      for (var periodKey in periods.keys) {
        final period = periods[periodKey];

        // Za dnevne podatke (pusti nespremenjeno)
        if (RegExp(r"^\d{4}-\d{2}-\d{2}$").hasMatch(periodKey)) {
          final date = DateTime.parse(periodKey);
          final progress = period['progress'] ?? 0.0;
          final status = period['status'] ?? "ongoing";

          if (status == 'completed') {
            final dateKey =
                "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
            tempDailyCompleted[dateKey] = (tempDailyCompleted[dateKey] ?? 0) + 1;
          }

          if (frequency == "Weekly") {
            final weekKey = "${date.year}-W${_weekOfYear(date)}";
            tempWeeklyCompletion.putIfAbsent(weekKey, () => []);
            tempWeeklyCompletion[weekKey]?.add(progress);
          }
        }

        // Za mesečne podatke (popravljeno)
        if (frequency == "Monthly" && RegExp(r"^\d{4}-\d{2}$").hasMatch(periodKey)) {
          // Preverimo, ali je `periodKey` oblikovan kot "YYYY-MM" (npr. "2024-12")
          final progress = period['progress'] ?? 0.0;

            tempMonthlyCompletion.putIfAbsent(periodKey, () => []);
            tempMonthlyCompletion[periodKey]?.add(progress);
        }
      }
    }

    // Izračun povprečja za tedenske podatke (ostaja nespremenjeno)
    final Map<String, double> weeklyAverages = tempWeeklyCompletion.map((key, progresses) {
      final total = progresses.reduce((a, b) => a + b);
      final average = progresses.isNotEmpty ? total / progresses.length : 0.0;
      return MapEntry(key, average > 1.0 ? 1.0 : average);
    });

    // Izračun povprečja za mesečne podatke (popravljeno za monthly)
    final Map<String, double> monthlyAverages = tempMonthlyCompletion.map((key, progresses) {
      final total = progresses.reduce((a, b) => a + b);
      final average = progresses.isNotEmpty ? total / progresses.length : 0.0;
      return MapEntry(key, average > 1.0 ? 1.0 : average);
    });

    setState(() {
      dailyCompletedHabits = tempDailyCompleted;
      weeklyCompletionRates = weeklyAverages;
      monthlyCompletionRates = monthlyAverages;
      totalHabitsPlannedThisWeek = tempTotalHabitsPlannedThisWeek;
    });

    print("mesečni podatki: $monthlyCompletionRates");
    print("tedenski podatki: $weeklyCompletionRates");
    print("dnevni podatki: $dailyCompletedHabits");
  } catch (e) {
    print("Error fetching data: $e");
  }
}

  int _weekOfYear(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysSinceFirstDay = date.difference(firstDayOfYear).inDays;
    return ((daysSinceFirstDay + firstDayOfYear.weekday - 1) / 7).ceil();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 16),
          Text(
            "Progress Overview",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          if (dailyCompletedHabits.isNotEmpty) _buildBarChart(),
          if (weeklyCompletionRates.isNotEmpty)
            _buildLineChart("Weekly Habits", weeklyCompletionRates, "Weeks"),
          if (monthlyCompletionRates.isNotEmpty)
            _buildMonthlyLineChart("Monthly Habits", monthlyCompletionRates),
          SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_left),
              onPressed: () => _moveWeek(-7),
            ),
            Text(
              "${_formatDate(startOfWeek)} - ${_formatDate(endOfWeek)}",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: Icon(Icons.arrow_right),
              onPressed: () => _moveWeek(7),
            ),
          ],
        ),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              maxY: 10,
              barGroups: List.generate(7, (index) {
                final date = startOfWeek.add(Duration(days: index));
                final dateKey =
                    "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                final count = dailyCompletedHabits[dateKey] ?? 0;

                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: count.toDouble(),
                      color: Colors.blue,
                      width: 16,
                      borderRadius: BorderRadius.circular(6),
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: 10,
                        color: Colors.grey[200],
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLineChart(String title, Map<String, double> data, String xAxisLabel) {
  if (data.isEmpty) return Container();

  // Izračunamo trenutni teden in zadnjih 6 tednov
  final today = DateTime.now();
  final currentWeekNumber = ((today.difference(DateTime(today.year, 1, 1)).inDays + 1) / 7).ceil();
  final year = today.year;

  // Ustvarimo zadnjih 6 tednov (ključ "YYYY-WXX")
  List<String> lastSixWeeks = List.generate(6, (index) {
    int week = currentWeekNumber - (5 - index);
    int adjustedYear = year;

    if (week < 1) {
      // Prejšnje leto
      adjustedYear -= 1;
      week = 52 + week;
    }

    return "$adjustedYear-W${week.toString().padLeft(2, '0')}";
  });

  // Zapolnimo manjkajoče tedne z 0%
  final filledData = {for (var week in lastSixWeeks) week: data[week] ?? 0.0};

  // Pripravimo točke za graf
  final spots = filledData.entries.map((entry) {
    final index = lastSixWeeks.indexOf(entry.key).toDouble();
    final progress = entry.value * 100; // Pretvorimo v odstotke
    return FlSpot(index, progress);
  }).toList();

  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
        ),
      ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                horizontalInterval: 20,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.grey.withOpacity(0.3),
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 20,
                    getTitlesWidget: (value, _) {
                      return Text(
                        "${value.toInt()}%", // Prikaz odstotkov na levi osi
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1, // Prikaz za vsak teden
                    getTitlesWidget: (value, _) {
                      final index = value.toInt();
                      if (index >= 0 && index < lastSixWeeks.length) {
                        final weekNumber = lastSixWeeks[index].split('-W').last; // Izlušči samo številko tedna
                        return Text(
                          "W$weekNumber", // Prikaz samo številke tedna
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        );
                      }
                      return Text("");
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border(
                  left: BorderSide(color: Colors.grey.withOpacity(0.5), width: 1),
                  bottom: BorderSide(color: Colors.grey.withOpacity(0.5), width: 1),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true, // Gladke črte
                  barWidth: 4,
                  color: Colors.blueAccent,
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        Colors.blueAccent.withOpacity(0.2),
                        Colors.transparent
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                      radius: 4,
                      color: Colors.blueAccent,
                      strokeWidth: 2,
                      strokeColor: Colors.white,
                    ),
                  ),
                ),
              ],
              minX: 0,
              maxX: lastSixWeeks.length.toDouble() - 1,
              minY: 0,
              maxY: 100,
            ),
          ),
        ),
      ),
    ],
  );
}

Widget _buildMonthlyLineChart(String title, Map<String, double> data) {
  if (data.isEmpty) return Container();

  // Pridobimo zadnjih 6 mesecev
  final today = DateTime.now();
  final currentMonth = today.month;
  final year = today.year;

  List<String> lastSixMonths = List.generate(6, (index) {
    int month = currentMonth - (5 - index);
    int adjustedYear = year;

    if (month < 1) {
      adjustedYear -= 1;
      month += 12;
    }

    return "$adjustedYear-${month.toString().padLeft(2, '0')}";
  });

  // Zapolnimo manjkajoče mesece z vrednostjo 0%
  final filledData = {for (var month in lastSixMonths) month: data[month] ?? 0.0};

  // Pripravimo točke za graf
  final spots = filledData.entries.map((entry) {
    final index = lastSixMonths.indexOf(entry.key).toDouble();
    final progress = entry.value * 100;
    return FlSpot(index, progress);
  }).toList();
  
  final subtitle =
      "From ${_formatDate(startOfWeek)} to ${_formatDate(endOfWeek)}"; // Podnaslovž

  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
      ),
      
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                horizontalInterval: 20,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.grey.withOpacity(0.3),
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false), // Skrij zgornje številke
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false), // Skrij desne številke
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 20,
                    getTitlesWidget: (value, _) {
                      return Text(
                        "${value.toInt()}%", // Dodano %
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) {
                      final index = value.toInt();
                      if (index >= 0 && index < lastSixMonths.length) {
                        final monthYear = lastSixMonths[index];
                        final monthNumber = int.parse(monthYear.split('-')[1]);
                        final monthName = _getMonthName(monthNumber);
                        return Text(
                          monthName, // Prikaže ime meseca
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        );
                      }
                      return Text("");
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border(
                  left: BorderSide(color: Colors.grey.withOpacity(0.5), width: 1),
                  bottom: BorderSide(color: Colors.grey.withOpacity(0.5), width: 1),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  barWidth: 4,
                  color: Colors.purpleAccent,
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [Colors.purpleAccent.withOpacity(0.2), Colors.transparent],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  dotData: FlDotData(show: true),
                ),
              ],
              minX: 0,
              maxX: lastSixMonths.length.toDouble() - 1,
              minY: 0,
              maxY: 100,
            ),
          ),
        ),
      ),
    ],
  );
}

  String _getMonthName(int month) {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return months[month - 1];
  }

  String _formatDate(DateTime date) {
    final months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];
    return "${date.day} ${months[date.month - 1]}";
  }
}