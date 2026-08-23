import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  static const Map<String, String> soundAssets = {
    'Monsoon Breath': 'sounds/Monsoon_Breath.wav',
    'Morning at the Ghat': 'sounds/Morning_at_the_Ghat.wav',
    'The Breathing Tide': 'sounds/The_Breathing_Tide.wav',
  };

  Future<void> playAmbientSound(String selectedSound, double volume) async {
    if (selectedSound != 'None' && soundAssets.containsKey(selectedSound)) {
      try {
        await _audioPlayer.setVolume(volume);
        await _audioPlayer.setReleaseMode(ReleaseMode.loop);
        await _audioPlayer.play(AssetSource(soundAssets[selectedSound]!));
      } catch (e) {
        debugPrint('Error playing sound: $e');
      }
    }
  }

  Future<void> stopAmbientSound() async {
    try {
      if (_audioPlayer.state == PlayerState.playing) {
        await _audioPlayer.stop();
      }
    } catch (e) {
      debugPrint('Error stopping sound: $e');
    }
  }

  Future<void> setVolume(double volume) async {
    try {
      await _audioPlayer.setVolume(volume);
    } catch (e) {
      debugPrint('Error setting volume: $e');
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
