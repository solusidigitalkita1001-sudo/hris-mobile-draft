// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hrm_app/core/config/app_config.dart';
import 'package:hrm_app/core/network/dio_client.dart';
import 'package:hrm_app/core/security/token_storage.dart';
import 'package:hrm_app/core/storage/preferences.dart';
import 'package:hrm_app/core/theme/app_theme.dart';
import 'package:hrm_app/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('renders login when no session exists', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    const config = AppConfig(
      baseUrl: 'https://example.test',
      connectTimeout: Duration(seconds: 1),
      receiveTimeout: Duration(seconds: 1),
      enableNetworkLogs: false,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          appConfigProvider.overrideWithValue(config),
          tokenStorageProvider.overrideWithValue(_FakeTokenStorage()),
        ],
        child: const HrmsApp(),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.text('Masuk'), findsNWidgets(2));
    expect(find.text('Alamat email'), findsOneWidget);
    expect(find.text('HRMS Enterprise'), findsNothing);
  });

  testWidgets('renders the existing HRMS shell without changing its UI', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    const config = AppConfig(
      baseUrl: 'https://example.test',
      connectTimeout: Duration(seconds: 1),
      receiveTimeout: Duration(seconds: 1),
      enableNetworkLogs: false,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          appConfigProvider.overrideWithValue(config),
          tokenStorageProvider.overrideWithValue(_FakeTokenStorage()),
        ],
        child: const MaterialApp(
          home: MainShell(
            themeMode: ThemeMode.light,
            onThemeToggle: _noop,
            onSignOut: _noop,
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Attendance'), findsOneWidget);
  });

  testWidgets('renders login inputs with dark-mode colors', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({'theme_mode': 'dark'});
    final preferences = await SharedPreferences.getInstance();
    const config = AppConfig(
      baseUrl: 'https://example.test',
      connectTimeout: Duration(seconds: 1),
      receiveTimeout: Duration(seconds: 1),
      enableNetworkLogs: false,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(preferences),
          appConfigProvider.overrideWithValue(config),
          tokenStorageProvider.overrideWithValue(_FakeTokenStorage()),
        ],
        child: const HrmsApp(),
      ),
    );
    await tester.pumpAndSettle();

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, AppColors.darkBg);
    final inputs = tester.widgetList<EditableText>(find.byType(EditableText));
    expect(inputs, hasLength(2));
    for (final input in inputs) {
      expect(input.style.color, AppColors.darkText);
    }
  });
}

void _noop() {}

class _FakeTokenStorage implements TokenStorage {
  String? accessToken;
  String? refreshToken;
  String? cookieHeader;
  String? csrfToken;
  Map<String, dynamic>? session;
  Map<String, dynamic>? cookieState;

  @override
  Future<void> clear() async {
    accessToken = null;
    refreshToken = null;
    cookieHeader = null;
    csrfToken = null;
    session = null;
    cookieState = null;
  }

  @override
  Future<String?> readAccessToken() async => accessToken;

  @override
  Future<String?> readRefreshToken() async => refreshToken;

  @override
  Future<String?> readCookieHeader() async => cookieHeader;

  @override
  Future<String?> readCsrfToken() async => csrfToken;

  @override
  Future<Map<String, dynamic>?> readCookieState() async => cookieState;

  @override
  Future<Map<String, dynamic>?> readSession() async => session;

  @override
  Future<void> saveSession(Map<String, dynamic> value) async => session = value;

  @override
  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    this.accessToken = accessToken;
    this.refreshToken = refreshToken;
  }

  @override
  Future<void> saveCookieSession({
    required String cookieHeader,
    required String csrfToken,
  }) async {
    this.cookieHeader = cookieHeader;
    this.csrfToken = csrfToken;
  }

  @override
  Future<void> saveCookieState({
    required Map<String, dynamic> state,
    String? cookieHeader,
    String? csrfToken,
  }) async {
    cookieState = state;
    this.cookieHeader = cookieHeader;
    this.csrfToken = csrfToken;
  }
}
