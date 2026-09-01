import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hrm_app/features/calendar/domain/entities/calendar_data.dart';
import 'package:hrm_app/features/calendar/presentation/controllers/calendar_controller.dart';

final calendarControllerProvider =
    NotifierProvider<CalendarController, CalendarData>(CalendarController.new);
