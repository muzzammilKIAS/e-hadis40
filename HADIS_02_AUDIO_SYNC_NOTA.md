# Hadis 02 — Audio, Sorotan Teks dan Font Arab

## Audio
- Fail: `assets/audio/hadith_02.mp3`
- Tempoh: 128.836 saat
- Format aplikasi: MP3 sebenar
- Sample rate: 44100 Hz
- Saluran: mono
- Normalisasi: sasaran -18 LUFS, true peak -1.5 dB

## Sinkronisasi
Rakaman mempunyai 37 jeda yang jelas dan dibahagikan kepada 38 petikan.

Fungsi:
- petikan aktif diserlahkan
- perkataan semasa disorot
- paparan bergerak secara automatik
- petikan selesai ditandakan
- tekan petikan untuk melompat ke audio
- kelajuan 0.75×, 1.0× dan 1.25×
- ulangan automatik
- pilihan Ikut audio
- larasan ±0.25 saat

## Bahasa pada kawalan audio
- Mainkan
- Jeda
- Main semula
- Mainkan semula dari awal
- Kelajuan
- Ulangan automatik
- Ikut audio
- Sorotan teks
- Teks lebih awal
- Teks lebih lewat

## Font Lotus Linotype
Lotus Linotype ditetapkan sebagai font utama teks Arab.

Atas sebab lesen, fail font tidak dibundel. Jika font tidak dipasang,
aplikasi menggunakan Noto Naskh Arabic, Amiri, kemudian Arial.

Untuk paparan Lotus Linotype yang konsisten pada semua peranti,
masukkan sendiri fail font berlesen ke `assets/fonts/` dan daftar dalam `pubspec.yaml`.
