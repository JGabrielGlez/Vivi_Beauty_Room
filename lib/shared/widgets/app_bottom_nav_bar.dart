import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  static const Color activeColor = Color(0xFFD4748F);
  static const Color inactiveColor = Color(0xFFB0B7C3);
  static const double iconSize = 24;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: activeColor.withOpacity(0.6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        currentIndex: currentIndex,
        onTap: onTap,
        selectedItemColor: activeColor,
        unselectedItemColor: inactiveColor,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.calendar, size: iconSize),
            label: 'AGENDA',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.users, size: iconSize),
            label: 'CLIENTES',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.scissors, size: iconSize),
            label: 'SERVICIOS',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.settings, size: iconSize),
            label: 'MÁS',
          ),
        ],
      ),
    );
  }
}
