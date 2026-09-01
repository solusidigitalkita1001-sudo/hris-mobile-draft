import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hrm_app/features/calendar/data/datasources/calendar_local_datasource.dart';
import 'package:hrm_app/features/calendar/data/repositories/calendar_repository_impl.dart';
import 'package:hrm_app/features/calendar/domain/repositories/calendar_repository.dart';

final calendarLocalDataSourceProvider = Provider<CalendarLocalDataSource>(
  (ref) => DemoCalendarLocalDataSource(),
);

final calendarRepositoryProvider = Provider<CalendarRepository>(
  (ref) => CalendarRepositoryImpl(ref.watch(calendarLocalDataSourceProvider)),
);
