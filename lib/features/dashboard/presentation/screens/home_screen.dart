import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hrm_app/core/theme/app_theme.dart';
import 'package:hrm_app/core/widgets/common.dart';
import 'package:hrm_app/features/dashboard/dashboard_providers.dart';
import 'package:hrm_app/features/dashboard/domain/entities/dashboard_snapshot.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, required this.onOpenAttendance});

  final VoidCallback onOpenAttendance;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  DashboardSnapshot get _dashboard => ref.watch(dashboardControllerProvider);

  bool get _clockedIn => _dashboard.attendance.isClockedIn;

  String get _clockInTime {
    final value = _dashboard.attendance.clockInTime;
    if (value == null) return '--:--';
    return '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
  }

  String get _workingTime {
    final minutes = _dashboard.attendance.workingMinutes;
    return '${minutes ~/ 60}h ${minutes % 60}m';
  }

  String _greeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";

    return "Good Evening";
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final textSub = isDark ? AppColors.darkTextSub : AppColors.lightTextSub;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,

      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,

          onRefresh: () =>
              ref.read(dashboardControllerProvider.notifier).refresh(),

          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),

            children: [
              const SizedBox(height: 20),

              //---------------------------------------------------
              // HEADER
              //---------------------------------------------------
              LayoutBuilder(
                builder: (_, constraints) {
                  final compact = constraints.maxWidth < 380;

                  return Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(
                              "${_greeting()},",
                              style: TextStyle(
                                fontSize: compact ? 13 : 14,
                                color: textSub,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              _dashboard.employee.name,

                              maxLines: 1,

                              overflow: TextOverflow.ellipsis,

                              style: TextStyle(
                                fontSize: compact ? 22 : 24,

                                fontWeight: FontWeight.bold,

                                color: isDark
                                    ? AppColors.darkText
                                    : AppColors.lightText,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 16),

                      AvatarWidget(
                        initials: _dashboard.employee.initials,
                        colorIndex: _dashboard.employee.avatarColorIndex,
                        size: compact ? 46 : 52,
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 24),

              //---------------------------------------------------
              // ATTENDANCE CARD
              //---------------------------------------------------
              Container(
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,

                    end: Alignment.bottomRight,

                    colors: [Color(0xff1D4ED8), Color(0xff2563EB)],
                  ),

                  borderRadius: BorderRadius.circular(24),
                ),

                child: LayoutBuilder(
                  builder: (_, constraints) {
                    final compact = constraints.maxWidth < 350;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  const Text(
                                    "Today's Attendance",

                                    style: TextStyle(
                                      color: Colors.white,

                                      fontSize: 12,

                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  Text(
                                    !_dashboard.attendanceAvailable
                                        ? 'Status belum tersedia'
                                        : _clockedIn
                                        ? "Clocked In • $_clockInTime"
                                        : "Not Clocked In",

                                    style: TextStyle(
                                      color: Colors.white,

                                      fontSize: compact ? 16 : 18,

                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    !_dashboard.attendanceAvailable
                                        ? 'Buka Kehadiran untuk melihat catatan server'
                                        : _clockedIn
                                        ? "Working Time : $_workingTime"
                                        : "Belum ada catatan masuk hari ini",

                                    style: const TextStyle(
                                      color: Colors.white,

                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 12),

                            Container(
                              width: compact ? 48 : 56,

                              height: compact ? 48 : 56,

                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: .15),

                                shape: BoxShape.circle,
                              ),

                              child: Icon(
                                Icons.fingerprint,

                                color: Colors.white,

                                size: compact ? 26 : 30,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 22),

                        SizedBox(
                          width: double.infinity,

                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.white,

                              foregroundColor: AppColors.primary,

                              padding: const EdgeInsets.symmetric(vertical: 14),

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),

                            onPressed: widget.onOpenAttendance,

                            child: const Text(
                              'Buka Kehadiran',

                              style: TextStyle(
                                fontWeight: FontWeight.bold,

                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 28),

              const SizedBox(height: 28),

              //---------------------------------------------------
              // LEAVE BALANCE
              //---------------------------------------------------
              const SectionHeader(title: "Leave Balance"),

              const SizedBox(height: 16),

              if (!_dashboard.leaveBalancesAvailable)
                const UnavailableFeatureCard(
                  title: 'Saldo cuti belum tersedia',
                  message:
                      'Saldo akan ditampilkan setelah data berhasil dimuat dari server.',
                  icon: Icons.beach_access_outlined,
                )
              else if (_dashboard.leaveBalances.isEmpty)
                const AppCard(
                  child: Text('Server tidak mengembalikan saldo cuti.'),
                )
              else
                LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;

                    int crossAxisCount = 2;

                    if (width >= 1200) {
                      crossAxisCount = 4;
                    } else if (width >= 700) {
                      crossAxisCount = 3;
                    }

                    final childAspectRatio = width < 400
                        ? .82
                        : width < 700
                        ? .92
                        : 1.02;

                    return GridView.builder(
                      shrinkWrap: true,

                      physics: const NeverScrollableScrollPhysics(),

                      itemCount: _dashboard.leaveBalances.length,

                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,

                        crossAxisSpacing: 16,

                        mainAxisSpacing: 16,

                        childAspectRatio: childAspectRatio,
                      ),

                      itemBuilder: (_, index) {
                        return LeaveBalanceCard(
                          type: _dashboard.leaveBalances[index].type,
                          total: _dashboard.leaveBalances[index].total,
                          used: _dashboard.leaveBalances[index].used,
                          colorIndex:
                              _dashboard.leaveBalances[index].colorIndex,
                        );
                      },
                    );
                  },
                ),

              const SizedBox(height: 30),

              //---------------------------------------------------
              // KPI SUMMARY
              //---------------------------------------------------
              const SectionHeader(title: "Monthly Summary"),

              const SizedBox(height: 16),

              if (!_dashboard.monthlySummaryAvailable)
                const UnavailableFeatureCard(
                  title: 'Ringkasan bulanan belum tersedia',
                  message:
                      'Ringkasan akan ditampilkan setelah data berhasil dimuat dari server.',
                  icon: Icons.insights_outlined,
                )
              else
                LayoutBuilder(
                  builder: (_, constraints) {
                    final width = constraints.maxWidth;

                    int count = 2;

                    if (width > 1000) {
                      count = 4;
                    } else if (width > 700) {
                      count = 3;
                    }

                    return GridView.count(
                      crossAxisCount: count,

                      shrinkWrap: true,

                      physics: const NeverScrollableScrollPhysics(),

                      crossAxisSpacing: 16,

                      mainAxisSpacing: 16,

                      childAspectRatio: 1.18,

                      children: [
                        KpiCard(
                          label: "Attendance",
                          value:
                              "${_dashboard.monthlySummary.attendancePercentage}%",
                          sub: "This Month",
                          accentColor: AppColors.success,
                          icon: Icons.check_circle,
                        ),

                        KpiCard(
                          label: "Late",
                          value: "${_dashboard.monthlySummary.lateCount}",
                          sub: "Occurrences",
                          accentColor: AppColors.warning,
                          icon: Icons.access_time,
                        ),

                        KpiCard(
                          label: "Overtime",
                          value: "${_dashboard.monthlySummary.overtimeHours}h",
                          sub: "This Month",
                          accentColor: AppColors.primary,
                          icon: Icons.schedule,
                        ),

                        KpiCard(
                          label: "Leave",
                          value: "${_dashboard.monthlySummary.remainingLeave}",
                          sub: "Remaining",
                          accentColor: AppColors.danger,
                          icon: Icons.beach_access,
                        ),
                      ],
                    );
                  },
                ),

              const SizedBox(height: 30),

              const SectionHeader(title: "Latest Payslip"),

              const SizedBox(height: 16),

              const UnavailableFeatureCard(
                title: 'Slip gaji belum tersedia',
                message:
                    'Nominal dan riwayat slip gaji akan ditampilkan setelah integrasi payroll selesai.',
                icon: Icons.account_balance_wallet_outlined,
              ),

              const SizedBox(height: 30),

              //---------------------------------------------------
              // ANNOUNCEMENT
              //---------------------------------------------------
              const SectionHeader(title: "Announcements"),

              const SizedBox(height: 16),

              if (!_dashboard.announcementsAvailable)
                const UnavailableFeatureCard(
                  title: 'Pengumuman belum tersedia',
                  message:
                      'Pengumuman akan ditampilkan setelah data berhasil dimuat dari server.',
                  icon: Icons.campaign_outlined,
                )
              else if (_dashboard.announcements.isEmpty)
                const AppCard(child: Text('Belum ada pengumuman dari server.'))
              else
                ..._dashboard.announcements.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),

                    child: AppCard(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Container(
                            width: 10,
                            height: 10,

                            margin: const EdgeInsets.only(top: 6, right: 14),

                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),

                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(
                                          alpha: .08,
                                        ),

                                        borderRadius: BorderRadius.circular(8),
                                      ),

                                      child: Text(
                                        item.category,

                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),

                                    const Spacer(),

                                    Text(
                                      item.time,

                                      style: TextStyle(
                                        fontSize: 11,
                                        color: textSub,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 10),

                                Text(
                                  item.title,

                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? AppColors.darkText
                                        : AppColors.lightText,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                Text(
                                  item.body,

                                  maxLines: 2,

                                  overflow: TextOverflow.ellipsis,

                                  style: TextStyle(
                                    fontSize: 13,
                                    height: 1.5,
                                    color: textSub,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
