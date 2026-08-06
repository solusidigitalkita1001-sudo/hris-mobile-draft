# Dokumentasi Step-by-Step Development
## HRMS Mobile App — Self Service, Approval & Absensi
### Arsitektur: Feature First + Clean Architecture + Riverpod
### Berdasarkan BRD Mobile Application HRMS v1.0.0 (3 Juli 2026)

> **Scope aplikasi ini:** Employee Self Service, Approval Center (Atasan/Manager), dan Absensi
> (Attendance). Modul administratif/back-office (Payroll Run, Organization Setup, dll.) **tidak
> termasuk** di sini dan tetap dilayani via web. Lihat BRD §1.3 untuk detail ruang lingkup.
>
> Dokumen ini melengkapi `ARCHITECTURE.md` (penjelasan prinsip arsitektur) dan
> `MIGRATION_GUIDE.md` (langkah migrasi dari struktur lama). Gunakan ketiganya bersamaan.

---

## Daftar Isi

1. [Prasyarat](#1-prasyarat)
2. [Membuat Project Flutter](#2-membuat-project-flutter)
3. [Struktur Folder: Feature First + Clean Architecture](#3-struktur-folder-feature-first--clean-architecture)
4. [Install Dependency (pubspec.yaml)](#4-install-dependency-pubspecyaml)
5. [Setup Environment Variable (.env)](#5-setup-environment-variable-env)
6. [Setup Firebase & FCM](#6-setup-firebase--fcm)
7. [Konfigurasi Android (Kotlin DSL)](#7-konfigurasi-android-kotlin-dsl)
8. [Konfigurasi iOS](#8-konfigurasi-ios)
9. [Membangun Core Layer (Shared)](#9-membangun-core-layer-shared)
10. [Pola Baku Membangun Satu Fitur (3 Layer)](#10-pola-baku-membangun-satu-fitur-3-layer)
11. [Modul: Authentication & Dashboard](#11-modul-authentication--dashboard)
12. [Modul: Attendance (Absensi)](#12-modul-attendance-absensi)
13. [Modul: Leave Management (Cuti)](#13-modul-leave-management-cuti)
14. [Modul: Self Service Request](#14-modul-self-service-request)
15. [Modul: Approval Center (Atasan)](#15-modul-approval-center-atasan)
16. [Modul: Notifikasi & Deep-link](#16-modul-notifikasi--deep-link)
17. [Modul: Kalender Kerja & Kalender Tim](#17-modul-kalender-kerja--kalender-tim)
18. [Modul: Slip Gaji & Dokumen Pribadi](#18-modul-slip-gaji--dokumen-pribadi)
19. [Modul: Profil & Pengaturan Akun](#19-modul-profil--pengaturan-akun)
20. [Wiring main.dart & App Router](#20-wiring-maindart--app-router)
21. [Testing Per Layer](#21-testing-per-layer)
22. [Testing Skenario Offline & Geofencing](#22-testing-skenario-offline--geofencing)
23. [Keamanan & Secure Storage](#23-keamanan--secure-storage)
24. [Build Release](#24-build-release)
25. [Checklist Per-Modul (MoSCoW)](#25-checklist-per-modul-moscow)

---

## 1. Prasyarat

| Tools | Minimal Versi | Cek dengan |
|---|---|---|
| Flutter SDK | 3.19+ (Dart 3.3+) | `flutter --version` |
| Android Studio | terbaru + Android SDK | `flutter doctor` |
| Xcode (Mac, untuk iOS) | 15+ | `xcodebuild -version` |
| CocoaPods | terbaru | `pod --version` |
| Akun Firebase | — | https://console.firebase.google.com |

```bash
flutter doctor -v
```

> **Platform target (BRD §7.4):** Android minimal **versi 9 / Pie (API 28)**, iOS minimal **14.0**.

---

## 2. Membuat Project Flutter

```bash
flutter create --org com.namaorganisasi --platforms android,ios hris_mobile_app
cd hris_mobile_app
flutter run   # verifikasi template default jalan
```

---

## 3. Struktur Folder: Feature First + Clean Architecture

Ini bagian paling penting yang berubah dari revisi sebelumnya. **Jangan taruh `models/`,
`screens/`, atau `widgets/` langsung di level `lib/`** — semua harus masuk ke dalam
folder fitur masing-masing, dengan 3 layer di dalamnya.

### 3.1 Aturan Arah Dependency (wajib dipatuhi seluruh tim)

```
presentation  →  domain  ←  data
```

- `domain/` = business logic murni. **Tidak boleh** import `dio`, `hive`, atau
  `package:flutter/material.dart`. Hanya boleh import Dart murni + `flutter_riverpod`
  (untuk provider wiring, ini pengecualian yang diterima).
- `data/` boleh import `domain/` untuk implement interface repository-nya.
- `presentation/` boleh import `domain/` (panggil use case), **tidak boleh** import
  `data/` secara langsung.

### 3.2 Struktur per fitur (3 layer wajib)

```
features/<nama_fitur>/
├── domain/
│   ├── entities/        # Objek bisnis murni, TIDAK tahu JSON/database
│   ├── repositories/     # Interface/kontrak (abstract class)
│   └── usecases/         # Satu class = satu aksi bisnis
├── data/
│   ├── datasources/       # Sumber data mentah: remote (Dio) & local (Hive)
│   ├── models/            # DTO — extends entity, punya fromJson/toJson
│   └── repositories/       # Implementasi konkret dari domain/repositories
└── presentation/
    ├── providers/          # Riverpod Notifier — state UI
    ├── screens/            # Halaman penuh (Scaffold)
    └── widgets/            # Komponen UI khusus fitur ini
```

### 3.3 Generate skeleton folder untuk semua fitur BRD

```bash
mkdir -p lib/core/{config,network,storage,services,theme,utils,router,errors,widgets}

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

> Command `mkdir -p a/{b,c}` butuh brace expansion (bash). Jika shell kamu tidak
> mendukungnya, jalankan tiap path satu-satu untuk menghindari folder salah nama
> seperti `lib/core/{config,network,...}` literal.

Struktur akhir `lib/`:
```
lib/
├── main.dart
├── app.dart
├── firebase_options.dart
├── core/                          # SHARED — dipakai semua fitur
│   ├── config/          # app_config.dart
│   ├── network/          # dio_client.dart, network_info.dart
│   ├── storage/           # hive_service.dart, secure_storage_service.dart
│   ├── services/           # fcm_service.dart, sync_service.dart
│   ├── theme/               # app_theme.dart
│   ├── router/               # app_router.dart (GoRouter)
│   ├── errors/                # failure.dart
│   ├── utils/                  # either.dart, date_util.dart, validators.dart
│   └── widgets/                 # widget generik lintas fitur (button, loading, empty state)
└── features/
    ├── auth/            # FR-AUTH
    ├── dashboard/       # FR-DASH
    ├── attendance/      # FR-ATT
    ├── leave/           # FR-LV
    ├── self_service/    # FR-SS
    ├── approval/        # FR-APR
    ├── notification/    # FR-NOT
    ├── calendar/        # FR-CAL
    ├── payslip/         # FR-DOC-01
    ├── document/        # FR-DOC-02
    └── profile/         # FR-PRF
```

> **Sudah pernah pakai struktur lama (models/screens/widgets di root)?**
> Ikuti `MIGRATION_GUIDE.md` untuk memindahkan semuanya ke pola ini tanpa merusak fungsionalitas yang sudah jalan.

---

## 4. Install Dependency (pubspec.yaml)

```yaml
name: hris_mobile_app
description: HRMS Mobile App — Self Service, Approval & Absensi
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.3.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter

  # --- State Management ---
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

  # --- HTTP Client ---
  dio: ^5.4.3+1
  pretty_dio_logger: ^1.3.1

  # --- Local Storage (offline queue) ---
  hive: ^2.2.3
  hive_flutter: ^1.1.0

  # --- Secure Storage (JWT — Keychain/Keystore) ---
  flutter_secure_storage: ^9.2.2
  shared_preferences: ^2.2.3

  # --- Firebase & FCM ---
  firebase_core: ^2.32.0
  firebase_messaging: ^14.9.4
  flutter_local_notifications: ^17.1.2

  # --- Offline Support & Connectivity ---
  connectivity_plus: ^6.0.3

  # --- GPS / Geofencing ---
  geolocator: ^12.0.0

  # --- Kamera & Foto ---
  image_picker: ^1.1.1
  camera: ^0.11.0+2

  # --- Biometric ---
  local_auth: ^2.3.0

  # --- Routing & Deep-link ---
  go_router: ^14.2.7

  # --- File & Permission ---
  open_filex: ^4.4.1
  path_provider: ^2.1.3
  permission_handler: ^11.3.1

  # --- Utilitas ---
  uuid: ^4.4.0
  flutter_dotenv: ^5.1.0
  intl: ^0.19.0
  cached_network_image: ^3.3.1
  shimmer: ^3.0.0

  cupertino_icons: ^1.0.6

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
  build_runner: ^2.4.10
  riverpod_generator: ^2.4.0
  hive_generator: ^2.0.1

flutter:
  uses-material-design: true
  assets:
    - .env
```

```bash
flutter pub get
```

> Catatan: package `Either`/`Failure` untuk error handling di contoh ini ditulis manual
> di `core/utils/either.dart` (ringan, tanpa dependency tambahan). Jika tim lebih suka
> versi lengkap, boleh ganti dengan package `fpdart` atau `dartz`.

---

## 5. Setup Environment Variable (.env)

```env
BASE_URL=https://api.example.com/v1
CONNECT_TIMEOUT_MS=15000
RECEIVE_TIMEOUT_MS=15000
ENABLE_LOGGING=true
GEOFENCE_DEFAULT_RADIUS_METERS=100
```

Tambahkan ke `.gitignore`:
```
.env
android/app/google-services.json
ios/Runner/GoogleService-Info.plist
```

---

## 6. Setup Firebase & FCM

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```
Pilih platform `android` dan `ios`. Otomatis generate `lib/firebase_options.dart`,
`android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist`.

Aktifkan Cloud Messaging di Firebase Console → **Engage → Messaging**. Untuk iOS,
upload **APNs Authentication Key** di **Project Settings → Cloud Messaging**.

---

## 7. Konfigurasi Android (Kotlin DSL)

> **Wajib** pakai Kotlin DSL (`*.gradle.kts`) — default Flutter 3.19+. Jangan campur
> dengan sintaks Groovy (`*.gradle`).

### 7.1 `android/settings.gradle.kts`
```kotlin
pluginManagement {
    val flutterSdkPath = run {
        val properties = java.util.Properties()
        file("local.properties").inputStream().use { properties.load(it) }
        val flutterSdkPath = properties.getProperty("flutter.sdk")
        require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
        flutterSdkPath
    }
    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.1.0" apply false
    id("org.jetbrains.kotlin.android") version "1.9.10" apply false
    id("com.google.gms.google-services") version "4.4.1" apply false
}

include(":app")
```

### 7.2 `android/app/build.gradle.kts`
```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.namaorganisasi.hris_mobile_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }
    kotlinOptions { jvmTarget = "1.8" }

    defaultConfig {
        applicationId = "com.namaorganisasi.hris_mobile_app"
        minSdk = 28   // BRD §7.4: minimal Android 9 / Pie
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug") // TODO: ganti production
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter { source = "../.." }

dependencies {
    implementation("androidx.multidex:multidex:2.0.1")
    implementation(platform("com.google.firebase:firebase-bom:32.8.1"))
}
```

### 7.3 `android/build.gradle.kts` (project level)
```kotlin
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
```

### 7.4 `android/app/src/main/AndroidManifest.xml`
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
    <uses-permission android:name="android.permission.USE_BIOMETRIC" />

    <application
        android:label="HRMS App"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            <intent-filter android:autoVerify="true">
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
            <meta-data android:name="io.flutter.embedding.android.NormalTheme" android:resource="@style/NormalTheme" />
        </activity>
        <meta-data android:name="com.google.firebase.messaging.default_notification_channel_id" android:value="hrms_default_channel" />
        <meta-data android:name="flutterEmbedding" android:value="2" />
    </application>
</manifest>
```

```bash
flutter build apk --debug
```

---

## 8. Konfigurasi iOS

### 8.1 `ios/Podfile`
```ruby
platform :ios, '14.0'   # BRD §7.4
ENV['COCOAPODS_DISABLE_STATS'] = 'true'

def flutter_root
  generated_xcode_build_settings_path = File.expand_path(File.join('..', 'Flutter', 'Generated.xcconfig'), __FILE__)
  unless File.exist?(generated_xcode_build_settings_path)
    raise "#{generated_xcode_build_settings_path} must exist."
  end
  File.foreach(generated_xcode_build_settings_path) do |line|
    matches = line.match(/FLUTTER_ROOT\=(.*)/)
    return matches[1].strip if matches
  end
  raise "FLUTTER_ROOT not found."
end

require File.expand_path(File.join('packages', 'flutter_tools', 'bin', 'podhelper'), flutter_root)
flutter_ios_podfile_setup

target 'Runner' do
  use_frameworks!
  use_modular_headers!
  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
  target 'RunnerTests' do
    inherit! :search_paths
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
    end
  end
end
```

### 8.2 `ios/Runner/Info.plist` — tambahkan key
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Aplikasi membutuhkan lokasi Anda untuk validasi absensi.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>Aplikasi membutuhkan lokasi untuk geofencing absensi saat berjalan di background.</string>
<key>NSCameraUsageDescription</key>
<string>Aplikasi membutuhkan kamera untuk foto bukti absensi.</string>
<key>NSFaceIDUsageDescription</key>
<string>Gunakan Face ID untuk masuk lebih cepat ke aplikasi.</string>
<key>FirebaseAppDelegateProxyEnabled</key>
<false/>
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

```bash
cd ios && pod install && cd ..
flutter build ios --debug --no-codesign
```

---

## 9. Membangun Core Layer (Shared)

Layer `core/` adalah fondasi yang dipakai **semua fitur** — bangun ini dulu sebelum
mulai fitur apa pun.

### 9.1 `core/errors/failure.dart`
```dart
abstract class Failure {
  const Failure(this.message);
  final String message;
}
class ServerFailure extends Failure { const ServerFailure(super.message); }
class CacheFailure extends Failure { const CacheFailure(super.message); }
class NetworkFailure extends Failure { const NetworkFailure(super.message); }
class LocationFailure extends Failure { const LocationFailure(super.message); }
```

### 9.2 `core/utils/either.dart`
```dart
sealed class Either<L, R> {
  const Either();
  T fold<T>(T Function(L left) onLeft, T Function(R right) onRight) {
    final self = this;
    if (self is Left<L, R>) return onLeft(self.value);
    if (self is Right<L, R>) return onRight(self.value);
    throw StateError('Unreachable');
  }
}
class Left<L, R> extends Either<L, R> { const Left(this.value); final L value; }
class Right<L, R> extends Either<L, R> { const Right(this.value); final R value; }
```
Semua repository di seluruh fitur mengembalikan `Either<Failure, T>` — bukan `throw`.

### 9.3 `core/network/dio_client.dart`
```dart
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: AppConfig.baseUrl,
    connectTimeout: Duration(milliseconds: AppConfig.connectTimeoutMs),
  ));
  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final token = await ref.read(secureStorageServiceProvider).getAccessToken();
      if (token != null) options.headers['Authorization'] = 'Bearer $token';
      handler.next(options);
    },
  ));
  return dio;
});
```

### 9.4 `core/network/network_info.dart`
```dart
abstract class NetworkInfo {
  Future<bool> get isConnected;
  Stream<bool> get onConnectivityChanged;
}
class NetworkInfoImpl implements NetworkInfo {
  NetworkInfoImpl(this._connectivity);
  final Connectivity _connectivity;
  @override
  Future<bool> get isConnected async {
    final result = await _connectivity.checkConnectivity();
    return result.any((r) => r != ConnectivityResult.none);
  }
  @override
  Stream<bool> get onConnectivityChanged => _connectivity.onConnectivityChanged
      .map((results) => results.any((r) => r != ConnectivityResult.none));
}
final networkInfoProvider = Provider<NetworkInfo>((ref) => NetworkInfoImpl(Connectivity()));
```

### 9.5 `core/storage/secure_storage_service.dart`
```dart
class SecureStorageService {
  SecureStorageService(this._storage);
  final FlutterSecureStorage _storage;
  Future<void> saveAccessToken(String t) => _storage.write(key: 'access_token', value: t);
  Future<String?> getAccessToken() => _storage.read(key: 'access_token');
  Future<void> saveRefreshToken(String t) => _storage.write(key: 'refresh_token', value: t);
  Future<String?> getRefreshToken() => _storage.read(key: 'refresh_token');
  Future<void> clearAll() => _storage.deleteAll();
}
final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  const storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
  return SecureStorageService(storage);
});
```

### 9.6 `core/storage/hive_service.dart`
```dart
class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();
    // Register semua adapter tiap fitur di sini, mis:
    Hive.registerAdapter(AttendancePendingModelAdapter()); // typeId: 1
    // Hive.registerAdapter(LeaveDraftModelAdapter());     // typeId: 2, dst.
    await Hive.openBox<AttendancePendingModel>(HiveBoxes.attendancePending);
  }
}
```

### 9.7 `core/services/fcm_service.dart` & `sync_service.dart`
Sama seperti revisi sebelumnya — lihat detail lengkap di §16 (Notifikasi).
`SyncService` memanggil use case sync tiap fitur yang butuh offline queue
(saat ini: Attendance), bukan repository langsung.

### 9.8 `core/router/app_router.dart`
```dart
final router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(path: '/login', builder: (ctx, _) => const LoginScreen()),
    GoRoute(path: '/dashboard', builder: (ctx, _) => const DashboardScreen()),
    GoRoute(path: '/attendance', builder: (ctx, _) => const AttendanceScreen()),
    GoRoute(path: '/leave', builder: (ctx, _) => const LeaveScreen()),
    GoRoute(path: '/self-service', builder: (ctx, _) => const SelfServiceScreen()),
    GoRoute(
      path: '/approval',
      builder: (ctx, _) => const ApprovalCenterScreen(),
      routes: [
        GoRoute(path: ':id', builder: (ctx, state) =>
            ApprovalDetailScreen(id: state.pathParameters['id']!)),
      ],
    ),
    GoRoute(path: '/notification', builder: (ctx, _) => const NotificationCenterScreen()),
    GoRoute(path: '/calendar', builder: (ctx, _) => const CalendarScreen()),
    GoRoute(path: '/payslip', builder: (ctx, _) => const PayslipScreen()),
    GoRoute(path: '/document', builder: (ctx, _) => const DocumentScreen()),
    GoRoute(path: '/profile', builder: (ctx, _) => const ProfileScreen()),
  ],
);
```

---

## 10. Pola Baku Membangun Satu Fitur (3 Layer)

**Ikuti urutan ini persis, untuk setiap fitur** (auth, attendance, leave, dst).
Referensi implementasi lengkap fitur Attendance ada di `hrm_app_clean_architecture.zip`
— tiru pola file-nya persis untuk fitur lain.

### Langkah 1 — Domain: Entity
`domain/entities/xxx_entity.dart` — objek bisnis murni, tanpa `fromJson`.
```dart
class LeaveEntity {
  const LeaveEntity({
    required this.id, required this.userId, required this.type,
    required this.startDate, required this.endDate, required this.status,
  });
  final String id;
  final String userId;
  final String type; // annual, sick, dst
  final DateTime startDate;
  final DateTime endDate;
  final String status; // draft, pending, approved, rejected, cancelled
}
```

### Langkah 2 — Domain: Repository Interface
`domain/repositories/xxx_repository.dart` — kontrak abstrak.
```dart
abstract class LeaveRepository {
  Future<Either<Failure, LeaveEntity>> submitLeave({required LeaveEntity leave});
  Future<Either<Failure, List<LeaveEntity>>> getLeaveHistory();
  Future<Either<Failure, void>> cancelLeave(String id);
}
```

### Langkah 3 — Domain: Use Cases
`domain/usecases/submit_leave_usecase.dart` — satu class per aksi bisnis,
validasi aturan bisnis di sini (bukan di UI ataupun repository).
```dart
class SubmitLeaveUseCase {
  SubmitLeaveUseCase(this._repository);
  final LeaveRepository _repository;

  Future<Either<Failure, LeaveEntity>> call(LeaveEntity leave) async {
    // Validasi bisnis: tanggal tidak boleh di masa lalu, dsb.
    if (leave.startDate.isAfter(leave.endDate)) {
      return const Left(ServerFailure('Tanggal mulai tidak boleh setelah tanggal selesai.'));
    }
    return _repository.submitLeave(leave: leave);
  }
}
```

### Langkah 4 — Data: Model (DTO)
`data/models/xxx_model.dart` — extends entity, tambah `fromJson`/`toJson`.
```dart
class LeaveModel extends LeaveEntity {
  const LeaveModel({required super.id, required super.userId, required super.type,
      required super.startDate, required super.endDate, required super.status});

  factory LeaveModel.fromJson(Map<String, dynamic> json) => LeaveModel(
    id: json['id'], userId: json['user_id'], type: json['type'],
    startDate: DateTime.parse(json['start_date']),
    endDate: DateTime.parse(json['end_date']), status: json['status'],
  );

  Map<String, dynamic> toJson() => {
    'user_id': userId, 'type': type,
    'start_date': startDate.toIso8601String(),
    'end_date': endDate.toIso8601String(),
  };
}
```

### Langkah 5 — Data: Datasource
`data/datasources/xxx_remote_datasource.dart` — HANYA HTTP call, tanpa logic bisnis.
```dart
abstract class LeaveRemoteDataSource {
  Future<LeaveModel> submitLeave(LeaveModel leave);
}
class LeaveRemoteDataSourceImpl implements LeaveRemoteDataSource {
  LeaveRemoteDataSourceImpl(this._dio);
  final Dio _dio;
  @override
  Future<LeaveModel> submitLeave(LeaveModel leave) async {
    final response = await _dio.post('/leave', data: leave.toJson(),
        options: Options(headers: {'Idempotency-Key': const Uuid().v4()}));
    return LeaveModel.fromJson(response.data);
  }
}
final leaveRemoteDataSourceProvider = Provider<LeaveRemoteDataSource>((ref) {
  return LeaveRemoteDataSourceImpl(ref.watch(dioProvider));
});
```

### Langkah 6 — Data: Repository Implementation
`data/repositories/xxx_repository_impl.dart` — implementasi konkret kontrak domain,
mengubah exception jadi `Failure`.
```dart
class LeaveRepositoryImpl implements LeaveRepository {
  LeaveRepositoryImpl(this._remote, this._networkInfo);
  final LeaveRemoteDataSource _remote;
  final NetworkInfo _networkInfo;

  @override
  Future<Either<Failure, LeaveEntity>> submitLeave({required LeaveEntity leave}) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure('Tidak ada koneksi internet.'));
    }
    try {
      final model = LeaveModel(id: '', userId: leave.userId, type: leave.type,
          startDate: leave.startDate, endDate: leave.endDate, status: 'pending');
      final result = await _remote.submitLeave(model);
      return Right(result);
    } on DioException catch (e) {
      return Left(ServerFailure(e.message ?? 'Gagal mengajukan cuti.'));
    }
  }
  // ...getLeaveHistory, cancelLeave dengan pola sama
}
```

### Langkah 7 — Provider Wiring
`domain/usecases/leave_providers.dart` — satu tempat menghubungkan semuanya.
```dart
final leaveRepositoryProvider = Provider<LeaveRepository>((ref) {
  return LeaveRepositoryImpl(
    ref.watch(leaveRemoteDataSourceProvider),
    ref.watch(networkInfoProvider),
  );
});
final submitLeaveUseCaseProvider = Provider((ref) =>
    SubmitLeaveUseCase(ref.watch(leaveRepositoryProvider)));
```

### Langkah 8 — Presentation: Notifier
`presentation/providers/leave_notifier.dart` — state UI, panggil use case saja.
```dart
class LeaveState {
  const LeaveState({this.history = const [], this.isLoading = false, this.errorMessage});
  final List<LeaveEntity> history;
  final bool isLoading;
  final String? errorMessage;
  LeaveState copyWith({List<LeaveEntity>? history, bool? isLoading, String? errorMessage}) =>
      LeaveState(history: history ?? this.history, isLoading: isLoading ?? this.isLoading,
          errorMessage: errorMessage);
}

class LeaveNotifier extends StateNotifier<LeaveState> {
  LeaveNotifier(this._submitUseCase) : super(const LeaveState());
  final SubmitLeaveUseCase _submitUseCase;

  Future<void> submit(LeaveEntity leave) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    final result = await _submitUseCase(leave);
    result.fold(
      (failure) => state = state.copyWith(isLoading: false, errorMessage: failure.message),
      (_) => state = state.copyWith(isLoading: false),
    );
  }
}

final leaveNotifierProvider = StateNotifierProvider<LeaveNotifier, LeaveState>((ref) {
  return LeaveNotifier(ref.watch(submitLeaveUseCaseProvider));
});
```

### Langkah 9 — Presentation: Screen & Widget
`presentation/screens/leave_screen.dart` — hanya `ref.watch`/`ref.read`, tidak pernah
panggil repository/datasource langsung.

**Checklist sebelum lanjut fitur berikutnya:**
- [ ] Entity tidak import `dio`/`hive`/`flutter`
- [ ] Repository interface ada di `domain/`, implementasi di `data/`
- [ ] Setiap aksi bisnis punya use case sendiri (bukan 1 repository dengan banyak method campur)
- [ ] Screen hanya bicara dengan notifier, tidak dengan repository/datasource
- [ ] Semua error dikonversi jadi `Failure`, tidak ada `throw` yang bocor ke UI

---

## 11. Modul: Authentication & Dashboard

**FR terkait:** FR-AUTH, FR-DASH-01 s.d. FR-DASH-12

Ikuti pola §10 untuk fitur `auth`:
- Entity: `UserEntity` (id, name, role, `isManager: bool`)
- Use case: `LoginUseCase`, `RefreshTokenUseCase`, `LogoutUseCase`, `BiometricLoginUseCase`
- Repository: simpan access & refresh token via `SecureStorageService` setelah login sukses

Dashboard (`features/dashboard/`) hanya **membaca** data dari fitur lain via use case
masing-masing (attendance status, leave balance, approval pending count) — tidak boleh
punya repository sendiri yang duplikat logic fitur lain. Gunakan provider gabungan:
```dart
final dashboardSummaryProvider = FutureProvider((ref) async {
  final attendanceToday = await ref.watch(getTodayAttendanceUseCaseProvider)();
  final leaveBalance = await ref.watch(getLeaveBalanceUseCaseProvider)();
  final pendingApprovals = ref.watch(isManager)
      ? await ref.watch(getPendingApprovalCountUseCaseProvider)()
      : null;
  return DashboardSummary(attendanceToday, leaveBalance, pendingApprovals);
});
```

**Widget Employee (Must):** status Clock In/Out, saldo cuti, status pengajuan terakhir.
**Widget Atasan tambahan (Must, hanya jika `user.isManager == true`):** badge pending
approval, ringkasan kehadiran tim.

---

## 12. Modul: Attendance (Absensi)

**FR terkait:** FR-ATT-01 s.d. FR-ATT-11 — **Sudah diimplementasikan lengkap** sebagai
contoh referensi di `hrm_app_clean_architecture.zip`. Struktur:

```
features/attendance/
├── domain/
│   ├── entities/attendance_entity.dart          # AttendanceType, AttendanceStatus, SyncStatus
│   ├── repositories/attendance_repository.dart   # kontrak recordAttendance, getLocalHistory, dst
│   └── usecases/
│       ├── clock_in_usecase.dart                  # validasi geofencing (FR-ATT-04)
│       ├── clock_out_usecase.dart
│       ├── get_attendance_history_usecase.dart
│       └── attendance_providers.dart               # wiring repository
├── data/
│   ├── models/
│   │   ├── attendance_pending_model.dart            # Hive model (offline queue)
│   │   └── attendance_response_model.dart            # parsing response API
│   ├── datasources/
│   │   ├── attendance_remote_datasource.dart          # POST /attendance + idempotency key
│   │   └── attendance_local_datasource.dart            # baca/tulis Hive box
│   └── repositories/attendance_repository_impl.dart      # pola local-first (FR-ATT-05)
└── presentation/
    ├── providers/attendance_notifier.dart
    ├── screens/attendance_screen.dart                     # Clock In/Out + geofencing check
    └── widgets/attendance_history_tile.dart
```

**Alur Clock In/Out (ringkas):**
1. UI (`AttendanceScreen`) ambil GPS via `Geolocator`, hitung `isWithinGeofence`
2. Panggil `ref.read(attendanceNotifierProvider.notifier).clockIn(...)`
3. Notifier panggil `ClockInUseCase` → validasi bisnis (wajib keterangan jika luar radius)
4. Use case panggil `AttendanceRepository.recordAttendance()`
5. `AttendanceRepositoryImpl`: simpan Hive dulu (selalu sukses) → jika online kirim ke API
6. Hasil (`Either<Failure, AttendanceEntity>`) mengalir balik ke notifier → state UI update

**Riwayat & Koreksi (FR-ATT-08 s.d. FR-ATT-11):** tambahkan use case
`GetAttendanceCalendarUseCase` dan integrasikan koreksi absensi sebagai use case baru
di fitur `self_service` (tipe request `attendance_correction`), bukan menduplikasi
logic di fitur attendance.

---

## 13. Modul: Leave Management (Cuti)

**FR terkait:** FR-LV-01 s.d. FR-LV-07

Ikuti pola §10 persis untuk fitur `leave`. Poin bisnis penting yang harus ada di
use case (bukan di UI):
- `GetLeaveBalanceUseCase` — ambil saldo per jenis cuti
- `SubmitLeaveUseCase` — validasi hari kerja dari Work Calendar (FR-LV-02),
  validasi saldo cukup (FR-LV-03)
- `CancelLeaveUseCase` — hanya boleh cancel status `pending`/`approved` yang belum berjalan (FR-LV-05)
- `GetTeamCalendarPreviewUseCase` — tampilkan overlay cuti tim sebelum submit (FR-LV-04, non-blocking)

---

## 14. Modul: Self Service Request

**FR terkait:** FR-SS-01 s.d. FR-SS-08

Semua tipe pengajuan (Izin, Lembur, Tukar Shift, Permohonan Dokumen, Koreksi Absensi)
sebaiknya berbagi **satu entity dasar** dengan `type` sebagai pembeda, supaya riwayat
gabungan (FR-SS-05) mudah diimplementasikan:

```dart
enum SelfServiceType { permit, overtime, shiftSwap, documentRequest, attendanceCorrection }

class SelfServiceRequestEntity {
  const SelfServiceRequestEntity({
    required this.id, required this.userId, required this.type,
    required this.status, required this.createdAt, this.attachmentUrl,
  });
  final String id;
  final String userId;
  final SelfServiceType type;
  final String status; // pending, approved, rejected
  final DateTime createdAt;
  final String? attachmentUrl;
}
```

Use case per tipe (`SubmitPermitUseCase`, `SubmitOvertimeUseCase`, dst.) tetap
terpisah agar validasi bisnis masing-masing jelas (mis. lampiran wajib untuk Izin
Sakit, maks ukuran file 5MB), tapi semua memanggil repository yang sama:
`SelfServiceRepository.submitRequest(SelfServiceRequestEntity request)`.

Sertakan `idempotency_key` di setiap datasource remote (BRD §7.2.1 poin 6),
sama seperti pola di `AttendanceRemoteDataSourceImpl`.

---

## 15. Modul: Approval Center (Atasan)

**FR terkait:** FR-APR-01 s.d. FR-APR-09

Ikuti pola §10 untuk fitur `approval`. Catatan penting:

```dart
abstract class ApprovalRepository {
  Future<Either<Failure, List<ApprovalItemEntity>>> getPendingApprovals();
  Future<Either<Failure, ApprovalItemEntity>> getApprovalDetail(String id);
  Future<Either<Failure, void>> approve(String id);
  Future<Either<Failure, void>> reject(String id, {required String reason});
  Future<Either<Failure, void>> delegate({
    required String delegateToUserId, required DateTimeRange range, required String reason,
  });
}
```

`RejectUseCase` wajib validasi `reason` tidak kosong sebelum panggil repository —
ini aturan bisnis, jadi tempatnya di use case, bukan di widget dialog UI.

> **Penting:** Mobile app hanya **konsumen** status dari Workflow Engine backend
> (BRD §9.1) — tidak ada logic approval berjenjang yang disimpan di client.

Push notification approval baru → deep-link `/approval/{id}` (lihat §16).

---

## 16. Modul: Notifikasi & Deep-link

**FR terkait:** FR-NOT-01 s.d. FR-NOT-04

`core/services/fcm_service.dart` (shared, bukan per-fitur karena FCM adalah
infrastruktur lintas fitur):
```dart
FirebaseMessaging.onMessageOpenedApp.listen((msg) {
  final route = msg.data['route'] as String?;
  if (route != null) router.go(route); // GoRouter dari core/router/app_router.dart
});
```

In-app Notification Center (FR-NOT-03) tetap dibuat sebagai fitur sendiri
(`features/notification/`) dengan 3 layer standar — datasource `GET /notifications`,
use case `MarkAsReadUseCase`, dst. — supaya konsisten dengan pola fitur lain.

---

## 17. Modul: Kalender Kerja & Kalender Tim

**FR terkait:** FR-CAL-01 s.d. FR-CAL-03

Fitur `calendar` punya 2 use case utama:
- `GetPersonalCalendarUseCase` (FR-CAL-01, Must)
- `GetTeamCalendarUseCase` (FR-CAL-02, Must, khusus Atasan) — tambahkan highlight
  konflik (FR-CAL-03, Should) sebagai bagian dari mapping entity→UI di presentation,
  bukan logic tambahan di use case (karena threshold konflik dikonfigurasi backend).

---

## 18. Modul: Slip Gaji & Dokumen Pribadi

**FR terkait:** FR-DOC-01 s.d. FR-DOC-03

Poin arsitektur penting: **re-autentikasi sebelum akses data sensitif** adalah bagian
dari use case, bukan sekadar UI gate:

```dart
class GetPayslipDetailUseCase {
  GetPayslipDetailUseCase(this._repository, this._biometricService);
  final PayslipRepository _repository;
  final BiometricService _biometricService;

  Future<Either<Failure, PayslipEntity>> call(String payslipId) async {
    final authenticated = await _biometricService.authenticate(
      reason: 'Verifikasi diperlukan untuk membuka slip gaji.',
    );
    if (!authenticated) {
      return const Left(ServerFailure('Autentikasi dibatalkan atau gagal.'));
    }
    return _repository.getPayslipDetail(payslipId);
  }
}
```

Setiap akses/unduhan otomatis tercatat di Audit Log backend (FR-DOC-03) — datasource
cukup memastikan endpoint yang dipanggil memang endpoint yang di-log backend, tidak
perlu logic tambahan di mobile.

---

## 19. Modul: Profil & Pengaturan Akun

**FR terkait:** FR-PRF-01 s.d. FR-PRF-05

- Data sensitif (gaji, rekening, NIK) **tidak ada use case edit-nya sama sekali**
  di fitur profile — hanya `GetProfileUseCase` (read-only). Perubahan data sensitif
  diarahkan ke `features/self_service/` sebagai tipe request baru menuju approval HR (FR-PRF-03).
- `UpdateContactUseCase` hanya untuk field non-sensitif (FR-PRF-02).
- `GetActiveDevicesUseCase` & `RevokeDeviceUseCase` untuk manajemen perangkat (FR-PRF-04).

---

## 20. Wiring main.dart & App Router

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await HiveService.init();
  await FcmService.instance.init();
  SyncService.instance.startListening();

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'HRMS App',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: router,
    );
  }
}
```

**Urutan wajib:** `.env` → Firebase → Hive → FCM → SyncService, baru `runApp`.
Ini karena tiap layer bergantung pada yang sebelumnya sudah siap saat provider
pertama kali dibaca oleh widget tree.

---

## 21. Testing Per Layer

Manfaat utama Clean Architecture: setiap layer bisa dites terpisah **tanpa** Flutter binding.

```
test/
└── features/
    └── attendance/
        ├── domain/
        │   └── usecases/clock_in_usecase_test.dart      # mock repository, test validasi bisnis
        ├── data/
        │   └── repositories/attendance_repository_impl_test.dart  # mock datasource
        └── presentation/
            └── providers/attendance_notifier_test.dart    # mock usecase, test state transition
```

Contoh unit test use case (murni Dart, tanpa `flutter_test` binding):
```dart
void main() {
  late ClockInUseCase useCase;
  late MockAttendanceRepository mockRepository;

  setUp(() {
    mockRepository = MockAttendanceRepository();
    useCase = ClockInUseCase(mockRepository);
  });

  test('return LocationFailure jika di luar geofence tanpa keterangan', () async {
    final result = await useCase(
      userId: 'u1', latitude: 0, longitude: 0,
      isWithinGeofence: false, outOfGeofenceNote: null,
    );
    expect(result.isLeft, true);
  });
}
```

```bash
flutter test
```

---

## 22. Testing Skenario Offline & Geofencing

### Skenario Offline — FR-ATT-05

| # | Skenario | Hasil yang Diharapkan |
|---|---|---|
| 1 | Airplane mode → Clock In | Tersimpan lokal via `AttendanceLocalDataSource`, badge `Pending` |
| 2 | Airplane mode → tutup & buka app | Riwayat tetap muncul (Hive persisted) |
| 3 | Matikan airplane mode | `SyncService` panggil `SyncPendingAttendanceUseCase`, badge → `Synced` |
| 4 | Backend down saat online | Status `Failed` di local datasource, bisa di-retry |
| 5 | Banyak pending sekaligus (5+) | Semua tersinkron tanpa duplikasi (idempotency key) |

```bash
adb shell svc wifi disable && adb shell svc data disable
adb shell svc wifi enable && adb shell svc data enable
```

### Skenario Geofencing — FR-ATT-01, FR-ATT-04

| # | Skenario | Hasil yang Diharapkan |
|---|---|---|
| 1 | Lokasi dalam radius | `ClockInUseCase` langsung sukses tanpa perlu note |
| 2 | Lokasi di luar radius, note kosong | `ClockInUseCase` return `Left(LocationFailure(...))` |
| 3 | Lokasi di luar radius, note diisi | Sukses, tersimpan dengan `status: needs_review` |

### Skenario Keamanan — BRD §7.2

| # | Skenario | Hasil yang Diharapkan |
|---|---|---|
| 1 | Akses slip gaji tanpa re-auth | `GetPayslipDetailUseCase` return `Left` sebelum panggil repository |
| 2 | Token expired | Interceptor Dio auto-refresh; gagal → redirect ke `/login` via router |
| 3 | Submit pengajuan 2x berturutan | Idempotency key di datasource mencegah duplikasi |
| 4 | Atasan approve bukan bawahannya | Server tolak 403; use case tampilkan `Failure` sesuai pesan server |

---

## 23. Keamanan & Secure Storage

| Lapisan | Implementasi di Layer Mana |
|---|---|
| 1. Validasi Input (Client) | `presentation/` — form validation |
| 2. Validasi Input (Server) | Backend, tapi `domain/usecases/` juga validasi ulang aturan bisnis sebelum kirim |
| 3. Autentikasi | `core/storage/secure_storage_service.dart` + interceptor `core/network/dio_client.dart` |
| 4. Otorisasi | Server (RBAC + row-level security); mobile hanya render sesuai `user.isManager` |
| 5. Aturan Bisnis | `domain/usecases/` — satu tempat semua validasi bisnis terpusat |
| 6. Idempotency | `data/datasources/` — setiap POST kritikal sertakan `Idempotency-Key` header |
| 7. Rate Limiting | Backend; `data/repositories/` konversi `429` jadi `Failure` dengan pesan ramah |

---

## 24. Build Release

### Android
```bash
flutter build apk --release
flutter build appbundle --release   # untuk Play Store
```
Ganti `signingConfig` ke keystore production sebelum release.

### iOS
```bash
flutter build ipa --release
```

---

## 25. Checklist Per-Modul (MoSCoW)

### Arsitektur (berlaku untuk semua fitur, cek dulu sebelum checklist fungsional)
- [ ] Setiap fitur BRD punya struktur `domain/data/presentation` lengkap
- [ ] Tidak ada file di `domain/` yang import `dio`/`hive`/`flutter` (kecuali riverpod)
- [ ] Tidak ada `presentation/` yang import `data/` secara langsung
- [ ] Semua repository return `Either<Failure, T>`, tidak ada `throw` yang bocor ke UI
- [ ] Folder lama `lib/models`, `lib/screens`, `lib/widgets` di root sudah dihapus (lihat `MIGRATION_GUIDE.md`)
- [ ] `flutter analyze` bersih

### Must Have — Rilis 1

**Authentication:** Login + token di Keystore/Keychain; auto-refresh; logout bersih.

**Dashboard:** Widget status Clock In/Out, saldo cuti, badge approval Atasan, ringkasan kehadiran tim.

**Attendance:** Clock In/Out + geofencing (FR-ATT-01, FR-ATT-04); offline-first (FR-ATT-05);
riwayat kalender (FR-ATT-08); koreksi via Self Service (FR-ATT-09); ringkasan tim (FR-ATT-10).

**Leave:** Saldo real-time (FR-LV-01); kalkulasi hari kerja (FR-LV-02); validasi submit (FR-LV-03); riwayat (FR-LV-06).

**Self Service:** Izin/Sakit + lampiran (FR-SS-01); Lembur (FR-SS-02); riwayat gabungan + filter (FR-SS-05); read-only setelah diproses (FR-SS-06).

**Approval Center:** Daftar pending lintas jenis (FR-APR-01); detail (FR-APR-02); approve/reject (FR-APR-03); push notif + deep-link (FR-APR-04).

**Notifikasi:** Semua event relevan (FR-NOT-01); deep-link (FR-NOT-02).

**Slip Gaji:** Tampil terfinalisasi (FR-DOC-01) + re-autentikasi wajib; audit log (FR-DOC-03).

**Profil:** Lihat data kepegawaian (FR-PRF-01); data sensitif tidak bisa diedit (FR-PRF-03).

**Keamanan:** JWT di Keystore/Keychain; TLS + certificate pinning; idempotency key; `flutter analyze` bersih; tidak crash di skenario UAT utama.

### Should Have — Rilis 1-2
Selfie Clock In/Out (FR-ATT-02) · Reminder Clock In (FR-ATT-07) · Bulan terkunci read-only
(FR-ATT-11) · Kalender tim sebelum ajukan cuti (FR-LV-04) · Batalkan pengajuan (FR-LV-05) ·
Tukar Shift (FR-SS-03) · Permohonan Dokumen (FR-SS-04) · Riwayat keputusan approval
(FR-APR-05) · Delegasi approval (FR-APR-06) · SLA reminder (FR-APR-08) · In-app notification
center (FR-NOT-03) · Kalender kerja pribadi (FR-CAL-01) · Kalender tim Atasan (FR-CAL-02) ·
Edit kontak non-sensitif (FR-PRF-02) · Manajemen perangkat (FR-PRF-04) · Dokumen pribadi
read-only (FR-DOC-02).

### Could Have — Rilis 2+
Geofencing Secondment (FR-ATT-06) · Saldo cuti Secondment (FR-LV-07) · Peringatan hari
libur (FR-SS-07) · Approver Secondment (FR-SS-08) · Badge konflik jadwal (FR-APR-07) ·
Multi-approver transparency (FR-APR-09) · Highlight konflik kalender (FR-CAL-03) ·
Preferensi kanal notifikasi (FR-NOT-04) · Label lintas Company (FR-DASH-12) ·
Multi-bahasa (FR-PRF-05).

### Won't Have (Fase Ini)
Modul back-office: Payroll Run, Recruitment, LMS, Asset Management, Group Executive
Dashboard, konfigurasi Organization Structure, Shift Management setup.

---

*— Akhir Dokumen STEP_BY_STEP v3.0 —*
*Arsitektur: Feature First + Clean Architecture + Riverpod*
*Sesuai BRD Mobile Application HRMS Self Service, Approval & Absensi v1.0.0 (3 Juli 2026)*
