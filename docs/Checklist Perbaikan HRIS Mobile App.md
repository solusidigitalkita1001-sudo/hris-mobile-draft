# Checklist Perbaikan HRIS Mobile App

> Dokumen ini adalah baseline audit awal dan beberapa temuan di bawah sudah
> diperbaiki. Status pelaksanaan terkini dan bukti per task berada di
> [Breakdown Task HRIS Mobile App](<Breakdown Task HRIS Mobile App.md>). Jangan
> memakai potongan endpoint lama di dokumen ini sebagai kontrak tanpa mengecek
> [API Contracts](<ai-agent/api-contracts.md>).

Repository mobile: `https://github.com/solusidigitalkita1001-sudo/hris-mobile-draft.git`
Repository web/backend: `https://github.com/solusidigitalkita1001-sudo/hris-draft.git`

Target: aplikasi Employee Self-Service + Approval yang layak rilis ke Play Store/App Store, setara kelas Mekari Talenta / GreatDay / Darwinbox untuk area ESS.

> Urutan pengerjaan wajib ikut prioritas. Jangan poles UI sebelum P0 selesai — sekarang aplikasi ini secara teknis masih **demo/prototype**, bukan aplikasi yang bisa dipakai karyawan.

---

## Ringkasan Hasil Audit Kode

Ini bukan tebakan, semua diverifikasi langsung dari source:

| Temuan | Bukti di kode |
|---|---|
| **10 dari 12 dependency berat tidak dipakai sama sekali** | `firebase_core`, `firebase_messaging`, `flutter_local_notifications`, `connectivity_plus`, `hive`, `image_picker`, `geolocator`, `fl_chart`, `table_calendar`, `uuid` dideklarasi di `pubspec.yaml` tapi 0 import di `lib/`. Hanya `flutter_secure_storage` yang benar-benar dipakai. |
| **GPS palsu** | `DemoLocationService` di `core/services/location_service.dart` return koordinat hardcode `-6.2088, 106.8456` (Monas). Geofencing tidak ada. |
| **Face recognition palsu** | `attendance_screen.dart:226` → `onTap: () => setState(() => _selfieVerified = !_selfieVerified)`. Cuma toggle boolean, tidak ada kamera. |
| **Permission tidak dideklarasi** | `AndroidManifest.xml` hanya punya `INTERNET`. Tidak ada `ACCESS_FINE_LOCATION`, `CAMERA`, `POST_NOTIFICATIONS`. `ios/Runner/Info.plist` tidak punya satu pun `NSxxxUsageDescription` → **auto-reject di App Store review**. |
| **3 modul masih data demo** | `DemoRequestLocalDataSource`, `DemoCalendarLocalDataSource`, `dashboard_local_datasource.dart` berisi data hardcode (R001–R005, event Juni 2025, dsb). |
| **Teks hardcode di UI** | `'Friday, 20 June 2025 · 16:36 WIB'`, `'Menara ACME, Jl. Sudirman 42'`, `'Within office radius (50m)'`, `'On Time'`, `'May 2025'`, `'Rp 45.360.000'`, `'MacBook Pro, iPhone 15 Pro'`. |
| **Quick Actions dikomentari total** | `home_screen.dart` baris ~305–380 seluruh blok Quick Action jadi comment. Header duplikat `// LATEST PAYSLIP` ditulis dua kali. |
| **8 menu mati** | 8 kemunculan `onTap: () {}` (Payroll History, My Documents, Assigned Assets, Certifications, Language, Security, View Monthly Report, Filter). |
| **Tidak ada router** | `main.dart` pakai `IndexedStack` + `setState(_currentIndex)`. Tidak ada `go_router`/`Navigator` named routes → **deep link dari push notification mustahil**, back button Android tidak terkelola. |
| **Tidak ada i18n** | Semua string Inggris hardcode, padahal user target Indonesia dan web sudah punya `frontend/src/i18n`. |
| **Tidak ada CI** | Repo mobile tidak punya `.github/workflows`, padahal repo web punya. |
| **Doc drift** | `docs/ai-agent/api-contracts.md` menyebut `POST /attendance/clock`, `GET /attendance/today`, `POST /leave/request` — backend nyatanya `POST /attendance`, `PATCH /attendance/:id/checkout`, `POST /leave`. |

