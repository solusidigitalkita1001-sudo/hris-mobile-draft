import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hrm_app/core/theme/app_theme.dart';
import 'package:hrm_app/features/attendance/presentation/screens/attendance_screen.dart';
import 'package:hrm_app/features/calendar/presentation/screens/calendar_screen.dart';
import 'package:hrm_app/features/dashboard/presentation/screens/home_screen.dart';
import 'package:hrm_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:hrm_app/features/self_service/presentation/screens/requests_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const ProviderScope(child: HrmsApp()));
}

// ─── Theme State ─────────────────────────────────────────────────────────────

class HrmsApp extends StatefulWidget {
  const HrmsApp({super.key});

  @override
  State<HrmsApp> createState() => _HrmsAppState();
}

class _HrmsAppState extends State<HrmsApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light
          ? ThemeMode.dark
          : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HRMS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,
      home: MainShell(themeMode: _themeMode, onThemeToggle: _toggleTheme),
    );
  }
}

// ─── Main Shell ───────────────────────────────────────────────────────────────

class MainShell extends StatefulWidget {
  final ThemeMode themeMode;
  final VoidCallback onThemeToggle;

  const MainShell({
    super.key,
    required this.themeMode,
    required this.onThemeToggle,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  static const List<_NavItem> _navItems = [
    _NavItem(
      icon: Icons.home_rounded,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    _NavItem(
      icon: Icons.access_time_outlined,
      activeIcon: Icons.access_time_filled_rounded,
      label: 'Attendance',
    ),
    _NavItem(
      icon: Icons.send_outlined,
      activeIcon: Icons.send_rounded,
      label: 'Requests',
    ),
    _NavItem(
      icon: Icons.calendar_month_outlined,
      activeIcon: Icons.calendar_month_rounded,
      label: 'Calendar',
    ),
    _NavItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final screens = [
      const HomeScreen(),
      const AttendanceScreen(),
      const RequestsScreen(),
      const CalendarScreen(),
      ProfileScreen(
        onThemeToggle: widget.onThemeToggle,
        isDarkMode: widget.themeMode == ThemeMode.dark,
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 1,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (i) => setState(() => _currentIndex = i),
          backgroundColor: isDark
              ? AppColors.darkSurface
              : AppColors.lightSurface,
          indicatorColor: AppColors.primary.withValues(alpha: 0.12),
          shadowColor: Colors.transparent,
          elevation: 0,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: _navItems
              .map(
                (item) => NavigationDestination(
                  icon: Icon(
                    item.icon,
                    size: 22,
                    color: isDark
                        ? AppColors.darkTextSub
                        : AppColors.lightTextSub,
                  ),
                  selectedIcon: Icon(
                    item.activeIcon,
                    size: 22,
                    color: AppColors.primary,
                  ),
                  label: item.label,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
