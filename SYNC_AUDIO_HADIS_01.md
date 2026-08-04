# Sinkronisasi Audio Hadis 1

Rakaman yang dimasukkan:
- `assets/audio/hadith_01.mp3`
- Tempoh: 35.348 saat
- Audio asal yang dimuat naik sebenarnya menggunakan bekas WAV/PCM walaupun namanya `.mp3`.
- Fail telah ditukar kepada MP3 sebenar supaya lebih stabil pada Flutter Web/PWA.

## Fungsi

- Petikan aktif bergerak automatik mengikut audio.
- Perkataan semasa diserlahkan.
- Petikan yang telah dibaca ditandakan.
- Pengguna boleh menekan petikan untuk lompat ke bahagian audio tersebut.
- Kelajuan 0.75×, 1.0× dan 1.25×.
- Ulang audio.
- Larasan `Teks lebih awal` atau `Teks lebih lewat` sebanyak 0.25 saat.
- Butang `Ikut audio` boleh dimatikan jika pengguna mahu scroll sendiri.

## Kaedah timing

Timing awal dibina mengikut sempadan suara dan jeda yang dikesan dalam rakaman,
kemudian dipadankan kepada 10 frasa hadis. Highlight perkataan dalam setiap frasa
bergerak secara berkadar berdasarkan tempoh frasa.

Larasan ±0.25 saat disediakan dalam aplikasi kerana ketepatan visual boleh berubah
sedikit mengikut browser dan peranti.
