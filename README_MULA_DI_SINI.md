# e-Hadis40 — Projek Flutter Web/PWA Lengkap

**Nama aplikasi:** e-Hadis40  
**Pengenalan rasmi:** Platform Pengajaran dan Pembelajaran Interaktif Modul Penghayatan Hadis 40 Imam al-Nawawi Kementerian Pendidikan Malaysia

## Fungsi yang sudah tersedia

- UI Elegant Islamic Learning Experience
- Light Mode, Dark Mode dan System Mode
- Dashboard responsive
- 8 modul pembelajaran (Hadis 1–40)
- Kandungan penuh Hadis 1: Keutamaan Niat
- Teks Arab RTL dan kawalan saiz tulisan
- Audio player lengkap dengan play, pause, replay, seek, repeat dan speed
- Hover/tap pengenalan perawi
- Huraian, dalil, pengajaran, penghayatan, nilai dan aktiviti
- Soalan refleksi dan nota peribadi
- Kuiz interaktif dengan semakan jawapan
- Bookmark
- Simpan progres, markah, tema dan nota dalam browser
- Mod Guru
- Mod Projektor
- Carian hadis
- PWA manifest dan ikon
- Responsive untuk telefon, tablet dan desktop

## Penting tentang audio

Audio player sudah siap. Fail bacaan sebenar belum disertakan kerana rakaman agama perlu disemak terlebih dahulu.

Letakkan fail MP3 di:

```text
assets/audio/hadith_01.mp3
```

Selepas fail dimasukkan, jalankan semula aplikasi. Audio player akan terus berfungsi.

## Cara buka dalam VS Code — paling mudah

1. Extract fail ZIP.
2. Buka VS Code.
3. Klik **File > Open Folder**.
4. Pilih folder `e_hadis40_flutter_full`.
5. Pastikan extension **Flutter** dan **Dart** telah dipasang dalam VS Code.
6. Buka menu **Terminal > New Terminal**.
7. Jalankan:

```bash
flutter pub get
flutter run -d chrome
```

Aplikasi akan dibuka dalam Google Chrome.

## Cara satu klik pada Mac

Selepas Flutter siap dipasang, double-click:

```text
START_E_HADIS40.command
```

Jika macOS menyekat fail tersebut:

1. Klik kanan fail.
2. Pilih **Open**.
3. Klik **Open** sekali lagi.

## Cara bina fail production

Dalam terminal:

```bash
flutter build web
```

Atau double-click:

```text
BUILD_WEB.command
```

Fail production akan berada di:

```text
build/web
```

## Pemeriksaan developer

```bash
flutter pub get
dart format .
flutter analyze
flutter test
flutter build web
```

## Struktur penting

```text
lib/
├── core/          # tema, constant, responsive
├── data/          # model dan repository
├── screens/       # semua paparan
├── services/      # simpanan progres dan audio
└── widgets/       # komponen UI reusable

assets/
├── data/          # JSON kandungan hadis
├── images/        # logo
└── audio/         # fail MP3 hadis
```

## Kandungan agama

Kandungan Hadis 1 dibina daripada modul yang diberikan. Sebelum penerbitan umum, teks Arab, tanda baris, terjemahan, rujukan dan audio hendaklah melalui semakan pihak yang berkelayakan.

Biografi perawi tidak direka oleh AI. Aplikasi memaparkan mesej semakan sehingga kandungan sah dimasukkan ke dataset.


## Fitur baharu: teks bergerak mengikut audio

Hadis 1 kini mempunyai paparan bacaan gaya karaoke:

1. Buka `Hadis 01 — Keutamaan Niat`.
2. Tekan `Mainkan`.
3. Petikan aktif akan bergerak ke tengah secara automatik.
4. Perkataan semasa akan di-highlight.
5. Tekan mana-mana petikan untuk lompat ke bahagian tersebut.
6. Jika highlight nampak sedikit awal atau lewat, buka `Laraskan ketepatan highlight`.
7. Gunakan `Teks lebih awal` atau `Teks lebih lewat`.

Rakaman Umi sudah dimasukkan ke:

```text
assets/audio/hadith_01.mp3
```

Rujuk `SYNC_AUDIO_HADIS_01.md` untuk butiran timing.


## Hadis 2 sudah tersedia

Modul 1 kini mempunyai:

- Hadis 01 — Keutamaan Niat
- Hadis 02 — Islam, Iman dan Ihsan

Hadis 2 boleh dibuka melalui `Modul > Modul 1` atau melalui carian.

Audio Hadis 2 belum tersedia. Apabila rakaman suara telah disediakan,
ia akan dimasukkan sebagai `assets/audio/hadith_02.mp3` dan diselaraskan
dengan teks seperti Hadis 1.


## Hadis 2 — audio dan teks bergerak
1. Buka `Modul 1`.
2. Pilih `Hadis 02 — Islam, Iman dan Ihsan`.
3. Tekan `Mainkan`.
4. Petikan dan perkataan semasa akan diserlahkan.
5. Paparan bergerak secara automatik.
6. Tekan petikan untuk melompat ke bahagian tersebut.
7. Gunakan `Teks lebih awal` atau `Teks lebih lewat` jika perlu.

Teks Arab menggunakan Lotus Linotype sebagai font utama. Fail font tidak
dibundel kerana tertakluk kepada lesen; fallback disediakan secara automatik.
