import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hrm_app/app/providers/theme_controller.dart';
import 'package:hrm_app/core/config/app_config.dart';
import 'package:hrm_app/core/network/dio_client.dart';
import 'package:hrm_app/core/storage/preferences.dart';
import 'package:hrm_app/core/security/session_lifecycle.dart';
import 'package:hrm_app/core/theme/app_theme.dart';
import 'package:hrm_app/features/attendance/presentation/screens/attendance_screen.dart';
import 'package:hrm_app/features/authentication/authentication_providers.dart';
import 'package:hrm_app/features/authentication/presentation/screens/login_screen.dart';
import 'package:hrm_app/features/authentication/presentation/screens/change_password_screen.dart';
import 'package:hrm_app/features/authentication/presentation/screens/employee_access_unavailable_screen.dart';
import 'package:hrm_app/features/calendar/presentation/screens/calendar_screen.dart';
import 'package:hrm_app/features/dashboard/presentation/screens/home_screen.dart';
import 'package:hrm_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:hrm_app/features/self_service/presentation/screens/requests_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  final preferences = await SharedPreferences.getInstance();
  final config = AppConfig.fromEnvironment();
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(preferences),
        appConfigProvider.overrideWithValue(config),
      ],
      child: const HrmsApp(),
    ),
  );
}

class HrmsApp extends ConsumerWidget {
  const HrmsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeControllerProvider);
    final featureSession = ref.watch(featureSessionProvider);
    return MaterialApp(
      key: ObjectKey(featureSession),
      title: 'HRMS',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      home: AuthGate(
        themeMode: themeMode,
        onThemeToggle: () =>
            ref.read(themeControllerProvider.notifier).toggle(),
      ),
    );
  }
}

class AuthGate extends ConsumerWidget {
  const AuthGate({
    super.key,
    required this.themeMode,
    required this.onThemeToggle,
  });

  final ThemeMode themeMode;
  final VoidCallback onThemeToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authControllerProvider);
    final featureSession = ref.watch(featureSessionProvider);
    return auth.when(
      skipLoadingOnRefresh: false,
      data: (session) => switch (session) {
        null => const LoginScreen(),
        _ when session.mustChangePassword => ChangePasswordScreen(
          onSignOut: () => ref.read(authControllerProvider.notifier).logout(),
        ),
        _ when !session.hasEmployeeAccess => EmployeeAccessUnavailableScreen(
          onSignOut: () => ref.read(authControllerProvider.notifier).logout(),
        ),
        _ => MainShell(
          key: ObjectKey(featureSession),
          themeMode: themeMode,
          onThemeToggle: onThemeToggle,
          onSignOut: () => ref.read(authControllerProvider.notifier).logout(),
        ),
      },
      loading: () => const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stackTrace) => const LoginScreen(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({
    super.key,
    required this.themeMode,
    required this.onThemeToggle,
    required this.onSignOut,
  });

  final ThemeMode themeMode;
  final VoidCallback onThemeToggle;
  final VoidCallback onSignOut;

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
      HomeScreen(onOpenAttendance: () => setState(() => _currentIndex = 1)),
      const AttendanceScreen(),
      const RequestsScreen(),
      const CalendarScreen(),
      ProfileScreen(
        onThemeToggle: widget.onThemeToggle,
        onSignOut: widget.onSignOut,
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
          onDestinationSelected: (index) =>
              setState(() => _currentIndex = index),
          backgroundColor: isDark
              ? AppColors.darkSurface
              : AppColors.lightSurface,
          indicatorColor: AppColors.primary.withValues(alpha: 0.12),
          shadowColor: Colors.transparent,
          elevation: 0,
          labelBehavior: MediaQuery.sizeOf(context).width < 360
              ? NavigationDestinationLabelBehavior.alwaysHide
              : NavigationDestinationLabelBehavior.alwaysShow,
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
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
}
