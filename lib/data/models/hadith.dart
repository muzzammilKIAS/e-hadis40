class Hadith {
  const Hadith({
    required this.id,
    this.narratorId,
    required this.moduleId,
    required this.number,
    required this.title,
    required this.subtitle,
    required this.theme,
    required this.arabicText,
    required this.translationMalay,
    required this.narrator,
    required this.reference,
    required this.explanations,
    required this.quranEvidence,
    required this.quranEvidences,
    required this.contextNotice,
    required this.learningIntentionExample,
    required this.lessons,
    required this.appreciation,
    required this.focusValues,
    required this.activities,
    required this.reflectionQuestions,
    required this.quiz,
    required this.passingScorePercent,
    required this.audioAsset,
    required this.audioDurationMs,
    required this.audioSyncOffsetMs,
    required this.wordHighlightMode,
    required this.audioTimings,
    required this.audioTranscriptNote,
    required this.learningObjectives,
    required this.supplications,
    required this.supplementaryHadiths,
    required this.supportingExample,
    required this.copyrightNotice,
    required this.sourceNote,
  });

  final String id;
  final String? narratorId;
  final String moduleId;
  final int number;
  final String title;
  final String subtitle;
  final String theme;
  final String arabicText;
  final String translationMalay;
  final NarratorInfo narrator;
  final String reference;
  final List<String> explanations;
  final QuranEvidence quranEvidence;
  final List<QuranEvidence> quranEvidences;
  final String contextNotice;
  final String learningIntentionExample;
  final List<String> lessons;
  final List<String> appreciation;
  final List<String> focusValues;
  final List<HadithActivity> activities;
  final List<String> reflectionQuestions;
  final List<QuizQuestion> quiz;
  final int passingScorePercent;
  final String audioAsset;
  final int audioDurationMs;
  final int audioSyncOffsetMs;
  final String wordHighlightMode;
  final List<AudioTextSegment> audioTimings;
  final String audioTranscriptNote;
  final List<String> learningObjectives;
  final List<Supplication> supplications;
  final List<SupplementaryHadith> supplementaryHadiths;
  final SupportingExample? supportingExample;
  final String copyrightNotice;
  final String sourceNote;

  String get displayNumber => number.toString().padLeft(2, '0');

  /// Dalil al-Quran: jika quranEvidences wujud → guna semua; jika tidak → fallback quranEvidence tunggal.
  List<QuranEvidence> get allQuranEvidences {
    if (quranEvidences.isNotEmpty) return quranEvidences;
    if (quranEvidence.surah.isNotEmpty) return [quranEvidence];
    return const [];
  }

  factory Hadith.fromJson(Map<String, dynamic> json) {
    final narratorJson = _map(json['narrator']);
    final evidenceJson = _map(json['quranEvidence']);
    final progressJson = _map(json['progressRules']);
    final audioJson = _map(json['audio']);
    final sourceJson = _map(json['source']);

    return Hadith(
      id: json['id'] as String? ?? '',
      narratorId: json['narratorId'] as String?,
      moduleId: json['moduleId'] as String? ?? '',
      number: _int(json['hadithNumber']),
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String? ?? '',
      theme: json['theme'] as String? ?? '',
      arabicText: json['arabicText'] as String? ?? '',
      translationMalay: json['translationMalay'] as String? ?? '',
      narrator: NarratorInfo.fromJson(narratorJson),
      reference: json['reference'] as String? ?? '',
      explanations: _stringList(json['explanations']),
      quranEvidence: QuranEvidence.fromJson(evidenceJson),
      quranEvidences: _list(json['quranEvidences'])
          .map((item) => QuranEvidence.fromJson(_map(item)))
          .toList(growable: false),
      contextNotice: json['contextNotice'] as String? ?? '',
      learningIntentionExample:
          json['learningIntentionExample'] as String? ?? '',
      lessons: _stringList(json['lessons']),
      appreciation: _stringList(json['appreciation']),
      focusValues: _stringList(json['focusValues']),
      activities: _list(json['suggestedActivities'])
          .map((item) => HadithActivity.fromJson(_map(item)))
          .toList(growable: false),
      reflectionQuestions: _stringList(json['reflectionQuestions']),
      quiz: _list(json['quiz'])
          .map((item) => QuizQuestion.fromJson(_map(item)))
          .toList(growable: false),
      passingScorePercent:
          _int(progressJson['passingScorePercent'], fallback: 80),
      audioAsset: audioJson['arabicRecitation'] as String? ?? '',
      audioDurationMs: _int(audioJson['durationMs']),
      audioSyncOffsetMs: _int(audioJson['syncOffsetMs']),
      wordHighlightMode: audioJson['wordHighlightMode'] as String? ?? '',
      audioTimings: _list(audioJson['timedSegments'])
          .map((item) => AudioTextSegment.fromJson(_map(item)))
          .toList(growable: false),
      audioTranscriptNote: json['audioTranscriptNote'] as String? ?? '',
      learningObjectives: _stringList(json['learningObjectives']),
      supplications: _list(json['supplications'])
          .map((item) => Supplication.fromJson(_map(item)))
          .toList(growable: false),
      supplementaryHadiths: _list(json['supplementaryHadiths'])
          .map((item) => SupplementaryHadith.fromJson(_map(item)))
          .toList(growable: false),
      supportingExample: json['supportingExample'] != null
          ? SupportingExample.fromJson(_map(json['supportingExample']))
          : null,
      copyrightNotice: json['copyrightNotice'] as String? ?? '',
      sourceNote: sourceJson['verificationNote'] as String? ?? '',
    );
  }

  bool matches(String query) {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return true;
    return number.toString() == normalized ||
        title.toLowerCase().contains(normalized) ||
        subtitle.toLowerCase().contains(normalized) ||
        theme.toLowerCase().contains(normalized) ||
        translationMalay.toLowerCase().contains(normalized) ||
        focusValues.any((value) => value.toLowerCase().contains(normalized));
  }

  static Map<String, dynamic> _map(dynamic value) {
    return value is Map<String, dynamic> ? value : const <String, dynamic>{};
  }

  static List<dynamic> _list(dynamic value) {
    return value is List<dynamic> ? value : const <dynamic>[];
  }

  static List<String> _stringList(dynamic value) {
    return _list(value).map((item) => item.toString()).toList(growable: false);
  }

  static int _int(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}

class AudioTextSegment {
  const AudioTextSegment({
    required this.startMs,
    required this.endMs,
    required this.text,
    this.words = const [],
  });

  final int startMs;
  final int endMs;
  final String text;
  final List<TimedWord> words;

  Duration get start => Duration(milliseconds: startMs);
  Duration get end => Duration(milliseconds: endMs);

  bool get hasWordTimings => words.isNotEmpty;

  factory AudioTextSegment.fromJson(Map<String, dynamic> json) {
    final wordsList = Hadith._list(json['words']);
    return AudioTextSegment(
      startMs: Hadith._int(json['startMs']),
      endMs: Hadith._int(json['endMs']),
      text: json['text'] as String? ?? '',
      words: wordsList
          .map((item) => TimedWord.fromJson(Hadith._map(item)))
          .toList(growable: false),
    );
  }
}

class TimedWord {
  const TimedWord({
    required this.text,
    required this.startMs,
    required this.endMs,
  });

  final String text;
  final int startMs;
  final int endMs;

  Duration get start => Duration(milliseconds: startMs);
  Duration get end => Duration(milliseconds: endMs);

  factory TimedWord.fromJson(Map<String, dynamic> json) {
    return TimedWord(
      text: json['text'] as String? ?? '',
      startMs: Hadith._int(json['startMs']),
      endMs: Hadith._int(json['endMs']),
    );
  }
}

class NarratorInfo {
  const NarratorInfo({
    required this.id,
    required this.name,
    required this.fullName,
    required this.title,
    required this.shortBiography,
    required this.tags,
    required this.source,
    required this.verified,
  });

  final String id;
  final String name;
  final String fullName;
  final String title;
  final String shortBiography;
  final List<String> tags;
  final String source;
  final bool verified;

  factory NarratorInfo.fromJson(Map<String, dynamic> json) {
    return NarratorInfo(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      title: json['title'] as String? ?? '',
      shortBiography: json['shortBiography'] as String? ?? '',
      tags: json['tags'] is List
          ? List<String>.from(json['tags'] as List)
          : const <String>[],
      source: json['source'] as String? ?? '',
      verified: json['verified'] as bool? ?? false,
    );
  }

  String get safeSummary {
    if (verified && shortBiography.trim().isNotEmpty) return shortBiography;
    return 'Maklumat ringkas perawi sedang dilengkapkan selepas proses semakan.';
  }
}

class QuranEvidence {
  const QuranEvidence({
    required this.surah,
    required this.verse,
    required this.verseEnd,
    required this.arabicText,
    required this.translationMalay,
  });

  final String surah;
  final int verse;
  final int verseEnd;
  final String arabicText;
  final String translationMalay;

  String get verseLabel {
    if (verseEnd > verse) return 'ayat $verse–$verseEnd';
    return 'ayat $verse';
  }

  factory QuranEvidence.fromJson(Map<String, dynamic> json) {
    return QuranEvidence(
      surah: json['surah'] as String? ?? '',
      verse: json['verse'] is int ? json['verse'] as int : 0,
      verseEnd: json['verseEnd'] is int ? json['verseEnd'] as int : 0,
      arabicText: json['arabicText'] as String? ?? '',
      translationMalay: json['translationMalay'] as String? ?? '',
    );
  }
}

class HadithActivity {
  const HadithActivity({required this.title, required this.description});

  final String title;
  final String description;

  factory HadithActivity.fromJson(Map<String, dynamic> json) {
    return HadithActivity(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }
}

class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
  });

  final String id;
  final String question;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    final options = json['options'] is List<dynamic>
        ? (json['options'] as List<dynamic>)
            .map((item) => item.toString())
            .toList(growable: false)
        : const <String>[];
    return QuizQuestion(
      id: json['id'] as String? ?? '',
      question: json['question'] as String? ?? '',
      options: options,
      correctAnswerIndex: json['correctAnswerIndex'] is int
          ? json['correctAnswerIndex'] as int
          : 0,
      explanation: json['explanation'] as String? ?? '',
    );
  }
}

