import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  int _selectedDay = 20;
  int _displayMonth = 6;
  int _displayYear = 2025;

  // Event data for June 2025
  final Map<int, List<_CalEvent>> _events = {
    5:  [_CalEvent('Public Holiday — Eid Al-Adha', AppColors.danger)],
    10: [_CalEvent('Dewi — Annual Leave', AppColors.primary)],
    11: [_CalEvent('Dewi — Annual Leave', AppColors.primary)],
    15: [_CalEvent('Team Offsite (Engineering)', AppColors.purple)],
    20: [
      _CalEvent('All-Hands Meeting 10:00', AppColors.success),
      _CalEvent('Putri — Annual Leave', AppColors.primary),
    ],
    21: [_CalEvent('Putri — Annual Leave', AppColors.primary)],
    22: [_CalEvent('Putri — Annual Leave', AppColors.primary)],
    25: [_CalEvent('Payroll Disbursement', AppColors.success)],
    27: [_CalEvent('Q2 Performance Review', AppColors.warning)],
    30: [_CalEvent('Month-End HR Reports Due', AppColors.info)],
  };

  String get _monthName {
    const names = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return names[_displayMonth];
  }

  int get _daysInMonth {
    return DateTime(_displayYear, _displayMonth + 1, 0).day;
  }

  int get _firstWeekday {
    // 0=Mon in Dart; we want 0=Sun
    final wd = DateTime(_displayYear, _displayMonth, 1).weekday;
    return wd % 7;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkText : AppColors.lightText;
    final textSub = isDark ? AppColors.darkTextSub : AppColors.lightTextSub;
    final bgColor = isDark ? AppColors.darkBg : AppColors.lightBg;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final selectedEvents = _events[_selectedDay] ?? [];

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'Calendar',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: textPrimary,
          ),
        ),
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        actions: [
          TextButton(
            onPressed: () => setState(() {
              _selectedDay = 20;
              _displayMonth = 6;
              _displayYear = 2025;
            }),
            child: const Text('Today',
                style: TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Calendar header
          Container(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              children: [
                // Month navigation
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => setState(() {
                        if (_displayMonth == 1) {
                          _displayMonth = 12;
                          _displayYear--;
                        } else {
                          _displayMonth--;
                        }
                      }),
                      icon: Icon(Icons.chevron_left, color: textSub),
                    ),
                    Text(
                      '$_monthName $_displayYear',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() {
                        if (_displayMonth == 12) {
                          _displayMonth = 1;
                          _displayYear++;
                        } else {
                          _displayMonth++;
                        }
                      }),
                      icon: Icon(Icons.chevron_right, color: textSub),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Day-of-week headers
                Row(
                  children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                      .map((d) => Expanded(
                            child: Center(
                              child: Text(
                                d,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                  color: textSub,
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ),

                const SizedBox(height: 8),

                // Calendar grid
                _buildGrid(isDark, textPrimary, textSub, borderColor),
              ],
            ),
          ),

          // Legend
          Container(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Row(
              children: [
                _LegendDot(color: AppColors.danger, label: 'Holiday'),
                const SizedBox(width: 16),
                _LegendDot(color: AppColors.primary, label: 'Leave'),
                const SizedBox(width: 16),
                _LegendDot(color: AppColors.success, label: 'Event'),
                const SizedBox(width: 16),
                _LegendDot(color: AppColors.warning, label: 'Review'),
              ],
            ),
          ),

          const Divider(height: 1),

          // Events list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  selectedEvents.isEmpty
                      ? 'No events on ${_monthName.substring(0, 3)} $_selectedDay'
                      : '${_monthName.substring(0, 3)} $_selectedDay — ${selectedEvents.length} event${selectedEvents.length > 1 ? "s" : ""}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textSub,
                  ),
                ),
                const SizedBox(height: 12),
                if (selectedEvents.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Column(
                        children: [
                          Icon(Icons.event_available_rounded,
                              size: 44, color: textSub.withOpacity(0.3)),
                          const SizedBox(height: 12),
                          Text('Clear day',
                              style: TextStyle(
                                  color: textSub.withOpacity(0.6),
                                  fontSize: 14)),
                        ],
                      ),
                    ),
                  )
                else
                  ...selectedEvents.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: borderColor),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 4,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: e.color,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  e.label,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: textPrimary,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: e.color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.chevron_right,
                                    size: 16, color: e.color),
                              ),
                            ],
                          ),
                        ),
                      )),

                const SizedBox(height: 16),
                SectionHeader(
                  title: 'Upcoming',
                  actionLabel: 'All',
                  onAction: () {},
                ),
                const SizedBox(height: 12),
                ...([
                  (25, 'Payroll Disbursement', AppColors.success),
                  (27, 'Q2 Performance Review', AppColors.warning),
                  (30, 'Month-End HR Reports Due', AppColors.info),
                ].map((ev) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: AppCard(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: ev.$3.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${ev.$1}',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: ev.$3,
                                    ),
                                  ),
                                  Text(
                                    'Jun',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      color: ev.$3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                ev.$2,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(
      bool isDark, Color textPrimary, Color textSub, Color borderColor) {
    final totalCells = _firstWeekday + _daysInMonth;
    final rows = (totalCells / 7).ceil();

    return Column(
      children: List.generate(rows, (row) {
        return Row(
          children: List.generate(7, (col) {
            final cellIndex = row * 7 + col;
            final day = cellIndex - _firstWeekday + 1;
            final isValid = day >= 1 && day <= _daysInMonth;
            final isSelected = isValid && day == _selectedDay;
            final isToday = isValid && day == 20 && _displayMonth == 6;
            final isWeekend = col == 0 || col == 6;
            final hasEvents = isValid && _events.containsKey(day);

            return Expanded(
              child: GestureDetector(
                onTap: isValid ? () => setState(() => _selectedDay = day) : null,
                child: Container(
                  margin: const EdgeInsets.all(2),
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : isToday
                            ? AppColors.primary.withOpacity(0.12)
                            : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isValid)
                        Text(
                          '$day',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected || isToday
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: isSelected
                                ? Colors.white
                                : isWeekend
                                    ? (isDark
                                        ? AppColors.darkTextSub
                                        : AppColors.lightTextSub)
                                    : textPrimary,
                          ),
                        ),
                      if (isValid && hasEvents)
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white
                                : _events[day]!.first.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      }),
    );
  }
}

class _CalEvent {
  final String label;
  final Color color;
  const _CalEvent(this.label, this.color);
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? AppColors.darkTextSub : AppColors.lightTextSub,
          ),
        ),
      ],
    );
  }
}
