import 'package:e_hadis40/data/models/hadith.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Hadith model membaca data asas', () {
    final hadith = Hadith.fromJson({
      'id': 'hadith_01',
      'moduleId': 'module_01',
      'hadithNumber': 1,
      'title': 'Keutamaan Niat',
      'narrator': const <String, dynamic>{},
      'quranEvidence': const <String, dynamic>{},
      'progressRules': const <String, dynamic>{'passingScorePercent': 80},
      'audio': const <String, dynamic>{
        'durationMs': 1000,
        'timedSegments': [
          {
            'startMs': 0,
            'endMs': 1000,
            'text': 'إِنَّمَا الْأَعْمَالُ بِالنِّيَّاتِ',
          },
        ],
      },
      'source': const <String, dynamic>{},
    });

    expect(hadith.number, 1);
    expect(hadith.title, 'Keutamaan Niat');
    expect(hadith.passingScorePercent, 80);
    expect(hadith.audioDurationMs, 1000);
    expect(hadith.audioTimings.length, 1);
  });
}