class Supplication {
  const Supplication({
    required this.id,
    required this.title,
    required this.arabic,
    required this.translationMalay,
    required this.reference,
  });

  final String id;
  final String title;
  final String arabic;
  final String translationMalay;
  final String reference;

  factory Supplication.fromJson(Map<String, dynamic> json) {
    return Supplication(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      arabic: json['arabic'] as String? ?? '',
      translationMalay: json['translationMalay'] as String? ?? '',
      reference: json['reference'] as String? ?? '',
    );
  }
}

class SupplementaryHadith {
  const SupplementaryHadith({
    required this.id,
    required this.title,
    required this.narrator,
    required this.arabic,
    required this.translationMalay,
    required this.reference,
  });

  final String id;
  final String title;
  final String narrator;
  final String arabic;
  final String translationMalay;
  final String reference;

  factory SupplementaryHadith.fromJson(Map<String, dynamic> json) {
    return SupplementaryHadith(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      narrator: json['narrator'] as String? ?? '',
      arabic: json['arabic'] as String? ?? '',
      translationMalay: json['translationMalay'] as String? ?? '',
      reference: json['reference'] as String? ?? '',
    );
  }
}

class SupportingExample {
  const SupportingExample({
    required this.title,
    required this.description,
    required this.reference,
    required this.sourceNote,
  });

  final String title;
  final String description;
  final String reference;
  final String sourceNote;

  factory SupportingExample.fromJson(Map<String, dynamic> json) {
    return SupportingExample(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      reference: json['reference'] as String? ?? '',
      sourceNote: json['sourceNote'] as String? ?? '',
    );
  }
}
