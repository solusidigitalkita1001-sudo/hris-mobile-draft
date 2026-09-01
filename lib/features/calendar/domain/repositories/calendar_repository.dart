import 'package:hrm_app/features/calendar/domain/entities/calendar_data.dart';

abstract interface class CalendarRepository {
  CalendarData get current;
  Future<CalendarData> loadMonth(int year, int month);
}
