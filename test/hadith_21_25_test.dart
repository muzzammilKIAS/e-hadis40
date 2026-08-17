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
  group('Hadis 21-25 integration', () {
    test('Semua H21-H25 load dengan module_05', () {
      for (final n in ['21', '22', '23', '24', '25']) {
        final h = Hadith.fromJson(_load('hadith_$n.json'));
        expect(h.id, 'hadith_$n', reason: 'ID Hadis $n');
        expect(h.number, int.parse(n));
        expect(h.moduleId, 'module_05', reason: 'Hadis $n mesti module_05');
        expect(h.audioAsset, 'assets/audio/hadith_$n.mp3');
        expect(h.audioTimings, isNotEmpty);
        expect(h.quiz.length, 10);
      }
    });

    test('Module 5 denominator == 5 dan available count == 5', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final repository = await HadithRepository.load();
      final module5 =
          AppCurriculumStructure.modules.firstWhere((m) => m.number == 5);
      expect(module5.hadithNumbers.length, 5);
      expect(module5.hadithNumbers, [21, 22, 23, 24, 25]);
      final available = repository.availableHadiths
          .where((h) => module5.hadithNumbers.contains(h.number))
          .length;
      expect(available, 5,
          reason: 'Module 5 mesti 5/5 selepas H21-H25 dimuatkan');
    });

    test('H24/H25 narrator canonical sama dengan Abu Dharr H18', () {
      final h18 = Hadith.fromJson(_load('hadith_18.json'));
      final h24 = Hadith.fromJson(_load('hadith_24.json'));
      final h25 = Hadith.fromJson(_load('hadith_25.json'));
      expect(h24.narratorId, 'abu_dharr_jundub_ibn_junadah');
      expect(h25.narratorId, 'abu_dharr_jundub_ibn_junadah');
      expect(h18.narratorIds, contains('abu_dharr_jundub_ibn_junadah'));
      expect(h24.narrator.id, h18.narrator.id,
          reason: 'H24 dan H18 mesti resolve ke objek perawi yang sama');
      expect(h25.narrator.id, h18.narrator.id,
          reason: 'H25 dan H18 mesti resolve ke objek perawi yang sama');
    });

    test('H21-H25 narrator canonical betul', () {
      final expected = {
        '21': 'sufyan_ibn_abdullah_al_thaqafi',
        '22': 'jabir_ibn_abdullah_al_ansari',
        '23': 'al_harith_ibn_asim_al_ashari',
        '24': 'abu_dharr_jundub_ibn_junadah',
        '25': 'abu_dharr_jundub_ibn_junadah',
      };
      for (final entry in expected.entries) {
        final h = Hadith.fromJson(_load('hadith_${entry.key}.json'));
        expect(h.narratorId, entry.value,
            reason: 'Hadis ${entry.key} narrator mesti ${entry.value}');
        expect(h.allNarratorIds, [entry.value]);
      }
    });

    test('Timing count 11/12/14/40/25', () {
      final expected = {
        '21': 11,
        '22': 12,
        '23': 14,
        '24': 40,
        '25': 25,
      };
      for (final entry in expected.entries) {
        final h = Hadith.fromJson(_load('hadith_${entry.key}.json'));
        expect(h.audioTimings.length, entry.value,
            reason: 'Timing count Hadis ${entry.key} mesti ${entry.value}');
      }
    });

    test('wordHighlightMode = phraseOnly', () {
      for (final n in ['21', '22', '23', '24', '25']) {
        final raw = _load('hadith_$n.json');
        final audio = raw['audio'] as Map<String, dynamic>;
        expect(audio['wordHighlightMode'], 'phraseOnly',
            reason: 'Hadis $n mesti phraseOnly');
      }
    });

    test('timedSegments sorted ascending, startMs < endMs, no overlap', () {
      final durations = {
        '21': 19728,
        '22': 26064,
        '23': 36624,
        '24': 112536,
        '25': 62136,
      };
      for (final entry in durations.entries) {
        final h = Hadith.fromJson(_load('hadith_${entry.key}.json'));
        final segments = h.audioTimings;
        for (var i = 0; i < segments.length; i++) {
          expect(segments[i].startMs, lessThan(segments[i].endMs),
              reason: 'Hadis ${entry.key} segmen $i: start < end');
          if (i > 0) {
            expect(segments[i].startMs,
                greaterThanOrEqualTo(segments[i - 1].endMs),
                reason:
                    'Hadis ${entry.key} segmen $i tidak boleh overlap segmen ${i - 1}');
          }
          expect(segments[i].endMs, lessThanOrEqualTo(entry.value),
              reason: 'Hadis ${entry.key} segmen $i endMs <= durationMs');
        }
      }
    });

    test('No رَوَاهُ dalam timedSegments H21-H25 (rujukan kekal statik)', () {
      for (final n in ['21', '22', '23', '24', '25']) {
        final raw = _load('hadith_$n.json');
        final h = Hadith.fromJson(raw);
        for (final segment in h.audioTimings) {
          expect(segment.text.contains('رَوَاهُ'), false,
              reason: 'Hadis $n timedSegment tidak boleh mengandungi رَوَاهُ');
        }
        final referenceArabic = raw['referenceArabic'] as String? ?? '';
        expect(referenceArabic.trim(), isNotEmpty,
            reason: 'Hadis $n mesti ada rujukan statik');
      }
    });

    test('H22 nota maksud lafaz tidak dalam audio transcript', () {
      final raw = _load('hadith_22.json');
      final transcript = raw['audioTranscriptText'] as String? ?? '';
      expect(transcript.contains('وَمَعْنَى حَرَّمْتُ الْحَرَامَ'), false,
          reason: 'Nota maksud lafaz bukan audio transcript');
      expect(transcript.contains('اجْتَنَبْتُهُ'), false);
      expect(transcript.contains('وَمَعْنَى أَحْلَلْتُ الْحَلَالَ'), false);
      expect(transcript.contains('مُعْتَقِدًا حِلَّهُ'), false);
      final h = Hadith.fromJson(raw);
      expect(h.explanations, isNotEmpty,
          reason: 'Nota maksud lafaz dipaparkan sebagai penjelasan statik');
      // Audio transcript berakhir pada نَعَمْ.
      expect(h.audioTimings.last.text, 'نَعَمْ.');
    });

    test('H23 varian تَمْلَآنِ - أَوْ تَمْلَأُ kekal', () {
      final h = Hadith.fromJson(_load('hadith_23.json'));
      expect(h.arabicText.contains('تَمْلَآنِ - أَوْ تَمْلَأُ'), true,
          reason: 'Lafaz variasi mesti kekal dalam teks hadis');
      expect(
          h.audioTimings
              .any((s) => s.text.contains('تَمْلَآنِ - أَوْ تَمْلَأُ')),
          true,
          reason: 'Lafaz variasi mesti kekal dalam timing');
    });

    test('H21 dalil Fussilat 30 dan H25 dalil Ali Imran 110', () {
      final h21 = Hadith.fromJson(_load('hadith_21.json'));
      final h25 = Hadith.fromJson(_load('hadith_25.json'));
      expect(h21.quranEvidence.surah, 'Fussilat');
      expect(h21.quranEvidence.verse, 30);
      expect(h21.allQuranEvidences.length, 1);
      expect(h25.quranEvidence.surah, "Ali 'Imran");
      expect(h25.quranEvidence.verse, 110);
      expect(h25.allQuranEvidences.length, 1);
    });

    test('H24 40 segmen tidak digabung jadi blok besar', () {
      final h = Hadith.fromJson(_load('hadith_24.json'));
      expect(h.audioTimings.length, 40);
      expect(h.audioTimings.last.text, 'فَلَا يَلُومَنَّ إِلَّا نَفْسَهُ.');
    });

    test('Audio assets H21-H25 wujud', () {
      for (final n in ['21', '22', '23', '24', '25']) {
        expect(File('assets/audio/hadith_$n.mp3').existsSync(), true,
            reason: 'assets/audio/hadith_$n.mp3 mesti wujud');
      }
    });

    test('Playlist global mengandungi H21-H25 (susunan naik)', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final repository = await HadithRepository.load();
      final playlist =
          repository.availableHadiths.where((h) => h.audioAsset.isNotEmpty);
      final ids = playlist.map((h) => h.id).toList();
      expect(ids, contains('hadith_21'));
      expect(ids, contains('hadith_22'));
      expect(ids, contains('hadith_23'));
      expect(ids, contains('hadith_24'));
      expect(ids, contains('hadith_25'));
      expect(ids.indexOf('hadith_21'), lessThan(ids.indexOf('hadith_22')));
      expect(ids.indexOf('hadith_22'), lessThan(ids.indexOf('hadith_23')));
      expect(ids.indexOf('hadith_23'), lessThan(ids.indexOf('hadith_24')));
      expect(ids.indexOf('hadith_24'), lessThan(ids.indexOf('hadith_25')));
    });

    test('Narrator repository dedupe: tiada duplicate canonical id', () {
      final narrators =
          jsonDecode(File('assets/data/narrators.json').readAsStringSync())
              as Map<String, dynamic>;
      final ids = narrators.keys.toList();
      expect(ids.toSet().length, ids.length);
      expect(ids, contains('sufyan_ibn_abdullah_al_thaqafi'));
      expect(ids, contains('jabir_ibn_abdullah_al_ansari'));
      expect(ids, contains('al_harith_ibn_asim_al_ashari'));
      expect(ids, contains('abu_dharr_jundub_ibn_junadah'));
    });

    test('Anatomi Sunnah HTML H21-H25 wujud dan guna sumber tempatan', () {
      for (final n in ['21', '22', '23', '24', '25']) {
        final file = File('web/anatomi_sunnah/hadith_$n.html');
        expect(file.existsSync(), true,
            reason: 'web/anatomi_sunnah/hadith_$n.html mesti wujud');
        final content = file.readAsStringSync();
        expect(content.contains('./lib/three.min.js'), true,
            reason: 'H$n mesti guna three.min.js tempatan');
        expect(content.contains('cdn.tailwindcss.com'), false,
            reason: 'H$n tidak boleh guna CDN');
        expect(content.contains('anatomi-back-btn'), true,
            reason: 'H$n mesti ada butang kembali');
        expect(content.contains('applyResponsiveView'), true,
            reason: 'H$n mesti ada responsive view');
      }
    });

    test('AnatomiSunnahScreen.availableHadithNumbers = 25', () {
      final source =
          File('lib/screens/anatomi_sunnah_screen.dart').readAsStringSync();
      expect(source.contains('availableHadithNumbers = 25'), true,
          reason: 'availableHadithNumbers mesti 25 untuk merangkumi H21-H25');
    });
  });
}
