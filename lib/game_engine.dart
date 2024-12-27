import 'dart:async';

import 'package:flutter/material.dart';



class GameEngine {
  final ValueNotifier<String> _currentTimeNotifier = ValueNotifier('0.00');
 ValueNotifier<String> get currentTimeNotifier=>_currentTimeNotifier;

  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;
  final String _currentTime = '0.00';

  // Expose current time
  String get currentTime => _currentTime;

  bool _pause = false;
  bool get isPaused => _pause;

  // Starts or resumes the game
 void play() {
  _pause = false;
  _stopwatch.start();
  _timer?.cancel();

  _timer = Timer.periodic(const Duration(milliseconds: 100), (Timer callback) {
    final double elapsed = _stopwatch.elapsed.inMilliseconds / 1000;
    final String formattedTime = elapsed.toStringAsFixed(2);
    _currentTimeNotifier.value = formattedTime;
  });
}



  // Stops the game and resets the timer
 void stop() {
  _pause = true;
  _stopwatch.reset(); // Reset the stopwatch.
  _timer?.cancel();
  _currentTimeNotifier.value = '0.00'; // Reset the displayed time.
}

 
  // Pauses the game
  void pause() {
    _pause = true;
    _stopwatch.stop();

    _timer?.cancel();
  }
}
