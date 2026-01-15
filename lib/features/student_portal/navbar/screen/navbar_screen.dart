import 'package:auto_flow/features/student_portal/dashboard/screen/dashboard_screen.dart';
import 'package:auto_flow/features/student_portal/history/screen/history_screen.dart';
import 'package:auto_flow/features/student_portal/settings/screen/settings_screen.dart';
import 'package:auto_flow/features/student_portal/upload/screen/upload_screen.dart';
import 'package:flutter/material.dart';

class NavBarScreen extends StatefulWidget {
  const NavBarScreen({super.key});

  @override
  State<NavBarScreen> createState() => _NavBarScreenState();
}

class _NavBarScreenState extends State<NavBarScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    DashboardScreen(),
    HistoryScreen(),
    UploadScreen(),
    SettingsScreen(),
  ];

  void _onNavPageTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: colorScheme.surface, // theme-aware
        currentIndex: _currentIndex,
        selectedItemColor: colorScheme.primary, // theme-aware
        unselectedItemColor: colorScheme.onSurface.withValues(alpha: 0.6),
        onTap: _onNavPageTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: "Dashboard",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "History",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.upload),
            label: "Upload",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
    );
  }
}
