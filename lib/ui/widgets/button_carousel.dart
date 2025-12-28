import 'package:flutter/material.dart';

// Bouton arrondi flexible
class ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;
  final bool isLeft; // true = bouton gauche, false = bouton droit

  const ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    this.textColor = Colors.white,
    required this.onTap,
    this.isLeft = true,
  });

  @override
  Widget build(BuildContext context) {
    BorderRadius radius;

    if (isLeft) {
      // coins arrondis à gauche
      radius = const BorderRadius.only(
        topLeft: Radius.circular(30),
        bottomLeft: Radius.circular(30),
        topRight: Radius.zero,
        bottomRight: Radius.circular(30),
      );
    } else {
      // coins arrondis à droite
      radius = const BorderRadius.only(
        topLeft: Radius.zero,
        bottomLeft: Radius.circular(30),
        topRight: Radius.circular(30),
        bottomRight: Radius.circular(30),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: color,
            borderRadius: radius,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: textColor, size: 20),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}