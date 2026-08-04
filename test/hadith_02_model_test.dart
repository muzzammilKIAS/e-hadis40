import 'dart:convert';

import 'package:e_hadis40/data/models/hadith.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Hadith 2 model parses essential fields', () {
    final decoded = jsonDecode(_sampleJson) as Map<String, dynamic>;
    final hadith = Hadith.fromJson(decoded);

    expect(hadith.number, 2);
    expect(hadith.title, 'Islam, Iman dan Ihsan');
    expect(hadith.focusValues, contains('Ihsan'));
    expect(hadith.quiz.length, 1);
    expect(hadith.audioAsset, 'assets/audio/hadith_02.mp3');
    expect(hadith.audioTimings, hasLength(1));
  });
}

const _sampleJson = '''
{
  "id": "hadith_02",
  "moduleId": "module_01",
  "hadithNumber": 2,
  "title": "Islam, Iman dan Ihsan",
  "subtitle": "Tiga teras agama.",
  "theme": "Islam, iman dan ihsan",
  "arabicText": "نص",
  "translationMalay": "Terjemahan",
  "narrator": {
    "name": "Umar bin al-Khattab r.a.",
    "fullName": "Umar bin al-Khattab r.a.",
    "title": "",
    "shortBiography": "",
    "source": "",
    "verified": false
  },
  "reference": "Riwayat Muslim",
  "explanations": ["Huraian"],
  "quranEvidence": {
    "surah": "al-A'raf",
    "verse": 187,
    "translationMalay": "Ringkasan"
  },
  "learningIntentionExample": "",
  "lessons": ["Pengajaran"],
  "appreciation": ["Penghayatan"],
  "focusValues": ["Ihsan"],
  "suggestedActivities": [
    {"title": "Halaqah", "description": "Aktiviti"}
  ],
  "reflectionQuestions": ["Soalan"],
  "quiz": [
    {
      "id": "q1",
      "question": "Soalan?",
      "options": ["A", "B", "C", "D"],
      "correctAnswerIndex": 0,
      "explanation": "Penerangan"
    }
  ],
  "progressRules": {"passingScorePercent": 80},
  "audio": {
    "arabicRecitation": "assets/audio/hadith_02.mp3",
    "durationMs": 128800,
    "syncOffsetMs": 0,
    "timedSegments": [
      {
        "startMs": 0,
        "endMs": 2100,
        "text": "عَنْ عُمَرَ"
      }
    ]
  },
  "source": {"verificationNote": "Semakan"}
}
''';
