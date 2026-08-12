import 'package:flutter/foundation.dart';

/// Coordinator ringan untuk memastikan hanya SATU audio berbunyi pada satu
/// masa. GLOBAL (Audio Semua Hadis) = pause sahaja, position disimpan.
/// LOCAL (HadithScreen/Projector) = stop + reset (route-scoped).
class AudioArbitration {
  static final List<VoidCallback> _localStoppers = [];
  static Future<void> Function()? _globalPauser;

  static void registerLocalStopper(VoidCallback stop) {
    if (!_localStoppers.contains(stop)) _localStoppers.add(stop);
  }

  static void unregisterLocalStopper(VoidCallback stop) {
    _localStoppers.remove(stop);
  }

  static void registerGlobalPauser(Future<void> Function() pauser) {
    _globalPauser = pauser;
  }

  /// Local (Hadith/Projector) mahu bermain → pause global, stop local lain.
  static Future<void> localStarting() async {
    final pauser = _globalPauser;
    if (pauser != null) await pauser();
    for (final stop in List.of(_localStoppers)) {
      stop();
    }
  }

  /// Global (Audio Semua Hadis) mahu bermain → stop semua local.
  static Future<void> globalStarting() async {
    for (final stop in List.of(_localStoppers)) {
      stop();
    }
  }
}
