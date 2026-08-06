# Arsitektur Aplikasi — Feature First + Clean Architecture + Riverpod

## 1. Kenapa Kombinasi Ini?

| Prinsip | Masalah yang Diselesaikan |
|---|---|
| **Feature First** | Kode dikelompokkan per fitur bisnis (attendance, leave, approval), bukan per tipe file. Tim bisa kerja paralel tanpa saling tabrak, dan gampang cari kode terkait satu fitur. |
| **Clean Architecture** | Memisahkan *apa yang aplikasi lakukan* (business logic/domain) dari *bagaimana* (UI, database, API). Logic bisa dites tanpa Flutter widget, dan gampang ganti Dio→lainnya tanpa merombak use case. |
| **Riverpod** | Dependency injection + state management yang type-safe, testable, dan tidak butuh `BuildContext` untuk akses provider. |

## 2. Struktur Per-Fitur (3 Layer)

Setiap folder di `lib/features/<nama_fitur>/` **wajib** punya 3 layer ini:

```
features/attendance/
├── data/
│   ├── datasources/       # Sumber data mentah: API (remote) & Hive/SharedPrefs (local)
│   ├── models/            # DTO — punya fromJson/toJson, extends entity domain
│   └── repositories/      # Implementasi konkret dari domain/repositories (interface)
├── domain/
│   ├── entities/           # Objek bisnis murni, TIDAK tahu soal JSON/database
│   ├── repositories/       # Interface/kontrak (abstract class), didefinisikan domain, diimplementasi data/
│   └── usecases/           # Satu class = satu aksi bisnis (mis. ClockInUseCase)
└── presentation/
    ├── providers/           # Riverpod providers/notifiers — state UI
    ├── screens/             # Halaman penuh (Scaffold)
    └── widgets/             # Komponen UI kecil khusus fitur ini
```

### Aturan Arah Dependency (WAJIB DIPATUHI)

```
presentation  →  domain  ←  data
```

- `domain/` **tidak boleh** import apa pun dari `data/` atau `presentation/`, dan **tidak boleh** import package Flutter/Dio/Hive. Murni Dart.
- `data/` boleh import `domain/` (untuk implement interface repository).
- `presentation/` boleh import `domain/` (untuk panggil use case) tapi **tidak boleh** import `data/` langsung — semua akses data lewat use case di domain.

Kenapa ketat begini? Karena `domain/` adalah bagian yang paling jarang berubah dan paling penting untuk dites. Kalau backend ganti dari REST ke GraphQL, yang berubah cuma `data/`, tidak menyentuh `domain/` maupun `presentation/`.

## 3. Migrasi dari Struktur Kamu Sekarang

Berdasarkan screenshot, struktur `lib/` kamu saat ini:
```
lib/
├── core/
├── features/        ← sudah ada, tapi isinya mungkin belum clean architecture
├── models/          ← HARUS dipecah & dipindah ke masing-masing features/<fitur>/data/models
├── screens/         ← HARUS dipindah ke masing-masing features/<fitur>/presentation/screens
├── theme/           ← TETAP di core/theme (ini benar, shared di seluruh app)
├── widgets/         ← Widget yang dipakai LINTAS fitur tetap di core/widgets;
│                       yang khusus 1 fitur pindah ke features/<fitur>/presentation/widgets
└── main.dart
```

### Langkah migrasi:

1. **Inventarisasi dulu.** Buka `lib/models/`, `lib/screens/`, `lib/widgets/` — buat daftar,
   setiap file itu punya fitur bisnis apa (attendance? leave? approval? profile?).

2. **Pindahkan models → data/models per fitur**, lalu tulis ulang jadi 2 bagian:
   - `domain/entities/xxx_entity.dart` (versi bersih, tanpa `fromJson`)
   - `data/models/xxx_model.dart` (extends entity, tambah `fromJson`/`toJson`)

3. **Pindahkan screens → presentation/screens per fitur.**

4. **Pindahkan widgets:**
   - Dipakai >1 fitur (mis. `LoadingButton`, `AppCard`) → `core/widgets/`
   - Khusus 1 fitur → `features/<fitur>/presentation/widgets/`

5. **`core/` isi akhir yang benar:**
   ```
   core/
   ├── config/        # app_config.dart
   ├── network/       # dio_client.dart, network_info.dart
   ├── storage/       # hive_service.dart, secure_storage_service.dart
   ├── services/      # fcm_service.dart, sync_service.dart
   ├── theme/          # app_theme.dart (TIDAK per fitur, dipakai semua)
   ├── router/         # app_router.dart
   ├── widgets/        # widget generik lintas fitur (tombol, loading, error state)
   ├── utils/           # date_util.dart, validators.dart
   └── errors/          # failure.dart, exceptions.dart (dipakai semua layer domain)
   ```

6. **Hapus folder `models/`, `screens/`, `widgets/` di root `lib/`** setelah semua isinya
   dipindah — folder-folder ini seharusnya tidak ada lagi di level `lib/` langsung.

## 4. Error Handling Lintas Layer

Gunakan tipe `Either<Failure, T>` (atau pola serupa) supaya domain layer tidak melempar
exception mentah ke presentation:

```dart
// core/errors/failure.dart
abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}
```

Repository (`domain/repositories/xxx_repository.dart`) mengembalikan `Either<Failure, Entity>`,
bukan melempar exception — sehingga UI selalu tahu cara menangani error tanpa try-catch bertingkat.

## 5. Riverpod: Provider per Layer

| Provider | Lokasi | Isi |
|---|---|---|
| `xxxRemoteDataSourceProvider` | `data/datasources/` | Instance data source, inject `Dio` |
| `xxxRepositoryProvider` | `data/repositories/` | Implementasi repository, inject datasource |
| `xxxUseCaseProvider` | `domain/usecases/` (atau taruh dekat repository provider) | Inject repository |
| `xxxNotifierProvider` (StateNotifier/AsyncNotifier) | `presentation/providers/` | Inject use case, expose state ke UI |

Prinsip: **UI hanya bicara dengan provider di `presentation/providers/`**, tidak pernah
langsung panggil repository atau datasource.

## 6. Testing yang Jadi Mungkin dengan Arsitektur Ini

```
domain/usecases/clock_in_usecase_test.dart     → unit test murni, mock repository
data/repositories/xxx_repository_test.dart      → mock datasource, test mapping data
presentation/providers/xxx_notifier_test.dart   → mock usecase, test state transition
```

Tidak butuh widget test atau Flutter binding untuk test business logic — inilah manfaat
utama Clean Architecture.
