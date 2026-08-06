# Business Requirements

Dokumen ini merangkum kebutuhan bisnis dan fungsional aplikasi mobile HRMS berdasarkan BRD Mobile Application - HRMS Self Service, Approval & Attendance.

## 1. Ringkasan Bisnis

Aplikasi mobile HRMS ditujukan untuk dua kelompok pengguna utama:

- Employee: karyawan aktif yang membutuhkan akses mandiri untuk absensi, pengajuan, dokumen, dan profil
- Atasan/Manager: pengguna yang memiliki bawahan langsung dan perlu meninjau serta memutuskan pengajuan bawahan

Fokus utama aplikasi adalah pada tiga pilar:

- Self Service
- Approval
- Attendance

## 2. Tujuan Bisnis Utama

- Memindahkan aktivitas rutin dari kanal manual atau web ke mobile agar lebih cepat dan mudah diakses
- Mempercepat siklus persetujuan melalui approval langsung dari perangkat mobile
- Meningkatkan akurasi data kehadiran dengan presensi berbasis GPS/geofencing
- Mengurangi beban administratif tim HR melalui self service
- Meningkatkan employee experience dengan antarmuka yang sederhana, cepat, dan minim friksi
- Memberikan visibilitas real-time bagi atasan mengenai status tim

## 3. Indikator Keberhasilan

- Adoption Rate: minimum 85% karyawan aktif menggunakan aplikasi dalam 3 bulan
- Attendance Compliance: minimum 90% clock-in/out dilakukan tepat waktu
- Approval Turnaround Time: turun minimal 40% dibanding proses manual/web
- Self Service Deflection: minimum 70% permintaan rutin tidak lagi memerlukan intervensi manual HR
- App Store Rating: minimum 4.3/5.0
- Crash-free Session Rate: minimum 99%

## 4. Modul Utama

- Authentication & Login
- Dashboard / Beranda
- Absensi (Attendance)
- Leave Management (Cuti)
- Self Service Request lainnya (izin, sakit, lembur, tukar shift, dokumen)
- Approval Center
- Kalender Kerja dan Kalender Tim
- Notifikasi
- Slip Gaji & Dokumen Pribadi
- Profil & Pengaturan Akun

## 5. Batasan dan Asumsi

- Aplikasi mobile fokus pada pengalaman Employee dan Atasan/Manager
- Konfigurasi administratif dan setup sistem tetap dilakukan melalui web/back office
- Backend HRMS tersedia atau dibangun paralel dengan aplikasi mobile
- Perangkat harus mendukung GPS dan berjalan pada platform iOS/Android
- Data sensitif tidak boleh diedit bebas dari mobile; akses harus sesuai otorisasi
- Struktur Company Group dan Secondment menjadi konteks bisnis penting dalam skema data dan peran pengguna

## 6. Prinsip Kebutuhan Fungsional

- Proses harus dapat dilakukan secara mandiri oleh pengguna tanpa perlu menghubungi HR secara langsung
- Persetujuan harus dapat dilakukan secara cepat dan transparan dari mana saja
- Data absensi harus tercatat dengan akurasi tinggi dan dapat divalidasi
- Notifikasi harus menjadi bagian penting dari alur approval, absensi, dan pengumuman
- Aplikasi harus menjaga keamanan sesi, otorisasi, dan integritas data sensitif
