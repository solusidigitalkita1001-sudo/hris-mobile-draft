import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hrm_app/core/theme/app_theme.dart';
import 'package:hrm_app/core/widgets/common.dart';
import 'package:hrm_app/features/dashboard/dashboard_providers.dart';
import 'package:hrm_app/features/dashboard/domain/entities/dashboard_snapshot.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool? _clockedInOverride;

  DashboardSnapshot get _dashboard => ref.watch(dashboardControllerProvider);

  bool get _clockedIn =>
      _clockedInOverride ?? _dashboard.attendance.isClockedIn;

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

                      Stack(
                        children: [
                          AvatarWidget(
                            initials: _dashboard.employee.initials,

                            colorIndex: _dashboard.employee.avatarColorIndex,

                            size: compact ? 46 : 52,
                          ),

                          Positioned(
                            right: 0,
                            bottom: 0,

                            child: Container(
                              width: 14,
                              height: 14,

                              decoration: BoxDecoration(
                                color: AppColors.success,

                                shape: BoxShape.circle,

                                border: Border.all(
                                  width: 2,

                                  color: isDark
                                      ? AppColors.darkBg
                                      : AppColors.lightBg,
                                ),
                              ),
                            ),
                          ),
                        ],
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
                                      color: Color(0xffBFDBFE),

                                      fontSize: 12,

                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  Text(
                                    _clockedIn
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
                                    _clockedIn
                                        ? "Working Time : $_workingTime"
                                        : "Tap button below to clock in",

                                    style: const TextStyle(
                                      color: Color(0xffBFDBFE),

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

                            onPressed: () {
                              setState(() {
                                _clockedInOverride = !_clockedIn;
                              });
                            },

                            child: Text(
                              _clockedIn ? "Clock Out" : "Clock In",

                              style: const TextStyle(
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

              //---------------------------------------------------
              // QUICK ACTION
              //---------------------------------------------------
              // SectionHeader(
              //   title: "Quick Actions",
              //   actionLabel: "All",
              //   onAction: () {},
              // ),

              // const SizedBox(height: 16),

              // LayoutBuilder(
              //   builder: (context, constraints) {
              //     final width = constraints.maxWidth;

              //     final itemWidth = width > 700
              //         ? (width - 48) / 5
              //         : (width - 32) / 4;

              //     return Wrap(
              //       alignment: WrapAlignment.spaceBetween,
              //       runSpacing: 18,
              //       spacing: 8,
              //       children: [
              //         SizedBox(
              //           width: itemWidth.clamp(68, 90),
              //           child: QuickAction(
              //             icon: Icons.beach_access_rounded,
              //             label: "Request\nLeave",
              //             color: AppColors.primary,
              //             onTap: () {},
              //           ),
              //         ),

              //         SizedBox(
              //           width: itemWidth.clamp(68, 90),
              //           child: QuickAction(
              //             icon: Icons.medical_services_rounded,
              //             label: "Sick\nLeave",
              //             color: AppColors.danger,
              //             onTap: () {},
              //           ),
              //         ),

              //         SizedBox(
              //           width: itemWidth.clamp(68, 90),
              //           child: QuickAction(
              //             icon: Icons.access_time_rounded,
              //             label: "Overtime\nRequest",
              //             color: AppColors.warning,
              //             onTap: () {},
              //           ),
              //         ),

              //         SizedBox(
              //           width: itemWidth.clamp(68, 90),
              //           child: QuickAction(
              //             icon: Icons.receipt_long_rounded,
              //             label: "Attendance\nCorrection",
              //             color: AppColors.info,
              //             onTap: () {},
              //           ),
              //         ),

              //         SizedBox(
              //           width: itemWidth.clamp(68, 90),
              //           child: QuickAction(
              //             icon: Icons.flight_takeoff_rounded,
              //             label: "Business\nTrip",
              //             color: AppColors.purple,
              //             onTap: () {},
              //           ),
              //         ),
              //       ],
              //     );
              //   },
              // ),
              const SizedBox(height: 28),

              //---------------------------------------------------
              // LEAVE BALANCE
              //---------------------------------------------------
              SectionHeader(
                title: "Leave Balance",
                actionLabel: "Details",
                onAction: () {},
              ),

              const SizedBox(height: 16),

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
                        colorIndex: _dashboard.leaveBalances[index].colorIndex,
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 30),

              //---------------------------------------------------
              // KPI SUMMARY
              //---------------------------------------------------
              SectionHeader(title: "Monthly Summary"),

              const SizedBox(height: 16),

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

              //---------------------------------------------------
              // LATEST PAYSLIP
              //---------------------------------------------------
              //---------------------------------------------------
              // LATEST PAYSLIP
              //---------------------------------------------------
              SectionHeader(
                title: "Latest Payslip",
                actionLabel: "History",
                onAction: () {},
              ),

              const SizedBox(height: 16),

              AppCard(
                onTap: () {},

                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,

                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: .10),
                        borderRadius: BorderRadius.circular(16),
                      ),

                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: AppColors.success,
                        size: 28,
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "May 2025",
                            style: TextStyle(fontSize: 12, color: textSub),
                          ),

                          const SizedBox(height: 4),

                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Rp 45.360.000",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: isDark
                                    ? AppColors.darkText
                                    : AppColors.lightText,
                              ),
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            "Net salary after deduction",
                            style: TextStyle(fontSize: 11, color: textSub),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    FilledButton(
                      onPressed: () {},

                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),

                      child: const Text("View"),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              //---------------------------------------------------
              // ANNOUNCEMENT
              //---------------------------------------------------
              SectionHeader(
                title: "Announcements",
                actionLabel: "All",
                onAction: () {},
              ),

              const SizedBox(height: 16),

              ..._dashboard.announcements.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),

                  child: AppCard(
                    onTap: () {},

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
