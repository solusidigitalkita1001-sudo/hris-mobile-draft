# Panduan Migrasi ke Feature-First + Clean Architecture + Riverpod

Dokumen ini melengkapi `ARCHITECTURE.md`. Isinya langkah konkret memindahkan struktur
project `hrm_app` yang sudah ada (dengan `lib/models`, `lib/screens`, `lib/widgets` di root)
menjadi struktur clean architecture per fitur.

## Langkah 1 — Audit isi folder lama

Jalankan di root project untuk melihat semua file yang perlu dipindah:
```bash
find lib/models lib/screens lib/widgets -type f
```

Kelompokkan tiap file ke salah satu fitur bisnis berikut (sesuai BRD):
`auth`, `dashboard`, `attendance`, `leave`, `self_service`, `approval`,
`notification`, `calendar`, `payslip`, `document`, `profile`.

## Langkah 2 — Buat skeleton folder tiap fitur

```bash
for feature in auth dashboard attendance leave self_service approval notification calendar payslip document profile; do
  mkdir -p "lib/features/$feature/domain/entities"
  mkdir -p "lib/features/$feature/domain/repositories"
  mkdir -p "lib/features/$feature/domain/usecases"
  mkdir -p "lib/features/$feature/data/datasources"
  mkdir -p "lib/features/$feature/data/models"
  mkdir -p "lib/features/$feature/data/repositories"
  mkdir -p "lib/features/$feature/presentation/providers"
  mkdir -p "lib/features/$feature/presentation/screens"
  mkdir -p "lib/features/$feature/presentation/widgets"
done
```

## Langkah 3 — Pindahkan & pecah tiap model lama

Untuk setiap file di `lib/models/xxx_model.dart`:

1. Identifikasi field yang murni bisnis (tanpa `fromJson`/`toJson`) → jadi
   `lib/features/<fitur>/domain/entities/xxx_entity.dart`
2. Sisa logic serialisasi (`fromJson`/`toJson`) → jadi
   `lib/features/<fitur>/data/models/xxx_model.dart`, class `extends XxxEntity`

**Contoh konkret** sudah dibuatkan lengkap untuk fitur Attendance, lihat:
- `lib/features/attendance/domain/entities/attendance_entity.dart`
- `lib/features/attendance/data/models/attendance_pending_model.dart`
- `lib/features/attendance/data/models/attendance_response_model.dart`

Tiru pola yang sama persis untuk model Leave, Self Service, Approval, dsb.

## Langkah 4 — Pindahkan screens

Setiap file di `lib/screens/xxx_screen.dart` pindah ke
`lib/features/<fitur>/presentation/screens/xxx_screen.dart`.

Jika screen tadinya langsung memanggil `http`/`Dio`/`SharedPreferences` di dalam
`StatefulWidget`, **ini yang harus diperbaiki**: pindahkan logic itu ke
use case + repository, screen hanya boleh panggil `ref.watch(xxxNotifierProvider)`.

## Langkah 5 — Pindahkan widgets

Untuk setiap file di `lib/widgets/xxx_widget.dart`, tanya:
> "Apakah widget ini dipakai lebih dari 1 fitur?"

- **Ya** (mis. `PrimaryButton`, `LoadingOverlay`, `EmptyStateWidget`) →
  pindah ke `lib/core/widgets/xxx_widget.dart`
- **Tidak**, khusus 1 fitur (mis. `AttendanceHistoryTile`) →
  pindah ke `lib/features/<fitur>/presentation/widgets/xxx_widget.dart`

## Langkah 6 — Buat repository interface + implementasi untuk tiap fitur

Untuk setiap fitur, minimal buat 3 file (ikuti pola Attendance):

```
domain/repositories/xxx_repository.dart        # abstract class (kontrak)
data/repositories/xxx_repository_impl.dart      # implementasi konkret
domain/usecases/xxx_usecase.dart                 # satu class per aksi bisnis
```

## Langkah 7 — Hapus folder lama

Setelah semua file di `lib/models/`, `lib/screens/`, `lib/widgets/` sudah
dipindahkan dan di-import ulang di tempat baru:

```bash
# Pastikan tidak ada lagi import ke folder lama
grep -r "package:hrm_app/models/" lib/
grep -r "package:hrm_app/screens/" lib/
grep -r "package:hrm_app/widgets/" lib/

# Jika sudah bersih (tidak ada hasil), hapus folder lama
rm -rf lib/models lib/screens lib/widgets
```

`lib/theme/` **tidak dihapus** — pindahkan isinya ke `lib/core/theme/` karena
theme memang shared di seluruh aplikasi, bukan spesifik satu fitur.

## Langkah 8 — Update main.dart

Pastikan `main.dart` tidak lagi mereferensikan folder lama, dan aplikasi
dibungkus `ProviderScope` (Riverpod) di level paling luar:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // ...init Firebase, Hive, dsb (lihat STEP_BY_STEP.md §19)
  runApp(const ProviderScope(child: MyApp()));
}
```

## Langkah 9 — Verifikasi arah dependency

Jalankan analisis manual atau pakai lint custom untuk memastikan:
- Tidak ada file di `domain/` yang meng-import `package:flutter/...`, `package:dio/...`,
  atau `package:hive/...` secara langsung (kecuali `flutter_riverpod` untuk provider
  wiring — ini pengecualian yang bisa diterima karena provider adalah bagian dari
  dependency injection, bukan business logic itu sendiri).
- Tidak ada file di `presentation/` yang meng-import langsung dari `data/repositories/`
  atau `data/datasources/` — harus selalu lewat `domain/usecases/`.

```bash
# Cek pelanggaran arah dependency (contoh sederhana)
grep -rl "import 'package:dio" lib/features/*/domain/
grep -rl "import 'package:hive" lib/features/*/domain/
```
Jika command di atas menghasilkan output (ada file yang match), berarti ada
pelanggaran yang harus diperbaiki.

## Checklist Migrasi

- [ ] Semua isi `lib/models/` sudah dipecah jadi entity + model per fitur
- [ ] Semua isi `lib/screens/` sudah pindah ke `presentation/screens/` masing-masing fitur
- [ ] Semua isi `lib/widgets/` sudah terklasifikasi core vs per-fitur
- [ ] `lib/theme/` sudah pindah ke `lib/core/theme/`
- [ ] Setiap fitur punya minimal: entity, repository interface, repository impl, 1+ usecase, 1+ provider, 1+ screen
- [ ] Folder `lib/models`, `lib/screens`, `lib/widgets` di root sudah terhapus
- [ ] Tidak ada import `dio`/`hive`/`flutter` langsung di folder `domain/` (kecuali riverpod)
- [ ] `flutter analyze` bersih setelah migrasi
- [ ] App tetap bisa jalan (`flutter run`) tanpa regresi fungsional
