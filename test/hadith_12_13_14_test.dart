import 'dart:convert';
import 'dart:io';

import 'package:e_hadis40/data/models/hadith.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _load(String name) {
  final file = File('assets/data/$name');
  return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
}

void main() {
  group('Hadis 12-14 integration', () {
    test('H12 load: module_03, abu_hurairah, al-Nisa 114', () {
      final h = Hadith.fromJson(_load('hadith_12.json'));
      expect(h.number, 12);
      expect(h.moduleId, 'module_03');
      expect(h.narratorId, 'abu_hurairah');
      expect(h.quranEvidence.surah, contains('Nisa'));
      expect(h.quranEvidence.verse, 114);
      expect(h.quiz.length, 10);
      expect(h.audioAsset, isNotEmpty);
      expect(h.audioTimings, isNotEmpty);
    });

    test('H13 load: anas_ibn_malik, al-Hujurat 10', () {
      final h = Hadith.fromJson(_load('hadith_13.json'));
      expect(h.number, 13);
      expect(h.moduleId, 'module_03');
      expect(h.narratorId, 'anas_ibn_malik');
      expect(h.quranEvidence.surah, contains('Hujurat'));
      expect(h.quranEvidence.verse, 10);
      expect(h.quiz.length, 10);
    });

    test('H14 load: abdullah_ibn_masud, 2 quranEvidences, contextNotice', () {
      final h = Hadith.fromJson(_load('hadith_14.json'));
      expect(h.number, 14);
      expect(h.moduleId, 'module_03');
      expect(h.narratorId, 'abdullah_ibn_masud');
      expect(h.quranEvidences.length, 2);
      expect(h.allQuranEvidences.length, 2);
      expect(h.contextNotice.trim(), isNotEmpty);
      expect(h.quiz.length, 10);
    });

    test('H12-H14 wordHighlightMode = phraseOnly', () {
      for (final n in ['12', '13', '14']) {
        final raw = _load('hadith_$n.json');
        final audio = raw['audio'] as Map<String, dynamic>;
        expect(audio['wordHighlightMode'], 'phraseOnly',
            reason: 'Hadis $n mesti phraseOnly');
      }
    });

    test('H12-H14 narrator dedup: abu_hurairah & abdullah_ibn_masud shared',
        () {
      final h9 = Hadith.fromJson(_load('hadith_09.json'));
      final h10 = Hadith.fromJson(_load('hadith_10.json'));
      final h12 = Hadith.fromJson(_load('hadith_12.json'));
      expect(h12.narratorId, h9.narratorId);
      expect(h12.narratorId, h10.narratorId);

      final h4 = Hadith.fromJson(_load('hadith_04.json'));
      final h14 = Hadith.fromJson(_load('hadith_14.json'));
      expect(h14.narratorId, h4.narratorId);
    });
  });
}
