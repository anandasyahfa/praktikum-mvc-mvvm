# Laporan Praktikum Mandiri: MVC, MVVM, dan Pengujian Flutter

| Informasi | Data Mahasiswa |
|---|---|
| **Nama Lengkap** | Ananda Syahfa Azzara |
| **NIM** | 362558302008 |
| **Kelas / Angkatan** | TRPL 2E / 2025 |
| **Dosen Pengampu** | Sepyan Purnama Kristanto, M.Kom. |


## Cara Menjalankan Aplikasi

**Yang dibutuhkan:**
- Flutter SDK sudah terpasang dan ada di `PATH`
- Google Chrome (untuk Web) atau emulator/perangkat yang aktif

**Langkah-langkah:**
1. Unduh dan ekstrak `Starter-Praktikum-MVC-MVVM-Flutter.zip`, lalu buka folder `prak_arsitektur_tugas` (yang ada `pubspec.yaml`-nya) di VS Code, dengan perintah cd prak_arsitektur_tugas.
2. Unduh dependensi:
   ```bash
   flutter pub get
   ```
3. Jalankan aplikasi di Chrome:
   ```bash
   flutter run -d chrome
   ```
4. Cek kode:
   ```bash
   flutter analyze
   ```
5. Jalankan pengujian:
   ```bash
   flutter test
   ```

## Keluaran Terminal

### 1. `flutter analyze` dan `flutter test` (setelah kode dipulihkan)

```text
PS C:\Users\Ananda Syafa Azzahra\Downloads\Starter-Praktikum-MVC-MVVM-Flutter\prak_arsitektur_tugas> flutter analyze
Analyzing prak_arsitektur_tugas...
No issues found! (ran in 2.3s)

PS C:\Users\Ananda Syafa Azzahra\Downloads\Starter-Praktikum-MVC-MVVM-Flutter\prak_arsitektur_tugas> flutter test
00:05 +7: All tests passed!
```

### 2. Kegagalan saat pemicu rebuild dihapus sementara

Aku hapus sementara `notifyListeners()` di `ubahStatus()` (`lib/mvvm/tugas_view_model.dart`) dan `setState()` di `_ubahFilter()` (`lib/mvc/layar_mvc.dart`). Hasilnya:

```text
00:02 +4 -1: test/layar_test.dart: MVVM memperbarui form dan ringkasan [E]
  Expected: exactly one matching candidate
    Actual: _TextWidgetFinder:<Found "1 0 1 [] dari selesai": text widgets with>
   Which: means none were found but one was expected

  package:matcher                                     expect
  package:flutter_test/src/widget_tester.dart:473:18  expect
  test\layar_test.dart:28:7                           main.<fn>.<fn>

00:03 +6 -1: Some tests failed.
```

> **Catatan:** Tanpa `notifyListeners()` (MVVM) atau `setState()` (MVC), data di memori (`TugasViewModel` / `PengendaliTugas`) tetap berubah, tapi UI tidak di-*rebuild*. Jadi ringkasan dan daftar di layar tidak ikut update. Setelah pemicunya dikembalikan, ketujuh tes lulus lagi.

## Perbandingan MVC vs MVVM

### 1. Saat filter diketuk, class mana yang menerima aksi dan menyimpan pilihan?

| MVC | MVVM |
| --- | --- |
| **View (`_LayarMvcState`)** menerima ketukan `FilterChip` lewat callback `_ubahFilter(bool aktif)`, lalu meneruskannya ke **Controller (`PengendaliTugas`)** lewat `ubahFilter(bool aktif)`. Pilihan disimpan di field `_hanyaBelumSelesai`. | **ViewModel (`TugasViewModel`)** menerima aksi langsung lewat callback `onSelected` di `PanelTugas` yang terhubung ke `ubahFilter(bool aktif)`. Pilihan disimpan di field `_hanyaBelumSelesai`. |

### 2. Apa pemicu rebuild, dan apa akibatnya kalau dihapus?

| | MVC | MVVM |
| --- | --- | --- |
| **Pemicu** | `setState(() => _pengendali.ubahFilter(aktif))` di `_LayarMvcState` (juga di `_tambah` dan `_ubahStatus`). | `notifyListeners()` di akhir `ubahFilter()`, `ubahStatus()`, dan `tambah()` pada `TugasViewModel`, yang didengarkan `ListenableBuilder` di `_LayarMvvmState`. |
| **Kalau dihapus** | Nilai `_hanyaBelumSelesai` tetap berubah di memori, tapi `build()` tidak dijadwalkan ulang. `FilterChip` tidak berubah dan tugas selesai tetap tampil (`flutter test test/filter_test.dart` gagal). | State di `TugasViewModel` berubah, tapi `ListenableBuilder` tidak diberi tahu. Ringkasan dan daftar tidak update (`layar_test.dart` dan `filter_test.dart` gagal). |
| **Setelah dikembalikan** | UI dan tes normal lagi. | Semua tes lulus lagi. |

### 3. Kapan memilih masing-masing pola?

| | MVC | MVVM |
| --- | --- | --- |
| **Cocok untuk** | Fitur satu layar yang simpel, aksinya sedikit, alur state-nya lurus. | Layar dengan beberapa state yang saling bergantung, misalnya ringkasan (`1 dari 2 selesai`), daftar tersaring (`daftarTampil`), dan pesan validasi (`galat`). |
| **Kelebihan** | Alur dari callback → Controller → `setState()` bisa dilacak di satu file (`lib/mvc/layar_mvc.dart`). | Semua state UI terpusat di `TugasViewModel`, jadi bisa diuji lengkap beserta notifikasinya lewat unit test (`test/logika_test.dart`) tanpa render widget. |
| **Risiko** | Tiap aksi baru (misal `FilterChip`) harus dibungkus `setState()` di View. Kalau lupa, tampilan tidak sinkron dengan data. | Harus mengurus *lifecycle* `ChangeNotifier` (wajib `_viewModel.dispose()` di `State.dispose()`) dan memastikan View terhubung ke `ListenableBuilder`. |

## Bukti Tangkapan Layar

| MVC (Filter Mati) | MVVM (Filter Mati) | MVVM (Filter Aktif) | MVVM (Semua Selesai) |
| :---: | :---: | :---: | :---: |
| ![MVC Filter Mati](bukti/mvc.png) | ![MVVM Filter Mati](bukti/mvvm.png) | ![MVVM Filter Aktif](bukti/mmvvm3.png) | ![MVVM Semua Selesai](bukti/mmvvm2.png) |
