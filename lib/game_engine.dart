import 'dart:async';

import 'package:flutter/material.dart';
import 'package:picture_tile_slider/sound_player.dart';

class GameEngine {
  final ValueNotifier<Duration> _currentTimeNotifier =
      ValueNotifier(Duration.zero);
  ValueNotifier<Duration> get currentTimeNotifier => _currentTimeNotifier;

  final Stopwatch _stopwatch = Stopwatch();
  final SoundPlayer soundPlayer = SoundPlayer();
  Timer? _timer;
  // final String _currentTime = '0.00';

  // // Expose current time
  // String get currentTime => _currentTime;

  bool _pause = false;
  bool get isPaused => _pause;

  // Starts or resumes the game
  void play() {
    _pause = false;
    _stopwatch.start();
    _timer?.cancel();

    _timer =
        Timer.periodic(const Duration(milliseconds: 100), (Timer callback) {
      final Duration elapsed = _stopwatch.elapsed;
      _currentTimeNotifier.value = elapsed;
    });
    soundPlayer.isSoundEnabled = true;
  }

  // Stops the game and resets the timer
  void stop() {
    _pause = true;
    _stopwatch.reset(); // Reset the stopwatch.
    _timer?.cancel();
    _currentTimeNotifier.value = Duration.zero; // Reset the displayed time.
    soundPlayer.isSoundEnabled = false;
  }

  // Pauses the game
  void pause() {
    _pause = true;
    _stopwatch.stop();
    soundPlayer.isSoundEnabled = false;
    _timer?.cancel();
  }
}
