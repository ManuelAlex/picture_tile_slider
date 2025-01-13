// ignore_for_file: unnecessary_getters_setters

import 'package:audioplayers/audioplayers.dart';

class SoundPlayer {
  final AudioPlayer _audioPlayer = AudioPlayer();

  SoundPlayer();
  bool _isSoundEnabled = true;
  bool get isSoundEnabled => _isSoundEnabled;
  set isSoundEnabled(bool value) => _isSoundEnabled = value;

  Future<void> play() async {
    if (_isSoundEnabled) {
      await _audioPlayer.play(AssetSource('sounds/whoosh-fire.wav'),
          position: const Duration(milliseconds: 20));
    }
  }

  Future<void> stop() async {
    if (_isSoundEnabled) {
      await _audioPlayer.stop();
    }
  }

  void toggleSound() {
    isSoundEnabled = !isSoundEnabled;
  }
}
