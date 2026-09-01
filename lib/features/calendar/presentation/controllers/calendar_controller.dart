import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hrm_app/features/calendar/calendar_dependencies.dart';
import 'package:hrm_app/features/calendar/domain/entities/calendar_data.dart';

class CalendarController extends Notifier<CalendarData> {
  @override
  CalendarData build() => ref.read(calendarRepositoryProvider).current;

  Future<void> loadMonth(int year, int month) async {
    state = await ref.read(calendarRepositoryProvider).loadMonth(year, month);
  }
}
