import 'package:flutter/material.dart';
import '../models/data.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen>
    with SingleTickerProviderStateMixin {
  bool _clockedIn = true;
  bool _selfieVerified = true;
  bool _gpsVerified = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkText : AppColors.lightText;
    final textSub = isDark ? AppColors.darkTextSub : AppColors.lightTextSub;
    final bgColor = isDark ? AppColors.darkBg : AppColors.lightBg;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          'Attendance',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: textPrimary,
          ),
        ),
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: textSub,
          indicatorColor: AppColors.primary,
          indicatorWeight: 2,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          tabs: const [Tab(text: 'Check In/Out'), Tab(text: 'History')],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCheckIn(isDark, textPrimary, textSub, cardColor, borderColor),
          _buildHistory(isDark, textPrimary, textSub, cardColor, borderColor),
        ],
      ),
    );
  }

  Widget _buildCheckIn(
    bool isDark,
    Color textPrimary,
    Color textSub,
    Color cardColor,
    Color borderColor,
  ) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // GPS map-like visual
        Container(
          height: 180,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: isDark ? const Color(0xFF1A2744) : const Color(0xFFEFF6FF),
            border: Border.all(color: borderColor),
          ),
          child: Stack(
            children: [
              // Grid pattern suggesting a map
              CustomPaint(
                size: const Size(double.infinity, 180),
                painter: _MapGridPainter(isDark: isDark),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.35),
                            blurRadius: 16,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Text(
                        'Menara ACME, Jl. Sudirman 42',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.gps_fixed, color: Colors.white, size: 12),
                      SizedBox(width: 4),
                      Text(
                        'GPS Active',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Verification status
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            children: [
              _VerificationRow(
                icon: Icons.location_on_rounded,
                label: 'GPS Location',
                sub: 'Within office radius (50m)',
                verified: _gpsVerified,
                isDark: isDark,
              ),
              Divider(height: 24, color: borderColor),
              _VerificationRow(
                icon: Icons.face_retouching_natural,
                label: 'Face Recognition',
                sub: _selfieVerified ? 'Identity confirmed' : 'Tap to verify',
                verified: _selfieVerified,
                isDark: isDark,
                onTap: () => setState(() => _selfieVerified = !_selfieVerified),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Today's summary
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              _TodayStat(label: 'Clock In', value: '08:02', color: AppColors.success, isDark: isDark),
              Container(width: 1, height: 40, color: borderColor),
              _TodayStat(label: 'Duration', value: '8h 34m', color: AppColors.primary, isDark: isDark),
              Container(width: 1, height: 40, color: borderColor),
              _TodayStat(
                label: 'Status',
                value: 'On Time',
                color: AppColors.success,
                isDark: isDark,
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Clock button
        GestureDetector(
          onTap: () => setState(() => _clockedIn = !_clockedIn),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: _clockedIn ? AppColors.danger : AppColors.success,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: (_clockedIn ? AppColors.danger : AppColors.success)
                      .withOpacity(0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _clockedIn
                      ? Icons.logout_rounded
                      : Icons.login_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _clockedIn ? 'Clock Out' : 'Clock In',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        Center(
          child: Text(
            'Friday, 20 June 2025 · 16:36 WIB',
            style: TextStyle(fontSize: 12, color: textSub),
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildHistory(
    bool isDark,
    Color textPrimary,
    Color textSub,
    Color cardColor,
    Color borderColor,
  ) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Week strip
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: AppData.thisWeek.map((r) {
            final isToday = r.day == 'Fri';
            return _DayStrip(
              day: r.day,
              date: r.date.split(' ').last,
              status: r.status,
              isToday: isToday,
              isDark: isDark,
            );
          }).toList(),
        ),

        const SizedBox(height: 24),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'This Week',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: textPrimary,
              ),
            ),
            Text(
              'Jun 16 – Jun 20',
              style: TextStyle(fontSize: 12, color: textSub),
            ),
          ],
        ),

        const SizedBox(height: 14),

        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            children: AppData.thisWeek.asMap().entries.map((entry) {
              final i = entry.key;
              final r = entry.value;
              final isLast = i == AppData.thisWeek.length - 1;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: _statusColor(r.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            _statusIcon(r.status),
                            size: 18,
                            color: _statusColor(r.status),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${r.day}, ${r.date}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                r.clockIn == '—'
                                    ? 'No record'
                                    : '${r.clockIn} → ${r.clockOut}  ·  ${r.hours}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: textSub,
                                ),
                              ),
                            ],
                          ),
                        ),
                        StatusBadge.attendance(r.status),
                      ],
                    ),
                  ),
                  if (!isLast) Divider(height: 1, color: borderColor),
                ],
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 20),

        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.calendar_month_rounded, size: 18),
          label: const Text('View Monthly Report'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  Color _statusColor(AttendanceStatus s) {
    switch (s) {
      case AttendanceStatus.onTime: return AppColors.success;
      case AttendanceStatus.late:   return AppColors.warning;
      case AttendanceStatus.absent: return AppColors.danger;
      case AttendanceStatus.leave:  return AppColors.info;
    }
  }

  IconData _statusIcon(AttendanceStatus s) {
    switch (s) {
      case AttendanceStatus.onTime: return Icons.check_circle_rounded;
      case AttendanceStatus.late:   return Icons.access_time_rounded;
      case AttendanceStatus.absent: return Icons.cancel_rounded;
      case AttendanceStatus.leave:  return Icons.beach_access_rounded;
    }
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _VerificationRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  final bool verified;
  final bool isDark;
  final VoidCallback? onTap;

  const _VerificationRow({
    required this.icon,
    required this.label,
    required this.sub,
    required this.verified,
    required this.isDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textPrimary = isDark ? AppColors.darkText : AppColors.lightText;
    final textSub = isDark ? AppColors.darkTextSub : AppColors.lightTextSub;

    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: verified
                  ? AppColors.success.withOpacity(0.1)
                  : AppColors.danger.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 18,
              color: verified ? AppColors.success : AppColors.danger,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: textPrimary)),
                Text(sub,
                    style: TextStyle(fontSize: 11, color: textSub)),
              ],
            ),
          ),
          Icon(
            verified ? Icons.verified_rounded : Icons.error_outline_rounded,
            color: verified ? AppColors.success : AppColors.danger,
            size: 20,
          ),
        ],
      ),
    );
  }
}

