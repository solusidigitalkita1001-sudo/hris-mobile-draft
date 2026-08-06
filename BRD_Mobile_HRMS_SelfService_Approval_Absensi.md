**BUSINESS REQUIREMENTS DOCUMENT**

**Mobile Application - HRMS Self Service, Approval & Attendance**

_Untuk Pengguna Employee & Atasan (Manager)_

Dokumen turunan dari:

**PRD HRM System v2.0.0 (Consolidated) & Dokumen Alur Sistem HRMS v1.0.0**

| **Atribut**     | **Detail**                                                             |
| --------------- | ---------------------------------------------------------------------- |
| Nama Dokumen    | BRD - Mobile Apps HRMS (Self Service, Approval, Absensi)               |
| Versi Dokumen   | 1.0.0                                                                  |
| Tanggal         | 3 Juli 2026                                                            |
| Status          | Draft                                                                  |
| Target Pengguna | Employee & Atasan/Manager (Mobile App)                                 |
| Dokumen Rujukan | PRD HRM System v2.0.0; Dokumen Alur Sistem HRMS v1.0.0 (Company Group) |

# **Daftar Isi**

# **1\. Pendahuluan**

## **1.1 Latar Belakang**

HRM System v2.0.0 beserta Dokumen Alur Sistem yang menyertainya mendefinisikan 28 modul HRMS secara end-to-end, termasuk penambahan struktur Company Group untuk mendukung operasional multi-perusahaan/holding. Sebagian besar proses tersebut saat ini dijalankan melalui platform web, sementara aktivitas harian karyawan - terutama presensi, pengajuan izin/cuti, dan persetujuan atasan - idealnya dapat dilakukan kapan saja dan di mana saja melalui perangkat mobile.

Dokumen ini disusun untuk memformalkan kebutuhan bisnis (business requirements) dari aplikasi mobile HRMS yang akan digunakan oleh dua kelompok pengguna utama: Employee (karyawan) dan Atasan/Manager, dengan fokus pada tiga pilar utama: Self Service, Approval, dan Absensi (Attendance).

## **1.2 Tujuan Dokumen**

Dokumen Business Requirements Document (BRD) ini bertujuan untuk:

- Mendefinisikan kebutuhan bisnis dan fungsional aplikasi mobile HRMS dari sudut pandang pengguna Employee dan Atasan/Manager.
- Menjadi acuan bersama antara Product Owner, Business Stakeholder, dan Tim Development (UI/UX, Mobile Engineer, Backend Engineer, QA) dalam merancang dan membangun aplikasi.
- Menentukan ruang lingkup (scope) - apa yang termasuk dan tidak termasuk dalam rilis aplikasi mobile - agar ekspektasi seluruh pihak selaras.
- Menjadi dasar penyusunan dokumen turunan berikutnya seperti Functional Specification Document (FSD), wireframe/UI design, dan test case.

## **1.3 Ruang Lingkup Dokumen**

Dokumen ini berfokus pada kebutuhan bisnis aplikasi mobile, bukan aplikasi web admin/HR back office. Modul-modul PRD yang bersifat administratif tingkat tinggi (konfigurasi sistem, Payroll Run, Organization Structure setup, Integration Hub, Company Group setup, dsb.) tidak termasuk dalam ruang lingkup aplikasi mobile ini kecuali sebagai data yang dikonsumsi (read-only) oleh Employee/Atasan - misalnya jadwal kerja, slip gaji, atau kalender kerja yang sudah dikonfigurasi melalui web.

## **1.4 Definisi & Istilah**

| **Istilah**     | **Definisi**                                                                                                                                       |
| --------------- | -------------------------------------------------------------------------------------------------------------------------------------------------- |
| BRD             | Business Requirements Document - dokumen kebutuhan bisnis tingkat tinggi sebelum masuk ke spesifikasi teknis.                                      |
| Employee        | Karyawan aktif perusahaan yang menggunakan aplikasi mobile untuk keperluan self service dan absensi pribadi.                                       |
| Atasan/Manager  | Karyawan dengan bawahan langsung (direct report) yang memiliki kewenangan menyetujui/menolak pengajuan bawahannya melalui aplikasi mobile.         |
| Self Service    | Kanal mandiri bagi karyawan untuk mengajukan berbagai jenis permintaan tanpa mendatangi HR secara fisik.                                           |
| Approval Center | Modul terpusat di aplikasi mobile atasan untuk meninjau dan memutuskan seluruh pengajuan bawahan.                                                  |
| Clock In/Out    | Aksi mencatat waktu mulai/selesai bekerja melalui aplikasi mobile.                                                                                 |
| Geofencing      | Validasi lokasi GPS perangkat terhadap radius area kerja yang ditentukan.                                                                          |
| Company Group   | Struktur holding yang menaungi lebih dari satu badan hukum (Company) dalam satu grup usaha, sebagaimana didefinisikan pada Dokumen Alur Sistem §2. |
| Secondment      | Status penugasan sementara karyawan di Company lain dalam satu Company Group tanpa mengubah status kepegawaian utamanya.                           |
| Workflow Engine | Mesin approval terpusat pada sistem HRMS backend yang menentukan urutan dan kondisi persetujuan setiap jenis pengajuan.                            |

## **1.5 Dokumen Referensi**

- PRD HRM System v2.0.0 (Consolidated) - §6.1 s.d. §6.28, §9 (Skema Data), §13 (Risk Mitigation).
- Dokumen Alur Sistem HRMS v1.0.0 - khususnya §2 (Company Group), §3.1, §3.2, §3.6, §3.7, §3.8, §3.12, dan §4.10 (Workflow Engine).

# **2\. Tujuan Bisnis (Business Objectives)**

## **2.1 Tujuan Bisnis Utama**

- Memindahkan aktivitas harian karyawan yang bersifat repetitif (absensi, pengajuan izin/cuti, cek slip gaji) dari kanal manual/web ke mobile app agar lebih cepat dan mudah diakses kapan saja.
- Mempercepat siklus persetujuan (approval turnaround time) dengan memungkinkan atasan menyetujui/menolak pengajuan langsung dari perangkat mobile, termasuk saat sedang di luar kantor/perjalanan dinas.
- Meningkatkan akurasi data kehadiran melalui presensi berbasis GPS/geofencing dan opsional face recognition, mengurangi praktik titip absen.
- Mengurangi beban administratif tim HR dengan mengalihkan permintaan-permintaan rutin ke kanal self service yang terhubung langsung ke Workflow Engine.
- Meningkatkan employee experience melalui antarmuka yang sederhana, cepat, dan minim friksi, sehingga adopsi aplikasi tinggi sejak awal peluncuran.
- Menyediakan visibilitas real-time bagi atasan atas kondisi tim (siapa hadir, siapa cuti, siapa memiliki pengajuan pending) tanpa harus membuka aplikasi web.

## **2.2 Indikator Keberhasilan (Success Metrics / KPI)**

| **Metrik**               | **Definisi**                                                                 | **Target Indikatif**                    |
| ------------------------ | ---------------------------------------------------------------------------- | --------------------------------------- |
| Adoption Rate            | Persentase karyawan aktif yang menggunakan aplikasi mobile minimal 1x/minggu | ≥ 85% dalam 3 bulan pasca rilis         |
| Attendance Compliance    | Persentase clock-in/out harian yang dilakukan tepat waktu melalui mobile app | ≥ 90%                                   |
| Approval Turnaround Time | Rata-rata waktu dari pengajuan dibuat hingga disetujui/ditolak               | Turun ≥ 40% dibanding proses manual/web |
| Self Service Deflection  | Persentase permintaan rutin yang tidak lagi memerlukan intervensi manual HR  | ≥ 70%                                   |
| App Store Rating         | Rating aplikasi di Play Store/App Store                                      | ≥ 4.3 / 5.0                             |
| Crash-free Session Rate  | Persentase sesi aplikasi tanpa crash                                         | ≥ 99%                                   |

# **3\. Stakeholder & Target Pengguna**

## **3.1 Daftar Stakeholder**

