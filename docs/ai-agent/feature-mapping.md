# Feature Mapping

Dokumentasi ini memetakan modul utama aplikasi mobile HRMS berdasarkan BRD agar AI agent dapat memahami hubungan fitur dan alur pengguna.

## 1. Area Pengguna

- Saya: self service pribadi, absensi, pengajuan, dokumen, profil
- Tim Saya: approval, ringkasan tim, kalender tim, dan visibilitas status bawahan (khusus Atasan/Manager)

## 2. Modul dan Fungsi

### Authentication & Login
- Login dengan email/username dan password
- Dukungan biometric atau PIN
- Reset password melalui OTP
- Manajemen sesi, lockout, dan keamanan akun

### Dashboard / Beranda
- Menampilkan status absensi hari ini
- Menampilkan saldo cuti dan pengajuan pending
- Menampilkan badge approval untuk Atasan/Manager
- Menampilkan pengumuman serta reminder terkait kontrak atau aktivitas penting

### Attendance
- Clock In/Clock Out dengan dukungan GPS dan geofencing
- Menampilkan status hadir, terlambat, lembur, atau pulang cepat
- Mendukung riwayat attendance bulanan
- Menyediakan koreksi absensi melalui self service
- Menyediakan dukungan offline dengan resync saat koneksi pulih

### Leave Management (Cuti)
- Menampilkan saldo cuti per tipe
- Memungkinkan pengajuan cuti dengan perhitungan hari kerja
- Menyediakan pembatalan pengajuan dan riwayat permintaan

### Self Service Request Lainnya
- Izin/Sakit
- Lembur
- Tukar Shift
- Permohonan Dokumen
- Riwayat gabungan semua pengajuan

### Approval Center
- Menampilkan antrian approval bawahan
- Memungkinkan approve, reject, atau delegation
- Menyimpan riwayat keputusan approval
- Menyediakan alur persetujuan yang terhubung ke workflow engine backend

### Kalender Kerja & Kalender Tim
- Menampilkan kalender kerja perusahaan
- Menampilkan kalender tim dan ketersediaan bawahan
- Menyediakan akses read-only untuk informasi kerja yang sudah dikonfigurasi dari web

### Notifikasi
- Push notification untuk approval, absensi, dan pengumuman
- Deep link ke detail pengajuan atau aktivitas terkait

### Slip Gaji & Dokumen Pribadi
- Menampilkan dan mengunduh slip gaji
- Menyediakan akses dokumen pribadi yang bersifat read-only

### Profil & Pengaturan Akun
- Menampilkan data pribadi dengan edit terbatas
- Mengubah password/PIN
- Mengatur preferensi notifikasi dan pengaturan akun

## 3. Hubungan Antar Modul

- Dashboard menjadi pintu masuk utama ke attendance, leave, approval, dan notifikasi
- Approval Center bergantung pada data pengajuan yang dibuat dari modul self service
- Attendance dan Leave dapat memengaruhi status tim yang terlihat di kalender tim dan dashboard atasan
- Notifikasi berperan sebagai trigger untuk mendorong pengguna kembali ke modul terkait
- Data dokumen, profil, dan pengaturan bersifat personal dan harus mengikuti otorisasi pengguna
