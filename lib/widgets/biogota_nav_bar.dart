import 'package:flutter/material.dart';

class BiogotaNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool isDarkMode;

  const BiogotaNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final activeColor = const Color(0xFF5D8BF4);
    final inactiveColor = isDarkMode ? Colors.white54 : Colors.black26;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _NavBarItem(
              icon: Icons.water_drop_outlined,
              label: "Agua",
              isActive: currentIndex == 0,
              activeColor: Colors.blue,
              inactiveColor: inactiveColor,
              onTap: () => onTap(0),
            ),
            _NavBarItem(
              icon: Icons.recycling_outlined,
              label: "Reciclaje",
              isActive: currentIndex == 1,
              activeColor: Colors.green,
              inactiveColor: inactiveColor,
              onTap: () => onTap(1),
            ),
            _MainNavBarItem(
              icon: Icons.home_rounded,
              isActive: currentIndex == 2,
              activeColor: activeColor,
              onTap: () => onTap(2),
            ),
            _NavBarItem(
              icon: Icons.bolt_outlined,
              label: "Energía",
              isActive: currentIndex == 3,
              activeColor: Colors.orange,
              inactiveColor: inactiveColor,
              onTap: () => onTap(3),
            ),
            _NavBarItem(
              icon: Icons.people_outline,
              label: "Amigos",
              isActive: currentIndex == 4,
              activeColor: activeColor,
              inactiveColor: inactiveColor,
              onTap: () => onTap(4),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color activeColor;
  final Color inactiveColor;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.activeColor,
    required this.inactiveColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? activeColor : inactiveColor,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? activeColor : inactiveColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _MainNavBarItem extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  const _MainNavBarItem({
    required this.icon,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: activeColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: activeColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 26,
        ),
      ),
    );
  }
}
