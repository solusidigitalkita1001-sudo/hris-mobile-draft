import 'package:dio/dio.dart';
import 'package:hrm_app/core/network/api_envelope.dart';
import 'package:hrm_app/core/network/request_context.dart';
import 'package:hrm_app/features/dashboard/domain/entities/dashboard_snapshot.dart';

abstract interface class DashboardRemoteDataSource {
  Future<DashboardSnapshot> fetch(
    RequestContext context,
    DashboardSnapshot fallback,
  );
}

class DioDashboardRemoteDataSource implements DashboardRemoteDataSource {
  const DioDashboardRemoteDataSource(this._dio);

  final Dio _dio;

  @override
  Future<DashboardSnapshot> fetch(
    RequestContext context,
    DashboardSnapshot fallback,
  ) async {
    final employeeId = context.employeeId;
    final companyId = context.activeCompanyId;
    if (employeeId == null || companyId == null) {
      return DashboardSnapshot(
        employee: _employee(context, fallback.employee),
        leaveBalances: const [],
        announcements: const [],
      );
    }

    final now = DateTime.now();
    final responses = await Future.wait<Object?>([
      _safeGet('/leave/balances/employee', {'employeeId': employeeId}),
      _safeGet('/attendance/summary', {
        'companyId': companyId,
        'month': now.month,
        'year': now.year,
      }),
      _safeGet('/attendance', {
        'companyId': companyId,
        'employeeId': employeeId,
        'month': now.month,
      }),
      _safeGet('/notifications', {'limit': 3}),
    ]);

    final balances = _leaveBalances(responses[0]);
    final attendance = _todayAttendance(responses[2], now);
    final notifications = _announcements(responses[3]);
    return DashboardSnapshot(
      employee: _employee(context, fallback.employee),
      leaveBalances: balances,
      announcements: notifications,
      attendance: attendance,
      monthlySummary: _summary(responses[1], balances, attendance),
      leaveBalancesAvailable: responses[0] != null,
      monthlySummaryAvailable: responses[1] != null,
      attendanceAvailable: responses[2] != null,
      announcementsAvailable: responses[3] != null,
    );
  }

