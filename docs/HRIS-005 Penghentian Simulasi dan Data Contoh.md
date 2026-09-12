# HRIS-005: Penghentian Simulasi dan Data Contoh

Tanggal: 11 September 2026.

Status: **DONE untuk penghentian simulasi pada jalur pengguna dan pengujian lokal.** Integrasi lengkap absensi, pengajuan, kalender, payroll, dokumen, aset, dan sertifikasi tetap berada pada task fitur masing-masing.

## Perubahan perilaku

- Home tidak lagi memiliki `_clockedInOverride` atau tombol yang mengubah status absensi lokal. Tombol `Buka Kehadiran` hanya memindahkan pengguna ke tab Kehadiran.
- Layar Kehadiran tidak lagi mengklaim GPS aktif, radius kantor valid, atau wajah terverifikasi. Clock-in/out dari aplikasi disembunyikan sampai lokasi nyata dan verifikasi server tersedia.
- Catatan absensi hari ini hanya ditampilkan bila endpoint mengembalikan record dengan ID. Loading, data kosong, dan error ditampilkan berbeda.
- Layar Pengajuan tidak lagi membuka form atau menyimpan transaksi in-memory. Provider produksi memakai datasource unavailable yang menolak operasi insert.
- Provider produksi Dashboard, Kalender, Profil, Pengajuan, dan Lokasi tidak lagi memilih implementasi `Demo*`.
- Nominal/periode slip gaji, aset, sertifikasi, riwayat absensi, event kalender, identitas karyawan, serta status aktif contoh tidak lagi muncul di layar pengguna.
- Aksi tanpa alur nyata di Home, Pengajuan, Kalender, dan Profil dihapus. Kalender lokal tetap dapat dinavigasi, tetapi event diberi status integrasi belum tersedia.

## Pemisahan unavailable dan empty

`DashboardSnapshot` membawa flag ketersediaan per bagian untuk absensi, saldo cuti, ringkasan bulanan, dan pengumuman. UI menggunakan flag tersebut agar nilai nol atau list kosong tidak disajikan sebagai data server jika request belum berhasil.

Untuk catatan absensi hari ini:

- loading menampilkan indikator beserta teks proses;
- kegagalan menampilkan pesan dan tombol `Coba Lagi`;
- respons server tanpa record menampilkan `Belum ada catatan hari ini`;
- record ber-ID menampilkan jam masuk/pulang dari response server.

Modul yang belum diintegrasikan menampilkan kartu `belum tersedia`, bukan empty state yang dapat disalahartikan sebagai hasil server.

## Jalur demo yang tersisa

Implementasi `Demo*` masih dipertahankan sebagai fixture eksplisit untuk unit test lama. Test yang membutuhkannya melakukan override provider secara eksplisit. Regression test memastikan provider produksi memilih implementasi empty/unavailable dan tidak memilih fixture tersebut.

Pemindahan seluruh fixture dari `lib/` ke paket test serta guard release merupakan lingkup HRIS-007 dan HRIS-020. Tidak ada `Demo*` yang dipilih oleh provider produksi setelah HRIS-005.

## Bukti pengujian

Test baru [no_demo_ui_test.dart](../test/features/safety/no_demo_ui_test.dart) mencakup:

- pemilihan datasource produksi dan penolakan lokasi/pengajuan lokal;
- tombol Home hanya memanggil navigasi Kehadiran tanpa mengubah status;
- layar Kehadiran tidak menampilkan klaim GPS/wajah/lokasi contoh dan tidak memanggil clock-in/out;
- Pengajuan, Kalender, payroll, serta data personal menampilkan status unavailable yang jujur;
- data contoh tidak ditemukan pada widget pengguna;
- click-through seluruh tab dan kontrol yang tersisa pada lebar 320 px;
- tema terang dan gelap pada skala teks 100% dan 200%, tanpa overflow atau exception.

Hasil verifikasi:

- `flutter analyze`: tidak ada issue.
- `flutter test`: 112 test lulus.
- `flutter build web --debug`: berhasil menghasilkan `build/web`; Wasm dry run masih memberi peringatan dependency legacy `flutter_secure_storage_web` yang sudah dicatat pada HRIS-004.
- Pemeriksaan kontras: teks utama/sub pada surface terang dan gelap lulus WCAG AA; primary pada putih lulus 5,17:1; teks putih pada biru utama lulus 5,17:1.

## Batas dan tindak lanjut

- Tidak ada transaksi live yang diuji karena akun uji belum tersedia.
- Clock-in/out mobile sengaja belum dapat dilakukan sampai HRIS-009 sampai HRIS-012 menyelesaikan permission, lokasi nyata, policy/geofence, dan kontrak transaksi server.
- Pengajuan, riwayat absensi, kalender kerja, payroll, dokumen, aset, dan sertifikasi harus diaktifkan kembali hanya setelah endpoint serta seluruh state sukses/kosong/gagal selesai.
- Perubahan ini menghentikan klaim palsu; tidak menyatakan modul-modul tersebut sudah terintegrasi.
