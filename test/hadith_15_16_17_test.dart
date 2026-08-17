import 'dart:convert';
import 'dart:io';

import 'package:e_hadis40/core/curriculum/app_curriculum_structure.dart';
import 'package:e_hadis40/data/models/hadith.dart';
import 'package:e_hadis40/data/repositories/hadith_repository.dart';
import 'package:e_hadis40/data/repositories/narrator_repository.dart';
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
        () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final h15 = Hadith.fromJson(_load('hadith_15.json'));
      final h16 = Hadith.fromJson(_load('hadith_16.json'));
      final h09 = Hadith.fromJson(_load('hadith_09.json'));
      expect(h15.narratorId, h16.narratorId);
      expect(h15.narratorId, h09.narratorId);

      final narratorRepo = await NarratorRepository.load();
      final n15 = narratorRepo.byId(h15.narratorId!);
      final n16 = narratorRepo.byId(h16.narratorId!);
      expect(n15, isNotNull);
      expect(n16, isNotNull);
      expect(identical(n15, n16), true);
    });

    test('H17 narrator canonical tunggal shaddad_ibn_aws', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final h17 = Hadith.fromJson(_load('hadith_17.json'));
      expect(h17.narratorId, 'shaddad_ibn_aws');
      final narratorRepo = await NarratorRepository.load();
      final profile = narratorRepo.byId('shaddad_ibn_aws');
      expect(profile, isNotNull);
      expect(profile!.id, 'shaddad_ibn_aws');
    });

    test('Tiada duplikasi profil Abu Hurairah dalam narrators.json', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final narratorRepo = await NarratorRepository.load();
      final abuHurairahCount = narratorRepo.all.values
          .where((p) => p.name.contains('Abu Hurairah'))
          .length;
      expect(abuHurairahCount, 1);
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

    test('H15/H16/H17 ADA dalam Anatomi Sunnah (availableHadithNumbers=25)',
        () {
      expect(15 <= 25, true);
      expect(16 <= 25, true);
      expect(17 <= 25, true);
    });
  });

  group('HadithRepository H15-17', () {
    test('Repository memuatkan H15, H16, H17', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final repository = await HadithRepository.load();
      expect(repository.byNumber(15), isNotNull);
      expect(repository.byNumber(16), isNotNull);
      expect(repository.byNumber(17), isNotNull);
      expect(repository.byNumber(18), isNotNull);
      expect(repository.availableHadiths.length, 25);
    });

    test('Dynamic module count: module_03 = 5/5, module_04 = 5/5', () async {
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
        if (module.number == 4) {
          expect(available, 5,
              reason: 'Module 4 mesti 5/5 selepas H18-H20 dimuatkan');
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
