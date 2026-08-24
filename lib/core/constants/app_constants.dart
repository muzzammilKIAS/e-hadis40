class AppConstants {
  const AppConstants._();

  static const appName = 'e-Hadis40';
  static const appShortDescription = 'Modul Penghayatan Hadis 40';
  // KPM dipaparkan sebagai SUMBER RUJUKAN modul, bukan pembangun/penerbit
  // e-Hadis40 — lihat audit atribusi KPM dalam laporan tugas berkaitan.
  static const appDescription =
      'Platform Pengajaran dan Pembelajaran Interaktif berasaskan Modul '
      'Penghayatan Hadis 40 Imam Nawawi Edisi Kedua. Rujukan modul: '
      'Kementerian Pendidikan Malaysia (KPM)';
  static const totalHadiths = 42;
  static const totalModules = 8;
  static const maxContentWidth = 1240.0;

  static const arabicFontFamily = 'LotusLinotype';
  static const arabicFontFallback = <String>[
    'Lotus Linotype',
    'Noto Naskh Arabic',
    'Amiri',
    'Traditional Arabic',
    'Arial',
  ];

  static const uiFontFamily = 'Poppins';
  static const uiFontFallback = <String>[
    'Inter',
    'Noto Sans',
    'sans-serif',
  ];
}