  Future<Object?> _safeGet(String path, Map<String, Object?> query) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: query,
      );
      return ApiEnvelope.fromJson(response.data ?? const {}).data;
    } on DioException {
      return null;
    } on FormatException {
      return null;
    }
  }

  DashboardEmployee _employee(
    RequestContext context,
    DashboardEmployee fallback,
  ) {
    final name = context.displayName?.trim();
    final emailName = context.email?.split('@').first.trim();
    final effectiveName = name != null && name.isNotEmpty
        ? name
        : emailName != null && emailName.isNotEmpty
        ? emailName
        : fallback.name;
    return DashboardEmployee(
      name: effectiveName,
      initials: _initials(effectiveName),
      avatarColorIndex: effectiveName.hashCode.abs() % 4,
    );
  }

  List<LeaveBalance> _leaveBalances(Object? data) {
    final list = _asList(data, const ['balances', 'items', 'leaveBalances']);
    return list.indexed
        .map((entry) {
          final (index, item) = entry;
          final typeObject = item['leaveType'] ?? item['type'];
          final type = typeObject is Map
              ? _text(typeObject, const ['name', 'label', 'code'])
              : typeObject?.toString();
          final total = _integer(item, const [
            'quota',
            'total',
            'entitled',
            'allocated',
          ]);
          final remaining = _integer(item, const [
            'remaining',
            'balance',
            'available',
            'remainingDays',
          ], fallback: total);
          final used = _integer(item, const [
            'used',
            'taken',
            'usedDays',
          ], fallback: (total - remaining).clamp(0, total));
          return LeaveBalance(
            type: type ?? 'Leave',
            total: total,
            used: used,
            colorIndex: index % 4,
          );
        })
        .toList(growable: false);
  }

  DashboardAttendance _todayAttendance(Object? data, DateTime now) {
    final records = _asList(data, const ['items', 'records', 'attendances']);
    Map<String, dynamic>? today;
    for (final record in records) {
      final raw = record['date'] ?? record['checkIn'] ?? record['checkedInAt'];
      final date = raw is String ? DateTime.tryParse(raw)?.toLocal() : null;
      if (date != null &&
          date.year == now.year &&
          date.month == now.month &&
          date.day == now.day) {
        today = record;
        break;
      }
    }
    if (today == null) return const DashboardAttendance();
    final checkIn = _date(today, const [
      'checkIn',
      'checkedInAt',
      'checked_in_at',
    ]);
    final checkOut = _date(today, const [
      'checkOut',
      'checkedOutAt',
      'checked_out_at',
    ]);
    final end = checkOut ?? now;
    final minutes = checkIn == null
        ? 0
        : end.difference(checkIn).inMinutes.clamp(0, 1440);
    return DashboardAttendance(
      isClockedIn: checkIn != null && checkOut == null,
      clockInTime: checkIn,
      workingMinutes: minutes,
    );
  }

  MonthlySummary _summary(
    Object? data,
    List<LeaveBalance> balances,
    DashboardAttendance today,
  ) {
    final map = _asMap(data);
    final present = _integer(map, const [
      'present',
      'presentDays',
      'totalPresent',
    ]);
    final working = _integer(map, const ['workingDays', 'totalWorkingDays']);
    final percentage = _integer(
      map,
      const ['attendancePercentage', 'percentage', 'attendanceRate'],
      fallback: working == 0
          ? (today.clockInTime == null ? 0 : 100)
          : ((present / working) * 100).round(),
    );
    final overtime = _number(map, const [
      'overtimeHours',
      'totalOvertimeHours',
      'overtime',
    ]);
    return MonthlySummary(
      attendancePercentage: percentage.clamp(0, 100),
      lateCount: _integer(map, const ['late', 'lateCount', 'totalLate']),
      overtimeHours: overtime,
      remainingLeave: balances.fold<int>(
        0,
        (sum, item) => sum + (item.total - item.used).clamp(0, item.total),
      ),
    );
  }

  List<Announcement> _announcements(Object? data) {
    final items = _asList(data, const ['items', 'notifications']);
    return items
        .take(3)
        .map((item) {
          final created = _date(item, const ['createdAt', 'created_at']);
          return Announcement(
            title: _text(item, const ['title', 'subject']) ?? 'Notification',
            body: _text(item, const ['message', 'body', 'content']) ?? '',
            time: _relativeTime(created),
            category: _text(item, const ['category', 'type']) ?? 'HRMS',
          );
        })
        .toList(growable: false);
  }
}

Map<String, dynamic> _asMap(Object? data) {
  if (data is Map<String, dynamic>) return data;
  return const {};
}

List<Map<String, dynamic>> _asList(Object? data, List<String> keys) {
  Object? raw = data;
  if (raw is Map<String, dynamic>) {
    final map = raw;
    for (final key in keys) {
      if (map[key] is List) {
        raw = map[key];
        break;
      }
    }
  }
  if (raw is! List) return const [];
  return raw.whereType<Map<String, dynamic>>().toList(growable: false);
}

String? _text(Map<dynamic, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value is String && value.trim().isNotEmpty) return value.trim();
  }
  return null;
}

int _integer(Map<dynamic, dynamic> map, List<String> keys, {int fallback = 0}) {
  for (final key in keys) {
    final value = map[key];
    if (value is num) return value.round();
    final parsed = int.tryParse('$value');
    if (parsed != null) return parsed;
  }
  return fallback;
}

num _number(Map<dynamic, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value is num) return value;
    final parsed = num.tryParse('$value');
    if (parsed != null) return parsed;
  }
  return 0;
}

DateTime? _date(Map<dynamic, dynamic> map, List<String> keys) {
  final value = _text(map, keys);
  return value == null ? null : DateTime.tryParse(value)?.toLocal();
}

String _initials(String name) {
  final words = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty);
  return words.take(2).map((word) => word[0].toUpperCase()).join();
}

String _relativeTime(DateTime? date) {
  if (date == null) return '';
  final difference = DateTime.now().difference(date);
  if (difference.inMinutes < 60) {
    return '${difference.inMinutes.clamp(0, 59)} min ago';
  }
  if (difference.inHours < 24) return '${difference.inHours} hours ago';
  return '${difference.inDays} days ago';
}
