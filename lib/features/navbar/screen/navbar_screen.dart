import 'package:auto_flow/features/home/screen/home_screen.dart';
import 'package:auto_flow/features/history/screen/history_screen.dart';
import 'package:auto_flow/features/settings/screen/settings_screen.dart';
import 'package:auto_flow/features/upload/screen/upload_screen.dart';
import 'package:auto_flow/features/workspace/screen/workspace_screen.dart';
import 'package:flutter/material.dart';

class NavBarScreen extends StatefulWidget {
  const NavBarScreen({super.key});

  @override
  State<NavBarScreen> createState() => _NavBarScreenState();
}

class _NavBarScreenState extends State<NavBarScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomeScreen(),
    UploadScreen(),
    WorkspaceScreen(),
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
        backgroundColor: colorScheme.surface,
        currentIndex: _currentIndex,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurface.withValues(alpha: 0.6),
        onTap: _onNavPageTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),

          BottomNavigationBarItem(icon: Icon(Icons.upload), label: "Upload"),

          BottomNavigationBarItem(
            icon: Icon(Icons.workspaces),
            label: "Workspace",
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
