import 'package:flutter/material.dart';

import 'package:hrm_app/core/theme/app_theme.dart';
import 'package:hrm_app/core/widgets/common.dart';
import 'package:hrm_app/features/dashboard/data/models/app_data.dart';

class ProfileScreen extends StatelessWidget {
  final VoidCallback onThemeToggle;
  final bool isDarkMode;

  const ProfileScreen({
    super.key,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkText : AppColors.lightText;
    final textSub = isDark ? AppColors.darkTextSub : AppColors.lightTextSub;
    final bgColor = isDark ? AppColors.darkBg : AppColors.lightBg;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final emp = AppData.currentEmployee;

    return Scaffold(
      backgroundColor: bgColor,
      body: ListView(
        children: [
          // Profile header
          Container(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
            child: Column(
              children: [
                Stack(
                  children: [
                    AvatarWidget(
                      initials: emp.initials,
                      colorIndex: emp.avatarColorIndex,
                      size: 80,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark
                                ? AppColors.darkSurface
                                : AppColors.lightSurface,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  emp.name,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(emp.role, style: TextStyle(fontSize: 14, color: textSub)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.2),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, size: 8, color: AppColors.success),
                      SizedBox(width: 6),
                      Text(
                        'Active Employee',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Info row
          Container(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(
              children: [
                _InfoChip(
                  icon: Icons.badge_rounded,
                  label: emp.id,
                  isDark: isDark,
                ),
                const SizedBox(width: 10),
                _InfoChip(
                  icon: Icons.business_rounded,
                  label: emp.department,
                  isDark: isDark,
                ),
                const SizedBox(width: 10),
                _InfoChip(
                  icon: Icons.location_on_rounded,
                  label: 'Jakarta',
                  isDark: isDark,
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Contact info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionLabel(label: 'CONTACT', textSub: textSub),
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      _InfoRow(
                        icon: Icons.mail_rounded,
                        label: 'Email',
                        value: emp.email,
                        textPrimary: textPrimary,
                        textSub: textSub,
                        borderColor: borderColor,
                        isDark: isDark,
                      ),
                      _InfoRow(
                        icon: Icons.phone_rounded,
                        label: 'Phone',
                        value: emp.phone,
                        textPrimary: textPrimary,
                        textSub: textSub,
                        borderColor: borderColor,
                        showDivider: false,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                _SectionLabel(label: 'EMPLOYMENT', textSub: textSub),
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      _InfoRow(
                        icon: Icons.calendar_today_rounded,
                        label: 'Join Date',
                        value: emp.joinDate,
                        textPrimary: textPrimary,
                        textSub: textSub,
                        borderColor: borderColor,
                        isDark: isDark,
                      ),
                      _InfoRow(
                        icon: Icons.domain_rounded,
                        label: 'Location',
                        value: emp.location,
                        textPrimary: textPrimary,
                        textSub: textSub,
                        borderColor: borderColor,
                        showDivider: false,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                _SectionLabel(label: 'DOCUMENTS & ASSETS', textSub: textSub),
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      _MenuRow(
                        icon: Icons.description_rounded,
                        iconColor: AppColors.primary,
                        label: 'My Documents',
                        sub: 'ID, contracts, certificates',
                        textPrimary: textPrimary,
                        textSub: textSub,
                        borderColor: borderColor,
                      ),
                      _MenuRow(
                        icon: Icons.account_balance_wallet_rounded,
                        iconColor: AppColors.success,
                        label: 'Payroll History',
                        sub: 'Payslips & tax reports',
                        textPrimary: textPrimary,
                        textSub: textSub,
                        borderColor: borderColor,
                      ),
                      _MenuRow(
                        icon: Icons.laptop_mac_rounded,
                        iconColor: AppColors.purple,
                        label: 'Assigned Assets',
                        sub: 'MacBook Pro, iPhone 15 Pro',
                        textPrimary: textPrimary,
                        textSub: textSub,
                        borderColor: borderColor,
                      ),
                      _MenuRow(
                        icon: Icons.workspace_premium_rounded,
                        iconColor: AppColors.warning,
                        label: 'Certifications',
                        sub: '3 active certificates',
                        textPrimary: textPrimary,
                        textSub: textSub,
                        borderColor: borderColor,
                        showDivider: false,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                _SectionLabel(label: 'SETTINGS', textSub: textSub),
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      _MenuRow(
                        icon: Icons.notifications_rounded,
                        iconColor: AppColors.info,
                        label: 'Notifications',
                        sub: 'All notifications enabled',
                        textPrimary: textPrimary,
                        textSub: textSub,
                        borderColor: borderColor,
                      ),
                      // Dark mode toggle
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: AppColors.purple.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.dark_mode_rounded,
                                color: AppColors.purple,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Dark Mode',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: textPrimary,
                                    ),
                                  ),
                                  Text(
                                    isDarkMode
                                        ? 'Dark theme active'
                                        : 'Light theme active',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: textSub,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: isDarkMode,
                              onChanged: (_) => onThemeToggle(),
                              activeThumbColor: AppColors.primary,
                            ),
                          ],
                        ),
                      ),
                      Divider(height: 1, color: borderColor),
                      _MenuRow(
                        icon: Icons.language_rounded,
                        iconColor: AppColors.success,
                        label: 'Language',
                        sub: 'English (US)',
                        textPrimary: textPrimary,
                        textSub: textSub,
                        borderColor: borderColor,
                      ),
                      _MenuRow(
                        icon: Icons.security_rounded,
                        iconColor: AppColors.warning,
                        label: 'Security',
                        sub: 'Biometric · PIN',
                        textPrimary: textPrimary,
                        textSub: textSub,
                        borderColor: borderColor,
                        showDivider: false,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Sign out
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.logout_rounded,
                      size: 18,
                      color: AppColors.danger,
                    ),
                    label: const Text(
                      'Sign Out',
                      style: TextStyle(
                        color: AppColors.danger,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.danger, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                Center(
                  child: Text(
                    'HRMS v1.0.0  ·  © 2025 Corp',
                    style: TextStyle(fontSize: 11, color: textSub),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final Color textSub;
  const _SectionLabel({required this.label, required this.textSub});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 2),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: textSub,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkMuted : AppColors.lightMuted,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: isDark ? AppColors.darkTextSub : AppColors.lightTextSub,
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color textPrimary;
  final Color textSub;
  final Color borderColor;
  final bool showDivider;
  final bool isDark;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.textPrimary,
    required this.textSub,
    required this.borderColor,
    this.showDivider = true,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: isDark ? AppColors.darkTextSub : AppColors.lightTextSub,
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 72,
                child: Text(
                  label,
                  style: TextStyle(fontSize: 13, color: textSub),
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        if (showDivider) Divider(height: 1, color: borderColor),
      ],
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String sub;
  final Color textPrimary;
  final Color textSub;
  final Color borderColor;
  final bool showDivider;

  const _MenuRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.sub,
    required this.textPrimary,
    required this.textSub,
    required this.borderColor,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: iconColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                        ),
                      ),
                      Text(sub, style: TextStyle(fontSize: 12, color: textSub)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, size: 18, color: textSub),
              ],
            ),
          ),
        ),
        if (showDivider) Divider(height: 1, color: borderColor),
      ],
    );
  }
}
