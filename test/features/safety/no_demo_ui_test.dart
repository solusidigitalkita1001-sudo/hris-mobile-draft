import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hrm_app/core/services/location_service.dart';
import 'package:hrm_app/core/theme/app_theme.dart';
import 'package:hrm_app/features/attendance/attendance_dependencies.dart';
import 'package:hrm_app/features/attendance/data/datasources/attendance_remote_datasource.dart';
import 'package:hrm_app/features/attendance/data/dto/attendance_dto.dart';
import 'package:hrm_app/features/attendance/domain/entities/attendance_command.dart';
import 'package:hrm_app/features/attendance/domain/entities/attendance_context.dart';
import 'package:hrm_app/features/attendance/presentation/screens/attendance_screen.dart';
import 'package:hrm_app/features/calendar/calendar_dependencies.dart';
import 'package:hrm_app/features/calendar/data/datasources/calendar_local_datasource.dart';
import 'package:hrm_app/features/calendar/presentation/screens/calendar_screen.dart';
import 'package:hrm_app/features/dashboard/dashboard_dependencies.dart';
import 'package:hrm_app/features/dashboard/data/datasources/dashboard_local_datasource.dart';
import 'package:hrm_app/features/dashboard/domain/entities/dashboard_snapshot.dart';
import 'package:hrm_app/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:hrm_app/features/dashboard/presentation/screens/home_screen.dart';
import 'package:hrm_app/features/profile/data/datasources/profile_local_datasource.dart';
import 'package:hrm_app/features/profile/domain/entities/employee.dart';
import 'package:hrm_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:hrm_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:hrm_app/features/profile/profile_dependencies.dart';
import 'package:hrm_app/features/self_service/data/datasources/request_local_datasource.dart';
import 'package:hrm_app/features/self_service/domain/entities/request_command.dart';
import 'package:hrm_app/features/self_service/presentation/screens/requests_screen.dart';
import 'package:hrm_app/features/self_service/self_service_dependencies.dart';
import 'package:hrm_app/main.dart';

