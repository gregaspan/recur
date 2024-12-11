import 'package:flutter/material.dart';
import 'overall_progress_screen.dart';
import 'weekly_progress_screen.dart';
import 'calendar_habit_screen.dart';
import 'package:recur_application/screens/bottom_navigation_bar.dart';

class ProgressScreenMain extends StatefulWidget {
  @override
  _ProgressScreenMainState createState() => _ProgressScreenMainState();
}

class _ProgressScreenMainState extends State<ProgressScreenMain> {
  final PageController pageController = PageController(initialPage: 0); // Upravljanje strani
  int currentPageIndex = 0; // Trenutni zaslon (Overall, Weekly, Calendar)
  int currentNavBarIndex = 1; // Trenutni zavihek za spodnjo navigacijo (Progress)

  void navigateToPage(int navBarIndex) {
    if (navBarIndex != currentNavBarIndex) {
      setState(() {
        currentNavBarIndex = navBarIndex;
      });
      if (navBarIndex == 0) {
        // Navigacija na Home
        Navigator.pushReplacementNamed(context, '/home');
      } else if (navBarIndex == 1) {
        // Navigacija na Progress (že na tej strani)
        pageController.jumpToPage(0); // Resetiraj na prvi zaslon Progress
      } else if (navBarIndex == 2) {
        // Navigacija na Challenges
        Navigator.pushReplacementNamed(context, '/challenges');
      } else if (navBarIndex == 3) {
        // Navigacija na Settings
        Navigator.pushReplacementNamed(context, '/settings');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          "Progress",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: PageView(
        controller: pageController,
        onPageChanged: (index) {
          setState(() {
            currentPageIndex = index; // Posodobi trenutni indeks strani
          });
        },
        children: [
          OverallProgressScreen(currentPageIndex: currentPageIndex), // Posreduj trenutni indeks
          WeeklyProgressScreen(), // Drugi zaslon (Weekly Progress Overview)
          CalendarProgressScreen(), // Tretji zaslon (Calendar Habit Tracking)
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: currentNavBarIndex, // Trenutni zavihek spodnje navigacije
        onTap: (index) {
          navigateToPage(index);
        },
      ),
    );
  }
}