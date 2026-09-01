import 'package:hrm_app/features/calendar/data/datasources/calendar_local_datasource.dart';
import 'package:hrm_app/features/calendar/domain/entities/calendar_data.dart';
import 'package:hrm_app/features/calendar/domain/repositories/calendar_repository.dart';

class CalendarRepositoryImpl implements CalendarRepository {
  CalendarRepositoryImpl(this._local);
  final CalendarLocalDataSource _local;

  @override
  CalendarData get current => _local.read();

  @override
  Future<CalendarData> loadMonth(int year, int month) async => _local.read();
}
