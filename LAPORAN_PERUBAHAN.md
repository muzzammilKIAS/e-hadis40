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
| `flutter analyze` | ✅ **0 isu** |
| `flutter test` | ✅ **20/20 lulus** |
| `flutter build web --release` | ✅ Berjaya |
| `flutter build web --debug` | ✅ Berjaya, **tiada jalur limpahan (RenderFlex overflow)** |
| Bug diketahui belum selesai | ⚠️ 2 item — lihat **Bahagian 5** |

> **Kemas kini pusingan ke-2 (16 Ogos):** 4 permintaan tambahan telah disiapkan —
> lihat **Bahagian 10**.

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

### 5.2 ~~Hadis 4 tiada teks Arab~~ ✅ SELESAI

Teks Arab penuh telah ditambah ke `hadith_04.html`. Saya kemudian melaraskan
saiznya (`text-3xl` → `text-lg`, `leading-loose`) dan warnanya
(`emerald` → `pink`, sepadan tema halaman), kerana matannya 917 aksara —
jauh lebih panjang daripada petikan 12–100 aksara pada 13 fail lain — dan
pada saiz asal ia menenggelamkan seluruh panel.

### 5.3 ~~Kebergantungan CDN pada folder anatomi~~ ✅ SELESAI (sebahagian)

`web/anatomi_sunnah/` kini memuatkan three.js, GSAP dan fon secara **setempat**
daripada `web/anatomi_sunnah/lib/`. (Lihat Bahagian 10.4 — laluan fon pada
mulanya rosak dan telah saya betulkan.)

⚠️ **MASIH BERBAKI:** `web/uji_minda/index.html` kekal bergantung sepenuhnya
kepada CDN:
```html
<script src="https://cdn.tailwindcss.com"></script>
<script src="https://unpkg.com/@phosphor-icons/web"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/gsap/3.12.2/gsap.min.js"></script>
<link href="https://fonts.googleapis.com/css2?family=Amiri...&family=Baloo+2...">
```
Nota tambahan: `cdn.tailwindcss.com` ialah pengkompil JIT dalam pelayar —
*anti-pattern* untuk produksi. Cadangan: localkan sama seperti folder anatomi,
dan pra-kompil Tailwind menjadi CSS statik.

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

---

## 10. Pusingan Ke-2 — 4 Permintaan Tambahan (16 Ogos 2026)

### 10.1 Saiz font Rumi dibesarkan (telefon & tablet)

Nilai lama terlalu kecil. Semua dinaikkan ~12–18%:

| Kelas | Telefon (lama → baharu) | Tablet (lama → baharu) |
|---|---|---|
| `text-4xl` | 1.35 → **1.6rem** | 1.75 → **2rem** |
| `text-3xl` | 1.15 → **1.4rem** | 1.45 → **1.65rem** |
| `text-2xl` | 1.05 → **1.25rem** | 1.25 → **1.45rem** |
| `text-xl` | 0.98 → **1.12rem** | 1.1 → **1.25rem** |
| `text-lg` | 0.92 → **1.05rem** | 1.0 → **1.12rem** |
| `text-sm` | 0.8 → **0.95rem** | *(tiada)* → **1rem** |
| `text-xs` | 0.72 → **0.88rem** | *(tiada)* → **0.92rem** |
| `.btn-action` | 0.76 → **0.92rem** | *(tiada)* → **1rem** |

**Dua pepijat sampingan turut dibetulkan:**
- Breakpoint **tablet** sebelum ini **tidak** melaraskan `text-sm`/`text-xs`
  langsung, jadi teks badan kekal pada saiz Tailwind lalai yang kecil.
- Kelas arbitrari `text-[12px]` / `text-[13px]` tidak pernah dilaraskan pada
  mana-mana breakpoint; kini ditambah.

**Tinggi panel dilaraskan semula** supaya teks lebih besar tidak memaksa skrol:

| Panel | Telefon | Tablet |
|---|---|---|
| Kepala | 31vh → **34vh** | 64vh → **52vh** |
| Kawalan | 38vh → **45vh** | 48vh → **36vh** |

> ⚠️ Nilai tablet asal (`64vh + 48vh = 112vh`) **melebihi tinggi skrin**,
> menyebabkan panel bersentuhan pada Hadis 4 (jalur 3D = **0px**).
> Kini 52+36 = 88vh → jalur 3D **139px**.

### 10.2 Bingkai Xplorasi Minda dibetulkan

**Punca:** baris kawalan (2 butang + pemasa + pil "Dijumpai" ≈ **424px**)
melebihi ruang dalam panel kaca pada telefon (**≈318px**), jadi pil "Dijumpai"
terkeluar daripada bingkai.

**Pembetulan** — `web/uji_minda/index.html`:
- `flex-wrap` + `w-full sm:w-auto` → kawalan membalut ke baris kedua.
- Saiz mengecil pada telefon: butang `w-10 h-10` (sm: `w-11 h-11`),
  padding & fon `text-base` (sm: `text-lg`).
