# Audit HRIS Mobile App dan Perbandingan Checklist

Tanggal: 10 September 2026. Basis: working tree di atas commit `23876b2`, termasuk perubahan autentikasi yang belum di-commit.

Acuan kebutuhan: [Checklist Perbaikan HRIS Mobile App](<Checklist Perbaikan HRIS Mobile App.md>). Checklist asli tidak diubah. Laporan ini menjadi baseline teknis untuk menyusun pekerjaan development.

## 1. Kesimpulan dan batas audit

Aplikasi berada pada tahap **prototype dengan integrasi API parsial**, belum memenuhi acceptance P0 untuk dipakai karyawan. Fondasi Riverpod, pemisahan domain/data/presentation, Dio, dan secure storage sudah tersedia. Namun beberapa aksi utama masih simulasi, sebagian data masih contoh, dan jalur autentikasi serta isolasi data antar akun memerlukan perbaikan.

Audit mencakup source `lib/`, konfigurasi Android/iOS, dependency, dokumentasi integrasi, dan seluruh test saat ini. Analyzer, test dengan coverage, serta build Android release dijalankan. Audit ini tidak melakukan transaksi ke backend, tidak menjalankan pengujian perangkat fisik, dan tidak memeriksa source repository backend. Karena itu, keberadaan endpoint di checklist dan validasi server **belum terverifikasi**. Tidak ada kode aplikasi yang diperbaiki dalam audit ini.

Status yang digunakan:

- **Ada:** implementasi ditemukan; tidak otomatis berarti teruji terhadap backend nyata.
- **Parsial:** sebagian alur sudah tersedia, tetapi acceptance belum terpenuhi.
- **Belum:** implementasi tidak ditemukan dalam source yang diperiksa.
- **Verifikasi:** membutuhkan kontrak backend, perangkat, pengujian runtime, atau konfigurasi eksternal.

Referensi baris di laporan ini merujuk working tree pada tanggal audit dan dapat bergeser setelah development berikutnya.

## 2. Hasil pemeriksaan otomatis

| Pemeriksaan | Hasil | Batas pembuktian |
|---|---|---|
| `flutter analyze` | Lulus, tidak ada issue | Tidak mendeteksi aksi bisnis simulasi atau ketidakcocokan kontrak API |
| `flutter test --coverage` | 26 test lulus dalam 11 file | Banyak test memakai fake/demo; belum membuktikan transaksi server |
| Line coverage LCOV | 1.463 / 2.434 baris, **60,11%** | Persentase terhadap baris yang masuk laporan LCOV, bukan persentase fitur selesai |
| `git diff --check` | Lulus pada perubahan yang sudah ada | Pemeriksaan whitespace |
| `flutter build apk --release --no-pub` | Lulus, APK **54,7 MB**, waktu build sekitar 210 detik | Release masih memakai debug signing; ada warning Java source/target 8 obsolete dan deprecated API |
| Build iOS / IPA | Tidak dijalankan | Lingkungan audit Linux; memerlukan macOS/Xcode dan konfigurasi signing |
| Uji login/refresh/logout dan ESS terhadap backend | Belum dijalankan | Membutuhkan akun uji, kontrak respons, dan data employee/company yang sesuai |

Area berisiko memiliki coverage rendah:

| File | Baris tercakup / terukur | Coverage |
|---|---:|---:|
| `lib/core/network/dio_client.dart` | 15 / 114 | 13,16% |
| `lib/features/authentication/data/repositories/auth_repository_impl.dart` | 26 / 52 | 50,00% |
| `lib/features/authentication/data/datasources/auth_remote_datasource.dart` | 1 / 21 | 4,76% |
| `lib/features/attendance/data/datasources/attendance_remote_datasource.dart` | 22 / 89 | 24,72% |
| `lib/features/dashboard/data/datasources/dashboard_remote_datasource.dart` | 1 / 124 | 0,81% |
| `lib/features/profile/data/datasources/profile_remote_datasource.dart` | 1 / 66 | 1,52% |

Catatan: file attendance remote juga memuat adapter demo, sehingga coverage file tersebut tidak boleh dibaca sebagai coverage request Dio. Test attendance menggunakan `DemoAttendanceRemoteDataSource` (`test/features/attendance/attendance_repository_test.dart:11`). Terdapat tiga widget test di `test/widget_test.dart`; belum ditemukan golden test, integration test, maupun test khusus interceptor HTTP. Artefak coverage berada di `coverage/lcov.info`; APK berada di `build/app/outputs/flutter-apk/app-release.apk`. Keduanya diabaikan Git. Ukuran APK hasil perintah ini bukan ukuran unduhan App Bundle per perangkat.

## 3. Temuan prioritas dengan bukti kode

### F01 — P0: tombol absensi Beranda tidak mencatat absensi

**Bukti:** [home_screen.dart](../lib/features/dashboard/presentation/screens/home_screen.dart), baris 17–22 dan 277–280. Tombol hanya mengganti `_clockedInOverride` melalui `setState`, tanpa memanggil use case atau API. Pull-to-refresh tidak menghapus override tersebut.

**Dampak:** pengguna dapat melihat perubahan Clock In/Out tanpa pencatatan server. Status Beranda dan tab Attendance bisa berbeda.

