import 'package:flutter/material.dart';

import 'package:hrm_app/core/theme/app_theme.dart';
import 'package:hrm_app/core/widgets/common.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _displayed = DateTime(
    DateTime.now().year,
    DateTime.now().month,
  );
  late int _selectedDay = DateTime.now().day;

  static const _monthNames = [
    '',
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  int get _daysInMonth =>
      DateTime(_displayed.year, _displayed.month + 1, 0).day;

  int get _firstWeekday =>
      DateTime(_displayed.year, _displayed.month, 1).weekday % 7;

  void _showToday() {
    final today = DateTime.now();
    setState(() {
      _displayed = DateTime(today.year, today.month);
      _selectedDay = today.day;
    });
  }

  void _moveMonth(int offset) {
    final next = DateTime(_displayed.year, _displayed.month + offset);
    final lastDay = DateTime(next.year, next.month + 1, 0).day;
    setState(() {
      _displayed = next;
      _selectedDay = _selectedDay.clamp(1, lastDay);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkText : AppColors.lightText;
    final textSub = isDark ? AppColors.darkTextSub : AppColors.lightTextSub;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        title: Text(
          'Calendar',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: textPrimary,
          ),
        ),
        backgroundColor: surface,
        actions: [
          TextButton(onPressed: _showToday, child: const Text('Today')),
        ],
      ),
      body: ListView(
        children: [
          Container(
            color: surface,
            padding: EdgeInsets.fromLTRB(
              MediaQuery.sizeOf(context).width < 360 ? 6 : 20,
              16,
              MediaQuery.sizeOf(context).width < 360 ? 6 : 20,
              20,
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      tooltip: 'Bulan sebelumnya',
                      onPressed: () => _moveMonth(-1),
                      icon: Icon(Icons.chevron_left, color: textSub),
                    ),
                    Expanded(
                      child: Text(
                        '${_monthNames[_displayed.month]} ${_displayed.year}',
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: textPrimary,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Bulan berikutnya',
                      onPressed: () => _moveMonth(1),
                      icon: Icon(Icons.chevron_right, color: textSub),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                      .map(
                        (day) => Expanded(
                          child: Center(
                            child: Text(
                              day,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: textSub,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 8),
                _buildGrid(isDark, textPrimary),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(20),
            child: UnavailableFeatureCard(
              title: 'Event kalender belum tersedia',
              message:
                  'Hari libur, jadwal kerja, cuti, dan agenda akan ditampilkan setelah integrasi kalender server selesai.',
              icon: Icons.event_busy_outlined,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(bool isDark, Color textPrimary) {
    final totalCells = _firstWeekday + _daysInMonth;
    final rows = (totalCells / 7).ceil();
    final today = DateTime.now();

    return Column(
      children: List.generate(rows, (row) {
        return Row(
          children: List.generate(7, (column) {
            final day = row * 7 + column - _firstWeekday + 1;
            final valid = day >= 1 && day <= _daysInMonth;
            final selected = valid && day == _selectedDay;
            final isToday =
                valid &&
                day == today.day &&
                _displayed.month == today.month &&
                _displayed.year == today.year;
            return Expanded(
              child: Semantics(
                button: valid,
                selected: selected,
                label: valid
                    ? '$day ${_monthNames[_displayed.month]} ${_displayed.year}'
                    : null,
                child: InkWell(
                  key: valid ? ValueKey('calendar-day-$day') : null,
                  onTap: valid
                      ? () => setState(() => _selectedDay = day)
                      : null,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 44,
                    margin: const EdgeInsets.all(2),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primary
                          : isToday
                          ? AppColors.primary.withValues(alpha: 0.12)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: valid
                        ? Text(
                            '$day',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: selected || isToday
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: selected
                                  ? Colors.white
                                  : column == 0 || column == 6
                                  ? (isDark
                                        ? AppColors.darkTextSub
                                        : AppColors.lightTextSub)
                                  : textPrimary,
                            ),
                          )
                        : null,
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
