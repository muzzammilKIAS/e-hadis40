import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../data/models/hadith.dart';
import 'audio_arbitration.dart';

enum GlobalRepeatMode { off, one, all }

class GlobalHadithAudioController extends ChangeNotifier {
  static final GlobalHadithAudioController _instance =
      GlobalHadithAudioController._();
  factory GlobalHadithAudioController() => _instance;
  GlobalHadithAudioController._();

  final AudioPlayer player = AudioPlayer();

  List<Hadith> _playlist = [];
  int _currentIndex = -1;

  bool _loading = false;
  bool _ready = false;
  String? _errorMessage;
  double _speed = 1;
  GlobalRepeatMode _repeatMode = GlobalRepeatMode.off;
  bool _autoNext = false;

  StreamSubscription<int?>? _currentIndexSub;

  AudioPlayer get playerRef => player;
  bool get loading => _loading;
  bool get ready => _ready;
  String? get errorMessage => _errorMessage;
  double get speed => _speed;
  GlobalRepeatMode get repeatMode => _repeatMode;
  bool get autoNext => _autoNext;
  int get currentIndex => _currentIndex;
  bool get playing => player.playing;

  List<Hadith> get playlist => List.unmodifiable(_playlist);

  Hadith? get currentHadith {
    if (_currentIndex < 0 || _currentIndex >= _playlist.length) return null;
    return _playlist[_currentIndex];
  }

  String? get currentHadithId => currentHadith?.id;

  bool get hasPrev => _currentIndex > 0;
  bool get hasNext => _currentIndex < _playlist.length - 1;

  void init(List<Hadith> hadiths) {
    _playlist =
        hadiths.where((h) => h.audioAsset.isNotEmpty).toList(growable: false);

    AudioArbitration.registerGlobalPauser(pauseForLocal);

    _currentIndexSub?.cancel();
    _currentIndexSub = player.currentIndexStream.listen((index) {
      if (index != null && index != _currentIndex) {
        _currentIndex = index;
        notifyListeners();
      }
    });

    player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _onTrackCompleted();
      }
      // Setiap perubahan play/pause mesti memberitahu UI (AppBar quick controls)
      notifyListeners();
    });

    _loadPlaylist();
  }

  Future<void> _loadPlaylist() async {
    if (_playlist.isEmpty) return;
    _loading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final sources =
          _playlist.map((h) => AudioSource.asset(h.audioAsset)).toList();
      await player.setAudioSources(sources);
      await player.setSpeed(_speed);
      await _applyLoopMode();
      _currentIndex = 0;
      _ready = true;
    } catch (_) {
      _errorMessage = 'Gagal memuatkan playlist audio.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void _onTrackCompleted() {
    if (_repeatMode == GlobalRepeatMode.one) {
      player.seek(Duration.zero);
      player.play();
      return;
    }
    if (_autoNext && hasNext) {
      next();
      return;
    }
    notifyListeners();
  }

  /// Dipanggil arbitration apabila LOCAL audio mahu bermain.
  /// Pause global TANPA reset position (resume boleh berlaku kemudian).
  Future<void> pauseForLocal() async {
    if (player.playing) {
      await player.pause();
      notifyListeners();
    }
  }

  Future<void> playHadith(Hadith hadith) async {
    if (!_ready) return;
    final idx = _playlist.indexWhere((h) => h.id == hadith.id);
    if (idx < 0) return;
    await AudioArbitration.globalStarting();
    if (_currentIndex != idx) {
      await player.seek(Duration.zero, index: idx);
    } else if (player.processingState == ProcessingState.completed) {
      await player.seek(Duration.zero);
    }
    await player.play();
    notifyListeners();
  }

  Future<void> togglePlay() async {
    if (!_ready) return;
    if (player.playing) {
      await player.pause();
    } else {
      if (player.processingState == ProcessingState.completed) {
        await player.seek(Duration.zero);
      }
      await AudioArbitration.globalStarting();
      await player.play();
    }
    notifyListeners();
  }

  Future<void> next() async {
    if (!_ready || !hasNext) return;
    await AudioArbitration.globalStarting();
    await player.seekToNext();
    await player.play();
    notifyListeners();
  }

  Future<void> previous() async {
    if (!_ready || !hasPrev) return;
    await AudioArbitration.globalStarting();
    await player.seekToPrevious();
    await player.play();
    notifyListeners();
  }

  Future<void> skipTo(int index) async {
    if (!_ready || index < 0 || index >= _playlist.length) return;
    await AudioArbitration.globalStarting();
    await player.seek(Duration.zero, index: index);
    await player.play();
    notifyListeners();
  }

  Future<void> seek(Duration position) async {
    if (!_ready) return;
    await player.seek(position);
  }

  Future<void> setSpeed(double value) async {
    _speed = value;
    await player.setSpeed(value);
    notifyListeners();
  }

  Future<void> setRepeatMode(GlobalRepeatMode mode) async {
    _repeatMode = mode;
    await _applyLoopMode();
    notifyListeners();
  }

  Future<void> cycleRepeatMode() async {
    switch (_repeatMode) {
      case GlobalRepeatMode.off:
        _repeatMode = GlobalRepeatMode.one;
      case GlobalRepeatMode.one:
        _repeatMode = GlobalRepeatMode.all;
      case GlobalRepeatMode.all:
        _repeatMode = GlobalRepeatMode.off;
    }
    await _applyLoopMode();
    notifyListeners();
  }

  Future<void> setAutoNext(bool value) async {
    _autoNext = value;
    notifyListeners();
  }

  Future<void> _applyLoopMode() async {
    switch (_repeatMode) {
      case GlobalRepeatMode.off:
        await player.setLoopMode(LoopMode.off);
      case GlobalRepeatMode.one:
        await player.setLoopMode(LoopMode.one);
      case GlobalRepeatMode.all:
        await player.setLoopMode(LoopMode.all);
    }
  }

  Future<void> stop() async {
    await player.stop();
    _ready = false;
    _currentIndex = -1;
    notifyListeners();
  }

  @override
  void dispose() {
    _currentIndexSub?.cancel();
    player.dispose();
    super.dispose();
  }
}