**Acceptance perbaikan:** kedua pintu masuk menggunakan satu alur absensi; status berubah berdasarkan hasil server; kegagalan tidak menampilkan status sukses; refresh menyelaraskan status kedua layar.

### F02 — P0: GPS, selfie, dan payload absensi belum membuktikan kehadiran

**Bukti:** `lib/core/services/location_service.dart:6` memakai `DemoLocationService`. `attendance_screen.dart:18` menginisialisasi selfie dan GPS sebagai terverifikasi; baris 226 hanya toggle selfie. `attendance_remote_datasource.dart:55` menerima `AttendanceCommand`, tetapi request baris 61–67 tidak menyertakan koordinat. Checkout baris 89 hanya mengirim waktu perangkat. `GeoCoordinate` dan `AttendanceCommand` belum memiliki accuracy, status mock, atau attachment.

**Dampak:** mengganti location service saja tidak cukup karena koordinat masih terputus sebelum request. UI mengklaim verifikasi yang belum dilakukan. Belum ada bukti backend menolak absensi di luar radius atau waktu yang dimanipulasi.

**Acceptance perbaikan:** permission dan GPS nyata, accuracy/mock terukur, selfie/upload sesuai kontrak, lokasi terkirim, kebijakan kantor dari server, serta pengujian penolakan server. Flag mock dari client sendiri bukan bukti bahwa request tidak dapat dimanipulasi.

### F03 — P0: state fitur tidak diisolasi saat pergantian akun

**Bukti:** `auth_controller.dart:31` membersihkan token/context saat logout, tetapi tidak menginvalidasi provider fitur. Provider dashboard/profile/attendance/request bukan `autoDispose`. `DashboardController.build` (`:8`), `ProfileController.build` (`:8`), dan `AttendanceController.build` (`:10`) membaca dependency dengan `ref.read`, tanpa mengamati perubahan identitas sesi.

**Skenario dari alur kode:** akun A membuka fitur → logout → akun B login dalam proses aplikasi yang sama. Provider yang masih hidup dapat menyajikan state A dan tidak menjalankan `build` kembali berdasarkan identitas B. Respons tertunda akun A juga belum memiliki penjagaan identitas sesi sebelum memperbarui state.

**Dampak:** risiko data dan status akun sebelumnya terlihat pada akun berikutnya. Ini temuan statis yang perlu test reproduksi lintas akun; belum diuji di perangkat.

**Acceptance perbaikan:** state dan cache diikat ke identitas akun/company, dibersihkan saat logout/invalidation; respons sesi lama tidak dapat memperbarui sesi baru. Test A → logout → B wajib lulus.

### F04 — P0: restore sesi dapat menimpa token hasil refresh dengan token lama

**Bukti:** `auth_repository_impl.dart:29–40` membaca `cached` sebelum `/auth/me`. Bila request tersebut 401, `dio_client.dart:156–182` menyimpan token baru lalu retry. Setelah `/auth/me` berhasil, `cached.mergeUser(user)` memakai token dari objek lama (`auth_session_dto.dart:126–130`), kemudian `_save` menulisnya kembali.

**Dampak:** pada jalur Bearer, access/refresh token baru dapat tertimpa token sebelum rotasi; request berikutnya berisiko gagal. Dukungan refresh sudah ada, tetapi belum layak ditandai selesai.

**Acceptance perbaikan:** penggabungan profil tidak mengganti kredensial terbaru; test restore dengan `/me` 401 → refresh berhasil → `/me` 200 memastikan secure storage tetap menyimpan token hasil rotasi.

### F05 — P0: dukungan cookie/CSRF masih membutuhkan validasi kontrak dan hardening

**Bukti:** `cookie_session.dart:3–20` hanya menyimpan pasangan nama/nilai cookie; atribut domain/path/secure/expiry dibuang. `dio_client.dart:69` menambahkan kredensial tanpa pemeriksaan origin request; `_storeCookieSession` juga tidak memeriksa origin respons. DTO login (`auth_session_dto.dart:34`) menerima keberadaan cookie nonkosong sebagai penanda cookie auth tanpa membedakan cookie autentikasi dari cookie lain. Refresh baris 162–172 dapat menganggap cookie lama yang masih tersimpan sebagai kredensial walaupun respons tidak memberi token baru.

**Dampak:** batas pengiriman dan masa berlaku cookie tidak direpresentasikan; bila Dio yang sama dipakai untuk URL absolut lain, kredensial ikut dikirim. Tidak ditemukan penggunaan lintas host saat ini, sehingga ini risiko pada desain transport, bukan bukti kebocoran yang sudah terjadi.

**Catatan koreksi:** log login yang diberikan sebelumnya menunjukkan body tanpa access token. Log tersebut tidak menyertakan `Set-Cookie`, sehingga pernyataan sebelumnya bahwa cookie `HttpOnly` sudah terkonfirmasi terlalu kuat. Implementasi cookie adalah kandidat solusi yang harus dibuktikan dari header login aktual dan request lanjutan. Jalur Flutter Web juga belum memiliki konfigurasi adapter credential khusus dan belum diuji.