- Bar kemajuan `w-full sm:w-32` supaya tidak memaksa lebar tetap.

**Pengesahan:** limpahan keluar-bingkai = **0px** pada telefon, tablet & desktop.

### 10.3 Dashboard — kotak modul diminimalkan

`lib/screens/home_screen.dart` kini memaparkan **pratonton** sahaja:

| Lajur | Modul dipaparkan |
|---|---|
| 1 (telefon) | **3** |
| 2 | **4** |
| 3 | **6** |
| 4 (desktop) | 8 (semua) |

Ditambah butang lebar penuh **"Lihat N modul lagi"** di bawah pratonton
(selain pautan "Lihat semua" sedia ada di kepala seksyen), dan subtajuk
bertukar kepada *"Memaparkan 3 daripada 8 modul (42 hadis)."*

**Pengesahan:** telefon menunjukkan 3 kad + butang "Lihat 5 modul lagi";
klik → skrin Modul penuh dengan kesemua 8 modul.

### 10.4 🔴 Font Arab (Amiri) — punca sebenar: SEMUA fail font 404

Ini bukan sekadar isu gaya — **ketujuh-tujuh fail font gagal dimuat.**

`web/anatomi_sunnah/lib/fonts.css` merujuk laluan bergaya Google Fonts:
```
url(./fonts/s/amiri/v30/J7aRnpd8CGxBHqUp.ttf)
url(./fonts/s/baloo2/v23/wXK0E3kTposypRydzVT08TS3JnAmtdgazapv.ttf)
```
tetapi fail sebenar disimpan **rata** di `./fonts/`:
```
fonts/J7aRnpd8CGxBHqUp.ttf
fonts/wXK0E3kTposypRydzVT08TS3JnAmtdgazapv.ttf
```

**Akibat:** Arab jatuh ke `serif` generik (bukan Amiri) **dan** Rumi jatuh ke
`sans-serif` generik (bukan Baloo 2) — jadi ini turut menyumbang kepada aduan
"font Rumi kecil/tak kemas" dalam 10.1.

**Pembetulan:** laluan `url()` ditulis semula supaya sepadan susun atur rata.

**Pengesahan** (14 fail, `document.fonts.check` + pemantauan HTTP):
```
hadith_01 … hadith_14   amiri=true  baloo=true  arabicEl="Amiri, serif"
tiada respons HTTP >= 400 bagi mana-mana fail font
```

**Bonus — Hadis 4:** teks Arabnya (baru ditambah) ialah matan **penuh 917
aksara** berbanding petikan 12–100 aksara pada 13 fail lain, tetapi masih
menggunakan `text-3xl` dan warna `emerald` (tema halaman itu merah jambu).
Ditukar kepada `text-lg` + `leading-loose` + `text-pink-200`, jadi kini
matan penuh **dan** terjemahan Melayu muat serentak tanpa skrol.

### 10.5 Pengesahan menyeluruh pusingan ke-2

| Ujian | Skop | Keputusan |
|---|---|---|
| `flutter analyze` | seluruh projek | ✅ 0 isu |
| `flutter test` | 20 ujian | ✅ lulus |
| Font Amiri + Baloo 2 | 14 fail | ✅ semua dimuat, 0 × HTTP 404 |
| Jalur 3D & limpahan panel | 14 fail × 3 saiz = 42 | ✅ tiada limpahan; jalur paling ketat 139px |
| Panel kawalan telefon terpotong | 14 fail | ✅ tiada |
| Bingkai Xplorasi Minda | 3 saiz | ✅ 0px keluar-bingkai |
| Jalur belang (debug build) | 5 tab × 4 tinggi = 20 | ✅ semua bersih |

---

## 11. Pembetulan Tambahan — "Tentang Aplikasi" tersembunyi (16 Ogos 2026)

**Aduan:** butang "Tentang Aplikasi" tidak dipaparkan pada paparan mobile & tablet.

**Punca:** **pepijat yang sama seperti 4.1** — `MainShell` menetapkan
`extendBody: true`, jadi badan skrin memanjang ke belakang bar navigasi bawah.
Butang "Tentang Aplikasi" ialah elemen **terakhir** dalam `AppFooter`, jadi ia
kekal tersembunyi di belakang bar itu walaupun sudah skrol habis.

Dalam laporan asal (4.1) saya sudah menandakan risiko ini:
> *"corak pepijat yang sama boleh berlaku pada mana-mana tab lain yang
> menggunakan senarai boleh skrol."*

Semasa menyiasat aduan ini saya semak **kesemua 5 tab**, dan mendapati **3**
daripadanya masih terjejas:

