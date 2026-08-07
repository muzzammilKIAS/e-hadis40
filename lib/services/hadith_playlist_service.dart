import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../data/models/hadith.dart';

class HadithPlaylistService extends ChangeNotifier {
  final List<Hadith> hadiths;

  final AudioPlayer _player = AudioPlayer();

  bool _loading = false;
  bool _ready = false;
  String? _errorMessage;
  double _speed = 1;
  LoopMode _repeatMode = LoopMode.off;
  int _currentIndex = -1;

  HadithPlaylistService({required this.hadiths}) {
    _player.currentIndexStream.listen((index) {
      if (index != null && index != _currentIndex) {
        _currentIndex = index;
        notifyListeners();
      }
    });
  }

  AudioPlayer get player => _player;
  bool get loading => _loading;
  bool get ready => _ready;
  String? get errorMessage => _errorMessage;
  double get speed => _speed;
  LoopMode get repeatMode => _repeatMode;
  int get currentIndex => _currentIndex;
  bool get playing => _player.playing;

  List<Hadith> get validHadiths =>
      hadiths.where((h) => h.audioAsset.isNotEmpty).toList();

  Hadith? get currentHadith {
    final tracks = validHadiths;
    if (currentIndex < 0 || currentIndex >= tracks.length) return null;
    return tracks[currentIndex];
  }

  Future<void> load() async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final tracks = validHadiths;
      if (tracks.isEmpty) {
        _errorMessage = 'Tiada audio hadis tersedia.';
        _loading = false;
        notifyListeners();
        return;
      }

      final sources =
          tracks.map((h) => AudioSource.asset(h.audioAsset)).toList();
      await _player.setAudioSources(sources.map((s) => s).toList());
      await _player.setSpeed(_speed);
      await _player.setLoopMode(_repeatMode);
      _currentIndex = 0;
      _ready = true;
    } catch (_) {
      _errorMessage = 'Gagal memuatkan playlist audio.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> togglePlay() async {
    if (!_ready) return;
    if (_player.playing) {
      await _player.pause();
    } else {
      if (_player.processingState == ProcessingState.completed) {
        await _player.seek(Duration.zero, index: 0);
      }
      await _player.play();
    }
  }

  Future<void> next() async {
    if (!_ready) return;
    await _player.seekToNext();
  }

  Future<void> previous() async {
    if (!_ready) return;
    await _player.seekToPrevious();
  }

  Future<void> skipTo(int index) async {
    if (!_ready) return;
    await _player.seek(Duration.zero, index: index);
    await _player.play();
  }

  Future<void> seek(Duration position) async {
    if (!_ready) return;
    await _player.seek(position);
  }

  Future<void> setSpeed(double value) async {
    _speed = value;
    await _player.setSpeed(value);
    notifyListeners();
  }

  Future<void> setRepeatMode(LoopMode mode) async {
    _repeatMode = mode;
    await _player.setLoopMode(mode);
    notifyListeners();
  }

  Future<void> cycleRepeatMode() async {
    switch (_repeatMode) {
      case LoopMode.off:
        _repeatMode = LoopMode.one;
      case LoopMode.one:
        _repeatMode = LoopMode.all;
      case LoopMode.all:
        _repeatMode = LoopMode.off;
    }
    await _player.setLoopMode(_repeatMode);
    notifyListeners();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
