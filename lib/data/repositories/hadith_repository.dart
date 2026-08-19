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
      'assets/data/hadith_12.json',
      'assets/data/hadith_13.json',
      'assets/data/hadith_14.json',
      'assets/data/hadith_15.json',
      'assets/data/hadith_16.json',
      'assets/data/hadith_17.json',
      'assets/data/hadith_18.json',
      'assets/data/hadith_19.json',
      'assets/data/hadith_20.json',
      'assets/data/hadith_21.json',
      'assets/data/hadith_22.json',
      'assets/data/hadith_23.json',
      'assets/data/hadith_24.json',
      'assets/data/hadith_25.json',
      'assets/data/hadith_26.json',
      'assets/data/hadith_27.json',
      'assets/data/hadith_28.json',
      'assets/data/hadith_29.json',
      'assets/data/hadith_30.json',
      'assets/data/hadith_31.json',
      'assets/data/hadith_32.json',
      'assets/data/hadith_33.json',
      'assets/data/hadith_34.json',
      'assets/data/hadith_35.json',
      'assets/data/hadith_36.json',
      'assets/data/hadith_37.json',
      'assets/data/hadith_38.json',
      'assets/data/hadith_39.json',
      'assets/data/hadith_40.json',
      'assets/data/hadith_41.json',
      'assets/data/hadith_42.json',
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
