import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/data.dart';

/// ===============================================================
/// Avatar Colors
/// ===============================================================

const List<Color> _avatarColors = [
  AppColors.primary,
  AppColors.success,
  AppColors.purple,
  AppColors.danger,
  AppColors.warning,
  AppColors.info,
];

/// ===============================================================
/// Avatar Widget
/// ===============================================================

class AvatarWidget extends StatelessWidget {
  final String initials;
  final int colorIndex;
  final double size;

  const AvatarWidget({
    super.key,
    required this.initials,
    required this.colorIndex,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final color = _avatarColors[colorIndex % _avatarColors.length];

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: size * .35,
        ),
      ),
    );
  }
}

/// ===============================================================
/// Status Badge
/// ===============================================================

class StatusBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const StatusBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  factory StatusBadge.request(RequestStatus status) {
    switch (status) {
      case RequestStatus.approved:
        return const StatusBadge(
          label: "Approved",
          backgroundColor: Color(0xffDCFCE7),
          textColor: Color(0xff166534),
        );

      case RequestStatus.pending:
        return const StatusBadge(
          label: "Pending",
          backgroundColor: Color(0xffFEF3C7),
          textColor: Color(0xff92400E),
        );

      case RequestStatus.rejected:
        return const StatusBadge(
          label: "Rejected",
          backgroundColor: Color(0xffFEE2E2),
          textColor: Color(0xff991B1B),
        );
    }
  }

  factory StatusBadge.attendance(
    AttendanceStatus status,
  ) {
    switch (status) {
      case AttendanceStatus.onTime:
        return const StatusBadge(
          label: "On Time",
          backgroundColor: Color(0xffDCFCE7),
          textColor: Color(0xff166534),
        );

      case AttendanceStatus.late:
        return const StatusBadge(
          label: "Late",
          backgroundColor: Color(0xffFEF3C7),
          textColor: Color(0xff92400E),
        );

      case AttendanceStatus.leave:
        return const StatusBadge(
          label: "Leave",
          backgroundColor: Color(0xffDBEAFE),
          textColor: Color(0xff1E40AF),
        );

      case AttendanceStatus.absent:
        return const StatusBadge(
          label: "Absent",
          backgroundColor: Color(0xffFEE2E2),
          textColor: Color(0xff991B1B),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// ===============================================================
/// Section Header
/// ===============================================================

class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),

        if (actionLabel != null)
          TextButton(
            onPressed: onAction,
            child: Text(
              actionLabel!,
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .primary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
      ],
    );
  }
}

/// ===============================================================
/// App Card
/// ===============================================================

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(18),
        child: Ink(
          padding: padding,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkCard
                : AppColors.lightSurface,
            borderRadius:
                BorderRadius.circular(18),
            border: Border.all(
              color: isDark
                  ? AppColors.darkBorder
                  : AppColors.lightBorder,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
/// ===============================================================
/// KPI CARD
/// ===============================================================

class KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final Color accentColor;
  final IconData icon;

  const KpiCard({
    super.key,
    required this.label,
    required this.value,
    required this.sub,
    required this.accentColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 180;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkCard
                : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark
                  ? AppColors.darkBorder
                  : AppColors.lightBorder,
            ),
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// HEADER
              Row(
                children: [

                  Expanded(
                    child: Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: compact ? 10 : 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: .5,
                        color: isDark
                            ? AppColors.darkTextSub
                            : AppColors.lightTextSub,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  Container(
                    width: compact ? 34 : 38,
                    height: compact ? 34 : 38,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      size: compact ? 18 : 20,
                      color: accentColor,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              /// VALUE
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: compact ? 24 : 28,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.darkText
                        : AppColors.lightText,
                  ),
                ),
              ),

              const SizedBox(height: 6),

              /// SUBTITLE
              Text(
                sub,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: compact ? 10 : 11,
                  color: isDark
                      ? AppColors.darkTextSub
                      : AppColors.lightTextSub,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
/// ===============================================================
/// LEAVE BALANCE CARD
/// ===============================================================

class LeaveBalanceCard extends StatelessWidget {
  final LeaveBalance balance;

  const LeaveBalanceCard({
    super.key,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final color =
        _avatarColors[balance.colorIndex % _avatarColors.length];

    return LayoutBuilder(
      builder: (context, constraints) {

        final compact = constraints.maxWidth < 170;

        final iconSize = compact ? 20.0 : 24.0;
        final iconBox = compact ? 42.0 : 48.0;

        final titleFont = compact ? 13.0 : 14.0;
        final valueFont = compact ? 28.0 : 34.0;
        final footerFont = compact ? 11.0 : 12.0;

        return Container(
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkCard
                : AppColors.lightSurface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark
                  ? AppColors.darkBorder
                  : AppColors.lightBorder,
            ),
          ),

          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// ==========================
              /// HEADER
              /// ==========================

              Row(
                children: [

                  Container(
                    width: iconBox,
                    height: iconBox,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: .12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.event_note_rounded,
                      color: color,
                      size: iconSize,
                    ),
                  ),

                  const Spacer(),

                  Text(
                    "${(balance.percentage * 100).round()}%",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: color,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              /// ==========================
              /// REMAINING DAYS
              /// ==========================

              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  "${balance.remaining}",
                  style: TextStyle(
                    fontSize: valueFont,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.darkText
                        : AppColors.lightText,
                  ),
                ),
              ),

              const SizedBox(height: 4),

              Text(
                balance.type,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: titleFont,
                  color: isDark
                      ? AppColors.darkTextSub
                      : AppColors.lightTextSub,
                ),
              ),

              const Spacer(),

              /// ==========================
              /// PROGRESS
              /// ==========================

              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: balance.percentage,
                  minHeight: 7,
                  backgroundColor:
                      color.withValues(alpha: .15),
                  valueColor:
                      AlwaysStoppedAnimation(color),
                ),
              ),

              const SizedBox(height: 10),

              Row(
                children: [

                  Icon(
                    Icons.check_circle_outline,
                    size: 14,
                    color: color,
                  ),

                  const SizedBox(width: 6),

                  Expanded(
                    child: Text(
                      "${balance.used} of ${balance.total} days used",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: footerFont,
                        color: isDark
                            ? AppColors.darkTextSub
                            : AppColors.lightTextSub,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
/// ===============================================================
/// QUICK ACTION
/// ===============================================================

class QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const QuickAction({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {

        final screenWidth =
            MediaQuery.of(context).size.width;

        final bool compact = screenWidth < 400;

        final double iconBox =
            compact ? 52 : 60;

        final double iconSize =
            compact ? 22 : 26;

        final double textWidth =
            compact ? 72 : 84;

        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),

          child: SizedBox(
            width: textWidth,

            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                AnimatedContainer(
                  duration: const Duration(
                    milliseconds: 200,
                  ),

                  width: iconBox,
                  height: iconBox,

                  decoration: BoxDecoration(
                    color: color.withValues(alpha: .10),
                    borderRadius:
                        BorderRadius.circular(18),

                    border: Border.all(
                      color: color.withValues(alpha: .20),
                    ),
                  ),

                  child: Icon(
                    icon,
                    color: color,
                    size: iconSize,
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: textWidth,

                  child: Text(
                    label,
                    maxLines: 2,
                    overflow:
                        TextOverflow.ellipsis,

                    textAlign: TextAlign.center,

                    style: TextStyle(
                      fontSize: compact ? 11 : 12,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                      color: isDark
                          ? AppColors.darkTextSub
                          : AppColors.lightTextSub,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}