**Acceptance perbaikan:** dokumentasikan nama dan cakupan cookie/token, CSRF, rotasi, expiry, logout serta perbedaan native/web; uji dengan respons tersanitasi dan backend. Cookie non-auth tidak boleh cukup untuk membuka sesi. Pengiriman kredensial dibatasi pada origin yang diizinkan.

### F06 — P0: beberapa kondisi gagal autentikasi belum menutup sesi dengan benar

**Bukti:** `dio_client.dart:88–90` langsung meneruskan 401 pada request yang sudah retry, tanpa invalidasi sesi; 401 login juga masuk alur refresh karena yang dikecualikan hanya `/auth/refresh`. `AuthSessionDto.mustChangePassword` disimpan, tetapi tidak digunakan sebagai guard pada `_AuthGate` (`lib/main.dart:76`).

**Dampak:** UI dapat tetap berada dalam sesi yang request-nya terus ditolak; login salah dapat memicu refresh sesi lama; kewajiban mengganti password tidak ditegakkan oleh navigasi mobile. Penegakan backend belum diperiksa.

**Acceptance perbaikan:** pisahkan 401 login dari protected request; invalidasi konsisten pada refresh/retry gagal; kewajiban mengganti password mengikuti kontrak backend dan diuji.

### F07 — P0: data contoh masih tampil dan pengajuan tidak tersimpan di server

**Bukti:** Home baris 555/565 berisi periode dan gaji tetap. Riwayat absensi memakai `AttendanceHistoryData.thisWeek` (`attendance_screen.dart:345`), yang berisi contoh Juni di `attendance_history_item.dart:21`. Request dan calendar dependency memilih `DemoRequestLocalDataSource` dan `DemoCalendarLocalDataSource`. Form request baris 573 memiliki input alasan tanpa binding; submit baris 587 hanya mengirim jenis. Datasource request baris 56 menyimpan literal `Select date range` ke list memory.

**Dampak:** list pengajuan terlihat berhasil, tetapi tidak ada proses approval atau persistence server. Alasan yang diketik tidak masuk command. Kalender `Today` kembali ke 20 Juni 2025 (`calendar_screen.dart:98`), dan daftar Upcoming di baris 307 juga memiliki event hardcode langsung di layar. Mengganti datasource kalender saja belum menghapus semua contoh.

**Acceptance perbaikan:** hilangkan data contoh dari jalur pengguna nyata; setiap submit menghasilkan ID server dan muncul lagi setelah aplikasi dibuka ulang; tanggal/alasan/lampiran dikirim dan tervalidasi.

### F08 — P0: transport dan logging belum memenuhi kebutuhan data sensitif

**Bukti:** `app_config.dart:23` memakai HTTP sebagai fallback; Android manifest baris 6 mengizinkan cleartext; iOS Info.plist baris 29–40 memiliki pengecualian HTTP. `dio_client.dart:37–43` menonaktifkan log header/request body tetapi tidak response body. Versi logger terpasang 1.4.0 memiliki default `responseBody: true`.

**Dampak:** pada konfigurasi development tersebut transport tidak terenkripsi. Saat debug logging diaktifkan, respons login, CSRF, identitas atau data gaji dari API bisa tercetak. Logger dibatasi `kDebugMode`, jadi temuan logging ini bukan klaim bahwa release selalu mencetak body.

**Acceptance perbaikan:** konfigurasi produksi memerlukan HTTPS; log sensitif diredaksi/dinonaktifkan; pinning bila tetap menjadi requirement dilengkapi strategi rotasi sertifikat; tidak ada secret dalam asset konfigurasi.

### F09 — P1: error API berubah menjadi angka kosong/seolah valid

**Bukti:** `dashboard_remote_datasource.dart:61–72` menangkap kegagalan menjadi `null`; parser memberi default nol/list kosong. Persentase bulanan dapat menjadi 100 berdasarkan satu check-in hari ini bila jumlah hari kerja tidak tersedia (`:179–182`). `profile_remote_datasource.dart:31–34` mengembalikan fallback pada error. Controller dashboard/profile hanya menyimpan entity, bukan status loading/error per section.

**Dampak:** pengguna tidak dapat membedakan saldo nol dengan saldo gagal dimuat; statistik bulanan dapat tampil tanpa data bulanan memadai.

**Acceptance perbaikan:** bedakan loading, kosong, gagal, dan data lama; retry per section; angka yang belum tersedia tidak diganti angka bisnis rekaan.

### F10 — P1: identitas employee/company dan sinkronisasi absensi belum lengkap

**Bukti:** payload login admin yang diberikan sebelumnya tidak berisi employee/company. `AuthController._setContext` hanya memetakan field sesi. Attendance menolak context kosong (`attendance_remote_datasource.dart:101`); dashboard menghentikan seluruh fetch termasuk notifikasi bila employee/company tidak ada (`dashboard_remote_datasource.dart:25`). Summary hanya mengirim company/month/year (`:36`), sehingga scope employee harus diverifikasi. Request daftar absensi tidak mengirim tahun maupun menangani pagination. Tanggal clock-in dibuat dari tanggal UTC sementara pembacaan hari ini memakai tanggal lokal.

