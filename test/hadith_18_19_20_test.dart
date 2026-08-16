import 'dart:convert';
import 'dart:io';

import 'package:e_hadis40/core/curriculum/app_curriculum_structure.dart';
import 'package:e_hadis40/data/models/hadith.dart';
import 'package:e_hadis40/data/repositories/hadith_repository.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _load(String name) {
  final file = File('assets/data/$name');
  return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
}

void main() {
  group('Hadis 18-20 integration', () {
    test('H18 load: module_04, 2 narratorIds, phraseOnly', () {
      final h = Hadith.fromJson(_load('hadith_18.json'));
      expect(h.id, 'hadith_18');
      expect(h.number, 18);
      expect(h.moduleId, 'module_04');
      expect(h.narratorIds.length, 2);
      expect(h.narratorIds, contains('abu_dharr_jundub_ibn_junadah'));
      expect(h.narratorIds, contains('muadh_ibn_jabal'));
      expect(h.allNarratorIds.length, 2);
      expect(h.audioAsset, 'assets/audio/hadith_18.mp3');
      expect(h.audioTimings, isNotEmpty);
      expect(h.quiz.length, 10);
    });

    test('H19 load: module_04, abdullah_ibn_abbas, riwayat tambahan wujud', () {
      final h = Hadith.fromJson(_load('hadith_19.json'));
      expect(h.id, 'hadith_19');
      expect(h.number, 19);
      expect(h.moduleId, 'module_04');
      expect(h.narratorId, 'abdullah_ibn_abbas');
      expect(h.allNarratorIds, ['abdullah_ibn_abbas']);
      expect(h.supplementaryNarrationText, isNotEmpty);
      expect(h.supplementaryNarrationIntro, contains('غَيْرِ التِّرْمِذِيِّ'));
      expect(h.audioTimings.length, greaterThan(16));
      expect(h.quiz.length, 10);
    });

    test('H20 load: module_04, abu_masud_uqbah_ibn_amr, nilai + aktiviti', () {
      final h = Hadith.fromJson(_load('hadith_20.json'));
      expect(h.id, 'hadith_20');
      expect(h.number, 20);
      expect(h.moduleId, 'module_04');
      expect(h.narratorId, 'abu_masud_uqbah_ibn_amr');
      expect(h.focusValues,
          containsAll(['Keyakinan', 'Kemampanan', 'Daya cipta']));
      expect(h.activities.length, 3);
      expect(h.appreciation, isNotEmpty);
      expect(h.quiz.length, 10);
      expect(h.audioTimings, isNotEmpty);
    });

    test('H18-H20 wordHighlightMode = phraseOnly', () {
      for (final n in ['18', '19', '20']) {
        final raw = _load('hadith_$n.json');
        final audio = raw['audio'] as Map<String, dynamic>;
        expect(audio['wordHighlightMode'], 'phraseOnly',
            reason: 'Hadis $n mesti phraseOnly');
      }
    });

    test('Audio assets H18/H19/H20 wujud', () {
      for (final n in ['18', '19', '20']) {
        expect(File('assets/audio/hadith_$n.mp3').existsSync(), true,
            reason: 'assets/audio/hadith_$n.mp3 mesti wujud');
      }
    });

    test('Quiz id unik untuk H18/H19/H20', () {
      for (final n in ['18', '19', '20']) {
        final h = Hadith.fromJson(_load('hadith_$n.json'));
        final ids = h.quiz.map((q) => q.id).toSet();
        expect(ids.length, h.quiz.length,
            reason: 'Quiz id Hadis $n mesti unik');
        for (final q in h.quiz) {
          expect(q.options.length, 4);
          expect(q.correctAnswerIndex, inInclusiveRange(0, 3));
        }
      }
    });

    test('No duplicate narrator IDs dalam narrators.json', () {
      final narrators =
          jsonDecode(File('assets/data/narrators.json').readAsStringSync())
              as Map<String, dynamic>;
      final ids = narrators.keys.toList();
      expect(ids.toSet().length, ids.length);
      expect(ids, contains('abu_dharr_jundub_ibn_junadah'));
      expect(ids, contains('muadh_ibn_jabal'));
      expect(ids, contains('abdullah_ibn_abbas'));
      expect(ids, contains('abu_masud_uqbah_ibn_amr'));
    });

    test('H18 dua perawi berbeza (bukan narratorId tunggal)', () {
      final h = Hadith.fromJson(_load('hadith_18.json'));
      expect(h.narratorIds.length, 2);
      expect(h.narratorIds[0], isNot(h.narratorIds[1]));
    });

    test('H19/H20 narrator canonical tunggal', () {
      final h19 = Hadith.fromJson(_load('hadith_19.json'));
      final h20 = Hadith.fromJson(_load('hadith_20.json'));
      expect(h19.allNarratorIds.length, 1);
      expect(h20.allNarratorIds.length, 1);
    });

    test('Backward compat: hadis lama masih guna narratorId tunggal', () {
      final h01 = Hadith.fromJson(_load('hadith_01.json'));
      expect(h01.narratorIds, isEmpty);
      expect(h01.allNarratorIds.length, 1);
    });
  });

  group('HadithRepository H18-20', () {
    test('Repository memuatkan H1-H20 (20 hadis)', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final repository = await HadithRepository.load();
      expect(repository.availableHadiths.length, 20);
      expect(repository.byNumber(18), isNotNull);
      expect(repository.byNumber(19), isNotNull);
      expect(repository.byNumber(20), isNotNull);
      expect(repository.byNumber(21), isNull);
    });

    test('Module 4 denominator == 5 dan available count == 5', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final repository = await HadithRepository.load();
      final module4 =
          AppCurriculumStructure.modules.firstWhere((m) => m.number == 4);
      expect(module4.hadithNumbers.length, 5);
      final available = repository.availableHadiths
          .where((h) => module4.hadithNumbers.contains(h.number))
          .length;
      expect(available, 5,
          reason: 'Module 4 mesti 5/5 selepas H18-20 dimuatkan');
    });

    test('Playlist mengandungi H18, H19, H20 (susunan naik)', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final repository = await HadithRepository.load();
      final playlist =
          repository.availableHadiths.where((h) => h.audioAsset.isNotEmpty);
      final ids = playlist.map((h) => h.id).toList();
      expect(ids, contains('hadith_18'));
      expect(ids, contains('hadith_19'));
      expect(ids, contains('hadith_20'));
      expect(ids.indexOf('hadith_18'), lessThan(ids.indexOf('hadith_19')));
      expect(ids.indexOf('hadith_19'), lessThan(ids.indexOf('hadith_20')));
    });
  });
}