**Endpoint backend yang sudah jadi tapi belum disentuh mobile sama sekali:**
`/leave/types`, `/leave/balances/employee`, `/leave/:id/workflow`, `/attendance/overtime`, `/attendance/:id/correction`, `/attendance/shift-swaps/my`, `/attendance/shift-swaps/approvals/my`, `/workflow-engine/instances/my-approvals`, `/workflow-engine/instances/bulk-approve`, `/notifications` + `/unread-count` + `/read-all`, `/travel-expense/claims/my` + `/trips/my`, `/employee-loan/my` + `/installments`, `/ewa`, `/document-management/:id/file`, `/payroll/payslips/:id`, `/performance/execution/my-assignments`, `/performance/results/me`, `/training/courses` + `/enrollments`, `/asset`, `/daily-activity`, `/organization/chart`.

Artinya: **backend jauh lebih matang daripada mobile-nya.** Sebagian besar pekerjaan mobile adalah "menyambungkan", bukan "membangun dari nol".

---

## P0 — Blocker: Aplikasi Tidak Bisa Rilis Tanpa Ini

### 1. Absensi harus benar-benar nyata

- [ ] Ganti `DemoLocationService` dengan implementasi `geolocator` asli (`GeolocatorLocationService implements LocationGateway`).
- [ ] Handle seluruh state permission: denied, deniedForever, serviceDisabled, restricted — masing-masing dengan UI dan CTA yang jelas (bukan snackbar generik).
- [ ] Ambil radius & titik kantor dari `GET /attendance/context` atau `/companies/:id/attendance-policy`, **jangan hardcode 50m**.
- [ ] Validasi geofence di **server**, bukan hanya di client. Client hanya kirim lat/long/accuracy; server yang memutuskan valid/tidak.
- [ ] Tolak clock-in jika `accuracy` di atas ambang (mis. >100m) — cegah GPS drift dipakai sebagai excuse.
- [ ] Deteksi **mock location / fake GPS** (`Position.isMocked` di Android). Ini fitur wajib di HRIS Indonesia, kompetitor semua punya.
- [ ] Implementasi selfie asli pakai `image_picker`/`camera` → compress → upload ke `/attendance` sebagai attachment.
- [ ] Sambungkan ke `GET /employees/:id/face-profile` yang **sudah ada di backend** untuk verifikasi wajah, atau hapus label "Face Recognition" sampai fiturnya nyata. Jangan biarkan UI mengklaim sesuatu yang tidak dilakukan.
- [ ] Hapus semua string hardcode di `attendance_screen.dart` (tanggal, jam, nama gedung, status "On Time") → ambil dari server + `intl` dengan locale `id_ID` dan timezone WIB/WITA/WIT.

**Acceptance:** Karyawan di luar radius tidak bisa clock-in walau memodifikasi request. Karyawan dengan fake GPS terdeteksi dan ditolak. Waktu yang tercatat adalah waktu server, bukan waktu device.

### 2. Deklarasi permission & privacy

- [ ] `AndroidManifest.xml`: `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`, `CAMERA`, `POST_NOTIFICATIONS`, `INTERNET`.
- [ ] `Info.plist`: `NSLocationWhenInUseUsageDescription`, `NSCameraUsageDescription`, `NSPhotoLibraryUsageDescription` — tulis dalam Bahasa Indonesia dan spesifik (Apple menolak deskripsi generik).
- [ ] Siapkan Privacy Policy URL + Data Safety form (Play) & Privacy Nutrition Label (App Store). Lokasi + kamera + data kepegawaian = kategori sensitif.
- [ ] Rename `applicationId` dari `com.example.hrm_app` → bundle ID perusahaan. `com.example.*` **ditolak Play Store**.
- [ ] Ganti icon launcher default Flutter dan splash screen.

### 3. Buang data demo dari jalur produksi

