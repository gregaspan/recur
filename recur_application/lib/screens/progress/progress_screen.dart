import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'overall_progress_screen.dart';
import 'weekly_progress_screen.dart';
import 'calendar_habit_screen.dart';
import 'package:recur_application/screens/bottom_navigation_bar.dart';

class ProgressScreenMain extends StatefulWidget {
  @override
  _ProgressScreenMainState createState() => _ProgressScreenMainState();
}

class _ProgressScreenMainState extends State<ProgressScreenMain> {
  final PageController pageController = PageController(initialPage: 0); // Page navigation controller
  int currentPageIndex = 0; // Current page index (Overall, Weekly, Calendar)
  int currentNavBarIndex = 1; // Current bottom navigation tab index (Progress)
  String selectedFilter = "All"; // Currently selected filter
  List<Map<String, dynamic>> filters = []; // Dynamic filters from Firestore

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchFilters(); // Fetch filters dynamically from Firestore
    });
  }

  Future<void> _fetchFilters() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('habits').get();
      Set<String> types = {"All"}; // Default filter "All"

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final type = data['type'] ?? '';
        if (type.isNotEmpty) {
          types.add(type);
        }
      }

      // Define a list of default Material colors
      List<Color> materialColors = [
        Colors.blue,
        Colors.green,
        Colors.orange,
        Colors.purple,
        Colors.red,
        Colors.teal,
      ];

      setState(() {
        filters = types.map((type) {
          int index = types.toList().indexOf(type) % materialColors.length;
          return {
            "label": type,
            "isSelected": type == "All",
            "color": materialColors[index], // Assign colors from the Material palette
          };
        }).toList();
      });
    } catch (e) {
      print("Error fetching filters: $e");
    }
  }

  void updateSelectedFilter(String filter) {
    setState(() {
      selectedFilter = filter;
    });
  }

  void navigateToPage(int navBarIndex) {
    if (navBarIndex != currentNavBarIndex) {
      setState(() {
        currentNavBarIndex = navBarIndex;
      });
      if (navBarIndex == 0) {
        // Navigate to Home
        Navigator.pushReplacementNamed(context, '/');
      } else if (navBarIndex == 1) {
        // Navigate to Progress (reset to first page)
        pageController.jumpToPage(0);
      } else if (navBarIndex == 2) {
        // Navigate to Challenges
        Navigator.pushReplacementNamed(context, '/challenges');
      } else if (navBarIndex == 3) {
        // Navigate to Settings
        Navigator.pushReplacementNamed(context, '/settings');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colorScheme.primary,
        title: Text(
          "Progress",
          style: TextStyle(color: colorScheme.onPrimary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Filters Section
          if (filters.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: filters
                      .map((filter) => GestureDetector(
                            onTap: () {
                              setState(() {
                                // Označi izbran filter
                                filters.forEach((f) => f['isSelected'] = false);
                                filter['isSelected'] = true;
                                updateSelectedFilter(filter['label']); // Posodobi filter
                              });
                            },
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 8.0),
                              decoration: BoxDecoration(
                                color: filter['color']?.withOpacity(filter['isSelected'] ? 1.0 : 0.4),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: Text(
                                filter['label'],
                                style: TextStyle(
                                  color: filter['isSelected'] ? colorScheme.onPrimary : colorScheme.onSurface,
                                  fontWeight: filter['isSelected'] ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),

          // PageView Section
          Expanded(
            child: PageView(
              controller: pageController,
              onPageChanged: (index) {
                setState(() {
                  currentPageIndex = index; // Update current page index
                });
              },
              children: [
                OverallProgressScreen(
                  selectedFilter: selectedFilter,
                ),
                WeeklyProgressScreen(
                  selectedFilter: selectedFilter,
                ),
                CalendarProgressScreen(
                  selectedFilter: selectedFilter, // Pass the selected filter
                ),
              ],
            ),
          ),

          // Pagination Dots
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3, // Number of pages
                (index) => Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.0),
                  width: 8.0,
                  height: 8.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: currentPageIndex == index
                        ? colorScheme.primary
                        : colorScheme.onSurface.withOpacity(0.3),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: currentNavBarIndex,
        onTap: (index) {
          navigateToPage(index);
        },
      ),
    );
  }
}