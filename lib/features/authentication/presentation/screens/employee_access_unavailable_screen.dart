import 'package:flutter/material.dart';
import 'package:hrm_app/core/theme/app_theme.dart';

class EmployeeAccessUnavailableScreen extends StatelessWidget {
  const EmployeeAccessUnavailableScreen({super.key, required this.onSignOut});

  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkText : AppColors.lightText;
    final textSub = isDark ? AppColors.darkTextSub : AppColors.lightTextSub;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: SafeArea(
        minimum: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.badge_outlined,
                  size: 42,
                  color: isDark ? AppColors.primaryLight : AppColors.primary,
                ),
                const SizedBox(height: 20),
                Text(
                  'Akses karyawan belum tersedia',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Akun berhasil masuk, tetapi belum terhubung ke employee dan company aktif. Hubungi administrator HR untuk memperbaiki penautan akun.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: textSub, height: 1.5),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: onSignOut,
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Keluar dari akun'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