- [ ] `DemoRequestLocalDataSource` → `RequestRemoteDataSource` (`GET /leave`, `GET /attendance/overtime`, `GET /permission-request`, `POST /leave`).
- [ ] `DemoCalendarLocalDataSource` → `GET /work-calendar`, `/work-calendar/holidays`, `/work-calendar/shifts`, `/leave?team=true`.
- [ ] `dashboard_local_datasource.dart` → hanya boleh dipakai sebagai **cache offline**, bukan sumber data.
- [ ] Tambahkan build flag `DEMO_MODE` yang default `false`, dan gagal di CI kalau `true` di release build.
- [ ] Hapus `Rp 45.360.000` / `May 2025` dari `home_screen.dart` — angka gaji palsu di layar utama adalah risiko reputasi kalau bocor ke demo klien.

### 4. Keamanan sesi

- [ ] Implementasi refresh token flow + auto-retry 401 sekali di interceptor `dio_client.dart`.
- [ ] Auto logout saat token invalid + hapus cache lokal (termasuk data payroll).
- [ ] Biometric/PIN unlock (`local_auth`) — disebut di BRD, di-list di UI Profile (`'Biometric · PIN'`), tapi belum ada implementasinya sama sekali.
- [ ] Screenshot protection (`FLAG_SECURE`) minimal di layar slip gaji dan dokumen pribadi.
- [ ] Certificate pinning untuk endpoint produksi.
- [ ] Jangan pernah cache slip gaji/dokumen ke storage tanpa enkripsi.

### 5. Push notification

