# AI Agent Documentation

Dokumentasi ini berisi panduan dan struktur konteks untuk AI agent yang bekerja pada proyek Flutter HRM mobile app.

## Tujuan

- Menyediakan konteks bisnis dan fungsional aplikasi mobile HRMS berdasarkan BRD
- Menjadi referensi singkat untuk modul Self Service, Approval, Attendance, dan Dokumen
- Memudahkan AI agent memahami ruang lingkup fitur, terminologi, dan alur data yang relevan

## Ruang Lingkup yang Dicakup

Dokumen ini fokus pada pengalaman pengguna untuk dua peran utama:

- Employee: self service personal, absensi, pengajuan, dokumen, profil
- Atasan/Manager: approval bawahan, ringkasan tim, kalender tim, dan visibilitas status tim

## Struktur Direktori

- `docs/ai-agent/`
  - `README.md` - ringkasan tujuan dan penggunaan dokumentasi AI agent
  - `business-requirements.md` - kebutuhan bisnis, tujuan, KPI, dan batasan
  - `feature-mapping.md` - peta modul dan fitur utama per area pengguna
  - `api-contracts.md` - ringkasan endpoint dan payload yang relevan untuk fitur mobile
  - `glossary.md` - definisi istilah kunci dari BRD

## Cara Pakai

1. Baca `business-requirements.md` untuk memahami tujuan bisnis, target pengguna, dan KPI.
2. Gunakan `feature-mapping.md` untuk mengenali modul, fitur, dan hubungan antar fitur.
3. Gunakan `api-contracts.md` dan `glossary.md` sebagai referensi saat mengidentifikasi alur data, payload, dan istilah domain.
4. Perbarui dokumen ini jika ada perubahan scope, modul, atau aturan bisnis dari BRD.
