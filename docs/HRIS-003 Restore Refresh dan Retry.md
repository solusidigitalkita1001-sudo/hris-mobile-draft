# HRIS-003: Restore, Refresh, dan Retry Autentikasi

Tanggal: 11 September 2026.

Status: **DONE untuk implementasi dan pengujian lokal.** Pengujian deployment nyata tetap menunggu akun khusus uji.

## Tujuan

Task ini menutup race saat restore menimpa token hasil refresh, refresh ganda ketika beberapa request menerima 401, retry tanpa batas, dan pemetaan kegagalan login yang keliru. Kontrak refresh mengikuti source backend pada commit `fa1d33cab5b39b2956c400cca046d73915933706`.

## Perubahan

- `AuthRefreshCoordinator` menjadi satu coordinator per container dan dipakai bersama oleh client autentikasi serta client fitur. Request 401 pada generasi sesi yang sama menunggu satu operasi refresh yang sama.
- `restoreSession` membaca ulang secure session setelah `/auth/me` selesai. Metadata user digabungkan ke kredensial terbaru, sehingga snapshot token sebelum request tidak dapat menimpa hasil rotasi.
- Setiap request membawa revisi sesi dan revisi kredensial. Respons 401 lama yang selesai setelah refresh lain tidak memulai refresh kedua.
- Protected request hanya dicoba ulang satu kali. Retry membawa method, query, body, custom header, dan `FormData` hasil clone. Body berbentuk stream tidak diulang otomatis karena tidak aman dikonsumsi dua kali.
- Refresh 401/403 dan retry 401 menginvalidasi sesi aktif. Refresh timeout/503 serta retry 403/429/503 mengembalikan error tanpa menghapus sesi yang masih mungkin dipakai kembali.
- Refresh yang selesai setelah logout atau pergantian akun tidak boleh menulis token, cookie, session JSON, atau menginvalidasi akun baru.
- Endpoint login, refresh, dan logout tidak masuk alur auto-refresh. Login salah tetap menjadi `AuthenticationFailure`; timeout dan koneksi gagal menjadi `NetworkFailure`.
- Auth bootstrap mendengarkan invalidasi tanpa membangun ulang provider selama restore sedang berjalan. Ini mencegah loop restore ketika refresh ditolak.

## Matriks hasil

| Kondisi | Hasil client |
|---|---|
| `/me` 401, refresh 200, retry 200 | Session dipulihkan memakai kredensial hasil rotasi |
| Beberapa protected request 401 bersamaan | Satu refresh, setiap request maksimal satu retry |
| Refresh 401/403 | Session aktif dibersihkan satu kali |
| Refresh timeout/503 | Session dipertahankan, error dapat dicoba lagi |
| Retry protected tetap 401 | Session diinvalidasi, tidak ada refresh kedua |
| Retry protected 403/429/503 | Error diteruskan, session tidak dihapus |
| Login 401 | Tidak mencoba refresh session lama |
| Request lama selesai setelah logout/login B | Dibatalkan atau hasilnya diabaikan |

## Bukti pengujian

Test utama adalah [auth_refresh_test.dart](../test/core/auth_refresh_test.dart), dengan 26 skenario lokal. Cakupannya meliputi Bearer dan cookie, concurrent 401 lintas client, timeout, respons refresh invalid, pembatalan satu waiter, bootstrap 401/503, POST, dan multipart.

Regresi akhir:

- `flutter analyze`: tidak ada issue.
- `flutter test --coverage`: 103 test lulus.
- Coverage ditulis ke `coverage/lcov.info`. Kelulusan ini tidak menyatakan seluruh jalur perangkat atau server live sudah diuji.

Perintah reproduksi:

```sh
flutter analyze
flutter test test/core/auth_refresh_test.dart
flutter test --coverage
```

## Batas pengujian

- HTTP test hanya memakai server loopback dan fixture sintetis. Tidak ada password, JWT, atau akun nyata.
- Retry otomatis tidak menjamin transaksi server belum diproses. Endpoint mutasi tetap perlu idempotency pada task fitur masing-masing.
- Kebijakan koneksi produksi, pinning, dan redaksi log berada pada HRIS-006.