**Dampak:** sukses login belum berarti akun bisa memakai ESS; akun admin tidak boleh diasumsikan punya employee. Ada risiko mengambil agregat perusahaan sebagai ringkasan pribadi jika backend tidak membatasi sendiri, serta ketidakcocokan tanggal sekitar pergantian hari.

**Acceptance perbaikan:** kontrak identitas ESS jelas, capability sesuai role, notifikasi tidak bergantung pada employee kecuali kontraknya mensyaratkan; scope/year/pagination/timezone diuji. Jangan mengisi employee/company dengan ID contoh.

### F11 — P1: alur clock-in/out belum aman terhadap loading dan kegagalan lokasi

**Bukti:** tombol Attendance (`attendance_screen.dart:272`) tetap aktif, getter status baris 329–330 default ke `true` saat data belum ada, dan controller tidak memiliki guard operasi sedang berjalan. `ClockIn.call`/`ClockOut.call` memanggil lokasi di luar pemetaan failure; exception lokasi dapat keluar setelah state controller dibuat loading. Setelah selesai checkout, controller memilih clock-in bila `isActive == false`; aturan sesi kedua per hari belum dimodelkan.

**Acceptance perbaikan:** state eksplisit belum mulai/aktif/selesai/error; blok double-submit; idempotency sesuai server; permission failure tidak meninggalkan spinner atau klaim clocked-in; aturan multi-shift dipastikan terlebih dahulu.

### F12 — P1/P4: konfigurasi distribusi masih development

**Bukti:** `android/app/build.gradle.kts:21` menggunakan `com.example.hrm_app`, dan baris 34 menandatangani release dengan debug signing. iOS masih memakai `com.example.hrmApp`. Tidak ditemukan `.github/workflows`, flavor produksi, crash reporting, maupun force-update flow. Android manifest utama baru mendeklarasikan `INTERNET`; izin camera/location/notifikasi dan deskripsi penggunaan iOS belum ditambahkan.

**Acceptance perbaikan:** ID milik organisasi, signing rilis, environment terpisah, izin sesuai fitur yang benar-benar digunakan, CI build Android/iOS, dan bukti pengujian perangkat. APK yang berhasil dibuat belum membuktikan siap dipublikasikan.

## 4. Perbandingan dengan kesimpulan audit pada checklist

| Pernyataan checklist | Hasil audit saat ini | Perlakuan untuk development |
|---|---|---|
| GPS dan face recognition palsu | Masih sesuai; koordinat bahkan belum masuk payload | P0 tetap terbuka; lihat F01/F02/F11 |
| Permission belum dideklarasikan | Sesuai untuk manifest/config sumber; merged manifest plugin belum diaudit | Deklarasikan sesuai fitur, lalu cek hasil build/platform |
| Tiga modul masih demo | Perlu diperinci: Request/Calendar demo; Dashboard/Profile campuran remote dan fallback; riwayat Attendance juga contoh | Audit jalur provider dan konten layar, bukan hanya nama file |
| Refresh token belum ada | Sudah ada single-flight refresh dan retry; masih memiliki celah F04–F06 | Tandai parsial, bukan membuat ulang atau menandai selesai |
| Saldo cuti dan notifikasi belum disentuh | Sudah ada GET saldo per employee dan GET notifikasi untuk dashboard | Lengkapi kontrak dan fitur, jangan menggandakan integrasi |
| Saldo cuti hanya angka tunggal | Parser/dashboard sudah memiliki list `LeaveBalance` per tipe | Belum ada katalog `/leave/types` dan integrasi form cuti lengkap |
| Tidak ada i18n, semua Inggris | Login punya toggle ID/EN lokal; sebagian pesan error Indonesia; belum ada i18n global | Migrasikan ke locale terpusat dan persistensi preferensi |
| Tidak ada widget test | Ada tiga widget test, selain unit/repository/architecture test | Tambah test skenario bisnis, golden dan integration yang belum ada |
| Delapan menu mati | Ada **10 lokasi callback kosong aktif**, ditambah reuse `_MenuRow` untuk tujuh menu profil; hitungan lokasi kode bukan jumlah tombol runtime | Inventarisasi per aksi; jangan memakai angka delapan sebagai acceptance |
| Quick Actions dinonaktifkan dan gaji contoh | Masih sesuai; tombol absensi Home juga simulasi | Hapus klaim sukses palsu sebelum pemolesan |
| Tidak ada router | Tidak ada router detail/deep link; yang tersedia `MaterialApp` + `IndexedStack` dan modal | `go_router` adalah arah implementasi checklist; acceptance berupa perilaku navigasi/deep link |
| Tidak ada CI dan dokumentasi drift | Masih sesuai | CI dasar dan inventaris kontrak perlu lebih awal |
| Sepuluh dari dua belas dependency berat tidak dipakai | Definisi angka tidak jelas; hitungan aktual di bagian 7 | Pisahkan import langsung, asset, tool build, dan dependency transitif |
| Klaim pasti ditolak store / perbandingan kompetitor | Tidak diverifikasi oleh audit source mobile ini; penanda `<cite index=...>` tidak menyediakan sumber yang dapat ditelusuri | Jangan jadikan klaim tersebut bukti teknis atau pengganti pemeriksaan persyaratan distribusi |

