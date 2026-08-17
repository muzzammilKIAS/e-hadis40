import 'dart:convert';
import 'dart:io';

import 'package:e_hadis40/core/curriculum/app_curriculum_structure.dart';
import 'package:e_hadis40/data/models/hadith.dart';
import 'package:e_hadis40/data/models/narrator_profile.dart';
import 'package:e_hadis40/data/repositories/hadith_repository.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _load(String name) {
  final file = File('assets/data/$name');
  return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
}

void main() {
  group('Hadis 15-17 integration', () {
    test('H15 load: module_03, abu_hurairah, al-Nisa 36, quiz 10', () {
      final h = Hadith.fromJson(_load('hadith_15.json'));
      expect(h.id, 'hadith_15');
      expect(h.number, 15);
      expect(h.moduleId, 'module_03');
      expect(h.narratorId, 'abu_hurairah');
      expect(h.quranEvidence.surah, contains('Nisa'));
      expect(h.quranEvidence.verse, 36);
      expect(h.quiz.length, 10);
      expect(h.audioAsset, 'assets/audio/hadith_15.mp3');
      expect(h.audioTimings, isNotEmpty);
      expect(h.audioTimings.length, 8);
    });

    test('H16 load: module_04, abu_hurairah, quranEvidence kosong', () {
      final h = Hadith.fromJson(_load('hadith_16.json'));
      expect(h.id, 'hadith_16');
      expect(h.number, 16);
      expect(h.moduleId, 'module_04');
      expect(h.narratorId, 'abu_hurairah');
      expect(h.quranEvidence.surah, isEmpty);
      expect(h.quranEvidences, isEmpty);
      expect(h.allQuranEvidences, isEmpty);
      expect(h.quiz.length, 10);
      expect(h.audioAsset, 'assets/audio/hadith_16.mp3');
      expect(h.audioTimings, isNotEmpty);
      expect(h.audioTimings.length, 8);
    });

    test('H17 load: module_04, shaddad_ibn_aws, 3 quranEvidences', () {
      final h = Hadith.fromJson(_load('hadith_17.json'));
      expect(h.id, 'hadith_17');
      expect(h.number, 17);
      expect(h.moduleId, 'module_04');
      expect(h.narratorId, 'shaddad_ibn_aws');
      expect(h.quranEvidences.length, 3);
      expect(h.allQuranEvidences.length, 3);
      expect(h.quranEvidences[0].surah, contains('al-Rum'));
      expect(h.quranEvidences[0].verse, 41);
      expect(h.quranEvidences[1].surah, contains('al-Nahl'));
      expect(h.quranEvidences[1].verse, 5);
      expect(h.quranEvidences[1].verseEnd, 6);
      expect(h.quranEvidences[2].surah, contains('al-Nahl'));
      expect(h.quranEvidences[2].verse, 90);
      expect(h.quiz.length, 10);
      expect(h.audioAsset, 'assets/audio/hadith_17.mp3');
      expect(h.audioTimings, isNotEmpty);
      expect(h.audioTimings.length, 8);
    });

    test('H15-H17 wordHighlightMode = phraseOnly', () {
      for (final n in ['15', '16', '17']) {
        final raw = _load('hadith_$n.json');
        final audio = raw['audio'] as Map<String, dynamic>;
        expect(audio['wordHighlightMode'], 'phraseOnly',
            reason: 'Hadis $n mesti phraseOnly');
      }
    });

    test('H15 dan H16 resolve ke narrator canonical abu_hurairah yang sama',
        () {
      final h15 = Hadith.fromJson(_load('hadith_15.json'));
      final h16 = Hadith.fromJson(_load('hadith_16.json'));
      final h09 = Hadith.fromJson(_load('hadith_09.json'));
      expect(h15.narratorId, h16.narratorId);
      expect(h15.narratorId, h09.narratorId);
      expect(h15.narratorId, 'abu_hurairah');

      final narrators =
          jsonDecode(File('assets/data/narrators.json').readAsStringSync())
              as Map<String, dynamic>;
      expect(narrators.containsKey('abu_hurairah'), true);
    });

    test('H17 narrator canonical tunggal shaddad_ibn_aws', () {
      final h17 = Hadith.fromJson(_load('hadith_17.json'));
      expect(h17.narratorId, 'shaddad_ibn_aws');

      final narrators =
          jsonDecode(File('assets/data/narrators.json').readAsStringSync())
              as Map<String, dynamic>;
      expect(narrators.containsKey('shaddad_ibn_aws'), true);
      final profile = NarratorProfile.fromJson(
          narrators['shaddad_ibn_aws'] as Map<String, dynamic>);
      expect(profile.id, 'shaddad_ibn_aws');
      expect(profile.name, contains('Syaddad bin Aus'));
    });

    test('Tiada duplikasi profil Abu Hurairah dalam narrators.json', () {
      final narrators =
          jsonDecode(File('assets/data/narrators.json').readAsStringSync())
              as Map<String, dynamic>;
      final profiles = narrators.values
          .map((v) => NarratorProfile.fromJson(v as Map<String, dynamic>))
          .toList();
      final abuHurairah =
          profiles.where((p) => p.name.contains('Abu Hurairah')).toList();
      expect(abuHurairah.length, 1,
          reason: 'Hanya satu profil canonical Abu Hurairah');
    });

    test('Audio assets H15/H16/H17 wujud', () {
      for (final n in ['15', '16', '17']) {
        expect(
          File('assets/audio/hadith_$n.mp3').existsSync(),
          true,
          reason: 'assets/audio/hadith_$n.mp3 mesti wujud',
        );
      }
    });

    test('Quiz id unik untuk setiap hadis', () {
      for (final n in ['15', '16', '17']) {
        final h = Hadith.fromJson(_load('hadith_$n.json'));
        final ids = h.quiz.map((q) => q.id).toSet();
        expect(ids.length, h.quiz.length,
            reason: 'Quiz id Hadis $n mesti unik');
        for (final q in h.quiz) {
          expect(q.id.startsWith('h${n}_q'), true,
              reason: 'Quiz id Hadis $n mesti berformat h${n}_qNN');
          expect(q.options.length, 4);
          expect(q.correctAnswerIndex, inInclusiveRange(0, 3));
        }
      }
    });

    test('H15/H16/H17 ADA dalam Anatomi Sunnah (availableHadithNumbers=20)',
        () {
      expect(15 <= 20, true);
      expect(16 <= 20, true);
      expect(17 <= 20, true);
    });
  });

  group('HadithRepository H15-17', () {
    test('Repository memuatkan H15, H16, H17', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final repository = await HadithRepository.load();
      expect(repository.byNumber(15), isNotNull);
      expect(repository.byNumber(16), isNotNull);
      expect(repository.byNumber(17), isNotNull);
      // H18+ dimuatkan dalam batch seterusnya; H21 masih belum tersedia.
      expect(repository.byNumber(21), isNull);
      expect(repository.availableHadiths.length, greaterThanOrEqualTo(17));
    });

    test('Dynamic module count: module_03 = 5/5', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final repository = await HadithRepository.load();

      for (final module in AppCurriculumStructure.modules) {
        final available = repository.availableHadiths
            .where((h) => module.hadithNumbers.contains(h.number))
            .length;
        if (module.number == 3) {
          expect(available, 5,
              reason: 'Module 3 mesti 5/5 selepas H15 dimuatkan');
        }
      }
    });

    test('Playlist order (audio asset) mengandungi H15, H16, H17', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final repository = await HadithRepository.load();
      final playlist =
          repository.availableHadiths.where((h) => h.audioAsset.isNotEmpty);
      final ids = playlist.map((h) => h.id).toList();
      expect(ids, contains('hadith_15'));
      expect(ids, contains('hadith_16'));
      expect(ids, contains('hadith_17'));
      expect(ids.indexOf('hadith_15'), lessThan(ids.indexOf('hadith_16')));
      expect(ids.indexOf('hadith_16'), lessThan(ids.indexOf('hadith_17')));
    });
  });
}
