import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../models/narrator_profile.dart';

class NarratorRepository {
  NarratorRepository._(this._profiles);
  final Map<String, NarratorProfile> _profiles;

  static Future<NarratorRepository> load() async {
    final raw = await rootBundle.loadString('assets/data/narrators.json');
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final profiles = <String, NarratorProfile>{};
    for (final entry in decoded.entries) {
      final map = _asMap(entry.value);
      profiles[entry.key] = NarratorProfile.fromJson(map);
    }
    return NarratorRepository._(profiles);
  }

  NarratorProfile? byId(String id) => _profiles[id];

  Map<String, NarratorProfile> get all => Map.unmodifiable(_profiles);

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    return {};
  }
}
