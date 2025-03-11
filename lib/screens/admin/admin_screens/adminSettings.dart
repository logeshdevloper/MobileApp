import 'package:flutter/material.dart';
import 'package:pops/common/styles/color.dart';

import '../../../common/auth/logout.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  _AdminSettingsScreenState createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Admin Settings'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          SettingsSection(title: 'Account Settings', options: [
            SettingsTile(
                icon: Icons.person, title: 'Edit Profile', onTap: () {}),
            SettingsTile(
                icon: Icons.lock, title: 'Change Password', onTap: () {}),
            SettingsTile(
                icon: Icons.logout,
                title: 'Logout',
                isDestructive: true,
                onTap: () async {
                  await logout(context);
                },
                iconColor: Colors.redAccent),
          ]),
          SettingsSection(title: 'User Management', options: [
            SettingsTile(
                icon: Icons.people, title: 'Manage Customers', onTap: () {}),
            SettingsTile(
                icon: Icons.work, title: 'Manage Workers', onTap: () {}),
            SettingsTile(
                icon: Icons.admin_panel_settings,
                title: 'Manage Admins',
                onTap: () {}),
          ]),
          SettingsSection(title: 'Orders & Deliveries', options: [
            SettingsTile(
                icon: Icons.shopping_cart, title: 'View Orders', onTap: () {}),
            SettingsTile(
                icon: Icons.delivery_dining,
                title: 'Assign Deliveries',
                onTap: () {}),
          ]),
          SettingsSection(title: 'Product & Inventory', options: [
            SettingsTile(
                icon: Icons.add_shopping_cart,
                title: 'Manage Products',
                onTap: () {}),
            SettingsTile(
                icon: Icons.inventory, title: 'Stock Updates', onTap: () {}),
          ]),
          SettingsSection(title: 'Analytics & Reports', options: [
            SettingsTile(
                icon: Icons.bar_chart, title: 'Sales Summary', onTap: () {}),
            SettingsTile(
                icon: Icons.trending_up, title: 'Order Trends', onTap: () {}),
          ]),
          SettingsSection(title: 'Payments & Transactions', options: [
            SettingsTile(
                icon: Icons.payment, title: 'Payment Settings', onTap: () {}),
            SettingsTile(
                icon: Icons.history,
                title: 'Transaction History',
                onTap: () {}),
          ]),
          SettingsSection(title: 'App Preferences', options: [
            SettingsTile(
                icon: Icons.dark_mode, title: 'Dark Mode', onTap: () {}),
            SettingsTile(
                icon: Icons.notifications,
                title: 'Notification Settings',
                onTap: () {}),
            SettingsTile(icon: Icons.language, title: 'Language', onTap: () {}),
          ]),
        ],
      ),
    );
  }
}

class SettingsSection extends StatelessWidget {
  final String title;
  final List<SettingsTile> options;

  SettingsSection({required this.title, required this.options});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        ...options,
        Divider(),
      ],
    );
  }
}

class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isDestructive;
  final VoidCallback onTap;
  final Color? iconColor;

  SettingsTile(
      {required this.icon,
      required this.title,
      this.isDestructive = false,
      required this.onTap,
      this.iconColor = Colors.amberAccent});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title,
          style: TextStyle(color: isDestructive ? Colors.red : Colors.black)),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
