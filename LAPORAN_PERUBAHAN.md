# Laporan Penuh Perubahan — e-Hadis40

**Projek:** `e_hadis40` (Flutter Web)
**Versi:** `1.17.0+17`
**Flutter:** 3.44.8 (stable)
**Tarikh laporan:** 15 Ogos 2026
**Tujuan dokumen:** Serahan kerja untuk disambung menggunakan DeepSeek.

---

## 0. Ringkasan Status Semasa

| Semakan | Keputusan |
|---|---|
| `flutter analyze` | ✅ **0 ralat, 0 amaran** — 2 mesej `info` sahaja (deprecation `dart:html`) |
| `flutter test` | ✅ **20/20 lulus** |
| `flutter build web --release` | ✅ Berjaya |
| `flutter build web --debug` | ✅ Berjaya, **tiada jalur limpahan (RenderFlex overflow)** |
| Bug diketahui belum selesai | ⚠️ 4 item — lihat **Bahagian 5** |

> **PENTING:** Semua kerja dalam laporan ini **belum di-commit**. Ia berada dalam
> *working tree* sahaja. Sila `git add` + `git commit` sebelum meneruskan kerja
> dengan alat lain, supaya ada titik pulih (*rollback point*).

---

## 1. Fail Yang Berubah

### 1.1 Fail baharu (belum dijejak Git / *untracked*)

```
lib/screens/anatomi_sunnah_screen.dart          # Skrin permainan 3D setiap hadis
lib/screens/anatomi_sunnah_list_screen.dart     # Senarai 42 kad hadis
lib/widgets/dashboard/anatomi_sunnah_hadith_card.dart
lib/widgets/dashboard/xplorasi_minda_title.dart # Tajuk "Xplorasi Minda" (kotak X emas)
assets/images/brain_chip.png
web/anatomi_sunnah/                             # 14 fail HTML + styles.css (600 KB)
```

### 1.2 Fail diubah suai

```
lib/core/theme/app_colors.dart              (  2 baris)
lib/core/theme/app_theme.dart               ( 66 baris)
lib/screens/home_screen.dart                (114 baris)
lib/screens/modules_screen.dart             (  9 baris)
lib/screens/projector_screen.dart           (110 baris)
lib/screens/uji_minda_screen.dart           ( 13 baris)
lib/widgets/dashboard/uji_minda_card.dart   (491 baris)
lib/widgets/hadith_playlist_panel.dart      ( 82 baris)
web/uji_minda/index.html                    ( 13 baris)
```

**Jumlah:** 711 penambahan, 189 pemadaman (belum termasuk fail baharu).

---

## 2. Modul Baharu: Anatomi Sunnah 3D

Modul simulasi 3D interaktif bagi Hadis 1–14 (daripada 42 hadis keseluruhan).

### 2.1 Seni bina

- Setiap hadis ada **fail HTML tersendiri** (`web/anatomi_sunnah/hadith_01.html`
  … `hadith_14.html`) — bukan satu templat dikongsi, kerana setiap simulasi
  mempunyai bentuk 3D, mekanik interaksi dan teks matan yang unik.
- Dibenamkan ke dalam Flutter melalui **iframe sama-origin**
  (`HtmlElementView` + `ui_web.platformViewRegistry`).
- Tema diselaraskan melalui kunci `localStorage` `ehadis40-theme` (dikongsi
  kerana iframe sama-origin).

### 2.2 Prestasi — Tailwind pra-kompil

**Masalah:** asalnya menggunakan `cdn.tailwindcss.com` (pengkompil JIT dalam
pelayar) — ini *anti-pattern* untuk produksi dan menyebabkan pembukaan terasa
berat.

**Penyelesaian:** dijana `styles.css` statik (271 KB) melalui Tailwind CLI
dengan konfigurasi `safelist` (regex) untuk menangkap kelas yang dibina secara
dinamik melalui *template literal* JavaScript.

> ⚠️ **Jika anda mengubah kelas Tailwind dalam mana-mana fail HTML anatomi,
> anda WAJIB menjana semula `styles.css`.** Kelas baharu yang tidak wujud
> dalam `styles.css` tidak akan berfungsi.

