import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hrm_app/core/theme/app_theme.dart';
import 'package:hrm_app/core/widgets/common.dart';
import 'package:hrm_app/features/profile/profile_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({
    super.key,
    required this.onThemeToggle,
    required this.onSignOut,
    required this.isDarkMode,
  });

  final VoidCallback onThemeToggle;
  final VoidCallback onSignOut;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkText : AppColors.lightText;
    final textSub = isDark ? AppColors.darkTextSub : AppColors.lightTextSub;
    final surface = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final cardColor = isDark ? AppColors.darkCard : AppColors.lightSurface;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final employee = ref.watch(profileControllerProvider);
    final chips = <({IconData icon, String value})>[
      if (employee.id.isNotEmpty)
        (icon: Icons.badge_outlined, value: employee.id),
      if (employee.department.isNotEmpty)
        (icon: Icons.business_outlined, value: employee.department),
      if (employee.location.isNotEmpty)
        (icon: Icons.location_on_outlined, value: employee.location),
    ];
    final contacts = <({IconData icon, String label, String value})>[
      if (employee.email.isNotEmpty)
        (
          icon: Icons.mail_outline_rounded,
          label: 'Email',
          value: employee.email,
        ),
      if (employee.phone.isNotEmpty)
        (icon: Icons.phone_outlined, label: 'Phone', value: employee.phone),
    ];
    final employment = <({IconData icon, String label, String value})>[
      if (employee.joinDate.isNotEmpty)
        (
          icon: Icons.calendar_today_outlined,
          label: 'Join Date',
          value: employee.joinDate,
        ),
      if (employee.location.isNotEmpty)
        (
          icon: Icons.domain_outlined,
          label: 'Location',
          value: employee.location,
        ),
    ];

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: ListView(
        children: [
          Container(
            color: surface,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
            child: Column(
              children: [
                AvatarWidget(
                  initials: employee.initials,
                  colorIndex: employee.avatarColorIndex,
                  size: 80,
                ),
                const SizedBox(height: 14),
                Text(
                  employee.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                  ),
                ),
                if (employee.role.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    employee.role,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: textSub),
                  ),
                ],
                if (chips.isNotEmpty) ...[
                  const SizedBox(height: 18),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: chips
                        .map(
                          (chip) => _InfoChip(
                            icon: chip.icon,
                            label: chip.value,
                            isDark: isDark,
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (contacts.isNotEmpty) ...[
                  _SectionLabel(label: 'CONTACT', color: textSub),
                  _InfoGroup(
                    items: contacts,
                    cardColor: cardColor,
                    borderColor: borderColor,
                    textPrimary: textPrimary,
                    textSub: textSub,
                  ),
                  const SizedBox(height: 20),
                ],
                if (employment.isNotEmpty) ...[
                  _SectionLabel(label: 'EMPLOYMENT', color: textSub),
                  _InfoGroup(
                    items: employment,
                    cardColor: cardColor,
                    borderColor: borderColor,
                    textPrimary: textPrimary,
                    textSub: textSub,
                  ),
                  const SizedBox(height: 20),
                ],
                const UnavailableFeatureCard(
                  title: 'Data personal lainnya belum tersedia',
                  message:
                      'Dokumen, slip gaji, aset, dan sertifikasi akan ditampilkan setelah endpoint masing-masing selesai diintegrasikan.',
                  icon: Icons.folder_off_outlined,
                ),
                const SizedBox(height: 20),
                _SectionLabel(label: 'SETTINGS', color: textSub),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.dark_mode_outlined,
                        color: AppColors.purple,
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
                              style: TextStyle(fontSize: 12, color: textSub),
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
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onSignOut,
                    icon: const Icon(Icons.logout_rounded, size: 18),
                    label: const Text('Sign Out'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: AppColors.danger),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.color});

  final String label;
  final Color color;

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
          color: color,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 220),
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
            size: 14,
            color: isDark ? AppColors.darkTextSub : AppColors.lightTextSub,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoGroup extends StatelessWidget {
  const _InfoGroup({
    required this.items,
    required this.cardColor,
    required this.borderColor,
    required this.textPrimary,
    required this.textSub,
  });

  final List<({IconData icon, String label, String value})> items;
  final Color cardColor;
  final Color borderColor;
  final Color textPrimary;
  final Color textSub;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: items.indexed.map((entry) {
          final (index, item) = entry;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Icon(item.icon, size: 17, color: textSub),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 72,
                      child: Text(
                        item.label,
                        style: TextStyle(fontSize: 13, color: textSub),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        item.value,
                        textAlign: TextAlign.end,
                        overflow: TextOverflow.ellipsis,
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
              if (index < items.length - 1)
                Divider(height: 1, color: borderColor),
            ],
          );
        }).toList(),
      ),
    );
  }
}
