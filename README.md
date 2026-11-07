# StudentApp

Aplikasi akademik mahasiswa sederhana yang dibuat dengan Flutter dan Material 3.
Proyek ini memenuhi tugas mata kuliah **Pemrograman Aplikasi Mobile**.

## Fitur

- Splash screen dengan animasi sederhana
- Login dengan akun yang ditanam langsung di kode
- Dashboard dengan ringkasan mata kuliah, nilai, dan IP sementara
- Form biodata mahasiswa yang dapat diisi dan diedit
- Daftar mata kuliah (ListView) dan form tambah mata kuliah
- Form input nilai dengan validasi 0-100
- Nilai huruf otomatis (A/B/C/D/E)
- Daftar nilai dengan fitur edit dan hapus
- Perhitungan IP sementara berdasarkan bobot nilai dan SKS
- Profil mahasiswa, edit biodata, dan logout
- Bottom navigation: Home, Mata Kuliah, Nilai, Profil
- Data tersimpan di perangkat menggunakan SharedPreferences
- Antarmuka dan date picker menggunakan Bahasa Indonesia

## Akun Demo

| Username | Password |
| -------- | -------- |
| `admin`  | `123456` |

Akun ini bersifat hardcoded di `lib/screens/login_screen.dart` (tanpa backend/API).

## Aturan Nilai

| Nilai Angka | Nilai Huruf | Bobot |
| ----------- | ----------- | ----- |
| 80 - 100    | A           | 4     |
| 70 - 79     | B           | 3     |
| 60 - 69     | C           | 2     |
| 50 - 59     | D           | 1     |
| 0 - 49      | E           | 0     |

IP sementara = total (bobot x SKS) / total SKS yang sudah dinilai.

## Struktur Project

```text
lib/
├── main.dart
├── models/
│   ├── course.dart
│   ├── grade.dart
│   └── student.dart
├── screens/
│   ├── biodata_screen.dart
│   ├── courses_screen.dart
│   ├── dashboard_screen.dart
│   ├── grades_screen.dart
│   ├── input_grade_screen.dart
│   ├── login_screen.dart
│   ├── main_shell.dart
│   ├── profile_screen.dart
│   └── splash_screen.dart
├── services/
│   └── app_state.dart
├── utils/
│   ├── app_theme.dart
│   ├── formatters.dart
│   └── validators.dart
└── widgets/
    ├── app_card.dart
    ├── custom_button.dart
    ├── grade_card.dart
    ├── section_header.dart
    └── stat_card.dart
```

Keterangan singkat:

- `models/` berisi struktur data mahasiswa, mata kuliah, dan nilai.
- `services/app_state.dart` menyimpan data aplikasi dan mengurus SharedPreferences.
- `screens/` berisi seluruh halaman aplikasi.
- `widgets/` berisi komponen yang dipakai berulang.
- `utils/` berisi tema, format tanggal/nilai, dan validasi.

## Cara Menjalankan

Pastikan Flutter sudah terpasang, lalu jalankan:

```bash
flutter pub get
flutter run
```

Untuk memeriksa kualitas kode dan menjalankan test:

```bash
flutter analyze
flutter test
```

## Catatan Data

- Biodata awal berisi data contoh agar dashboard langsung terlihat lengkap.
  Data ini dapat diganti melalui menu **Biodata**.
- Lima mata kuliah awal sudah disediakan sesuai ketentuan tugas.
- Daftar nilai dimulai dari kosong agar empty state dapat dilihat.
- Semua perubahan disimpan otomatis ke SharedPreferences dan tetap ada
  setelah aplikasi ditutup.
- Logout hanya menghapus status sesi, bukan data mahasiswa.