### 2.3 Butang kembali — melalui `postMessage`

**Masalah asas (penting difahami):** dalam Flutter Web, iframe (*platform view*)
**menelan semua peristiwa penunjuk** dalam kawasan skrin yang ditempatinya —
walaupun ada widget Flutter dilukis "di atas"nya secara visual dalam `Stack`.

Percubaan yang **gagal**:
1. Butang Flutter dalam `Stack` di atas iframe → klik tidak sampai.
2. `Scaffold.appBar` + `extendBodyBehindAppBar: true` → gagal juga (bertindih semula).
3. `Scaffold.appBar` biasa (tidak bertindih) → klik berfungsi, **tetapi**
   menghasilkan jalur hitam yang mengganggu paparan simulasi.

**Penyelesaian akhir:** butang kembali diletakkan **di dalam HTML simulasi itu
sendiri**, dan menghantar `window.parent.postMessage('anatomi-sunnah-back', '*')`.
Pihak Flutter mendengar melalui `html.window.onMessage`. Hasilnya: klik sentiasa
berfungsi **dan** tiada jalur/kotak tambahan langsung.

### 2.4 Responsif telefon & tablet

Ditampal seragam pada ke-14 fail (strukturnya identik):

**CSS — dua *breakpoint*:**
- **Tablet (≤1024px):** panel dikecilkan ~56%/44% lebar, padding & tajuk dikurangkan.
- **Telefon (≤640px):** panel jadi jalur penuh-lebar atas/bawah, teks & butang
  dipadatkan, `padding-top` ditambah supaya tidak tertutup butang kembali.
- Panel panjang dihadkan tingginya + boleh diskrol **di dalam kotaknya sendiri**
  (bar skrol halus ditambah sebagai petunjuk visual). Tiada kandungan hilang.

**JavaScript — pelarasan kamera 3D:**
```js
// Kekalkan medan pandang MENDATAR seperti skrin lebar; luaskan FOV menegak
// apabila skrin sempit supaya model tidak terpotong.
// Undur tambahan: 1.3x (telefon), 1.12x (tablet).
```
> Nota reka bentuk: hanya **FOV** dilaraskan, **bukan `camera.position`** —
> supaya animasi kamera khusus setiap simulasi tidak terjejas.

**Pengesahan:** 14 fail × 3 saiz (390×844 / 834×1112 / 1440×900) = 42 kombinasi.
Tiada ralat JS, canvas 3D berjaya dimuat, tiada panel terkeluar viewport,
jalur tengah lapang 220–365px pada telefon. Desktop **tidak berubah langsung**
(media query hanya aktif ≤1024px).

### 2.5 Arah teks (Rumi LTR / Arab RTL)

**Masalah:** panel kawalan bawah menggunakan kelas `text-right`, menyebabkan
teks **Rumi** di dalamnya dijajar ke kanan.

**Perubahan:**
1. `text-right` → `text-left` pada panel kawalan bawah (14 fail).
   `ml-auto` **dikekalkan** kerana itu kedudukan panel, bukan arah teks.
2. Jaring keselamatan CSS:
```css
.ui-layer { direction: ltr; text-align: left; }
.ui-layer .text-arabic { direction: rtl; text-align: right; unicode-bidi: isolate; }
```

**Pengesahan:** `direction` & `text-align` **terkira** (computed) diperiksa bagi
setiap elemen teks dalam 14 fail, **termasuk selepas menekan butang** (teks Arab
yang disuntik melalui JS). Semua Rumi = `ltr`, semua Arab = `rtl` + jajar kanan.
0 pelanggaran.

### 2.6 Pembetulan kandungan

- Teks Arab disemak silang dengan `assets/data/hadith_XX.json`.
- Pepijat *color-tween* GSAP dibetulkan.
- Saiz fon lencana/label dibesarkan (10px→12px, 11px→13px) untuk mod desktop.

---

## 3. Modul Xplorasi Minda

