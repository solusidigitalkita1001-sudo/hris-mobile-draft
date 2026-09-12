import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hrm_app/core/security/session_lifecycle.dart';
import 'package:hrm_app/features/calendar/calendar_dependencies.dart';
import 'package:hrm_app/features/calendar/domain/entities/calendar_data.dart';

class CalendarController extends Notifier<CalendarData> {
  late FeatureSession _session;
  @override
  CalendarData build() {
    _session = ref.watch(featureSessionProvider);
    return ref.watch(calendarRepositoryProvider).current;
  }

  Future<void> loadMonth(int year, int month) async {
    final session = _session;
    if (!session.isCurrent) return;
    final result = await ref
        .read(calendarRepositoryProvider)
        .loadMonth(year, month);
    if (session.isCurrent) state = result;
  }
}
