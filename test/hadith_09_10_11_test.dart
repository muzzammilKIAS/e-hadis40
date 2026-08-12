import 'dart:convert';
import 'dart:io';

import 'package:e_hadis40/data/models/hadith.dart';
import 'package:e_hadis40/data/models/narrator_profile.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _loadHadithJson(String name) {
  final file = File('assets/data/$name');
  return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
}

void main() {
  group('Hadis 09-11 integration', () {
    test('Hadis 9 load: module_02, al-Maidah 101, phraseOnly', () {
      final h = Hadith.fromJson(_loadHadithJson('hadith_09.json'));
      expect(h.number, 9);
      expect(h.moduleId, 'module_02');
      expect(h.quranEvidence.surah, contains('Ma'));
      expect(h.quranEvidence.verse, 101);
      expect(h.narratorId, 'abu_hurairah');
      expect(h.audioAsset, isNotEmpty);
      expect(h.audioTimings, isNotEmpty);
      expect(h.quiz.length, 10);
    });

    test('Hadis 10 load: module_02, al-Baqarah 172, abu_hurairah', () {
      final h = Hadith.fromJson(_loadHadithJson('hadith_10.json'));
      expect(h.number, 10);
      expect(h.moduleId, 'module_02');
      expect(h.quranEvidence.surah, contains('Baqarah'));
      expect(h.quranEvidence.verse, 172);
      expect(h.narratorId, 'abu_hurairah');
      expect(h.audioTimings, isNotEmpty);
      expect(h.focusValues, contains('Ihsan'));
    });

    test('Hadis 11 load: module_03, Qaf 16, al_hasan_ibn_ali', () {
      final h = Hadith.fromJson(_loadHadithJson('hadith_11.json'));
      expect(h.number, 11);
      expect(h.moduleId, 'module_03');
      expect(h.quranEvidence.surah, contains('Qaf'));
      expect(h.quranEvidence.verse, 16);
      expect(h.narratorId, 'al_hasan_ibn_ali');
      expect(h.audioTimings, isNotEmpty);
    });

    test('H9/H10 kongsi narratorId abu_hurairah yang sama', () {
      final h9 = Hadith.fromJson(_loadHadithJson('hadith_09.json'));
      final h10 = Hadith.fromJson(_loadHadithJson('hadith_10.json'));
      expect(h9.narratorId, h10.narratorId);
    });

    test('H3/H8 kongsi narratorId abdullah_ibn_umar yang sama', () {
      final h3 = Hadith.fromJson(_loadHadithJson('hadith_03.json'));
      final h8 = Hadith.fromJson(_loadHadithJson('hadith_08.json'));
      expect(h3.narratorId, h8.narratorId);
      expect(h3.narratorId, 'abdullah_ibn_umar');
    });

    test('H1/H2 kongsi narratorId umar_ibn_al_khattab yang sama', () {
      final h1 = Hadith.fromJson(_loadHadithJson('hadith_01.json'));
      final h2 = Hadith.fromJson(_loadHadithJson('hadith_02.json'));
      expect(h1.narratorId, h2.narratorId);
      expect(h1.narratorId, 'umar_ibn_al_khattab');
    });
  });

  group('NarratorRepository canonical dedupe', () {
    test('narrators.json load, tiada duplicate canonical id', () {
      final file = File('assets/data/narrators.json');
      final decoded =
          jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final ids = decoded.keys.toList();
      expect(ids.toSet().length, ids.length,
          reason: 'Tiada duplicate key dalam narrators.json');

      final profiles = decoded.values
          .map((v) => NarratorProfile.fromJson(v as Map<String, dynamic>))
          .toList();
      final abuHurairah =
          profiles.where((p) => p.name.contains('Hurairah')).toList();
      expect(abuHurairah.length, 1,
          reason: 'Hanya satu profil canonical Abu Hurairah');
      final ibnUmar =
          profiles.where((p) => p.name.contains('bin Umar r.a.')).toList();
      expect(ibnUmar.length, 1,
          reason: 'Hanya satu profil canonical Abdullah bin Umar');
    });

    test('semua narratorId dalam hadith_01-11 resolve dalam narrators.json',
        () {
      final file = File('assets/data/narrators.json');
      final decoded =
          jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
      final known = decoded.keys.toSet();
      for (var i = 1; i <= 11; i++) {
        final h = Hadith.fromJson(
            _loadHadithJson('hadith_${i.toString().padLeft(2, '0')}.json'));
        if (h.narratorId != null) {
          expect(known.contains(h.narratorId), isTrue,
              reason: 'Hadis $i narratorId ${h.narratorId} mesti wujud');
        }
      }
    });
  });
}