class _TodayStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _TodayStat({
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.darkTextSub : AppColors.lightTextSub,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _DayStrip extends StatelessWidget {
  final String day;
  final String date;
  final AttendanceStatus status;
  final bool isToday;
  final bool isDark;

  const _DayStrip({
    required this.day,
    required this.date,
    required this.status,
    required this.isToday,
    required this.isDark,
  });

  Color get _statusColor {
    switch (status) {
      case AttendanceStatus.onTime: return AppColors.success;
      case AttendanceStatus.late:   return AppColors.warning;
      case AttendanceStatus.absent: return AppColors.danger;
      case AttendanceStatus.leave:  return AppColors.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: isToday
            ? AppColors.primary
            : (isDark ? AppColors.darkCard : AppColors.lightSurface),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isToday
              ? AppColors.primary
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
      ),
      child: Column(
        children: [
          Text(
            day,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isToday
                  ? Colors.white.withOpacity(0.8)
                  : (isDark ? AppColors.darkTextSub : AppColors.lightTextSub),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            date,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isToday
                  ? Colors.white
                  : (isDark ? AppColors.darkText : AppColors.lightText),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: isToday ? Colors.white : _statusColor,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

// Simple map grid painter
class _MapGridPainter extends CustomPainter {
  final bool isDark;
  _MapGridPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isDark ? Colors.white : Colors.black).withOpacity(0.04)
      ..strokeWidth = 1;
    const spacing = 30.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    // A few thicker "road" lines
    final roadPaint = Paint()
      ..color = (isDark ? Colors.white : AppColors.primary).withOpacity(0.08)
      ..strokeWidth = 6;
    canvas.drawLine(Offset(size.width * 0.3, 0), Offset(size.width * 0.3, size.height), roadPaint);
    canvas.drawLine(Offset(0, size.height * 0.5), Offset(size.width, size.height * 0.5), roadPaint);
  }

  @override
  bool shouldRepaint(_MapGridPainter old) => false;
}
