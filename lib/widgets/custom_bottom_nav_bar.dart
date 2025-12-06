import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback onFabTap;
  final bool showFab;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.onFabTap,
    this.showFab = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? AppTheme.darkSurface : Colors.white;
    final activeColor = AppTheme.primary;
    final inactiveColor = AppTheme.textLight.withValues(alpha: 0.5);

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: BottomAppBar(
        shape: showFab ? const CircularNotchedRectangle() : null,
        notchMargin: 8.0,
        color: backgroundColor,
        elevation: 0,
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              0,
              Icons.list_alt_rounded,
              'Tasks',
              activeColor,
              inactiveColor,
            ),
            _buildNavItem(
              1,
              Icons.calendar_view_month,
              'Schedule',
              activeColor,
              inactiveColor,
            ),
            if (showFab) const SizedBox(width: 48), // Space for FAB
            _buildNavItem(
              2,
              Icons.timer_outlined,
              'Focus',
              activeColor,
              inactiveColor,
            ),
            _buildNavItem(
              3,
              Icons.settings,
              'Settings',
              activeColor,
              inactiveColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    String label,
    Color activeColor,
    Color inactiveColor,
  ) {
    final isSelected = currentIndex == index;
    return InkWell(
      onTap: () => onTap(index),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? activeColor : inactiveColor,
              size: 26,
            ),
            // Optional: Show dot or label for active state
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: activeColor,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
