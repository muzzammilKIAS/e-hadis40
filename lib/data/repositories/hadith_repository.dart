import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/hadith.dart';

class HadithRepository {
  HadithRepository._(this._hadiths);

  final List<Hadith> _hadiths;

  static Future<HadithRepository> load() async {
    const assetPaths = <String>[
      'assets/data/hadith_01.json',
      'assets/data/hadith_02.json',
      'assets/data/hadith_03.json',
      'assets/data/hadith_04.json',
      'assets/data/hadith_05.json',
      'assets/data/hadith_06.json',
      'assets/data/hadith_07.json',
      'assets/data/hadith_08.json',
      'assets/data/hadith_09.json',
      'assets/data/hadith_10.json',
      'assets/data/hadith_11.json',
    ];

    final hadiths = <Hadith>[];
    for (final assetPath in assetPaths) {
      final raw = await rootBundle.loadString(assetPath);
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      hadiths.add(Hadith.fromJson(decoded));
    }
    hadiths.sort((a, b) => a.number.compareTo(b.number));
    return HadithRepository._(hadiths);
  }

  List<Hadith> get availableHadiths => List<Hadith>.unmodifiable(_hadiths);

  Hadith? byNumber(int number) {
    for (final hadith in _hadiths) {
      if (hadith.number == number) return hadith;
    }
    return null;
  }

  Hadith? byId(String id) {
    for (final hadith in _hadiths) {
      if (hadith.id == id) return hadith;
    }
    return null;
  }

  List<Hadith> search(String query) {
    return _hadiths.where((hadith) => hadith.matches(query)).toList();
  }
}