- [ ] Inisialisasi `firebase_core` di `main.dart` (sekarang dependency-nya nganggur).
- [ ] Registrasi FCM token ke backend saat login, hapus saat logout.
- [ ] Handle foreground/background/terminated + `flutter_local_notifications` untuk foreground.
- [ ] Deep link ke detail pengajuan/approval — **wajib ganti ke `go_router` dulu** (lihat P1 #1).
- [ ] Badge unread di bottom bar dari `GET /notifications/unread-count`.
- [ ] Reminder lupa clock-out (local notification terjadwal).

---

## P1 — Navigasi & Arsitektur UI

### 1. Ganti struktur navigasi (ini permintaan utama lo)

**Kondisi sekarang:** 5 tab statis — Home, Attendance, Requests, Calendar, Profile. Semua bobotnya sama, padahal frekuensi pakainya jauh berbeda. Calendar dipakai mungkin 2x sebulan tapi menempati slot yang sama dengan aksi harian.

**Usulan: 4 tab + FAB tengah, adaptif per role.**

```
┌──────────────────────────────────────────────┐
│                    ╭───╮                     │
│  Beranda  Kehadiran│ ⏱ │Pengajuan     Saya   │
│    🏠        📍    ╰───╯    📄        👤     │
└──────────────────────────────────────────────┘
                      ▲
              FAB Clock In / Clock Out
      (berubah warna & label sesuai status hari ini)
```

- [ ] **Beranda** — dashboard, greeting, kartu absensi hari ini, quick action grid, saldo cuti, pengumuman, shortcut slip gaji.
- [ ] **Kehadiran** — riwayat + kalender kerja + shift + lembur + koreksi absensi. **Kalender dilebur ke sini**, jangan jadi tab sendiri.
- [ ] **FAB tengah** — clock in/out satu tap. Ini aksi yang dipakai 2x sehari setiap hari kerja; harus jadi elemen paling menonjol. Talenta menaruh Live Attendance sebagai aksi utama karena alasan yang sama.
- [ ] **Pengajuan** — cuti, izin, sakit, lembur, tukar shift, koreksi absensi, reimbursement, kasbon, perjalanan dinas. Satu pintu masuk.
- [ ] **Saya** — profil, slip gaji, dokumen, aset, sertifikasi, pengaturan.

**Adaptasi role (belum ada sama sekali di kode sekarang):**

- [ ] Untuk Atasan/Manager, tab **Pengajuan** berubah jadi **Approval** dengan badge jumlah pending, dan menu pengajuan pribadi pindah ke dalam tab Saya. Atau tampilkan 5 tab: `Beranda · Kehadiran · [FAB] · Approval · Tim · Saya` (max 5, jangan lebih).
- [ ] Sembunyikan menu yang tidak sesuai permission — jangan tampilkan lalu tolak saat ditap.
- [ ] Ambil kapabilitas dari `GET /rbac/me/resolved` yang **sudah tersedia di backend**.

**Detail teknis bottom bar:**

- [ ] Label pakai Bahasa Indonesia, bukan `Home/Attendance/Requests`.
- [ ] Icon outline saat inactive, filled saat active — sekarang Home pakai `Icons.home_rounded` untuk kedua state, jadi tidak ada perbedaan visual.
- [ ] Badge count di Pengajuan/Approval dan indikator titik di Beranda saat ada pengumuman baru.
- [ ] Haptic feedback ringan saat pindah tab.
- [ ] Hormati `SafeArea` bottom (gesture bar iOS & Android 10+).
- [ ] Tap tab yang sedang aktif = scroll to top; tap-hold = quick action sheet.
- [ ] Sembunyikan bottom bar di layar detail/form (push route, bukan tab).

### 2. Routing

- [ ] Adopsi `go_router`. `IndexedStack` cuma untuk shell tab, bukan pengganti navigasi.
- [ ] Definisikan named route untuk setiap detail: `/requests/:id`, `/approvals/:id`, `/payslip/:period`, `/attendance/:date`.
- [ ] `StatefulShellRoute` supaya state per tab tetap terjaga.
- [ ] Handle back button Android dengan benar (sekarang keluar app dari tab manapun).
- [ ] Deep link scheme + universal link untuk notifikasi.

### 3. State UI yang konsisten

- [ ] Buat komponen standar: `LoadingState`, `EmptyState`, `ErrorState`, `OfflineState`, `PermissionDeniedState` di `core/widgets/`.
- [ ] Ganti `CircularProgressIndicator` polos di `_AuthGate` dengan **skeleton loader** yang mirip bentuk konten.
- [ ] Error harus punya tombol Coba Lagi + pesan berbahasa manusia, bukan raw exception.
- [ ] Optimistic UI untuk approve/reject dengan rollback kalau gagal.
- [ ] Pull-to-refresh di semua list (sekarang cuma di Home).

---

## P2 — Fitur yang Hilang (Gap vs Backend & vs Kompetitor)

### Yang backend-nya SUDAH ADA tapi mobile belum punya

- [ ] **Approval Center** — `GET /workflow-engine/instances/my-approvals`, `POST /instances/:id/actions`, `POST /instances/bulk-approve`. Ini disebut eksplisit di BRD sebagai modul utama, dan **sama sekali tidak ada di aplikasi**. Ini gap paling besar.
- [ ] **Notifikasi** — layar inbox, `read`, `read-all`, unread badge.
- [ ] **Slip gaji** — list periode + detail komponen + download PDF + THR terpisah. Sekarang cuma kartu hardcode di Home.
- [ ] **Saldo cuti per tipe** — `GET /leave/types` + `/leave/balances/employee`. Sekarang angka tunggal tanpa breakdown.
- [ ] **Pengajuan cuti dengan hitung hari kerja otomatis** — sekarang `_showNewRequestSheet` menyimpan `dateRange: 'Select date range'` literal. Tidak ada date picker.
- [ ] **Koreksi absensi** — `PATCH /attendance/:id/correction`.
- [ ] **Lembur** — `POST /attendance/overtime` + lihat estimasi bayaran `/overtime/:id/pay`.
- [ ] **Tukar shift** — `/attendance/shift-swaps/my`, `/candidates/my`, `/approvals/my`. Backend lengkap, mobile nol.
- [ ] **Reimbursement / travel expense** — `/travel-expense/claims/my`, upload foto nota.
- [ ] **Kasbon / pinjaman karyawan** — `/employee-loan/my` + `/installments` + `/amortization`.
- [ ] **Earned Wage Access (EWA)** — modul `ewa` ada di backend dan frontend web.
- [ ] **Dokumen pribadi** — `/document-management/:id/file`, download + preview.
- [ ] **Performance** — `/performance/execution/my-assignments`, `/self-review`, `/results/me`, `/goals`.
- [ ] **Training/LMS** — `/training/courses`, `/enrollments`.
- [ ] **Aset** — daftar aset yang dipegang (sekarang hardcode "MacBook Pro, iPhone 15 Pro").
- [ ] **Daily activity** — modul `daily-activity` ada di backend & web.
- [ ] **Direktori karyawan + struktur organisasi** — `/organization/chart`, `/employees`.
- [ ] **Onboarding checklist** — `/onboarding/checklists`.

### Offline & sinkronisasi

- [ ] Aktifkan `hive` untuk cache: profil, saldo cuti, riwayat absensi 30 hari terakhir, daftar pengajuan.
- [ ] Aktifkan `connectivity_plus` + banner status offline.
- [ ] **Antrian clock-in/out offline** dengan resync otomatis saat online — ini eksplisit diminta di BRD dan jadi pembeda besar di lapangan (pabrik, gudang, area sinyal jelek).
- [ ] Idempotency key (`uuid`, yang juga nganggur) supaya resync tidak menghasilkan absen ganda.
- [ ] Timestamp offline harus disimpan dengan penanda "recorded offline" dan diverifikasi server.

---

## P3 — Tampilan & Kualitas Visual

### Design system

- [ ] Ekstrak spacing/radius/elevation jadi token (`AppSpacing`, `AppRadius`) — sekarang `SizedBox(height: 20)` dan `EdgeInsets.all(20)` bertebaran manual di 6 file screen.
- [ ] Buat `AppTypography` — sekarang `TextStyle(fontSize: 22, fontWeight: FontWeight.bold)` ditulis inline berkali-kali, tidak konsisten dengan `textTheme` yang sudah didefinisikan.
- [ ] **Bundle font Inter sebagai asset.** `google_fonts` mengunduh font saat runtime → first launch tanpa internet akan pakai font fallback dan layout bergeser.
- [ ] Hapus `bottomNavigationBarTheme` yang tidak terpakai (app pakai `NavigationBar` M3, bukan `BottomNavigationBar`) — dead config.
- [ ] Warna gradient `Color(0xff1D4ED8)` di-hardcode di `home_screen.dart` di luar `AppColors`. Konsolidasikan.
- [ ] Definisikan elevation/shadow yang konsisten — sekarang semua card `elevation: 0` + border, tapi kartu absensi pakai gradient tanpa shadow, terlihat datar.

### Layar per layar

- [ ] **Home** — aktifkan kembali Quick Actions (jangan biarkan jadi comment 80 baris), tambah kartu shift hari ini, countdown jam kerja, dan reminder kontrak/probation yang diminta BRD.
- [ ] **Home** — grafik tren kehadiran/lembur pakai `fl_chart` yang sudah jadi dependency tapi nganggur.
- [ ] **Attendance** — ganti kalender manual dengan `table_calendar` (juga nganggur), tambah heatmap bulanan, filter, export.
- [ ] **Requests** — form pengajuan butuh: date range picker, kalkulasi hari kerja otomatis, upload lampiran, preview approver chain, konfirmasi sebelum submit, dan status timeline per pengajuan.
- [ ] **Profile** — 8 menu mati harus disambungkan atau disembunyikan.
- [ ] **Login** — belum ada "Ingat saya", biometric, forgot password (backend web punya `/forgot-password`), dan handling lockout yang disebut BRD.

### Polish

- [ ] Animasi transisi antar tab & shared element untuk kartu → detail.
- [ ] Micro-interaction pada tombol clock in/out (progress ring, konfirmasi sukses, haptic).
- [ ] Dark mode audit menyeluruh — kontras teks `darkTextSub` (#CBD5E1) di atas `darkCard` (#1E293B) perlu dicek terhadap WCAG AA.
- [ ] Format angka & tanggal pakai `intl` locale `id_ID`: `Rp45.360.000`, `Kamis, 10 September 2026`.
- [ ] Handle `textScaleFactor` besar — banyak `Row` dengan teks tanpa `Flexible` akan overflow.
- [ ] Tambahkan `Semantics` label untuk screen reader, minimal di aksi utama.
- [ ] Pastikan tap target ≥48dp (icon size 22 di bottom bar masih oke, tapi cek chevron 18dp di list Profile).
- [ ] Empty state ilustratif, bukan cuma icon abu + teks.

---

## P4 — Engineering & Rilis

- [ ] Tambahkan `.github/workflows` untuk mobile: `flutter analyze`, `flutter test`, build APK/IPA. Repo web sudah punya CI, mobile belum.
- [ ] Naikkan coverage — test yang ada hanya repository-level, belum ada widget/golden test untuk 6 layar.
- [ ] Golden test untuk light & dark mode.
- [ ] Flavor: `dev`, `staging`, `prod` dengan base URL dan app ID berbeda.
- [ ] Crash reporting (Firebase Crashlytics / Sentry) + analytics funnel (login → clock in → submit request).
- [ ] Sinkronkan `docs/ai-agent/api-contracts.md` dengan endpoint backend yang sebenarnya — sekarang isinya salah dan akan menyesatkan siapa pun (termasuk AI agent) yang memakainya sebagai acuan.
- [ ] Hapus `tool/dev_cors_proxy.dart` dari release path.
- [ ] Force-update mechanism (cek versi minimum dari server).
- [ ] Optimasi ukuran APK — Darwinbox secara khusus mengiklankan app ringan 7MB sebagai keunggulan adopsi, karena banyak user menghapus app karena memori penuh.

---

## Perbandingan dengan Kompetitor

### Mekari Talenta (kompetitor paling relevan — pasar Indonesia)

<cite index="2-1">Fitur unggulan absensinya adalah Live Attendance, di mana karyawan cukup mengambil foto selfie dan sistem otomatis mendeteksi lokasi; tersedia juga absensi dinas untuk meeting di luar kantor.</cite> <cite index="3-1">Foto selfie diverifikasi dengan face recognition untuk mencegah kecurangan, slip gaji didistribusikan otomatis ke smartphone karyawan, dan absensi berbasis GPS mendukung pemantauan saat WFH.</cite> <cite index="6-1">Dari sisi karyawan, yang dipakai sehari-hari adalah payslip, reimburse, request time off, perubahan shift, informasi benefit, serta akses gaji lebih awal lewat fitur Accessible Salary.</cite>

**Gap aplikasi lo:** absensi dinas ❌, face recognition nyata ❌, distribusi slip gaji ❌, reimburse ❌, tukar shift ❌, benefit ❌, EWA ❌ (padahal backend sudah punya modul `ewa`).

### Darwinbox (benchmark UX enterprise)

<cite index="9-1">Aplikasinya mencakup slip gaji dan formulir pajak, pengajuan perjalanan dinas dan klaim reimbursement, cek saldo cuti dan kalender libur, goals dan performance review serta modul learning, feed sosial internal untuk apresiasi antar rekan, direktori karyawan dan org chart, approval cuti/absensi/permintaan secara real-time, toolkit manajemen tim termasuk shift dan roster, serta push notification untuk approval dan perubahan shift.</cite> <cite index="8-1">Mereka juga menyediakan asisten virtual berbasis AI dengan 140+ intent yang memunculkan aksi langsung di dalam jendela chat sehingga user tidak perlu menavigasi menu.</cite>

**Ambil pelajarannya:** org chart + direktori karyawan itu murah dibangun (backend lo sudah punya `/organization/chart` dan `/employees`) tapi dampak adopsinya besar. Feed/apresiasi internal adalah pembeda engagement yang belum lo punya sama sekali.

### Standar pasar Indonesia (GajiHub, GreatDay, Gadjian, KaryaONE)

<cite index="21-1">Pola yang sudah jadi standar: karyawan memotret nota lalu mengirim pengajuan reimbursement dari ponsel, dan setelah disetujui atasan nominalnya otomatis masuk rekap gaji bulan berjalan. Mekanisme yang sama berlaku untuk kasbon — sistem mencatat tenor cicilan dan memotong gaji otomatis di bulan berikutnya.</cite> <cite index="18-1">Di sisi payroll, output yang diharapkan mencakup laporan pajak 1721-A1, pembayaran BPJS, slip gaji digital, serta laporan lembur, pinjaman, dan reimbursement.</cite>

**Gap aplikasi lo:** foto nota ❌, tracking cicilan kasbon ❌ (backend `/employee-loan/:id/installments` sudah ada), akses bukti potong 1721-A1 ❌.

### Matriks ringkas

| Fitur ESS | App lo | Talenta | Darwinbox | Standar pasar ID |
|---|---|---|---|---|
| Clock in/out GPS | ⚠️ palsu | ✅ | ✅ | ✅ |
| Selfie + face recognition | ⚠️ palsu | ✅ | ✅ | ✅ |
| Anti fake-GPS | ❌ | ✅ | ✅ | ✅ |
| Absen offline + resync | ❌ | ✅ | ✅ | ✅ |
| Absensi dinas / kunjungan | ❌ | ✅ | ✅ | ✅ |
| Pengajuan cuti + saldo per tipe | ⚠️ dummy | ✅ | ✅ | ✅ |
| Lembur | ❌ | ✅ | ✅ | ✅ |
| Tukar shift | ❌ | ✅ | ✅ | ✅ |
| Koreksi absensi | ❌ | ✅ | ✅ | ✅ |
| **Approval center (atasan)** | ❌ | ✅ | ✅ | ✅ |
| Slip gaji + unduh PDF | ⚠️ hardcode | ✅ | ✅ | ✅ |
| Bukti potong pajak 1721-A1 | ❌ | ✅ | ✅ | ✅ |
| Reimbursement foto nota | ❌ | ✅ | ✅ | ✅ |
| Kasbon / pinjaman + cicilan | ❌ | ✅ | ✅ | ✅ |
| EWA / gaji lebih awal | ❌ | ✅ | ➖ | ➖ |
| Push notification + deep link | ❌ | ✅ | ✅ | ✅ |
| Dokumen pribadi | ❌ | ✅ | ✅ | ✅ |
| Direktori + org chart | ❌ | ✅ | ✅ | ➖ |
| Performance / goals | ❌ | ✅ | ✅ | ➖ |
| Learning / LMS | ❌ | ➖ | ✅ | ➖ |
| Feed sosial / apresiasi | ❌ | ➖ | ✅ | ➖ |
| Biometric login | ❌ | ✅ | ✅ | ✅ |
| Bahasa Indonesia | ❌ | ✅ | ✅ | ✅ |

---

## Urutan Eksekusi yang Disarankan

**Sprint 1–2 (P0):** permission + bundle ID + GPS asli + anti-fake-GPS + selfie asli + buang data demo + refresh token. Output: aplikasi yang datanya jujur.

**Sprint 3 (P1):** `go_router` + bottom bar baru + role-adaptive nav + state UI standar. Output: kerangka navigasi yang bisa ditumpangi fitur.

**Sprint 4–5 (P2 prioritas tinggi):** Approval Center + Notifikasi + Slip Gaji + Cuti lengkap dengan date picker. Ini empat fitur yang paling terasa hilang.

**Sprint 6–7 (P2 sisanya):** lembur, tukar shift, koreksi absensi, reimbursement, kasbon, dokumen, offline queue.

**Sprint 8 (P3–P4):** design system, i18n, polish, CI, crash reporting, rilis beta internal.

---

## Definition of Done Global

- [ ] `flutter analyze` bersih, `flutter test` hijau, build release Android & iOS sukses di CI.
- [ ] Tidak ada `Demo*DataSource`, tidak ada `onTap: () {}`, tidak ada string tanggal/nominal hardcode di `lib/`.
- [ ] Setiap dependency di `pubspec.yaml` benar-benar di-import, atau dihapus.
- [ ] Setiap layar punya loading, empty, error, offline, dan permission-denied state.
- [ ] Semua validasi kritikal (geofence, kuota cuti, otorisasi approval) dieksekusi di server.
- [ ] Semua teks lewat layer i18n, default `id_ID`.
- [ ] Tidak ada data sensitif (slip gaji, dokumen) tersimpan tanpa enkripsi atau ikut ter-log.
- [ ] `docs/ai-agent/api-contracts.md` sinkron dengan `backend/src/modules/*/*.routes.ts` yang sebenarnya.
