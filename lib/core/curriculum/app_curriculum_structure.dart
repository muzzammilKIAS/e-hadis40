import '../../data/models/learning_module.dart';

/// Pusat struktur kurikulum e-Hadis40.
/// Modul KPM mengandungi 42 hadis disusun dalam 8 modul.
/// SUMBER TUNGGAL untuk total hadis, total modul dan range setiap modul.
class AppCurriculumStructure {
  const AppCurriculumStructure._();

  static const int totalHadiths = 42;
  static const int totalModules = 8;

  /// Explicit mapping — BUKAN formula (modul 7 & 8 ada 6 hadis).
  static const Map<String, (int, int)> _moduleRanges = {
    'module_01': (1, 5),
    'module_02': (6, 10),
    'module_03': (11, 15),
    'module_04': (16, 20),
    'module_05': (21, 25),
    'module_06': (26, 30),
    'module_07': (31, 36),
    'module_08': (37, 42),
  };

  static List<LearningModule> get modules {
    final result = <LearningModule>[];
    _moduleRanges.forEach((id, range) {
      final number = int.parse(id.substring(id.length - 2));
      result.add(LearningModule(
        id: id,
        number: number,
        startHadith: range.$1,
        endHadith: range.$2,
      ));
    });
    result.sort((a, b) => a.number.compareTo(b.number));
    return result;
  }

  /// Module id bagi sesuatu nombor hadis (1..42).
  static String moduleIdFor(int hadithNumber) {
    for (final entry in _moduleRanges.entries) {
      final range = entry.value;
      if (hadithNumber >= range.$1 && hadithNumber <= range.$2) {
        return entry.key;
      }
    }
    throw ArgumentError('Nombor hadis di luar julat: $hadithNumber');
  }
}