- Dinamakan semula: "Eksplorasi Hadis 40" → **"Xplorasi Minda Hadis (40)"**
  (huruf X dalam kotak emas; "40" kekal dalam lencana kaca sedia ada).
- Kad dashboard direka semula: gaya kaca *duotone* + corak Islamik, sepadan
  dengan kad lain.
- Ikon otak dijadikan butang boleh tekan; animasi *chevron* dibuang.
- Ilustrasi roket "melancar" (api + asap) sebelum permainan dibuka.
- Warna tajuk diselaraskan antara kad dashboard dan AppBar skrin permainan.

---

## 4. Pembetulan Pepijat (Bug Fixes)

### 4.1 🔴 Kad Xplorasi Minda tersembunyi di bawah bar navigasi

**Punca:** `main_shell.dart:48` menetapkan `extendBody: true`, jadi badan skrin
memanjang **ke belakang** bar navigasi bawah. `ModulesScreen` tidak menambah
tinggi bar itu pada padding bawah, jadi kad terakhir kekal tersembunyi separuh
walau sudah skrol habis.

**Pembetulan** — [`lib/screens/modules_screen.dart`](lib/screens/modules_screen.dart):
```dart
padding: layout.pagePadding.copyWith(
  bottom: layout.pagePadding.bottom + MediaQuery.paddingOf(context).bottom,
),
```

> **Nota untuk kerja masa depan:** corak pepijat yang sama boleh berlaku pada
> mana-mana tab lain yang menggunakan senarai boleh skrol. Tab lain sudah
> disemak dan bersih, tetapi ingat `extendBody: true` apabila menambah skrin baharu.

### 4.2 🔴 Jalur belang (hazard) pada skrin Audio

**Dua punca berasingan:**

**(a) Kandungan panel bersaiz tetap** — kepala + kad "sedang dimainkan" tidak
boleh mengecil, jadi pada skrin pendek `Column` melimpah walaupun senarai trek
dibungkus `Flexible`.
→ Seluruh panel dijadikan satu `SingleChildScrollView`; senarai trek kini
`NeverScrollableScrollPhysics`.

**(b) `_DecorativeBackground` — punca utama** — ia `Column` dengan ketinggian
tetap berjumlah **660px** (160 + ikon 200 + ikon 240 + 60). Pada badan skrin
~563px, ia melimpah **97px** — tepat sepadan dengan mesej *"BOTTOM OVERFLOWED
BY 97 PIXELS"*.
→ Ditukar kepada `Stack` + `Positioned` + `ClipRect`, jadi tanda air hiasan
hanya bertindih/dipotong, tidak mungkin melimpah.

**Pengesahan:** 5 tab × 4 ketinggian (844/780/700/640) dalam **debug build**,
kesan piksel kuning secara automatik → semua bersih.

> ⚠️ **Pengajaran penting:** *release build* **memotong limpahan secara senyap**
> tanpa melukis jalur belang. Ujian limpahan **mesti** dibuat dalam
> **debug build**. Ujian awal saya dalam release menunjukkan "bersih" secara
> mengelirukan.

### 4.3 🔴 Ikon roket terpotong pada telefon

**Punca:** selepas kotak kad dijadikan penuh lebar, nilai limpahan roket
(~38% lebar kad) menolak penunggang kedua melepasi **tepi skrin sebenar**,
lalu dipotong oleh viewport.

**Pembetulan** — [`lib/widgets/dashboard/uji_minda_card.dart`](lib/widgets/dashboard/uji_minda_card.dart):
```dart
final artRight = -(width < 700 ? 14.0 : artSize * 0.38);
```

### 4.4 🔴 Spinner tersekat apabila membuka hadis yang sama kali kedua

**Ini pepijat paling halus yang dijumpai.**

**Punca:** `_factoryRegistered` disimpan sebagai medan **per-instance**
(sedangkan dalam `uji_minda_screen.dart` ia `static`).
`registerViewFactory` hanya berjaya **sekali** bagi setiap `viewType` —
panggilan kedua mengembalikan `false` **secara senyap** dan mengekalkan kilang
LAMA. Akibatnya, kunjungan kedua menggunakan *closure* daripada `State` LAMA
yang sudah dilupuskan → `mounted == false` → `setState` tidak pernah dipanggil
→ `_loaded` skrin baharu tersekat `false` selama-lamanya.