## 5. Matriks seluruh area P0–P4

### P0 — blocker

| Kelompok checklist | Status | Kekurangan utama / tindak lanjut |
|---|---|---|
| GPS asli, permission states, accuracy, anti-mock | Belum | F02/F11; model lokasi dan failure perlu diperluas |
| Titik kantor/radius, validasi server, waktu server | Verifikasi + belum di mobile | Pastikan kontrak policy dan endpoint pencatatan ESS, bukan mengasumsikan endpoint administrasi cocok |
| Selfie, kompresi/upload, face profile | Belum | Kamera, lifecycle berkas, multipart/reference attachment, validasi server |
| Tanggal/jam/alamat/status nyata | Parsial | Dashboard sebagian dinamis; Attendance/history/calendar masih contoh |
| Permission Android/iOS | Belum | F12; lihat manifest sumber, lanjut verifikasi merged manifest |
| Privacy policy dan deklarasi data store | Verifikasi | Tidak ditemukan URL/integrasi di aplikasi; isi console store tidak diperiksa |
| Bundle ID, launcher, splash | Parsial | Aset launcher/splash ada; ID masih contoh. Identitas visual final belum dinilai secara visual |
| Pengajuan remote | Belum | List dan submit masih memory |
| Kalender remote | Belum | Hari libur, shift, kalender tim belum dipanggil |
| Dashboard sebagai cache, DEMO_MODE | Belum | Demo datasource belum menjadi cache server; flag/guard release belum ada |
| Menghapus gaji contoh | Belum | F07 |
| Refresh, retry, invalidation, pembersihan cache | Parsial | F03–F06; secure storage ada, reset seluruh state belum ada |
| Biometric/PIN | Belum | Menu Security masih kosong; `local_auth` belum ada |
| Screenshot protection dan encrypted document cache | Belum | Fitur dokumen/slip belum ada; kebijakan harus menyertai implementasinya |
| HTTPS/pinning produksi | Belum | F08; konfigurasi pinning tidak ditemukan |
| Firebase/FCM register-delete, tiga lifecycle notification | Belum | Dependency ada; inisialisasi dan API token belum ada |
| Deep link notifikasi | Belum | Bergantung fondasi routing P1 |
| Unread badge dan pengingat clock-out | Belum | GET notifikasi dashboard bukan implementasi push/badge |

### P1 — navigasi dan state

| Kelompok checklist | Status | Kekurangan utama / tindak lanjut |
|---|---|---|
| Empat tab + FAB, kalender masuk Kehadiran | Belum | Lima tab statis; tidak ada FAB utama |
| Beranda/Saya/Pengajuan dengan fitur lengkap | Parsial | Kerangka layar ada; menu, aksi, data belum lengkap |
| Navigasi atasan, permission filtering, resolved RBAC | Belum | Roles/permissions disimpan, belum digunakan sebagai guard/menu capability |
| Bahasa label tab, outline/filled, badge | Parsial | Label Inggris; Home memakai icon yang sama untuk aktif/nonaktif; badge belum ada |
| Haptic, tap aktif scroll-to-top, tap-hold sheet | Belum | Handler tab hanya mengganti index |
| SafeArea dan perilaku back Android | Verifikasi | `NavigationBar` tersedia, tetapi inset dan back belum diuji perangkat; absennya wrapper SafeArea saja tidak cukup untuk menyatakan bug |
| Router, named detail route, shell state, deep/universal link | Belum | Tidak ada route detail maupun intent filter link aplikasi |
| Sembunyikan bottom bar di detail/form | Belum lengkap | Form memakai modal; hierarki halaman detail belum ada |
| Komponen loading/empty/error/offline/permission | Parsial | Requests/Calendar memiliki empty state lokal; belum komponen/state konsisten |
| Skeleton auth, retry manusiawi, refresh semua list | Parsial | Auth spinner; Attendance snackbar raw error; pull-to-refresh hanya Home |
| Optimistic approval + rollback | Belum | Modul approval belum ada; kebijakan update harus sesuai hasil otorisasi server |

### P2 — fitur ESS dan offline

| Fitur checklist | Status mobile | Pekerjaan berikutnya |
|---|---|---|
| Approval Center | Belum | Inbox, detail workflow, approve/reject, bulk, permission, alasan, audit trail |
| Notifikasi | Parsial | Dashboard mengambil tiga item; inbox/read/read-all/unread/deep link belum ada |
| Slip gaji, THR, PDF | Belum | Kartu contoh saja; katalog periode dan kontrak file belum dipastikan |
| Saldo cuti per tipe | Parsial | GET balances dan list tersedia; types, ketelitian angka, kontrak belum diuji |
| Pengajuan cuti/hari kerja/workflow | Belum | Date picker, alasan, kalender kerja, upload, server submit, status timeline |
| Koreksi absensi | Belum | Form, lampiran, validasi, lifecycle approval |
| Lembur dan estimasi bayaran | Belum | Menu/demo bukan transaksi server |
| Tukar shift | Belum | Kandidat, pengajuan, persetujuan, shift hasil perubahan |
| Reimbursement/perjalanan dinas | Belum | Detail trip/claim, foto nota, status approval |
| Kasbon/pinjaman/cicilan | Belum | Pengajuan dan jadwal cicilan |
| EWA | Belum | Verifikasi entitlement dan kontrak backend |
| Dokumen pribadi | Belum | Menu tidak aktif; download/preview/proteksi |
| Performance/goals/review | Belum | Belum ada modul mobile |
| Training/LMS | Belum | Belum ada modul mobile |
| Aset | Belum | Deskripsi perangkat hardcode di Profile |
| Daily activity | Belum | Belum ada modul mobile |
| Direktori dan org chart | Belum | GET detail employee untuk profil bukan direktori/org chart |
| Onboarding checklist | Belum | Belum ada modul mobile |
| Cache profil/cuti/riwayat/pengajuan | Belum | Sumber demo bukan cache; desain harus terisolasi per akun/company |
| Offline banner/connectivity | Belum | Dependency belum dipakai |
| Queue offline, resync, idempotency, waktu offline | Belum | Kontrak penerimaan absensi offline dan replay perlu disepakati dengan backend |

