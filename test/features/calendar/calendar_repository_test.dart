import 'package:flutter_test/flutter_test.dart';
import 'package:hrm_app/features/calendar/data/datasources/calendar_local_datasource.dart';
import 'package:hrm_app/features/calendar/data/repositories/calendar_repository_impl.dart';

void main() {
  test('returns calendar events through the repository contract', () {
    final repository = CalendarRepositoryImpl(DemoCalendarLocalDataSource());

    expect(repository.current.focusedDate, DateTime(2025, 6, 20));
    expect(repository.current.eventsByDay[20], hasLength(2));
  });
}