| **Stakeholder**     | **Peran dalam Proyek**                      | **Kepentingan Utama**                                              |
| ------------------- | ------------------------------------------- | ------------------------------------------------------------------ |
| Direksi/Manajemen   | Sponsor & pengambil keputusan strategis     | ROI, efisiensi operasional, citra perusahaan sebagai employer      |
| HR Department       | Business owner modul HR di aplikasi         | Kepatuhan proses, pengurangan beban administratif                  |
| IT/Product Team     | Pemilik produk & delivery aplikasi          | Kelayakan teknis, keamanan, roadmap pengembangan                   |
| Karyawan (Employee) | Pengguna utama (end user)                   | Kemudahan penggunaan, kecepatan proses pengajuan                   |
| Atasan/Manager      | Pengguna utama (approver)                   | Kecepatan & kejelasan informasi untuk mengambil keputusan approval |
| Finance/Payroll     | Pengguna data hasil absensi & self service  | Akurasi data sebagai basis perhitungan payroll                     |
| Compliance/Legal    | Pengawas kepatuhan regulasi ketenagakerjaan | Kepatuhan proses cuti, lembur, dan data pribadi karyawan           |

## **3.2 Peran Pengguna (User Roles) di Mobile App**

Aplikasi mobile pada fase ini melayani dua peran utama. Peran administratif/HR back office (Group Super Admin, HR Manager konfigurasi, Finance Payroll Run, dsb. sebagaimana didefinisikan di Dokumen Alur Sistem §2.4) tetap dilayani melalui aplikasi web dan berada di luar ruang lingkup mobile app ini.

| **Role**                             | **Deskripsi**                                                                    | **Akses Utama di Mobile App**                                                              |
| ------------------------------------ | -------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------ |
| Employee                             | Seluruh karyawan aktif berstatus Probasi/Kontrak/Tetap                           | Absensi, Self Service Request, Cek status pengajuan, Slip gaji, Kalender kerja, Notifikasi |
| Atasan/Manager (Direct Report Owner) | Karyawan yang memiliki satu atau lebih bawahan langsung pada struktur organisasi | Seluruh akses Employee + Approval Center + Ringkasan tim (kehadiran, cuti berjalan)        |

_Catatan: Seorang pengguna dapat memiliki kedua peran sekaligus (misalnya seorang Manager tetap melakukan absensi dan mengajukan cuti untuk dirinya sendiri sebagai Employee, sekaligus menyetujui pengajuan bawahannya sebagai Atasan). Aplikasi harus dapat menampilkan kedua konteks ini dalam satu akun tanpa perlu berganti login._

## **3.3 Persona Ringkas**

### **Persona 1 - Dian, Staff Operasional**

- Bekerja shift, sering di lapangan/cabang, mengandalkan HP sebagai alat kerja utama.
- Kebutuhan utama: absen cepat tanpa ribet, cek sisa cuti, ajukan izin mendadak.

### **Persona 2 - Rangga, Team Lead/Supervisor**

- Memiliki 6-10 bawahan langsung, sering rapat/perjalanan dinas.
- Kebutuhan utama: menyetujui pengajuan bawahan dengan cepat dari HP, melihat siapa saja yang cuti/izin hari ini sebelum menugaskan pekerjaan.

# **4\. Ruang Lingkup (Scope)**

## **4.1 In-Scope - Modul yang Dikembangkan di Mobile App**

| **No** | **Modul**                     | **Cakupan Utama**                                                                                      |
| ------ | ----------------------------- | ------------------------------------------------------------------------------------------------------ |
| 1      | Authentication & Login        | Login, biometric login, lupa password, sesi & keamanan perangkat                                       |
| 2      | Dashboard/Beranda             | Ringkasan status absensi hari ini, saldo cuti, pengajuan pending, pengumuman                           |
| 3      | Absensi (Attendance)          | Clock in/out via GPS/geofencing, opsional face recognition/QR, riwayat kehadiran, izin/koreksi absensi |
| 4      | Leave Management (Cuti)       | Ajukan cuti, cek saldo, kalender tim, riwayat & pembatalan cuti                                        |
| 5      | Self Service Request lain     | Izin/Sakit, Lembur, Tukar Shift, Koreksi Absensi, Permohonan Dokumen (Surat Keterangan Kerja, dsb.)    |
| 6      | Approval Center               | Antrian persetujuan untuk Atasan, approve/reject/delegasi, riwayat keputusan                           |
| 7      | Kalender Kerja & Kalender Tim | Lihat hari kerja/libur, jadwal shift pribadi, kalender ketersediaan tim (untuk atasan)                 |
| 8      | Notifikasi                    | Push notification untuk seluruh event terkait absensi, approval, dan pengumuman                        |
| 9      | Slip Gaji & Dokumen Pribadi   | Unduh/lihat slip gaji, akses dokumen pribadi (kontrak, sertifikat, dsb.) - read only                   |
| 10     | Profil & Pengaturan Akun      | Data pribadi (view/limited edit), ubah password/PIN, pengaturan notifikasi, ganti perangkat            |

## **4.2 Out-of-Scope (Fase Berikutnya / Tetap di Web)**

- Konfigurasi administratif: Organization Structure, Shift Template, Work Calendar setup, Salary Structure, Company Group setup - tetap dilakukan via web oleh HR/Admin.
- Payroll Run, finalisasi payroll, dan approval finalisasi HR Manager tingkat back-office.
- Modul Recruitment & ATS, Asset Management, LMS, Talent & Succession Planning, Workforce Planning & Budgeting, Integration Hub, Disciplinary Action Management - dipertimbangkan untuk fase mobile berikutnya, tidak termasuk rilis pertama.
- Group Executive Dashboard dan fitur analitik lintas Company - tetap menjadi kanal web untuk Group Super Admin/Group HR Director/Group Finance Director.
- Fitur Company Switcher lintas company kompleks (multi-context switching) - pada mobile app fase pertama, pengguna dengan akses lintas company tetap dilayani namun dengan tampilan disederhanakan (lihat §6.1.4).

## **4.3 Asumsi**

- Backend HRMS (API, Workflow Engine, Notification Service, Master Employee, dsb.) sebagaimana dijelaskan di Dokumen Alur Sistem sudah tersedia atau sedang dibangun paralel dan dapat dikonsumsi oleh mobile app melalui API.
- Struktur organisasi, jenis cuti, kalender kerja, dan shift sudah dikonfigurasi terlebih dahulu melalui aplikasi web sebelum karyawan dapat menggunakan mobile app secara efektif.
- Setiap karyawan memiliki nomor HP/email terverifikasi dan perangkat mobile pribadi (BYOD) yang mendukung GPS.
- Untuk perusahaan dengan struktur Company Group, mayoritas karyawan hanya beroperasi dalam satu Company (Primary assignment); skenario lintas company (Secondment) adalah kasus minoritas namun tetap harus didukung.

## **4.4 Batasan (Constraints)**

- Aplikasi harus dapat berjalan pada perangkat Android dan iOS dengan spesifikasi menengah ke bawah, mengingat sebagian pengguna adalah staf operasional/lapangan.
- Fitur absensi bergantung pada akurasi GPS perangkat dan kualitas jaringan seluler di lokasi kerja karyawan, termasuk area dengan konektivitas terbatas.
- Perubahan data sensitif (gaji, rekening) tetap harus melalui approval sesuai PRD §6.2 dan tidak dapat diedit bebas dari mobile app.

# **5\. Gambaran Umum Proses Bisnis**

## **5.1 Peta Modul Mobile App**

Secara garis besar, mobile app terbagi menjadi dua area pengalaman yang muncul dalam satu aplikasi yang sama: area 'Saya' (self service pribadi, berlaku untuk seluruh pengguna) dan area 'Tim Saya' (approval & ringkasan tim, hanya muncul bagi pengguna berperan Atasan).

| **Area**                      | **Modul di Dalamnya**                                                                  |
| ----------------------------- | -------------------------------------------------------------------------------------- |
| Beranda                       | Ringkasan status hari ini, shortcut absen, saldo cuti, pengumuman, notifikasi terbaru  |
| Absensi Saya                  | Clock in/out, riwayat kehadiran, pengajuan koreksi absensi                             |
| Pengajuan Saya (Self Service) | Cuti, Izin/Sakit, Lembur, Tukar Shift, Permohonan Dokumen - beserta riwayat & status   |
| Approval (khusus Atasan)      | Antrian pengajuan bawahan yang menunggu keputusan, riwayat approval, delegasi approval |
| Tim Saya (khusus Atasan)      | Kalender ketersediaan tim, ringkasan kehadiran tim hari ini                            |
| Dokumen Saya                  | Slip gaji, dokumen pribadi (kontrak, sertifikat)                                       |
| Profil & Pengaturan           | Data pribadi, keamanan akun, preferensi notifikasi                                     |

