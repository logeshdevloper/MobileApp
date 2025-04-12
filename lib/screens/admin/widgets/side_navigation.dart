import 'package:flutter/material.dart';

class SideNavigation extends StatelessWidget {
  const SideNavigation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      color: Colors.black87,
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Profile Image
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.grey[300],
            child: const Icon(Icons.person, size: 30, color: Colors.black54),
          ),
          const SizedBox(height: 40),
          // Navigation Items
          _NavItem(
            icon: Icons.list_alt,
            isSelected: true,
            onTap: () {},
          ),
          _NavItem(
            icon: Icons.home_outlined,
            onTap: () {},
          ),
          _NavItem(
            icon: Icons.access_time,
            onTap: () {},
          ),
          _NavItem(
            icon: Icons.analytics_outlined,
            onTap: () {},
          ),
          _NavItem(
            icon: Icons.person_outline,
            onTap: () {},
          ),
          const Spacer(),
          _NavItem(
            icon: Icons.settings_outlined,
            onTap: () {},
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    Key? key,
    required this.icon,
    this.isSelected = false,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        border: isSelected
            ? Border(
                left: BorderSide(
                  color: Colors.blue.shade400,
                  width: 3,
                ),
              )
            : null,
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: isSelected ? Colors.blue.shade400 : Colors.grey,
          size: 28,
        ),
        onPressed: onTap,
      ),
    );
  }
}
