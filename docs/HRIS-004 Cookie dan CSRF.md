# HRIS-004: Cookie, CSRF, dan Pembatasan Kredensial

Tanggal: 11 September 2026.

Status: **DONE untuk implementasi dan pengujian lokal native; target web berhasil dikompilasi.** Uji deployment nyata, perangkat, dan browser dengan akun khusus uji belum dilakukan.

## Kontrak yang diterapkan

Mobile mengikuti atribut yang diterbitkan source backend:

| Cookie | Path | HttpOnly | SameSite | Secure | Expiry |
|---|---|---:|---|---|---|
| `at` | `/` | ya | Lax | production | Max-Age 900 detik |
| `rt` | `/api/v1/auth` | ya | Lax | production | Max-Age 604800 detik |
| `csrf` | `/` | tidak | Lax | production | session cookie |

`GET`, `HEAD`, dan `OPTIONS` tidak membawa header CSRF. Metode lain membawa `X-CSRF-Token` hanya ketika request memakai cookie autentikasi. Refresh memakai `rt` cookie lebih dahulu; fallback body refresh token tetap tersedia untuk mode Bearer.

## Implementasi native

- `SessionCookieStore` hanya menerima nama `at`, `rt`, dan `csrf` dari origin API yang dikonfigurasi.
- Atribut path, domain, `HttpOnly`, `SameSite=Lax`, `Secure`, `Max-Age`, dan `Expires` divalidasi sebelum cookie disimpan. Origin HTTPS menolak cookie kontrak yang tidak memiliki atribut `Secure`.
- Metadata cookie disimpan di secure storage. Header untuk request dibuat ulang berdasarkan origin, path, scheme, dan waktu kedaluwarsa. Cookie `rt` tidak dikirim ke endpoint fitur.
- Rotasi login dan refresh wajib berisi bundel `at`, `rt`, dan `csrf` yang seluruhnya valid. Bundel parsial atau salah atribut ditolak secara atomik dan tidak menimpa cookie lama.
- Penghapusan `Max-Age=0` menghapus cookie hanya pada kombinasi nama, origin, dan path yang tepat.
- Bearer, Cookie, dan CSRF tidak dipasang pada URL di luar exact origin API. Redirect request yang membawa autentikasi, request auth, dan request browser dinonaktifkan pada Dio agar kredensial atau body login tidak diteruskan otomatis.
- State cookie rusak atau versi yang tidak dikenal diabaikan. Cookie non-auth tidak membuat `hasSession` bernilai benar.

## Login, refresh, restart, dan logout

Login HTTP 200 belum dianggap sukses hanya karena envelope atau cookie tampak ada. Repository menyimpan kredensial hasil login lalu memanggil `/auth/me`. Session baru diterbitkan ke controller setelah `/auth/me` mengembalikan user ID yang valid. Jika verifikasi gagal, kredensial yang belum terbukti dibersihkan.

Pada restart native, cookie store dibangun kembali dari metadata secure storage. `/auth/me` dapat memicu satu refresh jika `at` kedaluwarsa dan `rt` masih valid. Logout menangkap snapshot header milik sesi lama, membersihkan storage lokal lebih dahulu, lalu memanggil server secara best effort.

## Target web

Web tidak mencoba membaca atau menyimpan cookie `HttpOnly`. Conditional adapter memakai `BrowserHttpClientAdapter(withCredentials: true)`, sehingga browser menangani `at` dan `rt`. Dart hanya membaca cookie `csrf` yang memang bukan `HttpOnly` untuk membentuk header pada unsafe method. Login juga mengirim CSRF yang tersedia agar cookie sesi lama tidak menyebabkan penolakan middleware server.

`flutter build web --debug` berhasil. Wasm dry run memberi peringatan karena `flutter_secure_storage_web` versi dependency saat ini masih memakai API web legacy. Build JavaScript tetap berhasil; migrasi dependency untuk build Wasm bukan bagian task ini.

Deployment web lintas origin tetap memerlukan konfigurasi CORS server yang mengizinkan origin aplikasi dan credentials. Hal tersebut tidak dapat dibuktikan hanya dengan unit test mobile.

## Bukti pengujian

| Test | Cakupan |
|---|---|
| [session_cookie_store_test.dart](../test/core/session_cookie_store_test.dart), 9 test | Origin/path, safe vs unsafe CSRF, restart, Secure pada HTTP, expiry, rotasi, delete, cookie malformed/non-auth, state rusak, redirect eksternal dan login redirect |
| [auth_api_contract_test.dart](../test/features/authentication/auth_api_contract_test.dart) | Login, verifikasi `/me`, protected request, refresh cookie, retry, dan logout pada HTTP loopback |
| [auth_refresh_test.dart](../test/core/auth_refresh_test.dart) | Rotasi atomik, respons non-auth atau malformed, single-flight, retry, dan session race |
| [auth_repository_test.dart](../test/features/authentication/auth_repository_test.dart) | Cookie non-auth tidak membuka sesi; kegagalan `/me` membersihkan kredensial login |

Hasil akhir:

- `flutter analyze`: tidak ada issue.
- `flutter test --coverage`: 103 test lulus.
- `flutter build web --debug`: berhasil menghasilkan `build/web`.

Perintah reproduksi:

```sh
flutter analyze
flutter test test/core/session_cookie_store_test.dart test/core/auth_refresh_test.dart test/features/authentication/auth_api_contract_test.dart
flutter test --coverage
flutter build web --debug
```

## Batas dan tindak lanjut

- Belum ada uji server deployment, emulator Android, perangkat iOS, atau browser runtime karena akun khusus uji belum tersedia.
- Base URL default repository masih HTTP dan kebijakan cleartext Android belum dipersempit. Itu adalah blocker HRIS-006, bukan alasan melonggarkan aturan cookie `Secure`.
- Cookie `csrf` dipersist bersama sesi native agar restart tetap dapat melakukan mutasi. Cookie ini dibersihkan saat logout atau invalidasi sesi.
- Certificate pinning, biometric/PIN, dan enkripsi file pribadi berada pada HRIS-006, HRIS-028, dan HRIS-029.