| Tab | Fail | Status sebelum |
|---|---|---|
| Dashboard | `lib/screens/home_screen.dart` | ❌ terjejas (dilapor pengguna) |
| Modul | `lib/screens/modules_screen.dart` | ✅ sudah dibetulkan (4.1) |
| Bookmark | `lib/screens/bookmarks_screen.dart` | ❌ terjejas (belum dilapor) |
| Audio | `lib/screens/hadith_playlist_screen.dart` | ✅ `SafeArea` sudah mengendalikannya |
| Tetapan | `lib/screens/settings_screen.dart` | ❌ terjejas (belum dilapor) |

**Pembetulan** — corak sama pada ketiga-tiga fail:
```dart
padding: pagePadding.copyWith(
  bottom: pagePadding.bottom + MediaQuery.paddingOf(context).bottom,
),
```

**Pengesahan:**
- "Tentang Aplikasi" kini kelihatan pada Dashboard **dan** Tetapan, pada
  mobile (390×844) **dan** tablet (834×1112).
- Butang diklik → skrin "Tentang e-Hadis40" terbuka dengan betul.
- `flutter analyze` 0 isu · `flutter test` 20/20 lulus.

> ✅ Kini **kesemua 5 tab** sudah mengambil kira `extendBody: true`.

---

## 12. Integrasi Hadis 15, 16 dan 17 (16 Ogos 2026)

**Tujuan:** memuatkan Hadis 15, 16 dan 17 daripada pakej DeepSeek
(`eHadis40_DeepSeek_Hadis_15_16_17.zip`) dengan data KPM, audio MP3 sebenar
dan timing frasa.

### Fail dicipta
- `assets/data/hadith_15.json` — id `hadith_15`, `module_03`, perawi
  `abu_hurairah`, dalil al-Nisa’ 36, 10 soalan kuiz.
- `assets/data/hadith_16.json` — id `hadith_16`, `module_04`, perawi
  `abu_hurairah`, **tiada** quranEvidence rekaan, 10 soalan kuiz.
- `assets/data/hadith_17.json` — id `hadith_17`, `module_04`, perawi
  `shaddad_ibn_aws`, 3 dalil (al-Rum 41, al-Nahl 5–6, al-Nahl 90),
  10 soalan kuiz.
- `assets/audio/hadith_15.mp3`, `hadith_16.mp3`, `hadith_17.mp3` — MP3 sebenar
  mono 24 kHz 96 kbps (bukan WAV bersari nama .mp3).
- `test/hadith_15_16_17_test.dart` — 15 test integrasi.

### Fail diubah
- `lib/data/repositories/hadith_repository.dart` — muat hadith_15/16/17.
- `assets/data/narrators.json` — `abu_hurairah` dikemas kini
  (hadithNumbers 9,10,12,15,16); `shaddad_ibn_aws` ditambah (kanonik tunggal,
  tanpa biografi rekaan).
- `lib/screens/hadith_screen.dart` — butang Next H17 papar "Hadis 18 · Akan
  Datang" (dilumpuhkan) kerana H18 belum tersedia; import
  `AppCurriculumStructure`.

### Audio
- H15: MP3 mono 24 kHz 96 kbps, durasi 23.66 s (sumber ~23.6 s) — 8 segmen
  frasa.
- H16: MP3 mono 24 kHz 96 kbps, durasi 15.02 s (sumber ~14.96 s) — 8 segmen
  frasa.
- H17: MP3 mono 24 kHz 96 kbps, durasi 22.22 s (sumber ~22.16 s) — 8 segmen
  frasa.

### Timing
- Semua `wordHighlightMode = "phraseOnly"` (tiada proportional word timing).
- Timing ialah **starting point** daripada CSV pakej; status
  `STARTING_POINT_REVIEW_BY_EAR`. Perlu semakan pendengaran manusia untuk
  fine-tune startMs/endMs secara minimum.
- Rujukan hadis (`رَوَاهُ الْبُخَارِيُّ وَمُسْلِمٌ.` dsb.) kekal **statik** —
  tidak dimasukkan ke timedSegments kerana rakaman kelihatan tamat pada badan
  hadis.

### Modul (dinamik)
- Module 3 (Hadis 11–15): kini **5/5** tersedia.
- Module 4 (Hadis 16–20): kini **2/5** tersedia (H16, H17). H18–20 papar
  "Akan Datang".
- Kiraan dikira daripada `HadithRepository.availableHadiths` — tiada
  hard-code.

### Global Audio
- Playlist Global Audio dibina daripada semua hadis yang ada `audioAsset`,
  jadi H15–H17 automatik masuk. Tap baris trek hanya `skipTo(index)` (main,
  tidak navigate).

### Pengesahan
- `flutter analyze` — 0 ralat.
- `flutter test` — 33/33 lulus (termasuk 15 test H15–17).
- `flutter build web --release --base-href "/"` — berjaya.
- `flutter build web --debug` — berjaya.

### Perlu semakan manusia/ilmiah
- Fine-tune timing frasa mengikut pendengaran audio sebenar.
- Sahkan durasi audio dan kedudukan frasa dengan rakaman rasmi.
- Semakan ilmiah huraian KPM jika perlu.
