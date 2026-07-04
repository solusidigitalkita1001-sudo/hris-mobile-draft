# Feature Mapping

Dokumentasi fitur dan modul utama yang relevan untuk AI agent.

## Area Pengguna

- `Saya` - self service pribadi, pengajuan, absensi, dokumen, profil
- `Tim Saya` - approval, ringkasan tim, kalender tim (hanya untuk Atasan)

## Modul dan Fungsi

### Authentication & Login
- Login email/username + password
- Biometric / PIN
- Reset password OTP
- Sesi & lockout keamanan

### Dashboard / Beranda
- Status absensi hari ini
- Saldo cuti dan pengajuan pending
- Badge approval untuk Atasan
- Pengumuman dan reminder kontrak

### Absensi (Attendance)
- Clock In/Clock Out dengan GPS/geofencing
- Validasi offline dan resync
- Status hadir/terlambat/lembur/pulang cepat
- Riwayat attendance bulanan
- Koreksi absensi via self service

### Leave Management (Cuti)
- Saldo cuti per jenis
- Ajukan cuti dengan perhitungan hari kerja
- Pembatalan pengajuan dan riwayat

### Self Service Request lainnya
- Izin/Sakit
- Lembur
- Tukar Shift
- Permohonan Dokumen
- Riwayat gabungan pengajuan

### Approval Center
- Antrian approval bawahan
- Approve / Reject / delegasi
- Riwayat keputusan

### Kalender Kerja & Kalender Tim
- Kalender kerja perusahaan
- Kalender tim dan ketersediaan
- Work Calendar read-only

### Notifikasi
- Push notification event approval, absensi, pengumuman
- Deep link ke detail pengajuan

### Slip Gaji & Dokumen Pribadi
- Unduh/lihat slip gaji
- Akses dokumen pribadi read-only

### Profil & Pengaturan Akun
- Data pribadi dan edit terbatas
- Ubah password/PIN
- Preferensi notifikasi
