import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
void didUpdateWidget(covariant WeeklyProgressScreen oldWidget) {
  super.didUpdateWidget(oldWidget);
  if (oldWidget.selectedFilter != widget.selectedFilter) {
    _fetchData(); // Ponovno naloži podatke, ko se filter spremeni
  }
}

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
      // Pridobi trenutno prijavljenega uporabnika
    final String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      print("User is not logged in.");
      return;
    }

    // Pridobi habite za trenutnega uporabnika iz Firestore
    final snapshot = await FirebaseFirestore.instance
        .collection('habits')
        .where('userId', isEqualTo: userId) // Filtriraj po userId
        .get();

      final Map<String, int> tempDailyCompleted = {};
      final Map<String, List<double>> tempWeeklyCompletion = {};
      final Map<String, List<double>> tempMonthlyCompletion = {};
      int tempTotalHabitsPlannedThisWeek = 0;

      for (var habitDoc in snapshot.docs) {
        final habitData = habitDoc.data();
        final periods = habitData['periods'] as Map<String, dynamic>? ?? {};
        final type = habitData['type'] ?? "All";
        final frequency = habitData['frequency'] ?? "Unknown";

        print("Habit type: $type, Selected filter: ${widget.selectedFilter}");

        // Apply selected filter
        if (widget.selectedFilter != "All" && widget.selectedFilter != type) {
          print("Skipping habit of type $type");
          continue;
        }

        print("Including habit of type $type");

        tempTotalHabitsPlannedThisWeek++;

        for (var periodKey in periods.keys) {
          final period = periods[periodKey];

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

          if (frequency == "Monthly" && RegExp(r"^\d{4}-\d{2}$").hasMatch(periodKey)) {
            final progress = period['progress'] ?? 0.0;
            tempMonthlyCompletion.putIfAbsent(periodKey, () => []);
            tempMonthlyCompletion[periodKey]?.add(progress);
          }
        }
      }

      final Map<String, double> weeklyAverages = tempWeeklyCompletion.map((key, progresses) {
        final total = progresses.reduce((a, b) => a + b);
        final average = progresses.isNotEmpty ? total / progresses.length : 0.0;
        return MapEntry(key, average > 1.0 ? 1.0 : average);
      });

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

      print("Filtered monthly data: $monthlyCompletionRates");
      print("Filtered weekly data: $weeklyCompletionRates");
      print("Filtered daily data: $dailyCompletedHabits");
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
  final maxCompleted = dailyCompletedHabits.values.isNotEmpty
      ? dailyCompletedHabits.values.reduce((a, b) => a > b ? a : b)
      : 0;
  final maxY = (maxCompleted + 2).toDouble();

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
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              maxY: maxY,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  tooltipMargin: 8,
                  fitInsideHorizontally: true,
                  fitInsideVertically: true,
                  getTooltipColor: (group) {
                    // Nastavimo belo ozadje za tooltip
                    return Colors.white;
                  },
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final currentDate = startOfWeek.add(Duration(days: group.x.toInt()));
                    final currentDateKey =
                        "${currentDate.year}-${currentDate.month.toString().padLeft(2, '0')}-${currentDate.day.toString().padLeft(2, '0')}";
                    final countThisWeek = dailyCompletedHabits[currentDateKey] ?? 0;

                    final previousDate = currentDate.subtract(Duration(days: 7));
                    final previousDateKey =
                        "${previousDate.year}-${previousDate.month.toString().padLeft(2, '0')}-${previousDate.day.toString().padLeft(2, '0')}";
                    final countPreviousWeek = dailyCompletedHabits[previousDateKey] ?? 0;

                    String differenceText;
                    if (countPreviousWeek == 0) {
                      differenceText = countThisWeek > 0
                          ? "↑ ${countThisWeek * 100}%"
                          : "No change";
                    } else {
                      final percentageChange =
                          ((countThisWeek - countPreviousWeek) / countPreviousWeek) * 100;
                      differenceText = percentageChange >= 0
                          ? "↑ ${percentageChange.toStringAsFixed(1)}%"
                          : "↓ ${percentageChange.abs().toStringAsFixed(1)}%";
                    }

                    return BarTooltipItem(
                      "${currentDate.year}, ${_getMonthName(currentDate.month)} ${currentDate.day}\n",
                      TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                          text: "$countThisWeek times\n",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: "Progress $differenceText",
                          style: TextStyle(
                            color: differenceText.contains("↑") ? Colors.green : Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
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
                        show: false,
                      ),
                    ),
                  ],
                );
              }),
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
                    interval: maxY <= 10 ? 2 : maxY / 5,
                    getTitlesWidget: (value, _) {
                      return Text(
                        "${value.toInt()}",
                        style: TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (value, _) {
                      final index = value.toInt();
                      if (index >= 0 && index < 7) {
                        final date = startOfWeek.add(Duration(days: index));
                        return Text(
                          "${date.day}",
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        );
                      }
                      return Text("");
                    },
                  ),
                ),
              ),
              gridData: FlGridData(
                drawVerticalLine: false,
                horizontalInterval: maxY <= 10 ? 2 : maxY / 5,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: Colors.grey.withOpacity(0.3),
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border(
                  left: BorderSide(color: Colors.grey.withOpacity(0.5), width: 1),
                  bottom: BorderSide(color: Colors.grey.withOpacity(0.5), width: 1),
                ),
              ),
            ),
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

  // Izračunamo začetni in končni datum za prikazani obseg tednov
  final startOfFirstWeek = _getStartOfWeek(
      int.parse(lastSixWeeks.first.split('-W').first), int.parse(lastSixWeeks.first.split('-W').last));
  final endOfLastWeek = _getEndOfWeek(
      int.parse(lastSixWeeks.last.split('-W').first), int.parse(lastSixWeeks.last.split('-W').last));
  final subtitle = "${_formatDate(startOfFirstWeek)} - ${_formatDate(endOfLastWeek)}";

  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 16.0), // Razmik od naslova in grafa
        child: Text(
          subtitle,
          style: TextStyle(fontSize: 14, color: Colors.grey),
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

// Funkcija za pridobitev začetka tedna
DateTime _getStartOfWeek(int year, int weekNumber) {
  final firstDayOfYear = DateTime(year, 1, 1);
  final daysOffset = (weekNumber - 1) * 7 - firstDayOfYear.weekday + 1;
  return firstDayOfYear.add(Duration(days: daysOffset));
}

// Funkcija za pridobitev konca tedna
DateTime _getEndOfWeek(int year, int weekNumber) {
  return _getStartOfWeek(year, weekNumber).add(Duration(days: 6));
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

  // Pripravimo podnaslov (ime prvih in zadnjih mesecev v intervalu)
  final startMonth = lastSixMonths.first;
  final endMonth = lastSixMonths.last;
  final subtitle =
      "${_getMonthName(int.parse(startMonth.split('-')[1]))} ${startMonth.split('-')[0]} - "
      "${_getMonthName(int.parse(endMonth.split('-')[1]))} ${endMonth.split('-')[0]}";

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
      Padding(
        padding: const EdgeInsets.only(bottom: 16.0), // Razmik od naslova in grafa
        child: Text(
          subtitle,
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: 100,
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
                        "${value.toInt()}%",
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (value, _) {
                      final index = value.toInt();
                      if (index >= 0 && index < lastSixMonths.length) {
                        // Prikaži samo enkrat ime meseca
                        final monthYear = lastSixMonths[index];
                        final monthNumber = int.parse(monthYear.split('-')[1]);
                        final monthName = _getMonthName(monthNumber);
                        return Text(
                          monthName,
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