## **5.2 Alur Pengguna Utama - Employee**

Contoh alur end-to-end harian seorang Employee menggunakan mobile app:

- Buka aplikasi, login menggunakan PIN/biometric (sesi tersimpan aman di perangkat).
- Sistem menampilkan Beranda dengan status shift hari ini dan tombol Clock In yang menonjol.
- Karyawan menekan Clock In; aplikasi meminta izin lokasi (dan foto selfie bila diaktifkan), mengirim data ke server.
- Sistem memvalidasi terhadap geofencing Branch dan Work Calendar, lalu menampilkan status Hadir/Terlambat secara langsung di layar.
- Di tengah hari, karyawan ingin mengajukan izin pulang cepat esok hari - membuka menu Self Service, memilih tipe 'Izin', mengisi tanggal, alasan, dan mengunggah dokumen pendukung bila perlu.
- Pengajuan otomatis masuk ke Workflow Engine dan diteruskan sebagai notifikasi ke Atasan langsung.
- Karyawan dapat memantau status pengajuan (Pending/Approved/Rejected) secara real-time di menu 'Pengajuan Saya'.
- Pada jam pulang, karyawan melakukan Clock Out; sistem otomatis mendeteksi status lembur bila relevan.

## **5.3 Alur Pengguna Utama - Atasan/Manager**

Contoh alur end-to-end seorang Atasan menggunakan mobile app, termasuk saat sedang bepergian:

- Atasan menerima push notification: 'Dian mengajukan Izin untuk 4 Juli 2026'.
- Menekan notifikasi, aplikasi membuka langsung (deep-link) ke detail pengajuan di Approval Center.
- Atasan meninjau detail (tanggal, alasan, dokumen pendukung, sisa saldo cuti/izin bawahan, serta indikator bila ada konflik jadwal tim).
- Atasan menekan Approve atau Reject (wajib mengisi alasan jika Reject).
- Keputusan tersimpan, notifikasi status terkirim ke karyawan, dan modul terkait (Absensi/Leave) otomatis ter-update.
- Sebelum memulai rapat mingguan, Atasan membuka 'Tim Saya' untuk melihat siapa saja yang cuti/izin/dinas minggu ini sebagai bahan penugasan pekerjaan.

# **6\. Kebutuhan Fungsional (Functional Requirements)**