### P3 — kualitas tampilan

| Kelompok checklist | Status | Catatan |
|---|---|---|
| Spacing/radius/elevation/typography tokens | Parsial | `AppColors`, `AppTheme`, dan `textTheme` ada; spacing/radius dan style inline masih tersebar |
| Font Inter bundled | Belum | `GoogleFonts.interTextTheme`; tidak ada deklarasi asset font di pubspec |
| Dead theme dan warna gradient inline | Belum diperbaiki | `bottomNavigationBarTheme` masih ada meski shell memakai `NavigationBar`; warna inline masih ada |
| Konsistensi shadow/elevation | Verifikasi visual | Ada shadow pada tombol absensi; klaim seluruh UI datar perlu penilaian visual, bukan menghitung shadow |
| Quick Actions, shift, countdown, reminder kontrak | Belum lengkap | Greeting/durasi tersedia sebagian; Quick Actions dikomentari |
| Grafik tren/heatmap/filter/export | Belum | Tidak ada import `fl_chart`/`table_calendar`; pemilihan library bukan bukti fitur selesai |
| Form request lengkap dan menu Profile | Belum | F07; tujuh instance menu profil memakai handler kosong |
| Login remember/biometric/forgot password/lockout | Belum lengkap | Validasi form dan error tersedia; fitur spesifik tersebut belum ada |
| Transisi tab/shared element/micro-interaction | Parsial | Ada `AnimatedContainer`; progress/success/haptic dan route transition belum lengkap |
| Dark mode, skala teks, semantics, tap target | Verifikasi | Theme light/dark dan satu widget test dark login ada; belum audit aksesibilitas/render seluruh layar |
| `intl id_ID` dan timezone perusahaan | Parsial | `intl` hanya di mapping join date profil, tanpa locale eksplisit; login ID/EN lokal |
| Empty state visual | Parsial | Ada empty state lokal; konsistensi dan kebutuhan ilustrasi perlu review visual |

### P4 — engineering dan rilis

| Kelompok checklist | Status | Catatan |
|---|---|---|
| CI analyze/test/build Android/iOS | Belum | Tidak ditemukan `.github/workflows` |
| Coverage, widget/golden test | Parsial | Ada baseline test; kekurangan utama transport API dan lifecycle sesi |
| Flavor dev/staging/prod | Belum | Ada env/dart-define; belum flavor app ID/signing/environment terpisah |
| Crash reporting dan analytics funnel | Belum | Tidak ditemukan inisialisasi/instrumentasi |
| Sinkronisasi dokumentasi endpoint | Belum | Dokumen lama menyebut route berbeda dari pemanggilan mobile; backend belum diaudit |
| Dev CORS proxy dari release path | Tidak ditemukan keterlibatan dalam entrypoint aplikasi | Tool terpisah `tool/dev_cors_proxy.dart`; tidak diimport `lib/` atau didaftarkan sebagai asset. Tetap cek konfigurasi environment rilis |
| Force update | Belum | Tidak ada flow pemeriksaan minimum version |
| Ukuran APK | Terukur 54,7 MB | APK release lokal berhasil; evaluasi berikutnya per ABI/App Bundle, jangan memakai angka marketing kompetitor sebagai target tanpa metodologi yang sama |

## 6. Inventaris endpoint yang benar-benar dipanggil mobile

Prefix berasal dari `BASE_URL`, default saat ini `/api/v1`. Kolom berikut membuktikan pemanggilan dalam source, bukan bahwa server menerima payload tersebut.

| Metode dan path | Pemakai | Status / gap |
|---|---|---|
| `POST /auth/login` | Auth remote | Email/password; parse user/tokens dan cookie respons; kontrak native/web belum tervalidasi |
| `GET /auth/me` | Restore session | Digunakan saat restore; risiko overwrite token F04 |
| `POST /auth/refresh` | Interceptor | Body refresh token atau cookie/CSRF; test rotasi/concurrent 401 belum ada |
| `POST /auth/logout` | Auth remote | Logout remote bersifat best effort; pembersihan state fitur belum lengkap |
| `GET /attendance` | Attendance dan Dashboard | Filter employee/company/month; history UI belum memakai hasil API; tahun/pagination perlu kontrak |
| `POST /attendance` | Attendance | Clock-in; lokasi/selfie belum terkirim; waktu/status dari client |
| `PATCH /attendance/:id/checkout` | Attendance | Clock-out; hanya timestamp perangkat |
| `GET /attendance/summary` | Dashboard | Company/month/year; scope personal perlu dibuktikan |
| `GET /leave/balances/employee` | Dashboard | Employee ID; saldo per tipe parsial, bukan modul cuti lengkap |
| `GET /notifications` | Dashboard | Limit tiga; diproyeksikan sebagai announcements |
| `GET /employees/:id` | Profile | Detail employee; kegagalan dibungkam menjadi fallback |

