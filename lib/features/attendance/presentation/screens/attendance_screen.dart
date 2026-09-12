import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hrm_app/core/errors/failure.dart';
import 'package:hrm_app/core/security/session_lifecycle.dart';
import 'package:hrm_app/core/services/location_gateway.dart';
import 'package:hrm_app/core/services/location_service.dart';
import 'package:hrm_app/core/services/selfie_gateway.dart';
import 'package:hrm_app/core/services/selfie_service.dart';
import 'package:hrm_app/core/theme/app_theme.dart';
import 'package:hrm_app/core/widgets/common.dart';
import 'package:hrm_app/features/attendance/attendance_dependencies.dart';
import 'package:hrm_app/features/attendance/attendance_providers.dart';
import 'package:hrm_app/features/attendance/domain/entities/attendance_context.dart';
import 'package:hrm_app/features/attendance/domain/entities/attendance_entity.dart';

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  CapturedSelfie? _selfie;
  String? _captureError;
  bool _capturing = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final session = ref.watch(featureSessionProvider);
    final attendance = ref.watch(attendanceControllerProvider(session));
    final attendanceContext = ref.watch(attendanceContextProvider(session));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
        appBar: AppBar(
          title: const Text(
            'Absensi',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
          ),
          backgroundColor: isDark
              ? AppColors.darkSurface
              : AppColors.lightSurface,
          bottom: const TabBar(
            indicatorWeight: 2,
            tabs: [
              Tab(text: 'Hari ini'),
              Tab(text: 'Riwayat'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(attendanceContextProvider(session));
                ref.invalidate(attendanceControllerProvider(session));
                await Future.wait([
                  ref.read(attendanceContextProvider(session).future),
                  ref.read(attendanceControllerProvider(session).future),
                ]);
              },
              child: _today(context, session, attendance, attendanceContext),
            ),
            const _HistoryUnavailable(),
          ],
        ),
      ),
    );
  }

  Widget _today(
    BuildContext context,
    FeatureSession session,
    AsyncValue<AttendanceEntity> attendance,
    AsyncValue<AttendanceContext> contextState,
  ) {
    final record = attendance.valueOrNull;
    final policy = contextState.valueOrNull;
    final error = attendance.hasError ? attendance.error : contextState.error;
    final isBusy = attendance.isLoading || contextState.isLoading;
    final needsSelfie =
        record?.isActive == false && policy?.requiresSelfie == true;
    final canSubmit =
        !isBusy &&
        record != null &&
        policy != null &&
        (!needsSelfie || _selfie != null) &&
        _supportsAction(record, policy);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [
        if (policy != null) _PolicyCard(value: policy),
        if (policy != null) const SizedBox(height: 20),
        const SectionHeader(title: 'Catatan hari ini'),
        const SizedBox(height: 12),
        if (record != null)
          AppCard(child: _AttendanceRecord(record: record))
        else if (isBusy)
          const _LoadingCard(message: 'Memuat data absensi...'),
        if (needsSelfie) ...[
          const SizedBox(height: 20),
          _SelfieCard(
            selfie: _selfie,
            error: _captureError,
            isCapturing: _capturing,
            onCapture: _captureSelfie,
          ),
        ],
        if (error != null) ...[
          const SizedBox(height: 20),
          _AttendanceError(
            error: error,
            onRetry: () {
              ref.invalidate(attendanceContextProvider(session));
              ref.invalidate(attendanceControllerProvider(session));
            },
            onOpenSettings: _openSettings(error),
          ),
        ],
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: canSubmit
                ? () => _submit(session, record, needsSelfie)
                : null,
            icon: isBusy
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Icon(
                    record?.isActive == true
                        ? Icons.logout_rounded
                        : Icons.login_rounded,
                  ),
            label: Text(
              isBusy
                  ? 'Memproses...'
                  : record?.isActive == true
                  ? 'Catat pulang'
                  : 'Catat masuk',
            ),
          ),
        ),
        if (policy != null && !_supportsAction(record, policy)) ...[
          const SizedBox(height: 10),
          Text(
            record?.isActive == true
                ? 'Metode GPS seluler tidak diizinkan untuk absensi ini.'
                : 'Kebijakan perusahaan tidak menyediakan metode absensi yang didukung aplikasi.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }

  bool _supportsAction(AttendanceEntity? record, AttendanceContext policy) {
    if (record?.isActive == true) return policy.supportsMobileGps;
    if (policy.requiresSelfie) return policy.supportsFaceRecognition;
    return policy.supportsMobileGps;
  }

  Future<void> _captureSelfie() async {
    setState(() {
      _capturing = true;
      _captureError = null;
    });
    try {
      final capture = await ref.read(selfieServiceProvider).capture();
      if (!mounted) return;
      setState(() {
        if (capture != null) _selfie = capture;
      });
    } on SelfieException catch (error) {
      if (mounted) setState(() => _captureError = error.message);
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }

  Future<void> _submit(
    FeatureSession session,
    AttendanceEntity record,
    bool needsSelfie,
  ) async {
    final success = await ref
        .read(attendanceControllerProvider(session).notifier)
        .toggleAttendance(selfie: needsSelfie ? _selfie : null);
    if (!mounted || !success) return;
    setState(() {
      _selfie = null;
      _captureError = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          record.isActive
              ? 'Waktu pulang tercatat di server.'
              : 'Waktu masuk tercatat di server.',
        ),
      ),
    );
  }

  VoidCallback? _openSettings(Object error) {
    if (error is! LocationException) return null;
    return switch (error.kind) {
      LocationIssueKind.permissionDeniedForever => () {
        ref.read(locationServiceProvider).openAppSettings();
      },
      LocationIssueKind.serviceDisabled => () {
        ref.read(locationServiceProvider).openLocationSettings();
      },
      _ => null,
    };
  }
}

class _PolicyCard extends StatelessWidget {
  const _PolicyCard({required this.value});

  final AttendanceContext value;

  @override
  Widget build(BuildContext context) {
    final location = [
      value.branchName,
      value.branchCode,
    ].whereType<String>().where((item) => item.isNotEmpty).join(' • ');
    final schedule = [
      value.workStart,
      value.workEnd,
    ].whereType<String>().where((item) => item.isNotEmpty).join(' - ');
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.location_on_outlined, color: AppColors.primary),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Kebijakan absensi',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          if (location.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(location),
          ],
          if (schedule.isNotEmpty) ...[
            const SizedBox(height: 5),
            Text('Jadwal $schedule'),
          ],
          const SizedBox(height: 8),
          Text(
            value.requiresSelfie
                ? 'GPS dan selfie wajib dikirim untuk verifikasi server.'
                : 'Lokasi GPS akan dikirim untuk verifikasi server.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (value.gpsRadiusMeters case final radius?) ...[
            const SizedBox(height: 4),
            Text(
              'Radius lokasi ${radius.round()} meter',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          for (final warning in value.warnings) ...[
            const SizedBox(height: 8),
            Text(warning, style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}

class _SelfieCard extends StatelessWidget {
  const _SelfieCard({
    required this.selfie,
    required this.error,
    required this.isCapturing,
    required this.onCapture,
  });

  final CapturedSelfie? selfie;
  final String? error;
  final bool isCapturing;
  final VoidCallback onCapture;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Selfie verifikasi',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          if (selfie != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Semantics(
                image: true,
                label: 'Pratinjau selfie absensi',
                child: Image.memory(
                  selfie!.bytes,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                ),
              ),
            )
          else
            Text(
              'Ambil foto langsung dengan kamera depan. Foto hanya dikirim saat Anda mencatat masuk.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          if (error != null) ...[
            const SizedBox(height: 10),
            Semantics(
              liveRegion: true,
              child: Text(
                error!,
                style: TextStyle(
                  color: isDark
                      ? const Color(0xFFFCA5A5)
                      : const Color(0xFFB91C1C),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              onPressed: isCapturing ? null : onCapture,
              icon: const Icon(Icons.camera_alt_outlined),
              label: Text(
                isCapturing
                    ? 'Membuka kamera...'
                    : selfie == null
                    ? 'Ambil selfie'
                    : 'Ambil ulang',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => AppCard(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox.square(
          dimension: 22,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
        const SizedBox(width: 12),
        Flexible(child: Text(message)),
      ],
    ),
  );
}

class _AttendanceError extends StatelessWidget {
  const _AttendanceError({
    required this.error,
    required this.onRetry,
    this.onOpenSettings,
  });

  final Object error;
  final VoidCallback onRetry;
  final VoidCallback? onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final message = switch (error) {
      Failure(:final message) => message,
      LocationException(:final message) => message,
      _ => 'Absensi tidak dapat diproses. Periksa koneksi lalu coba lagi.',
    };
    return Semantics(
      liveRegion: true,
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Absensi belum tercatat',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(message),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Coba lagi'),
                ),
                if (onOpenSettings != null)
                  OutlinedButton.icon(
                    onPressed: onOpenSettings,
                    icon: const Icon(Icons.settings_outlined),
                    label: const Text('Buka pengaturan'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AttendanceRecord extends StatelessWidget {
  const _AttendanceRecord({required this.record});

  final AttendanceEntity record;

  String _time(DateTime? value) {
    if (value == null) return 'Belum tercatat';
    final local = value.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(
            record.id.isEmpty
                ? Icons.event_available_outlined
                : Icons.verified_outlined,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              record.id.isEmpty
                  ? 'Belum ada catatan'
                  : record.isActive
                  ? 'Sedang bekerja'
                  : 'Absensi selesai',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      const SizedBox(height: 14),
      Text('Masuk: ${_time(record.checkedInAt)}'),
      const SizedBox(height: 6),
      Text('Pulang: ${_time(record.checkedOutAt)}'),
      const SizedBox(height: 8),
      Text(
        'Status ini berasal dari server.',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    ],
  );
}

class _HistoryUnavailable extends StatelessWidget {
  const _HistoryUnavailable();

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: const [
      UnavailableFeatureCard(
        title: 'Riwayat absensi belum tersedia',
        message:
            'Riwayat akan ditampilkan setelah endpoint dan filter periode selesai diintegrasikan.',
        icon: Icons.history_rounded,
      ),
    ],
  );
}
