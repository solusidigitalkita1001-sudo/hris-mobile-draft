# Business Requirements

Dokumen ini merangkum kebutuhan bisnis dan fungsional mobile app HRMS berdasarkan `BRD_Mobile_HRMS_SelfService_Approval_Absensi.md`.

## Ringkasan

Aplikasi mobile HRMS melayani dua peran utama: `Employee` dan `Atasan/Manager`.
Fokus modul: Self Service, Approval, Absensi, Dashboard, Notifikasi, Dokumen, dan Profil.

## Tujuan Bisnis Utama

- Migrasi aktivitas rutin dari web/manual ke mobile
- Mempercepat siklus persetujuan
- Meningkatkan akurasi data absensi
- Mengurangi beban administratif HR
- Meningkatkan employee experience

## Indikator Keberhasilan

- Adoption Rate ≥ 85% dalam 3 bulan
- Attendance Compliance ≥ 90%
- Approval Turnaround Time turun ≥ 40%
- Self Service Deflection ≥ 70%
- App Store Rating ≥ 4.3
- Crash-free Session Rate ≥ 99%

## Modul Utama

- Authentication & Login
- Dashboard / Beranda
- Absensi (Attendance)
- Leave Management (Cuti)
- Self Service Request lainnya
- Approval Center
- Kalender Kerja dan Kalender Tim
- Notifikasi
- Slip Gaji & Dokumen Pribadi
- Profil & Pengaturan Akun

## Batasan dan Asumsi

- Mobile fokus pada pengalaman Employee dan Atasan
- Konfigurasi administratif tetap di web
- Backend HRMS tersedia atau dibangun paralel
- Perangkat harus mendukung GPS dan iOS/Android
- Data sensitif tidak dapat diedit bebas dari mobile