Sumber utama: `auth_remote_datasource.dart`, `dio_client.dart`, `attendance_remote_datasource.dart`, `dashboard_remote_datasource.dart`, `profile_remote_datasource.dart` di lokasi yang dirujuk pada temuan.

Endpoint checklist yang **belum dipanggil** mobile dikelompokkan untuk verifikasi kontrak:

| Kelompok | Kandidat dari checklist | Bukti yang dibutuhkan sebelum implementasi |
|---|---|---|
| Policy absensi dan face | `/attendance/context` atau `/companies/:id/attendance-policy`, `/employees/:id/face-profile` | Mana yang benar-benar tersedia; struktur policy, accuracy, timezone, aturan face/selfie |
| Cuti/izin | `/leave`, `/leave/types`, `/leave/:id/workflow`, `/permission-request` | Metode, periode, saldo, hari kerja, attachment, approval |
| Kalender | `/work-calendar`, `/work-calendar/holidays`, `/work-calendar/shifts`, `/leave?team=true` | Kontrak query team/month/year dan scope organisasi |
| Approval/RBAC | `/workflow-engine/instances/my-approvals`, actions, bulk-approve, `/rbac/me/resolved` | Prefix lengkap action/bulk; resolved permission dan state transition |
| Notifikasi/push | `/notifications/unread-count`, read, read-all; endpoint registrasi FCM | Nama/metode route read dan device-token lifecycle belum lengkap di checklist |
| Payroll/dokumen | `/payroll/payslips/:id`, `/document-management/:id/file` | Endpoint daftar periode/dokumen, file response, izin akses, URL expiry |
| Lembur/koreksi/tukar shift | `/attendance/overtime`, `/attendance/:id/correction`, `/attendance/shift-swaps/...` | CRUD/action method, candidates, biaya, approval |
| Travel/loan/EWA | `/travel-expense/...`, `/employee-loan/...`, `/ewa` | Konfirmasi nama singular/plural, amount/currency, cicilan, workflow |
| Performance/LMS/aset/direktori/onboarding | `/performance/...`, `/training/...`, `/asset`, `/daily-activity`, `/organization/chart`, `/employees`, `/onboarding/checklists` | Schema/pagination/permission masing-masing modul |

Untuk setiap endpoint, catat: metode + path lengkap, parameter wajib, response sukses/kosong/error, pagination, role, scope employee/company, waktu/timezone, format uang, mekanisme file, dan idempotency. Bentuk `/instances/:id/actions` dalam checklist belum cukup untuk menentukan prefix final.

## 7. Dependency dan aksi yang belum berfungsi

Dari **21 dependency runtime selain Flutter SDK**, delapan memiliki import langsung di `lib/`: `google_fonts`, `intl`, `flutter_riverpod`, `dio`, `pretty_dio_logger`, `shared_preferences`, `flutter_secure_storage`, `flutter_dotenv`.

Tiga belas tanpa import langsung: `cupertino_icons`, `fl_chart`, `table_calendar`, `hive`, `hive_flutter`, `firebase_core`, `firebase_messaging`, `flutter_local_notifications`, `connectivity_plus`, `path_provider`, `uuid`, `geolocator`, `image_picker`.

Tidak ada import langsung bukan bukti ukuran biner yang dapat langsung dihemat: dependency bisa menyediakan asset/plugin atau dipakai transitif. Contohnya, audit ukuran dan dependency tree perlu dilakukan sebelum penghapusan. Untuk pembangunan berikutnya, pilih mengimplementasikan penggunaan yang nyata atau menghapus deklarasi langsung yang tidak dibutuhkan. `build_runner` dan `hive_generator` merupakan dev dependency, sehingga aturan wajib di-import ke `lib/` tidak cocok untuk keduanya.

Inventaris callback kosong aktif:

| File/baris | Aksi |
|---|---|
| `home_screen.dart:387` | Aksi header saldo cuti |
| `home_screen.dart:522,528,589` | History, kartu slip gaji, tombol View |
| `home_screen.dart:610,620` | Semua pengumuman dan kartu pengumuman |
| `attendance_screen.dart:453` | View Monthly Report |
| `requests_screen.dart:166` | Filter |
| `calendar_screen.dart:304` | Aksi header agenda |
| `profile_screen.dart:573` | Handler bersama tujuh menu: Documents, Payroll, Assets, Certifications, Notifications, Language, Security |

Lima callback pada blok Quick Actions Home yang dikomentari tidak dihitung sebagai callback aktif. F01 merupakan aksi simulasi yang tidak tertangkap pencarian callback kosong.

