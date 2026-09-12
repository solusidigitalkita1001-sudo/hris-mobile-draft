import 'package:flutter/material.dart';

import 'package:hrm_app/core/theme/app_theme.dart';
import 'package:hrm_app/core/widgets/common.dart';

class RequestsScreen extends StatelessWidget {
  const RequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = isDark ? AppColors.darkText : AppColors.lightText;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        title: Text(
          'Requests',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: textPrimary,
          ),
        ),
        backgroundColor: isDark
            ? AppColors.darkSurface
            : AppColors.lightSurface,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          UnavailableFeatureCard(
            title: 'Pengajuan belum tersedia',
            message:
                'Form dan riwayat pengajuan akan ditampilkan setelah integrasi server selesai. Tidak ada pengajuan yang disimpan hanya di perangkat.',
            icon: Icons.description_outlined,
          ),
        ],
      ),
    );
  }
}