**Bukti (probe `console.log` dalam debug build):**
```
--- SEBELUM PEMBETULAN ---
VISIT 1:  build → onLoad(mounted=true)  → build     ✅ (setState berjaya)
VISIT 2:  build → onLoad(mounted=false) → (tiada)   ❌ (setState tidak dipanggil)

--- SELEPAS PEMBETULAN ---
VISIT 1:  build loaded=false → onLoad mounted=true → build loaded=true  ✅
VISIT 2:  build loaded=false → onLoad mounted=true → build loaded=true  ✅
```

**Mengapa ia tidak kelihatan:** spinner itu *memang* dilukis, tetapi
**tersembunyi di belakang iframe** — kesan sampingan kelakuan komposit
*platform view* yang sama seperti isu butang kembali (2.3). Jadi ia pepijat
**terpendam** yang boleh terserlah bila-bila masa jika kelakuan komposit
Flutter berubah, atau jika iframe lambat/gagal dimuatkan.

**Pembetulan** — [`lib/screens/anatomi_sunnah_screen.dart`](lib/screens/anatomi_sunnah_screen.dart):
```dart
// Set statik jenis paparan yang sudah didaftarkan
static final Set<String> _registeredViewTypes = <String>{};

// Peta panggil balik: kilang merujuk peta ini (bukan menangkap `this`),
// supaya ia sentiasa memberitahu State SEMASA
static final Map<String, VoidCallback> _onLoadCallbacks = {};

late final VoidCallback _onLoadCallback = () {
  if (mounted) setState(() => _loaded = true);
};

// dispose: buang hanya jika masih milik State ini
if (identical(_onLoadCallbacks[_viewType], _onLoadCallback)) {
  _onLoadCallbacks.remove(_viewType);
}
```

---

## 5. ⚠️ Isu Yang MASIH BELUM Selesai

Senarai ini adalah titik mula yang dicadangkan untuk kerja seterusnya.

### 5.1 `acceptDisclaimer()` tidak pernah dipanggil — dialog muncul setiap kali buka

`lib/services/app_controller.dart:158` mentakrifkan `acceptDisclaimer()` yang
menyimpan `e_hadis40_disclaimer_accepted = true` ke `SharedPreferences`.
**Tiada satu pun tempat dalam kod memanggilnya.** Butang "SAYA FAHAM & TERUSKAN"
dalam `splash_screen.dart` hanya memanggil `widget.onComplete()`.

**Kesan:** pengguna terpaksa menekan penafian **setiap kali** membuka aplikasi.
**Cadangan:** panggil `acceptDisclaimer()` pada butang itu, dan langkau dialog
apabila `disclaimerAccepted == true`.

### 5.2 Hadis 4 tiada teks Arab

`web/anatomi_sunnah/hadith_04.html` **tiada baris teks Arab** dalam kepalanya —
13 fail lain ada. Ini kandungan yang tertinggal.
Saya **sengaja tidak menambahnya** kerana tidak wajar mereka-cipta teks Arab
sendiri. Sila ambil daripada `assets/data/hadith_04.json`.

### 5.3 Kebergantungan CDN — tidak berfungsi luar talian

Setiap fail anatomi memuatkan daripada internet:
```html
<script src="https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/gsap/3.12.2/gsap.min.js"></script>
@import url('https://fonts.googleapis.com/css2?family=Amiri&family=Baloo+2...');
```
**Risiko:** simulasi 3D **gagal sepenuhnya** tanpa internet — bermasalah untuk
kegunaan di sekolah dengan talian tidak stabil.
**Cadangan:** muat turun three.js + GSAP + fon ke dalam `web/anatomi_sunnah/`
dan rujuk secara setempat (sama seperti yang sudah dibuat untuk Tailwind).

### 5.4 `dart:html` sudah *deprecated*