Setiap kebutuhan fungsional diberi ID unik dengan format FR-\[Modul\]-\[Nomor\] dan tingkat prioritas mengacu pada metode MoSCoW (Must have/Should have/Could have/Won't have this time), dijabarkan lebih lanjut pada Bagian 9.

## **6.1 Authentication & Login**

| **ID**     | **Kebutuhan**                                                                                                                                                                               | **Aktor**               | **Prioritas** |
| ---------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------- | ------------- |
| FR-AUTH-01 | Pengguna dapat login menggunakan email/username & password yang sama dengan akun HRMS web.                                                                                                  | Employee, Atasan        | Must          |
| FR-AUTH-02 | Pengguna dapat mengaktifkan login biometric (fingerprint/Face ID) atau PIN 6 digit untuk akses cepat setelah login pertama.                                                                 | Employee, Atasan        | Must          |
| FR-AUTH-03 | Sistem menerapkan lockout otomatis setelah 5 kali percobaan login gagal berturut-turut, konsisten dengan kebijakan pada PRD §6.1.                                                           | Sistem                  | Must          |
| FR-AUTH-04 | Pengguna dapat melakukan reset password melalui email/OTP tanpa perlu menghubungi HR.                                                                                                       | Employee, Atasan        | Must          |
| FR-AUTH-05 | Sistem mendukung 2FA (OTP) opsional sesuai kebijakan perusahaan yang dikonfigurasi di web.                                                                                                  | Sistem                  | Should        |
| FR-AUTH-06 | Sistem otomatis logout/invalidate sesi setelah periode idle tertentu (dikonfigurasi oleh Admin) demi keamanan data.                                                                         | Sistem                  | Should        |
| FR-AUTH-07 | Pengguna dapat login dari maksimal N perangkat terdaftar; login di perangkat baru mengirim notifikasi keamanan ke perangkat lama.                                                           | Employee, Atasan        | Should        |
| FR-AUTH-08 | Untuk pengguna dengan akses lintas Company (mis. Group HR terbatas), aplikasi menampilkan pilihan Company aktif secara sederhana saat login, mengikuti klaim company_scope pada token sesi. | Atasan (lintas company) | Could         |

## **6.2 Dashboard / Beranda (Role-Based Dashboard)**

Beranda dirancang sebagai satu layar yang sama secara struktural untuk seluruh pengguna, namun konten dan susunan widget-nya menyesuaikan secara dinamis berdasarkan role aktif pengguna (Employee vs Atasan) serta konteks pribadinya (jumlah bawahan, status kehadiran, jenis kontrak, dsb.). Tujuannya agar setiap pengguna langsung melihat informasi paling relevan untuk perannya tanpa perlu menggali menu lain - mempercepat pengambilan keputusan harian.

### **6.2.1 Prinsip Personalisasi Dashboard**

- Widget bersifat modular dan diatur oleh Role Engine di backend: setiap widget memiliki aturan visibilitas (mis. widget 'Approval Menunggu' hanya tampil bila pengguna memiliki ≥1 bawahan langsung aktif).
- Urutan widget mengikuti prioritas urgensi: aksi yang butuh tindakan segera (belum absen, approval pending) selalu berada di posisi teratas.
- Dashboard tetap dapat menampilkan kedua konteks bagi pengguna dual-role (Employee sekaligus Atasan) dalam satu layar yang sama, dipisahkan menjadi dua zona: 'Saya' dan 'Tim Saya', tanpa perlu berganti akun/mode.

### **6.2.2 Widget Dashboard - Role Employee**

| **ID**     | **Kebutuhan**                                                                                                                        | **Aktor** | **Prioritas** |
| ---------- | ------------------------------------------------------------------------------------------------------------------------------------ | --------- | ------------- |
| FR-DASH-01 | Widget status kehadiran hari ini (belum absen/hadir/terlambat) beserta tombol aksi Clock In/Out yang menonjol di posisi paling atas. | Employee  | Must          |
| FR-DASH-02 | Widget ringkasan saldo cuti tersisa per jenis cuti dan jumlah pengajuan pribadi yang sedang Pending.                                 | Employee  | Must          |
| FR-DASH-03 | Widget shift/jadwal kerja hari ini dan besok, termasuk lokasi/branch penugasan.                                                      | Employee  | Must          |
| FR-DASH-04 | Widget pengumuman/broadcast dari HR (mis. pengingat kalender belum dikonfigurasi, hari libur mendatang, kebijakan baru).             | Employee  | Should        |
| FR-DASH-05 | Widget pengingat kontrak/dokumen/sertifikasi yang akan berakhir milik karyawan sendiri.                                              | Employee  | Could         |
| FR-DASH-06 | Widget ringkasan slip gaji terbaru (nominal net & tautan unduh) setelah periode payroll difinalisasi.                                | Employee  | Could         |

### **6.2.3 Widget Dashboard - Role Atasan/Manager**

Selain seluruh widget Employee di atas (karena Atasan tetap melakukan absensi & pengajuan untuk dirinya sendiri), zona 'Tim Saya' pada dashboard Atasan menambahkan widget berikut:

| **ID**     | **Kebutuhan**                                                                                                                                                                    | **Aktor**               | **Prioritas** |
| ---------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------- | ------------- |
| FR-DASH-07 | Widget badge jumlah pengajuan bawahan yang menunggu approval, dengan quick-access langsung ke Approval Center.                                                                   | Atasan                  | Must          |
| FR-DASH-08 | Widget ringkasan kehadiran tim hari ini (jumlah hadir/terlambat/belum absen/cuti-izin dari total bawahan aktif).                                                                 | Atasan                  | Must          |
| FR-DASH-09 | Widget daftar bawahan yang sedang cuti/izin dalam 7 hari ke depan, membantu perencanaan penugasan.                                                                               | Atasan                  | Should        |
| FR-DASH-10 | Widget indikator konflik jadwal tim (mis. lebih dari N anggota tim cuti bersamaan pada tanggal yang sama).                                                                       | Atasan                  | Could         |
| FR-DASH-11 | Widget SLA approval - menyoroti pengajuan yang sudah mendekati/melewati batas waktu proses (default 3 hari) agar tidak menumpuk.                                                 | Atasan                  | Should        |
| FR-DASH-12 | Untuk Atasan dengan span-of-control lintas Company (kasus khusus, lihat Dokumen Alur Sistem §2.4), dashboard menandai dengan jelas asal Company setiap item dalam ringkasan tim. | Atasan (lintas company) | Could         |

_Catatan: Widget FR-DASH-07 s.d. FR-DASH-12 hanya dirender bila sistem mendeteksi pengguna memiliki minimal satu bawahan langsung aktif (role Atasan). Pengguna Employee murni tidak akan melihat zona 'Tim Saya' sama sekali, menjaga dashboard tetap sederhana dan tidak membingungkan._

## **6.3 Absensi (Attendance)**

### **6.3.1 Clock In / Clock Out**

| **ID**    | **Kebutuhan**                                                                                                                                                                                            | **Aktor**             | **Prioritas** |
| --------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------- | ------------- |
| FR-ATT-01 | Karyawan dapat melakukan Clock In/Clock Out melalui satu tombol dengan validasi lokasi GPS terhadap radius geofencing Branch tempat karyawan ditugaskan.                                                 | Employee              | Must          |
| FR-ATT-02 | Sistem dapat dikonfigurasi (oleh Admin di web) untuk mewajibkan foto selfie pada saat Clock In/Out sebagai verifikasi tambahan.                                                                          | Employee              | Should        |
| FR-ATT-03 | Sistem menampilkan status real-time (Hadir/Terlambat/Lembur/Pulang Cepat) segera setelah Clock In/Out berhasil, mengikuti perhitungan toleransi shift.                                                   | Sistem                | Must          |
| FR-ATT-04 | Jika lokasi berada di luar radius geofencing, aplikasi tetap mengizinkan submit namun menandai status 'Perlu Review' dan meminta karyawan mengisi keterangan (mis. dinas luar/WFH).                      | Employee              | Must          |
| FR-ATT-05 | Aplikasi mendukung mode offline: data Clock In/Out tersimpan lokal saat tidak ada koneksi dan disinkronkan otomatis ketika koneksi tersedia, dengan prinsip server-side wins bila terjadi konflik waktu. | Sistem                | Should        |
| FR-ATT-06 | Karyawan dengan status Secondment aktif diarahkan secara otomatis ke validasi geofencing Branch tempat penugasan sementara berlaku, bukan branch asal.                                                   | Employee (Secondment) | Could         |
| FR-ATT-07 | Aplikasi mengirim reminder push notification jika mendekati batas waktu Clock In dan karyawan belum melakukan absensi.                                                                                   | Employee              | Should        |

### **6.3.2 Riwayat & Koreksi Absensi**

| **ID**    | **Kebutuhan**                                                                                                                                                         | **Aktor** | **Prioritas** |
| --------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------- | ------------- |
| FR-ATT-08 | Karyawan dapat melihat riwayat kehadiran (kalender bulanan) dengan indikator warna status per hari (Hadir/Terlambat/Absen/Cuti/Libur).                                | Employee  | Must          |
| FR-ATT-09 | Karyawan dapat mengajukan koreksi absensi (lupa absen/device error) melalui Self Service, melampirkan alasan dan bukti pendukung, yang diteruskan ke approval atasan. | Employee  | Must          |
| FR-ATT-10 | Atasan dapat melihat ringkasan kehadiran tim (siapa sudah/belum absen) pada hari berjalan.                                                                            | Atasan    | Must          |
| FR-ATT-11 | Riwayat absensi bulan yang sudah dikunci (cutoff payroll) ditampilkan sebagai read-only tanpa opsi pengajuan koreksi baru.                                            | Employee  | Should        |

## **6.4 Leave Management (Cuti)**

| **ID**   | **Kebutuhan**                                                                                                                                                                        | **Aktor**             | **Prioritas** |
| -------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | --------------------- | ------------- |
| FR-LV-01 | Karyawan dapat melihat saldo cuti tersisa per jenis cuti secara real-time.                                                                                                           | Employee              | Must          |
| FR-LV-02 | Karyawan dapat mengajukan cuti dengan memilih jenis cuti, rentang tanggal, dan alasan; sistem otomatis menghitung jumlah hari kerja (bukan hari kalender) berdasarkan Work Calendar. | Employee              | Must          |
| FR-LV-03 | Sistem menolak otomatis pengajuan yang seluruh rentang tanggalnya jatuh pada hari libur nasional, dan memvalidasi kecukupan saldo sebelum submit.                                    | Sistem                | Must          |
| FR-LV-04 | Sebelum mengajukan, karyawan dapat melihat kalender tim (siapa saja yang sudah mengambil cuti pada periode yang sama) sebagai peringatan non-blocking.                               | Employee              | Should        |
| FR-LV-05 | Karyawan dapat membatalkan pengajuan cuti yang belum disetujui, atau mengajukan pembatalan cuti yang sudah disetujui namun belum berjalan.                                           | Employee              | Should        |
| FR-LV-06 | Karyawan dapat melihat riwayat lengkap pengajuan cuti beserta status (Draft/Pending/Approved/Rejected/Cancelled).                                                                    | Employee              | Must          |
| FR-LV-07 | Untuk karyawan Secondment, saldo cuti yang ditampilkan dan dipotong tetap mengikuti Company asal (Primary assignment) sesuai ketentuan PRD.                                          | Employee (Secondment) | Could         |

## **6.5 Self Service Request Lainnya**

Mengacu pada Dokumen Alur Sistem §3.8, kanal Self Service mendukung beberapa tipe pengajuan lain di luar Cuti, dengan pola alur yang konsisten: pilih tipe → isi detail → lampirkan dokumen (bila perlu) → submit ke Workflow Engine → pantau status.

| **ID**   | **Kebutuhan**                                                                                                                                                                                                         | **Aktor**             | **Prioritas** |
| -------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------- | ------------- |
| FR-SS-01 | Karyawan dapat mengajukan Izin/Sakit dengan tanggal, alasan, dan unggah dokumen pendukung (mis. surat dokter, maks. 5MB per file).                                                                                    | Employee              | Must          |
| FR-SS-02 | Karyawan dapat mengajukan Lembur (permohonan sebelum bekerja lembur) minimal H-1 sesuai kebijakan, atau melihat lembur yang otomatis terdeteksi dari Clock Out.                                                       | Employee              | Must          |
| FR-SS-03 | Karyawan dapat mengajukan Tukar Shift dengan rekan kerja tertentu; sistem memvalidasi ulang batas jam kerja maksimum sebelum diteruskan ke approval.                                                                  | Employee              | Should        |
| FR-SS-04 | Karyawan dapat mengajukan Permohonan Dokumen (Surat Keterangan Kerja, dsb.) yang setelah disetujui langsung tersedia untuk diunduh di menu Dokumen Saya.                                                              | Employee              | Should        |
| FR-SS-05 | Karyawan dapat melihat satu daftar riwayat gabungan seluruh jenis pengajuan (Cuti, Izin, Lembur, Tukar Shift, Koreksi Absensi, Dokumen) dengan filter status & jenis.                                                 | Employee              | Must          |
| FR-SS-06 | Pengajuan yang sudah diproses (Approved/Rejected) tidak dapat diedit; karyawan hanya dapat mengajukan permintaan baru.                                                                                                | Employee              | Must          |
| FR-SS-07 | Sistem menampilkan peringatan non-blocking apabila tanggal yang diajukan (Izin/Koreksi) bertepatan dengan hari libur pada Work Calendar.                                                                              | Sistem                | Could         |
| FR-SS-08 | Untuk karyawan Secondment, aplikasi menampilkan dengan jelas kepada siapa pengajuan operasional harian (izin/lembur) akan diarahkan - Atasan Company asal atau Atasan Company tujuan - sesuai konfigurasi assignment. | Employee (Secondment) | Could         |

## **6.6 Approval Center (Atasan)**

| **ID**    | **Kebutuhan**                                                                                                                                                                                                                                                                        | **Aktor** | **Prioritas** |
| --------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | --------- | ------------- |
| FR-APR-01 | Atasan memiliki satu Approval Center terpusat yang menampilkan seluruh pengajuan bawahan yang menunggu keputusannya, lintas jenis (Cuti, Izin, Lembur, Tukar Shift, Koreksi Absensi, Dokumen).                                                                                       | Atasan    | Must          |
| FR-APR-02 | Atasan dapat membuka detail lengkap setiap pengajuan (tanggal, alasan, dokumen pendukung, sisa saldo terkait) sebelum memutuskan.                                                                                                                                                    | Atasan    | Must          |
| FR-APR-03 | Atasan dapat melakukan Approve atau Reject langsung dari daftar (quick action) atau dari halaman detail; Reject wajib disertai alasan.                                                                                                                                               | Atasan    | Must          |
| FR-APR-04 | Atasan menerima push notification real-time setiap kali ada pengajuan baru yang membutuhkan persetujuannya, dengan deep-link langsung ke detail pengajuan.                                                                                                                           | Atasan    | Must          |
| FR-APR-05 | Atasan dapat melihat riwayat seluruh keputusan approval yang pernah diambil beserta timestamp.                                                                                                                                                                                       | Atasan    | Should        |
| FR-APR-06 | Atasan dapat mendelegasikan kewenangan approval sementara ke Atasan pengganti (mis. saat cuti), sesuai mekanisme backup approver pada Workflow Engine.                                                                                                                               | Atasan    | Should        |
| FR-APR-07 | Sistem menampilkan indikator/badge pada pengajuan yang berpotensi konflik jadwal tim (mis. beberapa anggota tim cuti bersamaan).                                                                                                                                                     | Sistem    | Could         |
| FR-APR-08 | Sistem menampilkan eskalasi otomatis (SLA reminder) jika suatu pengajuan belum diproses melebihi batas waktu yang dikonfigurasi (default 3 hari).                                                                                                                                    | Sistem    | Should        |
| FR-APR-09 | Untuk pengajuan yang menurut Workflow Engine memerlukan approval tambahan di luar Atasan langsung (mis. eskalasi Group HR Director), aplikasi menampilkan status tahapan approval secara transparan (siapa approver berikutnya) tanpa perlu Atasan menindaklanjuti langkah tersebut. | Atasan    | Could         |

## **6.7 Kalender Kerja & Kalender Tim**

| **ID**    | **Kebutuhan**                                                                                                                                                                              | **Aktor** | **Prioritas** |
| --------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | --------- | ------------- |
| FR-CAL-01 | Karyawan dapat melihat kalender kerja pribadi: hari kerja, hari libur nasional/perusahaan, dan jadwal shift yang berlaku, hasil warisan hierarki Group→Company→Branch→Department→Employee. | Employee  | Must          |
| FR-CAL-02 | Atasan dapat melihat kalender ketersediaan tim (overlay cuti/izin approved seluruh bawahan) dalam tampilan bulanan.                                                                        | Atasan    | Must          |
| FR-CAL-03 | Sistem menyoroti (highlight) potensi konflik jadwal, misalnya banyak anggota tim cuti pada periode yang sama.                                                                              | Sistem    | Should        |

## **6.8 Notifikasi**

| **ID**    | **Kebutuhan**                                                                                                                                                 | **Aktor**        | **Prioritas** |
| --------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------- | ------------- |
| FR-NOT-01 | Sistem mengirim push notification untuk seluruh event relevan: status pengajuan berubah, pengajuan baru masuk approval, reminder Clock In/Out, pengumuman HR. | Employee, Atasan | Must          |
| FR-NOT-02 | Setiap notifikasi yang ditekan mengarahkan pengguna langsung (deep-link) ke halaman detail terkait, bukan hanya membuka aplikasi ke Beranda.                  | Employee, Atasan | Must          |
| FR-NOT-03 | Pengguna dapat melihat daftar riwayat seluruh notifikasi (in-app notification center) dan menandainya sebagai sudah dibaca.                                   | Employee, Atasan | Should        |
| FR-NOT-04 | Pengguna dapat mengatur preferensi kanal notifikasi (push saja / push+email) untuk kategori tertentu, sesuai konfigurasi yang diizinkan Admin.                | Employee, Atasan | Could         |

## **6.9 Slip Gaji & Dokumen Pribadi**

| **ID**    | **Kebutuhan**                                                                                                                                                       | **Aktor** | **Prioritas** |
| --------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------- | ------------- |
| FR-DOC-01 | Karyawan dapat melihat dan mengunduh slip gaji digital (PDF) untuk periode yang sudah difinalisasi, dengan akses terproteksi (PIN/biometric ulang sebelum membuka). | Employee  | Must          |
| FR-DOC-02 | Karyawan dapat melihat dan mengunduh dokumen pribadi miliknya (kontrak kerja, sertifikat, surat keterangan) yang tersimpan di Document Management System.           | Employee  | Should        |
| FR-DOC-03 | Seluruh akses/unduhan dokumen sensitif tercatat pada Audit Log backend, konsisten dengan PRD §6.24 dan §6.13.                                                       | Sistem    | Must          |

## **6.10 Profil & Pengaturan Akun**

| **ID**    | **Kebutuhan**                                                                                                                                                                       | **Aktor**        | **Prioritas** |
| --------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------- | ------------- |
| FR-PRF-01 | Karyawan dapat melihat data profil pribadi (data kepegawaian dasar, departemen, atasan, kontak).                                                                                    | Employee, Atasan | Must          |
| FR-PRF-02 | Karyawan dapat mengubah data kontak non-sensitif (nomor HP, alamat email pribadi, kontak darurat) langsung dari aplikasi.                                                           | Employee, Atasan | Should        |
| FR-PRF-03 | Perubahan data sensitif (gaji, rekening bank, NIK) tidak dapat diedit dari mobile app; pengguna diarahkan ke Self Service Request agar melalui approval HR Manager sesuai PRD §6.2. | Sistem           | Must          |
| FR-PRF-04 | Karyawan dapat mengelola perangkat terdaftar (melihat daftar perangkat login, melakukan revoke/logout perangkat lain).                                                              | Employee, Atasan | Should        |
| FR-PRF-05 | Karyawan dapat mengganti bahasa aplikasi (minimal Bahasa Indonesia & Inggris).                                                                                                      | Employee, Atasan | Could         |

# **7\. Kebutuhan Non-Fungsional**

## **7.1 Kinerja (Performance)**

- Waktu buka aplikasi (cold start) tidak lebih dari 3 detik pada perangkat kelas menengah dengan jaringan 4G.
- Proses Clock In/Out (dari tekan tombol hingga konfirmasi status) selesai dalam waktu maksimal 5 detik pada kondisi jaringan normal.
- Aplikasi tetap responsif (tidak freeze) saat memuat riwayat data dengan volume besar melalui teknik pagination/lazy loading.
- Data yang bersifat baca-cepat dan sering diakses (status kehadiran hari ini, saldo cuti, ringkasan dashboard) dilayani dari lapisan cache di backend agar waktu respons tetap konsisten meski jumlah pengguna aktif tinggi pada jam-jam sibuk (lihat detail skema pada Bagian 8).

## **7.2 Keamanan (Security)**

Prinsip utama keamanan aplikasi adalah defense in depth: setiap request tetap divalidasi secara presisi di sisi server meskipun sudah melewati validasi di sisi aplikasi mobile, karena validasi client-side hanya bertujuan meningkatkan pengalaman pengguna (early feedback) dan tidak pernah menjadi satu-satunya lapisan pertahanan.

### **7.2.1 Lapisan Validasi (Validation Layers)**

| **Lapisan**                                        | **Ketentuan Presisi**                                                                                                                                                                                                                                                                                            |
| -------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1\. Validasi Input (Client)                        | Format data (tanggal, nominal, panjang teks, tipe file, ukuran maksimal upload) divalidasi di aplikasi sebelum dikirim, untuk mengurangi request yang pasti gagal - namun tidak dipercaya sebagai validasi final.                                                                                                |
| 2\. Validasi Input (Server)                        | Seluruh payload divalidasi ulang di server (tipe data, rentang nilai, wajib/tidak wajib, whitelist nilai enum) menggunakan schema validation yang sama persis dengan aturan bisnis, menolak request dengan pesan error yang presisi dan tidak generik.                                                           |
| 3\. Validasi Otentikasi                            | Setiap request wajib menyertakan token sesi valid (JWT) yang diverifikasi tanda tangan, masa berlaku, dan status blacklist (mis. setelah logout) sebelum diproses lebih lanjut.                                                                                                                                  |
| 4\. Validasi Otorisasi (RBAC & Row-Level Security) | Setiap request diverifikasi terhadap role dan scope kepemilikan data - mis. Atasan hanya dapat meng-approve pengajuan milik bawahan langsungnya sendiri (dicek terhadap struktur organisasi aktual di database, bukan hanya klaim pada token), konsisten dengan filter company_scope pada PRD §2.4.              |
| 5\. Validasi Aturan Bisnis (Business Rule)         | Aturan seperti kecukupan saldo cuti, radius geofencing, batas approval berjenjang, dan status pengajuan yang masih dapat diproses (belum Approved/Rejected) diverifikasi ulang di server tepat sebelum transaksi disimpan, untuk mencegah race condition (mis. dua approval bersamaan pada pengajuan yang sama). |
| 6\. Validasi Idempotensi                           | Aksi kritikal (submit pengajuan, Clock In/Out, approve/reject) menyertakan idempotency key agar pengiriman ulang akibat retry jaringan tidak menghasilkan duplikasi transaksi.                                                                                                                                   |
| 7\. Rate Limiting & Anomaly Detection              | Permintaan dibatasi per akun/perangkat dalam jendela waktu tertentu untuk mencegah brute-force maupun penyalahgunaan API; pola akses tidak wajar (mis. lokasi absen berpindah drastis dalam waktu singkat) ditandai untuk ditinjau HR.                                                                           |

### **7.2.2 Ketentuan Keamanan Tambahan**

- Seluruh komunikasi data antara aplikasi dan server menggunakan enkripsi TLS 1.2 ke atas; sertifikat divalidasi dengan certificate pinning untuk mencegah man-in-the-middle.
- Token sesi (JWT) disimpan menggunakan secure storage bawaan platform (Keychain di iOS, Keystore di Android), tidak disimpan dalam plain text, dan memiliki masa berlaku pendek dengan mekanisme refresh token terpisah.
- Data biometric (jika digunakan untuk face recognition absensi maupun login) tidak disimpan mentah di server; hanya representasi terenkripsi/hash yang digunakan untuk pencocokan.
- Aplikasi mendukung remote wipe/logout paksa dari sisi admin apabila perangkat karyawan hilang/dicuri.
- Seluruh aksi kritikal (Clock In/Out, submit pengajuan, approve/reject) tercatat di Audit Log backend sesuai PRD §6.13, termasuk device ID, hasil validasi, dan lokasi bila relevan - sehingga setiap keputusan sistem dapat ditelusuri dan dipertanggungjawabkan.

## **7.3 Usability & Aksesibilitas**

- Alur Clock In/Out dapat diselesaikan pengguna baru tanpa training dalam maksimal 2 langkah/tap dari Beranda.
- Antarmuka mendukung ukuran teks yang dapat disesuaikan (accessibility text scaling) dan kontras warna yang memadai bagi pengguna dengan keterbatasan penglihatan ringan.
- Bahasa aplikasi utama adalah Bahasa Indonesia, dengan istilah yang konsisten dengan yang digunakan di aplikasi web agar tidak membingungkan pengguna lintas platform.

## **7.4 Platform & Kompatibilitas**

- Aplikasi tersedia untuk Android (minimal versi 9/Pie ke atas) dan iOS (minimal versi 14 ke atas).
- Aplikasi mendukung berbagai ukuran layar smartphone umum; dukungan tablet bersifat opsional pada fase awal.

## **7.5 Ketersediaan & Keandalan (Availability & Reliability)**

- Target service availability backend yang dikonsumsi aplikasi minimal 99.5% di luar jadwal maintenance terjadwal.
- Fitur Clock In/Out mendukung mode offline dengan sinkronisasi otomatis sesuai FR-ATT-05, memastikan karyawan di area dengan konektivitas lemah tetap dapat absen.

## **7.6 Lokalisasi & Kepatuhan Data**

- Data pribadi karyawan (lokasi, foto selfie, dokumen) diproses dan disimpan sesuai regulasi perlindungan data pribadi yang berlaku di Indonesia.
- Retensi data lokasi presensi mengikuti kebijakan retensi Audit Log/data kepegawaian sebagaimana diatur pada PRD §6.13 dan §11.

# **8\. Arsitektur & Optimasi Kinerja Sistem**

Bagian ini menetapkan kebutuhan arsitektur pendukung tingkat tinggi (high-level) agar aplikasi mobile tetap responsif dan andal pada momen beban puncak - misalnya saat seluruh karyawan melakukan Clock In pada jam masuk kerja yang hampir bersamaan, atau saat notifikasi massal dikirim ke seluruh pengguna. Detail implementasi teknis sepenuhnya menjadi kewenangan Tim Engineering, namun prinsip berikut menjadi kebutuhan bisnis yang wajib dipenuhi demi pengalaman pengguna yang konsisten.

## **8.1 Skema Baca-Tulis: Database sebagai Sumber Kebenaran, Cache untuk Kecepatan Baca**

Pola yang digunakan adalah cache-aside/write-through sederhana: setiap kali terjadi perubahan data (transaksi baru - mis. Clock In/Out, submit pengajuan, approve/reject), sistem selalu menuliskan data tersebut ke database utama terlebih dahulu sebagai satu-satunya sumber kebenaran (source of truth), lalu memperbarui/menghapus (invalidate) entri cache terkait. Untuk permintaan baca (read) yang sering diakses dan jarang berubah dalam rentang waktu singkat - seperti status kehadiran hari ini, saldo cuti, ringkasan dashboard, dan konfigurasi kalender kerja - sistem melayani dari cache in-memory (mis. Redis) tanpa membebani database pada setiap request.

| **Tahapan**                                                                 | **Perilaku Sistem**                                                                                                                                                                                                                        |
| --------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Ada perubahan data (write)                                                  | Request disimpan ke database (transaksional, ACID) → setelah berhasil, cache lama untuk entitas terkait di-invalidate/diperbarui → event perubahan dipublikasikan ke message queue untuk diproses lebih lanjut (lihat §8.2).               |
| Tidak ada perubahan data (read)                                             | Request pertama-tama dicek ke cache; jika ditemukan (cache hit) data langsung dikembalikan tanpa query ke database; jika tidak ditemukan (cache miss) sistem mengambil dari database, lalu menyimpannya ke cache untuk request berikutnya. |
| Data sensitif/transaksional final (slip gaji terfinalisasi, hasil approval) | Tetap dibaca dari database sebagai rujukan utama begitu status berubah final, dengan cache hanya digunakan sebagai lapisan percepatan tampilan, bukan pengganti data resmi.                                                                |

- Cache diberi waktu kedaluwarsa (TTL) yang wajar per jenis data - mis. status kehadiran harian TTL singkat (hitungan menit), data referensi seperti kalender kerja TTL lebih panjang (hitungan jam).
- Setiap transaksi yang mengubah data (write) selalu memicu invalidasi cache terkait secara eksplisit, bukan hanya mengandalkan TTL kedaluwarsa, agar data yang tampil di aplikasi tidak pernah basi (stale) setelah suatu aksi berhasil disimpan.

## **8.2 Pemrosesan Asinkron untuk Beban Non-Kritikal**

Proses yang tidak perlu langsung mempengaruhi respons ke pengguna - seperti pengiriman push notification, pencatatan ke Audit Log, sinkronisasi data ke Dashboard/Reporting agregat, dan reminder terjadwal - diproses secara asinkron melalui message queue (mis. RabbitMQ), bukan dieksekusi sinkron di dalam alur request utama.

- Saat transaksi utama (mis. Approve pengajuan) berhasil disimpan ke database, sistem menerbitkan event ke queue; worker terpisah yang mengonsumsi event tersebut untuk mengirim notifikasi, memperbarui cache agregat, dan mencatat audit trail.
- Pola ini memastikan pengguna menerima konfirmasi keberhasilan aksi secepat mungkin (karena tidak menunggu proses notifikasi selesai), sementara notifikasi tetap terkirim dalam hitungan detik melalui worker di belakang layar.
- Jika worker gagal memproses (mis. layanan push notification eksternal sedang gangguan), pesan tetap berada di queue dan dicoba ulang otomatis (retry dengan backoff) tanpa kehilangan data maupun perlu mengulang transaksi utama.

## **8.3 Skalabilitas Layanan: Load Balancer**

Lalu lintas dari aplikasi mobile diarahkan melalui load balancer yang mendistribusikan request ke beberapa instance server aplikasi secara merata, memungkinkan sistem menambah kapasitas secara horizontal (menambah instance) saat beban meningkat, misalnya pada jam masuk/pulang kerja bersamaan, tanpa mengubah satu titik layanan menjadi bottleneck tunggal.

- Health check otomatis pada load balancer memastikan request hanya diarahkan ke instance server yang sehat/responsif, dan secara otomatis mengeluarkan instance yang bermasalah dari rotasi.
- Sesi pengguna tidak bergantung pada satu instance server tertentu (stateless authentication via JWT) sehingga request dari pengguna yang sama dapat dilayani oleh instance server manapun secara aman.

## **8.4 Ringkasan Manfaat Bisnis dari Skema Ini**

| **Komponen**                     | **Manfaat Bisnis**                                                                                                                                                                  |
| -------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Cache (mis. Redis)               | Waktu respons aplikasi tetap cepat meski diakses ribuan karyawan bersamaan pada jam sibuk, tanpa membebani database utama secara berlebihan.                                        |
| Message Queue (mis. RabbitMQ)    | Notifikasi dan proses pendukung tetap berjalan andal walau terjadi gangguan sementara pada layanan eksternal, tanpa mengorbankan kecepatan respons transaksi utama.                 |
| Load Balancer                    | Aplikasi tetap tersedia dan responsif saat jumlah pengguna aktif bertambah (skalabilitas), serta lebih tahan terhadap gangguan pada satu server tanpa memengaruhi seluruh pengguna. |
| Database sebagai Source of Truth | Menjamin akurasi dan konsistensi data akhir (mis. saldo cuti, status approval) tetap terjaga meskipun sebagian besar traffic baca dilayani dari cache.                              |

_Catatan: Pemilihan teknologi spesifik (Redis, RabbitMQ, jenis load balancer, dsb.) merupakan keputusan teknis Tim Engineering/Infra berdasarkan kebutuhan pada bagian ini; BRD menetapkan kebutuhan pola arsitektur (write-through ke database, cache untuk baca, async processing, horizontal scaling) sebagai kebutuhan bisnis wajib, bukan mendikte produk/vendor tertentu._

# **9\. Kebutuhan Integrasi & Dependency**

## **9.1 Integrasi dengan Modul Backend HRMS Existing**

| **Modul Backend (PRD)**               | **Bentuk Integrasi dengan Mobile App**                                                            |
| ------------------------------------- | ------------------------------------------------------------------------------------------------- |
| Authentication & Authorization (§6.1) | Login, refresh token, klaim company_scope untuk row-level security.                               |
| Master Employee (§6.2)                | Sumber data profil, struktur atasan-bawahan, status kepegawaian.                                  |
| Organization Structure (§6.3)         | Referensi Department/Position/Branch untuk validasi konteks pengajuan.                            |
| Shift Management (§6.4)               | Rujukan shift aktif karyawan untuk perhitungan status Clock In/Out.                               |
| Work Calendar (§6.5)                  | Rujukan hari kerja/libur untuk kalkulasi cuti dan validasi absensi.                               |
| Attendance (§6.6)                     | Endpoint Clock In/Out, riwayat kehadiran, geofencing per Branch.                                  |
| Leave Management (§6.7)               | Saldo cuti, pengajuan, kalender tim.                                                              |
| Self Service Request (§6.8)           | Seluruh endpoint pengajuan Izin/Lembur/Tukar Shift/Koreksi/Dokumen.                               |
| Workflow Engine (§6.23/§4.10)         | Mesin approval bersama; mobile app hanya konsumen status, tidak menyimpan logic approval sendiri. |
| Notification & Alert (§6.12)          | Push notification real-time & deep-link ke halaman terkait.                                       |
| Payroll (§6.9)                        | Slip gaji read-only setelah periode difinalisasi.                                                 |
| Document Management System (§6.24)    | Penyimpanan & akses dokumen pribadi, termasuk log akses.                                          |
| Audit Log (§6.13)                     | Pencatatan seluruh aksi kritikal dari mobile app.                                                 |

## **9.2 Integrasi Perangkat / Layanan Eksternal**

- GPS/Location Service perangkat untuk validasi geofencing.
- Kamera perangkat untuk fitur selfie/face recognition saat absensi (bila diaktifkan).
- Push Notification Service (Firebase Cloud Messaging untuk Android, Apple Push Notification Service untuk iOS).
- Biometric API perangkat (Fingerprint/Face ID) untuk login cepat, terpisah dari face recognition absensi.

## **9.3 Dependency terhadap Konsep Company Group**

Meskipun ruang lingkup utama mobile app adalah self service, approval, dan absensi tingkat individu/tim, beberapa perilaku aplikasi tetap dipengaruhi oleh struktur Company Group sebagaimana dijelaskan pada Dokumen Alur Sistem §2, khususnya untuk kasus Secondment/mutasi lintas company. Ketentuan berikut menjadi acuan:

- Validasi geofencing dan approval operasional harian mengikuti Company/Branch tempat penugasan aktif karyawan berlaku, bukan selalu Company asal (lihat FR-ATT-06, FR-SS-08).
- Saldo cuti tetap bersumber dari Company Primary assignment karyawan untuk mencegah duplikasi kuota (lihat FR-LV-07).
- Approval yang memerlukan eskalasi ke Group HR Director/Group Finance Director tetap ditampilkan statusnya di mobile app, namun keputusan approval tingkat Group tersebut dapat dilakukan melalui web maupun mobile sesuai kebijakan yang berlaku (lihat FR-APR-09).

_Catatan: Detail teknis mendalam terkait Company Group (skema data, RBAC, hierarki entitas) sepenuhnya mengacu pada Dokumen Alur Sistem §2 dan tidak diulang di sini; BRD ini hanya menandai titik-titik di mana perilaku mobile app perlu menyesuaikan._

# **10\. Matriks Prioritas Kebutuhan (MoSCoW)**

Prioritas berikut menjadi acuan awal untuk perencanaan rilis (release planning); pembagian rinci ke dalam sprint/milestone akan ditentukan lebih lanjut oleh Tim Product bersama Engineering.

| **Kategori**            | **Definisi**                                                                    | **Cakupan Modul Utama**                                                                                                            |
| ----------------------- | ------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------- |
| Must Have (Rilis 1)     | Wajib ada agar aplikasi dapat digunakan secara fungsional dan bernilai bisnis   | Login, Clock In/Out, Leave (ajukan & saldo), Self Service dasar (Izin/Sakit), Approval Center dasar, Notifikasi, Riwayat pengajuan |
| Should Have (Rilis 1-2) | Meningkatkan pengalaman & efisiensi, dapat menyusul tak lama setelah rilis awal | Koreksi Absensi, Tukar Shift, Delegasi Approval, Mode Offline, Kalender Tim, Slip Gaji                                             |
| Could Have (Rilis 2+)   | Nilai tambah namun tidak menghambat peluncuran awal                             | Permohonan Dokumen, Multi-device management, Multi-bahasa, Konteks Secondment lintas company, Highlight konflik jadwal             |
| Won't Have (Fase Ini)   | Sengaja tidak dikerjakan pada horizon dokumen ini                               | Modul administratif/back-office, Payroll Run, Recruitment, LMS, Asset Management, Group Executive Dashboard                        |

# **11\. Risiko & Mitigasi**

| **Risiko**                                                                                         | **Dampak**                                                                                   | **Mitigasi**                                                                                                                    |
| -------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| Akurasi GPS rendah di area kerja tertentu (dalam gedung/basement)                                  | Karyawan gagal Clock In meski berada di lokasi kerja sah                                     | Radius geofencing dapat dikonfigurasi lebih longgar per Branch; sediakan opsi 'Perlu Review' alih-alih blokir total (FR-ATT-04) |
| Adopsi rendah karena resistensi perubahan dari kanal manual/web ke mobile                          | Target adoption rate tidak tercapai, ROI proyek berkurang                                    | Sosialisasi & training bertahap, UX yang sederhana, quick-win pada fitur Clock In (FR-DASH-01)                                  |
| Ketergantungan konektivitas internet di lokasi kerja lapangan                                      | Absensi tidak tercatat tepat waktu                                                           | Mode offline dengan sinkronisasi otomatis (FR-ATT-05)                                                                           |
| Kesalahpahaman approver terhadap kasus lintas Company (Secondment)                                 | Pengajuan tersangkut/salah arah approval                                                     | Indikator jelas approver yang dituju pada tampilan pengajuan (FR-SS-08, FR-APR-09)                                              |
| Kebocoran data sensitif (slip gaji, dokumen pribadi) bila perangkat dicuri                         | Pelanggaran privasi & kepatuhan data                                                         | Re-autentikasi wajib sebelum membuka dokumen sensitif, remote wipe (§7.2)                                                       |
| Beban server meningkat akibat push notification & polling status real-time                         | Penurunan performa backend saat jam sibuk (absen pagi bersamaan)                             | Skema caching (Redis) dan load balancer sesuai Bagian 8 untuk menyerap beban baca & mendistribusikan traffic                    |
| Data pada cache tidak konsisten dengan database (stale data) setelah suatu transaksi               | Pengguna melihat status yang sudah usang (mis. saldo cuti belum ter-update setelah approval) | Invalidasi cache eksplisit segera setelah write berhasil (bukan hanya mengandalkan TTL), sesuai skema write-through pada §8.1   |
| Antrian pesan (message queue) menumpuk saat layanan konsumen (mis. push notification) gagal/lambat | Notifikasi terlambat sampai ke pengguna                                                      | Mekanisme retry dengan backoff dan monitoring kedalaman antrian (queue depth) pada §8.2                                         |

# **12\. Kriteria Penerimaan Umum (Acceptance Criteria)**

Kriteria berikut berlaku secara umum di seluruh modul dan menjadi syarat minimum sebelum aplikasi dinyatakan siap rilis (Rilis 1 - cakupan Must Have):

- Karyawan dapat melakukan Clock In/Out dengan validasi lokasi dan mendapat konfirmasi status dalam satu alur tanpa error, pada perangkat Android dan iOS.
- Karyawan dapat mengajukan Cuti dan Izin/Sakit, dengan validasi saldo dan hari kerja berjalan sesuai Work Calendar yang berlaku.
- Atasan menerima notifikasi real-time untuk setiap pengajuan baru dan dapat menyelesaikan approve/reject dalam maksimal 3 tap dari notifikasi.
- Seluruh status pengajuan (Pending/Approved/Rejected) konsisten antara tampilan mobile app dan aplikasi web dalam waktu real-time (tanpa jeda sinkronisasi yang signifikan).
- Seluruh aksi kritikal tercatat di Audit Log backend dan dapat ditelusuri (siapa, kapan, aksi apa, dari perangkat mana).
- Aplikasi lulus pengujian keamanan dasar (penetration testing ringan) tanpa temuan kritikal terkait penyimpanan token/data sensitif.
- Tidak ditemukan crash mayor pada skenario uji utama (Clock In/Out, submit pengajuan, approval) selama UAT (User Acceptance Testing).

# **13\. Lampiran**

## **13.1 Traceability Matrix - Modul PRD vs Fitur Mobile App**

| **Modul PRD/Dokumen Alur Sistem**        | **Fitur di Mobile App**                                                                 | **Catatan Cakupan**                                                                                               |
| ---------------------------------------- | --------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------- |
| §6.1 Authentication & Authorization      | Login, biometric, reset password                                                        | Company Switcher disederhanakan (Could Have)                                                                      |
| §6.2 Master Employee                     | Profil & Pengaturan Akun                                                                | Edit terbatas pada field non-sensitif                                                                             |
| §6.3 Organization Structure              | Referensi struktur pada Approval & Profil                                               | Read-only, tidak ada fitur admin di mobile                                                                        |
| §6.4 Shift Management                    | Rujukan shift pada Absensi & Kalender                                                   | Read-only, konfigurasi tetap di web                                                                               |
| §6.5 Work Calendar                       | Kalender Kerja & Kalender Tim                                                           | Read-only                                                                                                         |
| §6.6 Attendance                          | Absensi (Clock In/Out, riwayat, koreksi)                                                | Cakupan penuh di mobile                                                                                           |
| §6.7 Leave Management                    | Leave Management                                                                        | Cakupan penuh di mobile                                                                                           |
| §6.8 Self Service Request                | Self Service (Izin/Lembur/Tukar Shift/Dokumen)                                          | Cakupan penuh di mobile                                                                                           |
| §6.9 Payroll                             | Slip Gaji                                                                               | Read-only, setelah finalisasi                                                                                     |
| §6.12 Notification & Alert               | Notifikasi                                                                              | Cakupan penuh di mobile                                                                                           |
| §6.13 Audit Log                          | Pencatatan aksi kritikal backend                                                        | Tidak ada UI khusus di mobile, hanya sumber data                                                                  |
| §4.10 Workflow Engine (§6.23)            | Approval Center                                                                         | Cakupan penuh di mobile                                                                                           |
| §4.11 Document Management System (§6.24) | Dokumen Saya                                                                            | Read-only untuk dokumen pribadi karyawan                                                                          |
| §2 Company Group                         | Penyesuaian konteks Secondment pada Absensi, Self Service, Approval                     | Cakupan terbatas - hanya perilaku turunan yang relevan bagi Employee/Atasan                                       |
| PRD §13 Risk Mitigation                  | Bagian 8 - Arsitektur & Optimasi Kinerja Sistem (caching, message queue, load balancer) | Kebutuhan arsitektur pendukung baru, tidak eksplisit disebut di PRD namun selaras dengan prinsip keandalan sistem |

## **13.2 Glosarium Tambahan**

| **Istilah**                 | **Keterangan**                                                                                                                                                                              |
| --------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Deep-link                   | Tautan yang membuka aplikasi langsung ke halaman/konten spesifik, bukan hanya membuka aplikasi secara umum.                                                                                 |
| MoSCoW                      | Teknik prioritisasi kebutuhan: Must have, Should have, Could have, Won't have this time.                                                                                                    |
| UAT                         | User Acceptance Testing - pengujian oleh pengguna akhir sebelum aplikasi dinyatakan siap rilis.                                                                                             |
| BYOD                        | Bring Your Own Device - kebijakan penggunaan perangkat pribadi karyawan untuk keperluan kerja.                                                                                              |
| Cache-aside / Write-through | Pola arsitektur di mana data ditulis ke database sebagai sumber kebenaran, sementara pembacaan data yang sering diakses dilayani dari lapisan cache (mis. Redis) untuk mempercepat respons. |
| Redis                       | Salah satu contoh in-memory data store yang umum digunakan sebagai lapisan cache berkecepatan tinggi.                                                                                       |
| Message Queue / RabbitMQ    | Komponen middleware untuk memproses tugas secara asinkron (mis. pengiriman notifikasi) tanpa memperlambat respons transaksi utama; RabbitMQ adalah salah satu contoh produknya.             |
| Load Balancer               | Komponen yang mendistribusikan traffic masuk ke beberapa instance server aplikasi agar beban merata dan sistem dapat diskalakan secara horizontal.                                          |
| TTL (Time to Live)          | Batas waktu suatu data dianggap valid di dalam cache sebelum dianggap kedaluwarsa dan perlu diambil ulang dari database.                                                                    |
| Idempotency Key             | Penanda unik pada suatu request untuk memastikan pengiriman ulang (retry) tidak menghasilkan transaksi duplikat.                                                                            |

**- Akhir Dokumen -**