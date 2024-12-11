import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  CustomBottomNavigationBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: Colors.blueGrey[1000], // Spremeni ozadje
      selectedItemColor: Colors.black, // Barva izbranih elementov
      unselectedItemColor: Colors.grey[400], // Barva neizbranih elementov
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.timeline),
          label: 'Progress',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.star),
          label: 'Challenges',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
}