void main() {
  test('production providers never select demo data sources', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      container.read(dashboardLocalDataSourceProvider),
      isA<EmptyDashboardLocalDataSource>(),
    );
    expect(
      container.read(requestLocalDataSourceProvider),
      isA<UnavailableRequestLocalDataSource>(),
    );
    expect(
      container.read(calendarLocalDataSourceProvider),
      isA<UnavailableCalendarLocalDataSource>(),
    );
    expect(
      container.read(profileLocalDataSourceProvider),
      isA<EmptyProfileLocalDataSource>(),
    );
    expect(
      container.read(locationServiceProvider),
      isA<GeolocatorLocationService>(),
    );
    await expectLater(
      container
          .read(requestLocalDataSourceProvider)
          .insert(const SubmitRequestCommand(type: 'Annual Leave')),
      throwsA(isA<UnsupportedError>()),
    );
  });

  testWidgets('Home opens Attendance without changing attendance locally', (
    tester,
  ) async {
    var openedAttendance = false;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          dashboardRepositoryProvider.overrideWithValue(
            _DashboardRepository(_unavailableDashboard),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: HomeScreen(onOpenAttendance: () => openedAttendance = true),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Status belum tersedia'), findsOneWidget);
    expect(find.text('Rp 45.360.000'), findsNothing);
    expect(find.text('May 2025'), findsNothing);
    await tester.tap(find.text('Buka Kehadiran'));
    expect(openedAttendance, isTrue);
    expect(find.text('Status belum tersedia'), findsOneWidget);
  });

  testWidgets('Attendance exposes server state without fake verification', (
    tester,
  ) async {
    final remote = _AttendanceRemote();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [attendanceDataSourceProvider.overrideWithValue(remote)],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const AttendanceScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Kebijakan absensi'), findsOneWidget);
    expect(find.text('Belum ada catatan'), findsOneWidget);
    expect(find.text('Catat masuk'), findsOneWidget);
    expect(find.text('GPS Active'), findsNothing);
    expect(find.text('Identity confirmed'), findsNothing);
    expect(find.text('Menara ACME, Jl. Sudirman 42'), findsNothing);
    expect(remote.clockCalls, 0);

    await tester.tap(find.text('Riwayat'));
    await tester.pumpAndSettle();
    expect(find.text('Riwayat absensi belum tersedia'), findsOneWidget);
    expect(remote.clockCalls, 0);
  });

  testWidgets('Requests and Calendar label unavailable integrations', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const RequestsScreen()),
    );
    expect(find.text('Pengajuan belum tersedia'), findsOneWidget);
    expect(find.text('Submit Request'), findsNothing);
    expect(find.byIcon(Icons.add_rounded), findsNothing);

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.light, home: const CalendarScreen()),
    );
    expect(find.text('Event kalender belum tersedia'), findsOneWidget);
    expect(find.text('Payroll Disbursement'), findsNothing);
    expect(find.text('Q2 Performance Review'), findsNothing);
  });

  testWidgets(
    'Profile hides example personal data and keeps controls working',
    (tester) async {
      var themeToggles = 0;
      var signOuts = 0;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            profileRepositoryProvider.overrideWithValue(
              const _ProfileRepository(_employee),
            ),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: ProfileScreen(
              isDarkMode: false,
              onThemeToggle: () => themeToggles++,
              onSignOut: () => signOuts++,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Authenticated User'), findsOneWidget);
      expect(find.text('MacBook Pro, iPhone 15 Pro'), findsNothing);
      expect(find.text('3 active certificates'), findsNothing);
      expect(find.text('Active Employee'), findsNothing);
      expect(find.text('Data personal lainnya belum tersedia'), findsOneWidget);

      await tester.tap(find.byType(Switch));
      expect(themeToggles, 1);
      await tester.ensureVisible(find.text('Sign Out'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sign Out'));
      expect(signOuts, 1);
    },
  );

  for (final themeMode in [ThemeMode.light, ThemeMode.dark]) {
    for (final textScale in [1.0, 2.0]) {
      testWidgets(
        'HRIS-005 controls work at 320px in ${themeMode.name} mode at ${textScale}x text',
        (tester) async {
          tester.view.physicalSize = const Size(320, 568);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          var themeToggles = 0;
          var signOuts = 0;
          final remote = _AttendanceRemote();

          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                dashboardRepositoryProvider.overrideWithValue(
                  _DashboardRepository(_unavailableDashboard),
                ),
                profileRepositoryProvider.overrideWithValue(
                  const _ProfileRepository(_employee),
                ),
                attendanceDataSourceProvider.overrideWithValue(remote),
              ],
              child: MaterialApp(
                theme: AppTheme.light,
                darkTheme: AppTheme.dark,
                themeMode: themeMode,
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: TextScaler.linear(textScale)),
                  child: child!,
                ),
                home: MainShell(
                  themeMode: themeMode,
                  onThemeToggle: () => themeToggles++,
                  onSignOut: () => signOuts++,
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          await tester.ensureVisible(find.text('Buka Kehadiran'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Buka Kehadiran'));
          await tester.pumpAndSettle();
          expect(
            tester
                .widget<NavigationBar>(find.byType(NavigationBar))
                .selectedIndex,
            1,
          );
          await tester.tap(find.text('Riwayat'));
          await tester.pumpAndSettle();
          expect(find.text('Riwayat absensi belum tersedia'), findsOneWidget);

          await tester.tap(find.byIcon(Icons.send_outlined));
          await tester.pumpAndSettle();
          expect(find.text('Pengajuan belum tersedia'), findsOneWidget);

          await tester.tap(find.byIcon(Icons.calendar_month_outlined));
          await tester.pumpAndSettle();
          await tester.tap(find.byIcon(Icons.chevron_left));
          await tester.tap(find.byIcon(Icons.chevron_right));
          await tester.tap(find.text('Today'));
          await tester.pumpAndSettle();
          final dayTarget = tester.getSize(
            find.byKey(ValueKey('calendar-day-${DateTime.now().day}')),
          );
          expect(dayTarget.width, greaterThanOrEqualTo(44));
          expect(dayTarget.height, greaterThanOrEqualTo(44));
          await tester.fling(
            find.byType(ListView).hitTestable(),
            const Offset(0, -500),
            1000,
          );
          await tester.pumpAndSettle();
          expect(find.text('Event kalender belum tersedia'), findsOneWidget);

          await tester.tap(find.byIcon(Icons.person_outline_rounded));
          await tester.pumpAndSettle();
          await tester.ensureVisible(find.byType(Switch));
          await tester.pumpAndSettle();
          await tester.tap(find.byType(Switch));
          expect(themeToggles, 1);
          await tester.ensureVisible(find.text('Sign Out'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Sign Out'));
          expect(signOuts, 1);
          expect(remote.clockCalls, 0);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}

const _unavailableDashboard = DashboardSnapshot(
  employee: DashboardEmployee(
    name: 'Authenticated User',
    initials: 'AU',
    avatarColorIndex: 0,
  ),
  leaveBalances: [],
  announcements: [],
);

const _employee = Employee(
  id: 'employee-1',
  name: 'Authenticated User',
  role: 'Employee',
  department: '',
  email: 'user@example.test',
  phone: '',
  location: '',
  joinDate: '',
  salary: 0,
  initials: 'AU',
  avatarColorIndex: 0,
);

class _DashboardRepository implements DashboardRepository {
  const _DashboardRepository(this.snapshot);

  final DashboardSnapshot snapshot;

  @override
  DashboardSnapshot get current => snapshot;

  @override
  Future<DashboardSnapshot> refresh() async => snapshot;
}

class _AttendanceRemote implements AttendanceRemoteDataSource {
  int clockCalls = 0;

  @override
  Future<AttendanceDto> getToday() async => AttendanceDto(
    id: '',
    employeeId: 'employee-1',
    checkedInAt: null,
    status: 'notStarted',
    latitude: 0,
    longitude: 0,
  );

  @override
  Future<AttendanceContext> getContext() async => const AttendanceContext(
    employeeId: 'employee-1',
    companyId: 'company-1',
    branchName: 'Kantor Pusat',
    allowedMethods: {AttendanceCaptureMethod.mobileGps},
    requiresLocation: true,
    requiresSelfie: false,
    isWorkingDay: true,
    allowHolidayAttendance: false,
    allowWeekendAttendance: false,
    warnings: [],
  );

  @override
  Future<AttendanceDto> clockIn(AttendanceCommand command) {
    clockCalls++;
    throw UnimplementedError();
  }

  @override
  Future<AttendanceDto> clockOut(AttendanceCommand command) {
    clockCalls++;
    throw UnimplementedError();
  }
}

class _ProfileRepository implements ProfileRepository {
  const _ProfileRepository(this.employee);

  final Employee employee;

  @override
  Employee get currentEmployee => employee;

  @override
  Future<Employee> refresh() async => employee;
}
