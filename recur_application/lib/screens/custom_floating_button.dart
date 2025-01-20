import 'package:flutter/material.dart';

class CustomFloatingButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final double size;

  const CustomFloatingButton({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.size = 56.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        color: theme.primaryColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: theme.colorScheme.onPrimary,
          size: size / 2.5,
        ),
        onPressed: onPressed,
      ),
    );
  }
}