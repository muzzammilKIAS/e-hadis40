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
  group('Hadis 31-42 (FINAL) integration', () {
    test('Semua H31-H42 load dengan module_07/module_08', () {
      for (final n in ['31', '32', '33', '34', '35', '36']) {
        final h = Hadith.fromJson(_load('hadith_$n.json'));
        expect(h.id, 'hadith_$n', reason: 'ID Hadis $n');
        expect(h.number, int.parse(n));
        expect(h.moduleId, 'module_07', reason: 'Hadis $n mesti module_07');
        expect(h.audioAsset, 'assets/audio/hadith_$n.mp3');
        expect(h.audioTimings, isNotEmpty);
        expect(h.quiz.length, 10);
      }
      for (final n in ['37', '38', '39', '40', '41', '42']) {
        final h = Hadith.fromJson(_load('hadith_$n.json'));
        expect(h.id, 'hadith_$n', reason: 'ID Hadis $n');
        expect(h.number, int.parse(n));
        expect(h.moduleId, 'module_08', reason: 'Hadis $n mesti module_08');
        expect(h.audioAsset, 'assets/audio/hadith_$n.mp3');
        expect(h.audioTimings, isNotEmpty);
        expect(h.quiz.length, 10);
      }
    });

    test('Module 7 denominator == 6 dan available count == 6', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final repository = await HadithRepository.load();
      final module7 =
          AppCurriculumStructure.modules.firstWhere((m) => m.number == 7);
      expect(module7.hadithNumbers.length, 6);
      expect(module7.hadithNumbers, [31, 32, 33, 34, 35, 36]);
      final available = repository.availableHadiths
          .where((h) => module7.hadithNumbers.contains(h.number))
          .length;
      expect(available, 6, reason: 'Module 7 mesti 6/6 selepas H31-H36 dimuatkan');
    });

    test('Module 8 denominator == 6 dan available count == 6', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final repository = await HadithRepository.load();
      final module8 =
          AppCurriculumStructure.modules.firstWhere((m) => m.number == 8);
      expect(module8.hadithNumbers.length, 6);
      expect(module8.hadithNumbers, [37, 38, 39, 40, 41, 42]);
      final available = repository.availableHadiths
          .where((h) => module8.hadithNumbers.contains(h.number))
          .length;
      expect(available, 6, reason: 'Module 8 mesti 6/6 selepas H37-H42 dimuatkan');
    });

    test('Keseluruhan repository = 42 hadis tersedia, tiada duplicate ID', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final repository = await HadithRepository.load();
      expect(repository.availableHadiths.length, 42);
      final ids = repository.availableHadiths.map((h) => h.id).toList();
      expect(ids.toSet().length, ids.length, reason: 'Tiada ID hadis berulang');
      final numbers = repository.availableHadiths.map((h) => h.number).toSet();
      expect(numbers, Set<int>.from(List.generate(42, (i) => i + 1)));
    });

    test('Narrator canonical betul (baharu + REUSE) untuk H31-H42', () {
      final expected = {
        '31': 'sahl_ibn_sad_al_saidi',
        '32': 'abu_said_sad_ibn_malik_al_khudri',
        '33': 'abdullah_ibn_abbas',
        '34': 'abu_said_sad_ibn_malik_al_khudri',
        '35': 'abu_hurairah',
        '36': 'abu_hurairah',
        '37': 'abdullah_ibn_abbas',
        '38': 'abu_hurairah',
        '39': 'abdullah_ibn_abbas',
        '40': 'abdullah_ibn_umar',
        '41': 'abdullah_ibn_amr_ibn_al_as',
        '42': 'anas_ibn_malik',
      };
      for (final entry in expected.entries) {
        final h = Hadith.fromJson(_load('hadith_${entry.key}.json'));
        expect(h.narratorId, entry.value,
            reason: 'Hadis ${entry.key} narrator mesti ${entry.value}');
        expect(h.allNarratorIds, [entry.value]);
      }
    });

    test('Narrator repository dedupe: tiada duplicate canonical id (H1-H42)', () {
      final narrators =
          jsonDecode(File('assets/data/narrators.json').readAsStringSync())
              as Map<String, dynamic>;
      final ids = narrators.keys.toList();
      expect(ids.toSet().length, ids.length);
      expect(ids, contains('sahl_ibn_sad_al_saidi'));
      expect(ids, contains('abu_said_sad_ibn_malik_al_khudri'));
      expect(ids, contains('abdullah_ibn_amr_ibn_al_as'));
    });

    test('Timing count 12/5/8/10/18/26/20/18/7/14/5/14 (jumlah 157)', () {
      final expected = {
        '31': 12,
        '32': 5,
        '33': 8,
        '34': 10,
        '35': 18,
        '36': 26,
        '37': 20,
        '38': 18,
        '39': 7,
        '40': 14,
        '41': 5,
        '42': 14,
      };
      var total = 0;
      for (final entry in expected.entries) {
        final h = Hadith.fromJson(_load('hadith_${entry.key}.json'));
        expect(h.audioTimings.length, entry.value,
            reason: 'Timing count Hadis ${entry.key} mesti ${entry.value}');
        total += h.audioTimings.length;
      }
      expect(total, 157);
    });

    test('wordHighlightMode = phraseOnly untuk H31-H42', () {
      for (var n = 31; n <= 42; n++) {
        final raw = _load('hadith_$n.json');
        final audio = raw['audio'] as Map<String, dynamic>;
        expect(audio['wordHighlightMode'], 'phraseOnly',
            reason: 'Hadis $n mesti phraseOnly');
      }
    });

    test('timedSegments sorted ascending, startMs < endMs, no overlap, end <= duration', () {
      final durations = {
        '31': 27864,
        '32': 13152,
        '33': 18552,
        '34': 21240,
        '35': 40008,
        '36': 59520,
        '37': 46056,
        '38': 42864,
        '39': 15168,
        '40': 31080,
        '41': 13656,
        '42': 35376,
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

    test('No رَوَاهُ dalam timedSegments H31-H42 (rujukan kekal statik)', () {
      for (var n = 31; n <= 42; n++) {
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

    test('H37 commentary Imam Nawawi tidak berada dalam timedSegments/arabicText', () {
      final h37 = Hadith.fromJson(_load('hadith_37.json'));
      expect(h37.audioTimings.length, 20);
      // Matan H37 berakhir pada "سَيِّئَةً وَاحِدَةً." — tiada teks commentary
      // (yang biasanya bermula dengan frasa berbeza/lebih panjang) ditambah selepasnya.
      expect(h37.audioTimings.last.text.trim(), 'وَاحِدَةً.');
      expect(h37.arabicText.trim().endsWith('وَاحِدَةً.'), true,
          reason: 'arabicText H37 mesti tamat pada matan, bukan commentary');
    });

    test('H40 companion statement (pesanan Ibn Umar) kekal', () {
      final h40 = Hadith.fromJson(_load('hadith_40.json'));
      // 14 segmen: 0-5 sabda Nabi SAW ("kun fi al-dunya..."), 6-13 pesanan
      // Ibn Umar r.a. Semak bilangan dan kandungan terus daripada
      // timedSegments (bukan retaip Arab dalam ujian) supaya tiada risiko
      // kesilapan taip diakritik.
      expect(h40.audioTimings.length, 14);
      for (final segment in h40.audioTimings) {
        expect(h40.arabicText.contains(segment.text), true,
            reason: 'Setiap segmen (termasuk pesanan Ibn Umar) mesti kekal '
                'dalam arabicText H40');
      }
      // Segmen ke-9 (indeks 8) ialah pertengahan pesanan Ibn Umar — ia
      // mesti wujud dan berbeza daripada segmen pertama (sabda Nabi SAW),
      // membuktikan companion statement bukan sekadar diulang/dipotong.
      expect(h40.audioTimings[8].text, isNot(equals(h40.audioTimings[0].text)));
    });

    test('H42 dalil al-Quran Ali \'Imran 133 disahkan, bukan fabricated', () {
      final h42 = Hadith.fromJson(_load('hadith_42.json'));
      expect(h42.quranEvidence.surah, "Ali 'Imran");
      expect(h42.quranEvidence.verse, 133);
      expect(h42.allQuranEvidences.length, 1);
    });

    test('Audio assets H31-H42 wujud', () {
      for (var n = 31; n <= 42; n++) {
        expect(File('assets/audio/hadith_$n.mp3').existsSync(), true,
            reason: 'assets/audio/hadith_$n.mp3 mesti wujud');
      }
    });

    test('Global playlist H1-H42 order betul, H42 last track', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final repository = await HadithRepository.load();
      final playlist =
          repository.availableHadiths.where((h) => h.audioAsset.isNotEmpty);
      final numbers = playlist.map((h) => h.number).toList();
      expect(numbers.length, 42);
      for (var n = 1; n < 42; n++) {
        expect(numbers.indexOf(n), lessThan(numbers.indexOf(n + 1)),
            reason: 'Hadis $n mesti sebelum hadis ${n + 1} dalam playlist');
      }
      expect(numbers.last, 42, reason: 'H42 mesti trek terakhir playlist global');
    });

    test('H42 hasNext == false (tiada H43 palsu)', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final repository = await HadithRepository.load();
      expect(repository.byNumber(43), isNull);
      expect(AppCurriculumStructure.totalHadiths, 42);
    });

    test('Navigasi silang modul H36 -> H37 berfungsi', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final repository = await HadithRepository.load();
      final h36 = repository.byNumber(36);
      final h37 = repository.byNumber(37);
      expect(h36, isNotNull);
      expect(h37, isNotNull);
      expect(h36!.moduleId, 'module_07');
      expect(h37!.moduleId, 'module_08');
    });
  });
}
