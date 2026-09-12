# HRIS-002: Isolasi data sesi

Tanggal: 11 September 2026. Status: selesai untuk implementasi dan pengujian lokal.

Task ini menangani audit F03: data akun A tetap terbaca setelah logout dan login B dalam proses aplikasi yang sama. Pengujian memakai identitas sintetis, fake repository, secure-storage mock, dan HTTP loopback. Tidak ada akses akun atau server live.

## Perubahan

- `SessionLifecycle` memberi nomor generasi pada sesi. Login, logout, dan kegagalan refresh mengganti generasi. Operasi penyimpanan diserialkan: clear menunggu write yang sudah berjalan, sedangkan write antrean dari generasi lama diabaikan.
- `featureSessionProvider` mengikat provider ke generasi sesi dan snapshot identitas/company. Dashboard, profil, kalender, dan pengajuan membangun ulang state serta datasource lokal ketika scope berubah. Controller mengabaikan hasil async scope lama.
- Provider absensi memakai `autoDispose.family` dengan scope sesi sebagai key. Loading akun B tidak menyertakan `AsyncData` akun A. Operasi absensi menangkap use case sebelum `await`, sehingga tidak mengambil repository akun baru setelah menunggu lokasi.
- `featureDioProvider` membawa snapshot scope. Client lama ditutup saat scope dibuang; request yang belum terkirim ditolak jika scope berubah. Repository memakai identitas yang ditangkap saat dibuat, bukan membaca identitas akun terbaru ketika operasi lama dilanjutkan.
- Interceptor memeriksa generasi sebelum mengirim request, menyimpan cookie, me-refresh token, dan melakukan retry. Refresh A yang selesai sesudah logout tidak menyimpan kredensial atau menginvalidasi sesi B. Login tidak membawa kredensial akun sebelumnya dan respons login hanya disimpan melalui repository yang memeriksa generasi.
- Logout langsung menghapus identitas dan state autentikasi pada client. Repository menangkap kredensial A lalu membersihkan storage sebelum meminta logout server. Request logout memakai snapshot A; responsnya tidak menghapus atau mengganti cookie B. Kegagalan logout server tidak membatalkan logout lokal.
- Auth controller mengabaikan login/restore lama ketika operasi autentikasi yang lebih baru sudah dimulai. Provider status sesi legacy meneruskan sign-out ke auth controller yang sama.
- Key aplikasi dan shell mengikuti scope sesi. Logout/pergantian akun/company membuang navigator, dialog, form, dan tab lama. Preferensi tema tetap berada di provider preferensi perangkat.

## Bukti pengujian

Test reproduksi sebelum perbaikan gagal karena daftar pengajuan B masih berisi `Only A`. Test yang sama lulus setelah perbaikan.

| Test | Cakupan |
|---|---|
| [session_isolation_test.dart](../test/core/session_isolation_test.dart), 7 test | Pengajuan A setelah logout/login B; submit tertunda; respons dashboard/profil/kalender/absensi tertunda ketika akun/company berubah atau sesi diinvalidasi; reset cache ketika login ulang; antrean write lama vs clear |
| [session_lifecycle_test.dart](../test/features/authentication/session_lifecycle_test.dart), 3 test | Logout lokal sebelum server selesai, logout gagal setelah B login, login A tertunda, restore A tertunda |
| [session_network_test.dart](../test/core/session_network_test.dart), 7 test | HTTP refresh 200 tertunda setelah logout, refresh 200/401 tertunda setelah B login, refresh gagal untuk sesi aktif, cookie respons A terlambat, logout 200/503 tertunda; client A tidak mengirim request baru |
| [session_navigation_test.dart](../test/session_navigation_test.dart), 1 widget test | Buka profil A, buka route draft A, logout, login B, tab kembali Home, buka profil B, tidak ada data/draft A, tema gelap tetap, tidak ada exception widget |

Hasil akhir:

- `flutter analyze`: tidak ada issue.
- `flutter test --coverage`: 66 test lulus, termasuk 18 test baru HRIS-002 dan regresi kontrak HRIS-001.
- Coverage tersedia di `coverage/lcov.info`. Angka kelulusan test tidak berarti seluruh jalur kode atau perilaku perangkat sudah tercakup.

Perintah reproduksi:

```sh
flutter analyze
flutter test test/core/session_isolation_test.dart test/core/session_network_test.dart test/features/authentication/session_lifecycle_test.dart test/session_navigation_test.dart
flutter test --coverage
```

## Aturan untuk fitur dan cache berikutnya

1. Provider cache/repository milik pengguna harus `watch(featureSessionProvider)` dan membuat instance baru untuk scope tersebut. Tangkap `session.context` sebelum operasi async.
2. Ambil client API fitur dari `featureDioProvider`. `dioProvider` tanpa scope digunakan alur autentikasi; jangan menyimpannya dalam operasi fitur yang bisa berjalan melewati pergantian akun.
3. Controller menangkap scope sebelum `await` dan memeriksa `session.isCurrent` sebelum menulis state. Gunakan family per scope untuk AsyncNotifier agar loading tidak membawa data lama.
4. Daftarkan penutupan resource/pembersihan cache pada `ref.onDispose`. Untuk cache disk atau dokumen yang belum tersedia, pisahkan namespace berdasarkan user/company dan tentukan kebijakan penghapusan file saat fitur tersebut diimplementasikan. Task ini mereset cache memori yang ada, tidak mengimplementasikan penyimpanan offline baru.
5. Semua penulisan kredensial dan clear baru harus melalui `SessionLifecycle.protect` dengan generasi operasi yang ditangkap. Jangan mengambil generasi terbaru setelah respons jaringan selesai, dan jangan menaruh request jaringan di dalam antrean storage.

## Batas dan pekerjaan berikutnya

- Belum ada pengujian akun live, emulator/perangkat, atau browser pada tahap ini. Widget test menjalankan interaksi navigasi lokal; test HTTP hanya menghubungi `127.0.0.1` dengan port acak.
- Membatalkan request client tidak menjamin transaksi yang sudah diterima server dibatalkan. Test submit tertunda membuktikan hasilnya tidak masuk state B, bukan membuktikan rollback server.
- Logout server bersifat best effort. Jika koneksi gagal, client sudah logout tetapi pencabutan sesi server belum terverifikasi.
- Data demo dan submit pengajuan lokal masih ada sesuai baseline. Isolasi cache tidak mengubahnya menjadi integrasi API nyata; penghentian simulasi merupakan HRIS-005.
- Restore, single-flight refresh, retry, cookie scoping, dan transport web telah dilanjutkan pada [HRIS-003](<HRIS-003 Restore Refresh dan Retry.md>) serta [HRIS-004](<HRIS-004 Cookie dan CSRF.md>). Verifikasi live tetap menunggu akun khusus uji.
