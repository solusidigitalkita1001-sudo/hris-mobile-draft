# HRIS-006: Koneksi dan Logging Aman

Tanggal verifikasi lokal: 11 September 2026.

## Hasil

Konfigurasi development dan production sekarang memiliki aturan berbeda. Build
release/profile selalu diperlakukan sebagai production, wajib menerima
`BASE_URL` eksplisit dengan skema HTTPS, dan menolak `ENABLE_LOGGING=true`.
Development tetap dapat memakai endpoint HTTP yang terdokumentasi untuk server
referensi yang belum menyediakan TLS.

Kesalahan konfigurasi menghasilkan `AppConfigException` yang menyebut nama
setting dan perbaikannya. Nilai URL juga ditolak bila bukan URL HTTP(S) absolut,
memuat credential, query, atau fragment. Timeout wajib berupa bilangan bulat
positif.

| Build/environment | Base URL | Network log | Cleartext platform |
|---|---|---|---|
| Debug/development | HTTPS atau HTTP development | Opsional, default mati | Android debug dan ATS domain debug iOS |
| Debug/production | HTTPS eksplisit | Wajib mati | Binary debug masih memiliki exception platform untuk kebutuhan developer |
| Profile/release | HTTPS eksplisit, tanpa fallback | Wajib mati | Ditolak Android dan tidak memiliki ATS exception iOS |

## Logging

`PrettyDioLogger` dihapus karena tetap dapat mencetak response body. Penggantinya
adalah `SafeNetworkLogInterceptor`, yang hanya mencatat:

- nomor urut request lokal;
- HTTP method;
- status code atau kategori `DioException`;
- durasi.

Logger tidak membaca atau mencetak origin/path URL, query, request/response
headers, cookie, CSRF, body, payload error, maupun exception message. Dengan
demikian access/refresh token, identitas employee/company, data payroll, lokasi,
dan attachment tidak masuk ke output logger tersebut. Interceptor hanya dipasang
pada `kDebugMode` ketika flag logging diaktifkan.

## Konfigurasi publik

`.env` dihapus dari daftar asset Flutter dan `flutter_dotenv` dihapus dari
dependency. File lokal tetap diabaikan Git dan hanya diberikan ke Flutter tool:

```bash
flutter run --dart-define-from-file=.env
```

`.env.example` hanya mendokumentasikan `APP_ENV`, `BASE_URL`, timeout koneksi,
timeout respons, dan flag logging. Semua compile-time define tetap dianggap
publik karena dapat diekstrak dari binary. Secret layanan, password, private key,
token, cookie, dan CSRF tidak boleh diletakkan di file tersebut.

Contoh build production:

```bash
flutter build appbundle --release \
  --dart-define=APP_ENV=production \
  --dart-define=BASE_URL=https://api.example.com/api/v1 \
  --dart-define=ENABLE_LOGGING=false
```

## Pembatasan cleartext

- Manifest utama Android menetapkan `usesCleartextTraffic=false`.
- Manifest Android debug melakukan override eksplisit menjadi `true`; profile
  dan release tetap mewarisi `false`.
- `ios/Runner/Info.plist` untuk profile/release tidak memiliki ATS exception.
- Target Debug iOS memakai `Info-Debug.plist`, dengan exception hanya untuk
  domain HTTP server development saat ini.

Hasil manifest merger Android ikut diperiksa: APK debug menghasilkan
`usesCleartextTraffic=true`, sedangkan APK release menghasilkan `false`.

## Pengujian

- 6 test `AppConfig`: fallback development, keharusan URL production, penolakan
  HTTP/environment development/logging pada production, HTTPS valid, URL dengan
  credential, dan timeout invalid.
- 2 test logger: respons sukses dan error 401 dengan fixture berisi token,
  cookie, CSRF, email, password, path payroll, query, response body, dan
  `Set-Cookie`; tidak ada nilai sensitif yang masuk log.
- 2 test guard repository: cleartext hanya debug, `.env` diabaikan/tidak menjadi
  asset, dependency logger/dotenv lama hilang, dan key contoh tetap allowlist.
- `flutter analyze`: tidak ada issue.
- `flutter test`: 122 test lulus.
- APK debug: berhasil dibangun dengan endpoint HTTP development.
- APK release: berhasil dibangun dengan endpoint HTTPS dummy; manifest release
  menonaktifkan cleartext.
- Web release: berhasil dibangun dengan endpoint HTTPS dummy.

## Batas verifikasi

Belum ada URL HTTPS production atau akun uji live, sehingga TLS dan login pada
deployment sebenarnya belum dapat diuji. Build release menggunakan domain dummy
yang aman dari sisi skema hanya untuk membuktikan guard dan kompilasi. Domain,
sertifikat, CORS, serta smoke test live perlu diisi Backend/Infra sebelum
distribusi.

Certificate pinning sengaja tidak ditebak sebelum domain dan strategi rotasi
sertifikat tersedia. Pekerjaan itu tetap berada di HRIS-042 agar aplikasi tidak
terkunci pada sertifikat sementara tanpa backup pin dan prosedur rotasi.
