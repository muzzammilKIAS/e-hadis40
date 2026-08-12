import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import 'audio_arbitration.dart';

/// Route-scoped LOCAL audio untuk HadithScreen / Projector.
/// Memiliki AudioPlayer sendiri. Dispose = stop + reset.
/// Sebelum bermain, arbitrasi: pause GLOBAL + stop local lain.
class HadithLocalAudioController extends ChangeNotifier {
  final AudioPlayer player = AudioPlayer();

  bool _loading = false;
  bool _ready = false;
  String? _errorMessage;
  double _speed = 1;
  bool _repeat = false;

  bool get loading => _loading;
  bool get ready => _ready;
  String? get errorMessage => _errorMessage;
  double get speed => _speed;
  bool get repeat => _repeat;

  Future<void> load(String assetPath) async {
    if (assetPath.trim().isEmpty) {
      _ready = false;
      _errorMessage = 'Audio bacaan sedang disediakan.';
      notifyListeners();
      return;
    }

    _loading = true;
    _ready = false;
    _errorMessage = null;
    notifyListeners();

    try {
      await player.stop();
      await player.setAsset(assetPath);
      await player.setSpeed(_speed);
      await player.setLoopMode(_repeat ? LoopMode.one : LoopMode.off);
      _ready = true;
    } catch (_) {
      _errorMessage = 'Gagal memuatkan audio.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> play() async {
    if (!_ready) return;
    await AudioArbitration.localStarting();
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
      await AudioArbitration.localStarting();
      await player.play();
    }
    notifyListeners();
  }

  Future<void> seek(Duration position) async {
    if (!_ready) return;
    await player.seek(position);
  }

  /// Seek ke segment dan pastikan track ini yang bermain.
  Future<void> seekAndPlay(Duration position) async {
    if (!_ready) return;
    await AudioArbitration.localStarting();
    await player.seek(position);
    await player.play();
    notifyListeners();
  }

  Future<void> setSpeed(double value) async {
    _speed = value;
    await player.setSpeed(value);
    notifyListeners();
  }

  Future<void> toggleRepeat() async {
    _repeat = !_repeat;
    await player.setLoopMode(_repeat ? LoopMode.one : LoopMode.off);
    notifyListeners();
  }

  Future<void> replay() async {
    if (!_ready) return;
    await AudioArbitration.localStarting();
    await player.seek(Duration.zero);
    await player.play();
    notifyListeners();
  }

  /// Dipanggil oleh arbitration apabila local lain/global mahu bermain.
  void stopSilent() {
    if (player.playing) {
      player.pause();
    }
  }

  Future<void> stop() async {
    await player.stop();
    notifyListeners();
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }
}