## 8. Backlog eksekusi yang dapat langsung dipakai

Urutan mengikuti blocker P0. Fondasi CI dan kontrak ditarik lebih awal karena diperlukan untuk membuktikan perbaikan; fondasi routing mendahului penutupan push/deep-link P0. Ini urutan dependency pekerjaan, bukan estimasi jumlah sprint yang sudah disepakati.

| ID | Prioritas | Pekerjaan / cakupan | Dependency | Bukti selesai |
|---|---|---|---|---|
| DEV-01 | P0 | Verifikasi kontrak auth, employee/company, absensi/policy/upload; fixture tersanitasi dan inventaris route | Akses kontrak backend dan akun employee/manager/non-employee | Contoh respons nyata dan matriks role; field tidak ditebak |
| DEV-02 | P0 | Perbaiki lifecycle auth F03–F06; native/web dipisahkan bila diperlukan | DEV-01 untuk cookie final | Test rotasi, concurrent 401, retry gagal, cookie non-auth, logout A/login B, respons tertunda |
| DEV-03 | P0 | Konfigurasi environment/HTTPS/log redaction; CI analyze/test dasar | URL environment; kepemilikan signing disiapkan | Log tanpa data sensitif, config produksi eksplisit, pemeriksaan otomatis berjalan |
| DEV-04 | P0 | Hapus klaim absensi sukses dan data contoh dari jalur pengguna; hubungkan Home ke alur absensi | Dapat dimulai segera; final API mengikuti DEV-01 | Tidak ada perubahan status tanpa hasil server; tanpa gaji/riwayat/pengajuan contoh |
| DEV-05 | P0 | GPS, permission, accuracy/mock, selfie/upload, geofence/server time | DEV-01/02/03 | Uji perangkat dan penolakan server: izin ditolak, GPS mati, lokasi buruk, luar radius, mock, timeout |
| DEV-06 | P0 | Perluas model request dan integrasikan list/submit cuti/izin; kalender remote | Kontrak cuti/kalender dan DEV-02 | Tanggal/alasan/lampiran nyata, ID server, persist setelah restart, error dan retry |
| DEV-07 | P1 pendukung P0 | Router detail, shell, role capability, state standar; i18n foundation | DEV-02; kontrak RBAC | Back/deep link/guard diuji; state akun terisolasi; locale tersimpan |
| DEV-08 | P0 + P2 | Notifikasi inbox/unread/read; FCM token lifecycle dan deep link; reminder | DEV-07, Firebase config, kontrak device registration | Foreground/background/terminated dan logout device-token tervalidasi |
| DEV-09 | P2 utama | Approval Center dan status workflow pengajuan | DEV-06/07, kontrak workflow | Employee tak berizin ditolak server; manager approve/reject/bulk konsisten |
| DEV-10 | P0 keamanan + P2 | Slip gaji, daftar periode, PDF/dokumen, biometric/PIN dan proteksi berkas sesuai kebutuhan | Kontrak payroll/file, DEV-02/07 | Scope akses, logout cleanup, preview/download dan proteksi data teruji |
| DEV-11 | P2 | Lembur/koreksi/tukar shift → travel/reimburse → loan/EWA → ESS tambahan | DEV-06/09; kontrak per modul | Tiap modul lulus kontrak, lifecycle workflow, dan uji per role |
| DEV-12 | P2 | Cache offline per akun, queue/idempotency, retry/resync | Kontrak offline server, DEV-02/05 | Replay tidak menduplikasi, timestamp offline ditandai, konflik terlihat |
| DEV-13 | P3/P4 | Polish, audit perangkat/aksesibilitas, golden test, crash reporting, flavor/signing, privacy, beta | Alur utama lengkap; keputusan identitas organisasi | Android/iOS release CI dan smoke test perangkat dengan data uji |

DEV-06 sengaja menggabungkan kebutuhan membuang sumber demo P0 dengan form pengajuan yang di checklist berada di P2/P3; mengganti datasource saja tidak menyelesaikan form yang tidak mengumpulkan data wajib. i18n foundation lebih awal mencegah form baru menambah string hardcode. Offline clock-in tidak boleh dijanjikan selesai sebelum kebijakan server disepakati.

## 9. Definition of Done untuk menutup item

Setiap item ditutup setelah jalur UI → controller/use case → repository → datasource → server berjalan; response sukses, kosong, dan gagal ditangani; akses sesuai role/company; dan tidak memakai fallback data contoh. Item yang hanya memiliki adapter atau test fake tetap berstatus parsial.

Untuk baseline ini, seluruh DoD global checklist masih **belum terpenuhi sepenuhnya**: analyzer/test sudah lulus, tetapi validasi runtime/backend, konfigurasi distribusi, i18n, penghapusan demo, state UI, proteksi data, dan sinkronisasi kontrak masih terbuka.

Prioritas awal development: **DEV-01 sampai DEV-05**, dengan F01 (absensi Home), F03 (isolasi akun), F04 (rotasi token), dan F02 (bukti kehadiran) sebagai masalah fungsional utama. Jadikan hasil audit ini baseline; perbarui status dengan bukti pengujian saat masing-masing pekerjaan selesai.
