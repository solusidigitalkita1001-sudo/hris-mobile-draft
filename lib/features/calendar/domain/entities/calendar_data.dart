enum CalendarEventTone { danger, primary, purple, success, warning, info }

class CalendarEvent {
  const CalendarEvent(this.label, this.tone);
  final String label;
  final CalendarEventTone tone;
}

class CalendarData {
  const CalendarData({required this.focusedDate, required this.eventsByDay});

  final DateTime focusedDate;
  final Map<int, List<CalendarEvent>> eventsByDay;
}
