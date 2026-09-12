# HRIS-007: CI Dasar

Tanggal verifikasi lokal: 12 September 2026.

## Hasil

Workflow `.github/workflows/mobile-ci.yml` sekarang berjalan pada pull request
serta push ke `master` atau `main`. Hak akses workflow dibatasi ke
`contents: read`, job lama dibatalkan oleh concurrency group, dan tiap job
memiliki timeout.

Versi Flutter dikunci ke framework revision
`f0bbd8333c91b52d879e7c034645887b5768b43a`, yaitu SDK yang dipakai saat
validasi lokal. Workflow tidak bergantung pada versi Flutter bergerak tanpa
pin.

## Quality gate

Job `quality` menjalankan:

1. dependency resolution dan pemeriksaan bahwa `pubspec.lock` tidak berubah;
2. `dart format --output=none --set-exit-if-changed lib test tool`;
3. `flutter analyze`;
4. test guard konfigurasi release, transport, dan larangan data demo;
5. seluruh test dengan coverage;
6. upload `coverage/lcov.info` sebagai artefak selama 14 hari.

Job `android` hanya berjalan setelah quality lulus. Job ini memakai Java 17,
membangun App Bundle release dengan `APP_ENV=production`, URL HTTPS eksplisit,
dan logging mati, lalu mengunggah AAB sebagai artefak validasi. Artefak belum
ditandatangani untuk distribusi; signing tetap bagian HRIS-046.

## Pengujian

- Test arsitektur mem-parsing workflow sebagai YAML dan memastikan job
  `quality` serta `android` tersedia.
- Test juga menjaga perintah quality gate, revision Flutter, production
  define, dan path artefak AAB.
- `flutter analyze`: tidak ada issue saat verifikasi lokal.
- `flutter test`: 141 test lulus.
- App Bundle release production berhasil dibangun di
  `build/app/outputs/bundle/release/app-release.aab` dengan ukuran 54,6 MB.

## Batas verifikasi

Workflow belum pernah dijalankan oleh GitHub Actions dari workspace lokal.
Status DONE berarti definisi dan guard lokal selesai. Bukti runner pertama
tetap perlu diperoleh setelah branch didorong ke repository GitHub. Secret
signing, publikasi store, dan build iOS tidak dimasukkan karena memerlukan
credential organisasi dan termasuk task distribusi terpisah.
