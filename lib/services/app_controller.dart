import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/learning_module.dart';

class AppController extends ChangeNotifier {
  static const _themeKey = 'e_hadis40_theme_mode';
  static const _bookmarksKey = 'e_hadis40_bookmarks';
  static const _completedKey = 'e_hadis40_completed';
  static const _openedKey = 'e_hadis40_opened';
  static const _scoresKey = 'e_hadis40_scores';
  static const _notesKey = 'e_hadis40_notes';
  static const _arabicScaleKey = 'e_hadis40_arabic_scale';
  static const _teacherModeKey = 'e_hadis40_teacher_mode';
  static const _lastHadithKey = 'e_hadis40_last_hadith';
  static const _disclaimerAcceptedKey = 'e_hadis40_disclaimer_accepted';

  late SharedPreferences _preferences;

  ThemeMode _themeMode = ThemeMode.system;
  final Set<String> _bookmarks = <String>{};
  final Set<String> _completed = <String>{};
  final Set<String> _opened = <String>{};
  final Map<String, int> _bestScores = <String, int>{};
  final Map<String, String> _notes = <String, String>{};
  double _arabicScale = 1;
  bool _teacherMode = false;
  String? _lastHadithId;
  bool _disclaimerAccepted = false;

  ThemeMode get themeMode => _themeMode;
  Set<String> get bookmarks => Set<String>.unmodifiable(_bookmarks);
  Set<String> get completed => Set<String>.unmodifiable(_completed);
  Set<String> get opened => Set<String>.unmodifiable(_opened);
  double get arabicScale => _arabicScale;
  bool get teacherMode => _teacherMode;
  String? get lastHadithId => _lastHadithId;
  bool get disclaimerAccepted => _disclaimerAccepted;

  double get overallProgress =>
      (_completed.length / 40).clamp(0.0, 1.0).toDouble();

  Future<void> initialize() async {
    _preferences = await SharedPreferences.getInstance();
    _themeMode = _decodeTheme(_preferences.getString(_themeKey));
    _bookmarks.addAll(_preferences.getStringList(_bookmarksKey) ?? const []);
    _completed.addAll(_preferences.getStringList(_completedKey) ?? const []);
    _opened.addAll(_preferences.getStringList(_openedKey) ?? const []);
    _bestScores.addAll(_decodeIntMap(_preferences.getString(_scoresKey)));
    _notes.addAll(_decodeStringMap(_preferences.getString(_notesKey)));
    _arabicScale = _preferences.getDouble(_arabicScaleKey) ?? 1;
    _teacherMode = _preferences.getBool(_teacherModeKey) ?? false;
    _lastHadithId = _preferences.getString(_lastHadithKey);
    _disclaimerAccepted = _preferences.getBool(_disclaimerAcceptedKey) ?? false;
  }

  bool isBookmarked(String id) => _bookmarks.contains(id);
  bool isCompleted(String id) => _completed.contains(id);
  int bestScore(String id) => _bestScores[id] ?? 0;
  String noteFor(String id) => _notes[id] ?? '';

  double moduleProgress(LearningModule module) {
    final completedCount = module.hadithNumbers
        .where((number) =>
            _completed.contains('hadith_${number.toString().padLeft(2, '0')}'))
        .length;
    return completedCount / module.hadithNumbers.length;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    await _preferences.setString(_themeKey, mode.name);
  }

  Future<void> toggleBookmark(String id) async {
    if (!_bookmarks.add(id)) _bookmarks.remove(id);
    notifyListeners();
    await _preferences.setStringList(
        _bookmarksKey, _bookmarks.toList()..sort());
  }

  Future<void> markOpened(String id) async {
    _opened.add(id);
    _lastHadithId = id;
    notifyListeners();
    await _preferences.setStringList(_openedKey, _opened.toList()..sort());
    await _preferences.setString(_lastHadithKey, id);
  }

  Future<void> markCompleted(String id) async {
    _completed.add(id);
    _lastHadithId = id;
    notifyListeners();
    await _preferences.setStringList(
        _completedKey, _completed.toList()..sort());
    await _preferences.setString(_lastHadithKey, id);
  }

  Future<void> saveQuizScore(String id, int score) async {
    if (score <= bestScore(id)) return;
    _bestScores[id] = score;
    notifyListeners();
    await _preferences.setString(_scoresKey, jsonEncode(_bestScores));
  }

  Future<void> saveNote(String id, String note) async {
    final normalized = note.trim();
    if (normalized.isEmpty) {
      _notes.remove(id);
    } else {
      _notes[id] = normalized;
    }
    notifyListeners();
    await _preferences.setString(_notesKey, jsonEncode(_notes));
  }

  Future<void> setArabicScale(double value) async {
    _arabicScale = value.clamp(0.8, 1.6).toDouble();
    notifyListeners();
    await _preferences.setDouble(_arabicScaleKey, _arabicScale);
  }

  Future<void> setTeacherMode(bool value) async {
    _teacherMode = value;
    notifyListeners();
    await _preferences.setBool(_teacherModeKey, value);
  }

  Future<void> resetLearningData() async {
    _bookmarks.clear();
    _completed.clear();
    _opened.clear();
    _bestScores.clear();
    _notes.clear();
    _lastHadithId = null;
    notifyListeners();
    await _preferences.remove(_bookmarksKey);
    await _preferences.remove(_completedKey);
    await _preferences.remove(_openedKey);
    await _preferences.remove(_scoresKey);
    await _preferences.remove(_notesKey);
    await _preferences.remove(_lastHadithKey);
  }

  Future<void> acceptDisclaimer() async {
    _disclaimerAccepted = true;
    notifyListeners();
    await _preferences.setBool(_disclaimerAcceptedKey, true);
  }

  ThemeMode _decodeTheme(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Map<String, int> _decodeIntMap(String? value) {
    if (value == null || value.isEmpty) return <String, int>{};
    try {
      final decoded = jsonDecode(value) as Map<String, dynamic>;
      return decoded.map((key, item) => MapEntry(key, (item as num).toInt()));
    } catch (_) {
      return <String, int>{};
    }
  }

  Map<String, String> _decodeStringMap(String? value) {
    if (value == null || value.isEmpty) return <String, String>{};
    try {
      final decoded = jsonDecode(value) as Map<String, dynamic>;
      return decoded.map((key, item) => MapEntry(key, item.toString()));
    } catch (_) {
      return <String, String>{};
    }
  }
}
