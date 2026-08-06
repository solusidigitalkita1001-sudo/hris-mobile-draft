# API Contracts

Dokumen ini berisi ringkasan endpoint API dan payload yang relevan untuk fitur mobile HRMS berdasarkan kebutuhan BRD.

## 1. Autentikasi

- `POST /auth/login`
  - Payload: email/username, password, device info
  - Tujuan: login pengguna dan menghasilkan sesi otentikasi
- `POST /auth/refresh`
  - Payload: refresh token
  - Tujuan: memperbarui sesi pengguna
- `POST /auth/reset-password`
  - Payload: email/username, OTP, password baru
  - Tujuan: reset password akun

## 2. Attendance

- `GET /attendance/today`
  - Tujuan: mengambil status absensi hari ini
- `POST /attendance/clock`
  - Payload: action (clock_in/clock_out), timestamp, latitude, longitude, location accuracy
  - Tujuan: mencatat clock in/out dan validasi geofencing
- `GET /attendance/history`
  - Query: month, employeeId
  - Tujuan: menampilkan riwayat absensi bulanan
- `POST /attendance/correction`
  - Payload: request type, reason, datetime, attachment(optional)
  - Tujuan: mengajukan koreksi absensi melalui self service

## 3. Leave & Self Service

- `GET /leave/balance`
  - Tujuan: mengambil saldo cuti per jenis
- `POST /leave/request`
  - Payload: leave type, start date, end date, reason, attachment(optional)
  - Tujuan: mengajukan cuti atau izin
- `GET /requests/history`
  - Tujuan: menampilkan riwayat pengajuan gabungan
- `POST /requests/cancel`
  - Payload: requestId, reason
  - Tujuan: membatalkan pengajuan yang masih aktif

## 4. Approval

- `GET /approval/pending`
  - Tujuan: mengambil daftar pengajuan yang menunggu persetujuan atasan
- `POST /approval/decision`
  - Payload: requestId, decision (approve/reject), note, delegation(optional)
  - Tujuan: memproses keputusan approval
- `GET /approval/history`
  - Tujuan: menampilkan riwayat keputusan approval

## 5. Notifikasi & Dokumen

- `GET /notifications`
  - Tujuan: mengambil daftar notifikasi pengguna
- `POST /notifications/read`
  - Payload: notificationId
  - Tujuan: menandai notifikasi sebagai dibaca
- `GET /documents/personal`
  - Tujuan: mengambil daftar dokumen pribadi yang dapat dilihat pengguna
- `GET /payroll/slips`
  - Tujuan: mengambil daftar slip gaji yang tersedia

## 6. Profil & Pengaturan

- `GET /profile/me`
  - Tujuan: mengambil profil pengguna aktif
- `PUT /profile/me`
  - Payload: phone, address, emergency contact, notification preferences
  - Tujuan: memperbarui data profil terbatas
- `PUT /settings/preferences`
  - Payload: notification settings, language, biometric preference
  - Tujuan: mengatur preferensi akun

## 7. Catatan Implementasi

- Semua endpoint harus mematuhi otorisasi per role (Employee vs Atasan/Manager)
- Endpoint attendance dan approval harus mempertimbangkan kondisi offline dan resync
- Payload yang mengandung data sensitif harus disimpan dan dikirim dengan perlindungan keamanan yang memadai
