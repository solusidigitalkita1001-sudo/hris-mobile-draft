# API Contracts

Dokumen ini berisi ringkasan endpoint API dan payload yang relevan untuk fitur mobile HRMS. Bagian autentikasi telah diverifikasi terhadap source backend lokal pada 10 September 2026. Bagian modul lain masih merupakan referensi BRD lama dan belum boleh dianggap kontrak backend terverifikasi.

## 1. Autentikasi

Rincian sumber, cookie, identitas employee/company, error, fixture dan batas pengujian ada di [HRIS-001 Kontrak Autentikasi dan Identitas](<../HRIS-001 Kontrak Autentikasi dan Identitas.md>).

- `POST /auth/login`: `{email,password,totp?}`. Respons `data:{user,tokens:{expiresIn}}`; token lewat cookie `at`/`rt`, CSRF lewat cookie `csrf`.
- `GET /auth/me`: `data` langsung berupa user/context; employee/company opsional untuk akun non-employee.
- `GET /auth/csrf`: menerbitkan cookie CSRF; `data:null`.
- `POST /auth/refresh`: cookie `rt`, body boleh kosong; fallback `{refreshToken}` masih diterima. Merotasi cookie `at`/`rt`/`csrf`.
- `POST /auth/logout`: protected; cookie auth + CSRF, body boleh kosong. Revoke refresh dan hapus cookie.
- `POST /auth/change-password`: `{currentPassword,newPassword}`; protected, menghapus flag wajib ganti password dan merevoke refresh token.
- Mutasi dengan cookie `at` atau `rt` memerlukan cookie `csrf` dan header `X-CSRF-Token` yang cocok. Authenticate mendahulukan `at`, lalu Bearer.
- `/auth/forgot-password` dan `/auth/reset-password` tidak dipasang pada auth router source yang diverifikasi, meskipun schema-nya ada.

Source: backend commit `fa1d33cab5b39b2956c400cca046d73915933706`. Verifikasi deployment live ditunda karena akun uji belum tersedia; test lokal memakai fixture sintetis.

## 2. Attendance

Bagian ini diverifikasi terhadap source backend commit yang sama pada 12
September 2026.

- `GET /attendance/context`: query wajib `employeeId` dan `date`, `companyId`
  opsional. Respons memuat branch, schedule, policy, `allowedMethods`,
  `policySnapshot`, dan warnings hasil resolusi server.
- `GET /attendance`: query wajib `companyId`; filter opsional `employeeId`,
  `date`, `month`, dan `status`. Mobile memakai endpoint ini untuk record hari
  ini karena tidak ada `/attendance/today`.
- `POST /attendance`: body wajib `employeeId`, `companyId`, `date`; mobile juga
  mengirim `checkIn`, `method`, `source`, koordinat, serta `deviceGps` berisi
  akurasi dan indikator mock location. Untuk `FACE_RECOGNITION`, selfie kamera
  dikirim sebagai data URI pada `faceRecognition.selfieImage` beserta MIME dan
  ukuran file.
- `PATCH /attendance/:id/checkout`: body `checkOut`, `method`,
  `checkOutLatitude`, dan `checkOutLongitude`.
- `PATCH /attendance/:id/correction`: koreksi record. Kontrak workflow koreksi
  belum diverifikasi untuk UI mobile.

Keputusan geofence dilakukan server berdasarkan policy branch. Client menolak
akurasi di atas 100 meter dan lokasi yang ditandai mocked sebagai pemeriksaan
awal, bukan pengganti validasi server.

Batas backend yang masih terbuka:

- `enforceTrustedFaceRecognition` selalu fail-closed dengan 503 setelah selfie
  dan profil referensi valid karena retrieval/decoding/embedding server belum
  terhubung. Mobile dapat mengambil dan mengirim selfie, tetapi tidak mengklaim
  verifikasi atau keberhasilan ketika server menolak.
- `checkIn` dan `checkOut` masih menerima timestamp client; waktu otoritatif
  server belum diterapkan.
- Header `Idempotency-Key` dikirim mobile, tetapi backend belum memiliki
  middleware/store idempotency. Unique attendance per employee/tanggal hanya
  mengurangi sebagian risiko duplikasi.
- Penolakan mock location server belum konsisten untuk `MOBILE_GPS`; nilai
  `isMockLocation=false` dari client tidak boleh dianggap bukti anti-manipulasi.

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
