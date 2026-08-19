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
  group('Hadis 26-30 integration', () {
    test('Semua H26-H30 load dengan module_06', () {
      for (final n in ['26', '27', '28', '29', '30']) {
        final h = Hadith.fromJson(_load('hadith_$n.json'));
        expect(h.id, 'hadith_$n', reason: 'ID Hadis $n');
        expect(h.number, int.parse(n));
        expect(h.moduleId, 'module_06', reason: 'Hadis $n mesti module_06');
        expect(h.audioAsset, 'assets/audio/hadith_$n.mp3');
        expect(h.audioTimings, isNotEmpty);
        expect(h.quiz.length, 10);
      }
    });

    test('Module 6 denominator == 5 dan available count == 5', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final repository = await HadithRepository.load();
      final module6 =
          AppCurriculumStructure.modules.firstWhere((m) => m.number == 6);
      expect(module6.hadithNumbers.length, 5);
      expect(module6.hadithNumbers, [26, 27, 28, 29, 30]);
      final available = repository.availableHadiths
          .where((h) => module6.hadithNumbers.contains(h.number))
          .length;
      expect(available, 5,
          reason: 'Module 6 mesti 5/5 selepas H26-H30 dimuatkan');
    });

    test('Narrator canonical betul, termasuk reuse H26/H29', () {
      final h18 = Hadith.fromJson(_load('hadith_18.json'));
      final h26 = Hadith.fromJson(_load('hadith_26.json'));
      final h27 = Hadith.fromJson(_load('hadith_27.json'));
      final h28 = Hadith.fromJson(_load('hadith_28.json'));
      final h29 = Hadith.fromJson(_load('hadith_29.json'));
      final h30 = Hadith.fromJson(_load('hadith_30.json'));

      expect(h26.narratorId, 'abu_hurairah');
      expect(h27.narratorId, 'al_nawwas_ibn_saman');
      expect(h28.narratorId, 'al_irbad_ibn_sariyah');
      expect(h29.narratorId, 'muadh_ibn_jabal');
      expect(h30.narratorId, 'abu_thalabah_al_khushani');

      // H29 mesti resolve ke perawi kanonik Mu'az yang sama dengan H18.
      expect(h18.narratorIds, contains('muadh_ibn_jabal'));
      expect(h29.narrator.name, contains('Muaz bin Jabal'));
    });

    test('H27 dual-riwayat: al-Nawwas + Wabisah tidak flatten', () {
      final h27 = Hadith.fromJson(_load('hadith_27.json'));
      expect(h27.narratorIds, ['al_nawwas_ibn_saman', 'wabisah_ibn_mabad'],
          reason: 'H27 mesti kekalkan kedua-dua perawi berasingan');
      expect(h27.supplementaryHadiths.length, 1,
          reason: 'Riwayat Wabisah mesti disimpan sebagai supplementaryHadiths berasingan');
      expect(h27.supplementaryHadiths.first.narrator, contains('Wabisah'));
      // Segmen "رَوَاهُ مُسْلِمٌ." (penutup riwayat pertama) kekal dalam
      // timedSegments kerana ia benar-benar dibaca dalam rakaman audio.
      expect(
          h27.audioTimings.any((s) => s.text.trim() == 'رَوَاهُ مُسْلِمٌ.'),
          true,
          reason: 'Penutup riwayat pertama H27 dibaca dalam audio, bukan statik sahaja');
    });

    test('Timing count 13/18/19/48/13', () {
      final expected = {
        '26': 13,
        '27': 18,
        '28': 19,
        '29': 48,
        '30': 13,
      };
      for (final entry in expected.entries) {
        final h = Hadith.fromJson(_load('hadith_${entry.key}.json'));
        expect(h.audioTimings.length, entry.value,
            reason: 'Timing count Hadis ${entry.key} mesti ${entry.value}');
      }
    });

    test('wordHighlightMode = phraseOnly', () {
      for (final n in ['26', '27', '28', '29', '30']) {
        final raw = _load('hadith_$n.json');
        final audio = raw['audio'] as Map<String, dynamic>;
        expect(audio['wordHighlightMode'], 'phraseOnly',
            reason: 'Hadis $n mesti phraseOnly');
      }
    });

    test('timedSegments sorted ascending, startMs < endMs, no overlap', () {
      final durations = {
        '26': 32856,
        '27': 43584,
        '28': 43608,
        '29': 89664,
        '30': 25656,
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

    test('H29 petikan al-Quran (As-Sajdah 16-17) kekal dalam matan/audio', () {
      final h29 = Hadith.fromJson(_load('hadith_29.json'));
      expect(h29.arabicText.contains('تَتَجَافَىٰ جُنُوبُهُمْ عَنِ الْمَضَاجِعِ'), true,
          reason: 'Petikan al-Quran mesti kekal dalam arabicText H29');
      expect(h29.arabicText.contains('يَعْمَلُونَ'), true);
      expect(
          h29.audioTimings.any((s) => s.text.contains('تَتَجَافَىٰ')),
          true,
          reason: 'Petikan al-Quran mesti kekal dalam timedSegments (bukan dibuang)');
      expect(h29.quranEvidence.surah, 'As-Sajdah');
    });

    test('Audio assets H26-H30 wujud', () {
      for (final n in ['26', '27', '28', '29', '30']) {
        expect(File('assets/audio/hadith_$n.mp3').existsSync(), true,
            reason: 'assets/audio/hadith_$n.mp3 mesti wujud');
      }
    });

    test('Playlist global mengandungi H26-H30 (susunan naik)', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final repository = await HadithRepository.load();
      final playlist =
          repository.availableHadiths.where((h) => h.audioAsset.isNotEmpty);
      final ids = playlist.map((h) => h.id).toList();
      for (final n in ['26', '27', '28', '29', '30']) {
        expect(ids, contains('hadith_$n'));
      }
      expect(ids.indexOf('hadith_25'), lessThan(ids.indexOf('hadith_26')));
      expect(ids.indexOf('hadith_26'), lessThan(ids.indexOf('hadith_27')));
      expect(ids.indexOf('hadith_27'), lessThan(ids.indexOf('hadith_28')));
      expect(ids.indexOf('hadith_28'), lessThan(ids.indexOf('hadith_29')));
      expect(ids.indexOf('hadith_29'), lessThan(ids.indexOf('hadith_30')));
    });

    test('Narrator repository dedupe: H26/H29 reuse, tiada duplicate canonical id', () {
      final narrators =
          jsonDecode(File('assets/data/narrators.json').readAsStringSync())
              as Map<String, dynamic>;
      final ids = narrators.keys.toList();
      expect(ids.toSet().length, ids.length);
      expect(ids, contains('abu_hurairah'));
      expect(ids, contains('muadh_ibn_jabal'));
      expect(ids, contains('al_nawwas_ibn_saman'));
      expect(ids, contains('wabisah_ibn_mabad'));
      expect(ids, contains('al_irbad_ibn_sariyah'));
      expect(ids, contains('abu_thalabah_al_khushani'));
    });

    test('Anatomi Sunnah HTML H26-H30 wujud dan guna sumber tempatan', () {
      for (final n in ['26', '27', '28', '29', '30']) {
        final file = File('web/anatomi_sunnah/hadith_$n.html');
        expect(file.existsSync(), true,
            reason: 'web/anatomi_sunnah/hadith_$n.html mesti wujud');
        final content = file.readAsStringSync();
        expect(content.contains('./lib/three.min.js'), true,
            reason: 'H$n mesti guna three.min.js tempatan');
        expect(content.contains('./lib/gsap.min.js'), true,
            reason: 'H$n mesti guna gsap.min.js tempatan');
        expect(content.contains('cdn.tailwindcss.com'), false,
            reason: 'H$n tidak boleh guna CDN Tailwind');
        expect(content.contains('cdnjs.cloudflare.com'), false,
            reason: 'H$n tidak boleh guna CDN cloudflare');
        expect(content.contains('anatomi-back-btn'), true,
            reason: 'H$n mesti ada butang kembali');
        expect(content.contains('applyResponsiveView'), true,
            reason: 'H$n mesti ada responsive view');
      }
    });

    test('AnatomiSunnahScreen.availableHadithSet merangkumi H26-H30', () {
      final source =
          File('lib/screens/anatomi_sunnah_screen.dart').readAsStringSync();
      expect(source.contains('26, 27, 28, 29, 30,'), true,
          reason: 'Hadis 26-30 mesti tersenarai dalam availableHadithSet');
    });
  });
}
