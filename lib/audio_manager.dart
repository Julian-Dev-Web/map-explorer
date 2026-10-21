import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart'; // For debug print

// GLOBAL PLAYERS
final AudioPlayer globalBgmPlayer = AudioPlayer();
final AudioPlayer globalSfxPlayer = AudioPlayer();

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;

  AudioManager._internal() {
    _initAudioContext();
  }

  // --- AUDIO MIXING SETUP (SAFE VERSION) ---
  Future<void> _initAudioContext() async {
    try {
      await AudioPlayer.global.setAudioContext(AudioContext(
        android: AudioContextAndroid(
          isSpeakerphoneOn: true,
          stayAwake: true,
          contentType: AndroidContentType.music,
          usageType: AndroidUsageType.game,
          audioFocus: AndroidAudioFocus.none,
        ),
        iOS: AudioContextIOS(
          // 'ambient' allows mixing, 'playback' stops other music. 
          // Use 'ambient' for games usually, or 'playback' if you want it distinct.
          category: AVAudioSessionCategory.ambient, 
          options: {
            AVAudioSessionOptions.mixWithOthers,
            AVAudioSessionOptions.duckOthers
          },
        ),
      ));
    } catch (e) {
      debugPrint("Error setting AudioContext: $e");
    }
  }

  // VOLUME VARIABLES
  double _bgmVolume = 0.5;
  double _sfxVolume = 1.0;

  double get currentBgmVolume => _bgmVolume;
  double get currentSfxVolume => _sfxVolume;

  // --- 1. SMART PLAY MUSIC ---
  Future<void> playBGM() async {
    // Kung nagpe-play na, wag na ulitin para di magpatong
    if (globalBgmPlayer.state == PlayerState.playing) {
      return; 
    }

    try {
      print("🚀 Starting BGM...");
      await globalBgmPlayer.setReleaseMode(ReleaseMode.loop);
      
      // IMPORTANT: Siguraduhin na 'assets/audio/snd_bgm_menu.mp3' ay tama
      await globalBgmPlayer.play(AssetSource('audio/snd_bgm_menu.mp3'));
      await globalBgmPlayer.setVolume(_bgmVolume);
    } catch (e) {
      print("❌ ERROR PLAYING BGM: $e");
    }
  }

  // --- 2. PLAY SOUND EFFECT (SAFE MODE) ---
  // Note: fileName should ONLY be the name (e.g. 'snd_click.wav'), NOT 'audio/snd_click.wav'
  Future<void> playSFX(String fileName) async {
    try {
      // Stop previous SFX only if you don't want overlap. 
      // For clicking, overlapping is usually okay, so I removed the stop() 
      // unless you really want single channel SFX.
      if (globalSfxPlayer.state == PlayerState.playing) {
         await globalSfxPlayer.stop();
      }

      // Check volume before playing
      if (_sfxVolume > 0) {
        // DITO NAGKAKATALU: Ang 'audio/' ay naka-hardcode na.
        // Kaya dapat ang ipapasa mo lang ay "snd_click.wav"
        await globalSfxPlayer.play(AssetSource('audio/$fileName'));
        await globalSfxPlayer.setVolume(_sfxVolume);
      }
    } catch (e) {
      // Eto ang sasalo ng error para HINDI MAG-CRASH ang app (Red Screen)
      print("❌ ERROR PLAYING SFX ($fileName): $e");
    }
  }

  // --- 3. VOLUME CONTROLS ---
  void setBGMVolume(double value) {
    _bgmVolume = value;
    globalBgmPlayer.setVolume(value);
  }

  void setSFXVolume(double value) {
    _sfxVolume = value;
  }
  
  // OPTIONAL: Stop BGM pag exit ng app or game loop
  void stopBGM() {
    globalBgmPlayer.stop();
  }
}