2 fail masih menggunakannya (`anatomi_sunnah_screen.dart`, `uji_minda_screen.dart`).
- Tahap: `info` sahaja — **tidak menghalang pembinaan**.
- Menyekat pembinaan **WebAssembly** (`flutter build web --wasm`).
- **Cadangan:** hijrah ke `package:web` + `dart:js_interop` apabila ada masa.

### 5.5 `postMessage` menggunakan `targetOrigin: '*'`

```js
window.parent.postMessage('anatomi-sunnah-back', '*')
```
Risiko rendah (iframe sama-origin, mesej tiada data sensitif), tetapi amalan
lebih baik ialah menetapkan origin yang khusus.

---

## 6. Nota Teknikal Penting Untuk Kerja Seterusnya

### 6.1 Iframe menelan semua klik
Widget Flutter yang dilukis "di atas" `HtmlElementView` **tidak** menerima klik,
dan **tidak** menutupinya secara visual dengan boleh dipercayai. Jika perlukan
kawalan di atas iframe, letakkannya **di dalam HTML** dan berkomunikasi melalui
`postMessage`.

### 6.2 Uji limpahan dalam DEBUG sahaja
Release build memotong limpahan secara senyap. Gunakan:
```bash
flutter build web --debug
```

### 6.3 `extendBody: true` dalam `MainShell`
Sentiasa tambah `MediaQuery.paddingOf(context).bottom` pada padding bawah
sebarang senarai boleh skrol dalam tab.

### 6.4 Menjana semula `styles.css` Tailwind
Wajib selepas menambah kelas Tailwind baharu dalam fail HTML anatomi. Gunakan
konfigurasi `safelist` (regex) kerana banyak kelas dibina dinamik melalui JS.

### 6.5 Struktur 14 fail anatomi adalah IDENTIK
`.ui-layer`, blok pengendali `resize`, dan struktur panel adalah **bait-demi-bait
sama** merentas 14 fail. Ini menjadikan tampalan *scripted* (Python) sangat
selamat dan boleh diulang — corak yang saya guna sepanjang kerja ini.

---

## 7. Cara Uji

```bash
# Analisis statik + ujian unit
flutter analyze
flutter test

# Bina & uji limpahan (WAJIB debug untuk jalur belang)
flutter build web --debug
cd build/web && python3 -m http.server 8765

# Bina produksi
flutter build web --release
```

**Saiz ujian disyorkan:**
| Peranti | Saiz |
|---|---|
| Telefon | 390×844, 430×932, 400×775 |
| Telefon pendek | 390×640 (kes paling ketat) |
| Tablet | 834×1112 |
| Desktop | 1440×900 |

---

## 8. Sejarah Commit (konteks sebelum kerja ini)

```
1cb37c2  Tambah modul Uji Minda: game Eksplorasi Hadis 40
ef1ef07  Betulkan ejaan nama Saeid Ramadhan
c0c6320  Tambah nama pembangun aplikasi pada footer dan Tentang Aplikasi
646fb51  Polish dashboard atmosphere: rainbow whisper, sage depth, dark gold accents
c2444ab  App icon rasmi baharu + Emerald Sage dashboard lengkap
0a19857  Bump version 1.8.0+9 -> 1.17.0+17 (paksa service worker update)
c8563ce  Emerald Sage design system + responsive mobile dashboard
```

---

## 9. Cadangan Commit

```bash
git add -A
git commit -m "Anatomi Sunnah 3D responsif + pembetulan limpahan & platform view

- Modul Anatomi Sunnah 3D (Hadis 1-14) melalui iframe sama-origin
- Responsif telefon/tablet: panel dikecilkan, FOV kamera dilaraskan
- Arah teks: Rumi LTR, Arab RTL (14 fail)
- Butang kembali melalui postMessage (elak iframe menelan klik)
- Betulkan limpahan RenderFlex pada skrin Audio (_DecorativeBackground 660px)
- Betulkan kad Xplorasi Minda tersembunyi di bawah bar navigasi
- Betulkan spinner tersekat pada kunjungan kedua (view factory static)
- Tailwind pra-kompil menggantikan CDN JIT"
```
