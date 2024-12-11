import 'package:flutter/material.dart';

class CustomFloatingButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color iconColor;
  final double size; // Dodaj možnost za velikost gumba

  CustomFloatingButton({
    required this.icon,
    required this.onPressed,
    this.backgroundColor = Colors.teal, // Privzeta barva
    this.iconColor = Colors.white, // Privzeta barva ikone
    this.size = 56.0, // Privzeta velikost
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle, // Okrogla oblika
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: Offset(0, 3), // Poudarek na senco
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: iconColor,
          size: size / 2.5, // Velikost ikone glede na gumb
        ),
        onPressed: onPressed,
      ),
    );
  }
}