import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart'; // IMPORT THIS!
import 'audio_manager.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double _musicVolume = 0.5;
  double _sfxVolume = 1.0;

  @override
  void initState() {
    super.initState();
    // 1. SAFETY NET: Play BGM if not playing
    AudioManager().playBGM(); 
    
    // 2. SYNC VOLUME
    _musicVolume = AudioManager().currentBgmVolume;
    _sfxVolume = AudioManager().currentSfxVolume;
  }

  // --- LOGIC TO WIPE DATA ---
  Future<void> _wipeData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // ETO YUNG MAGIC: Buburahin lahat ng achievements at progress!
    
    debugPrint("DATA WIPED SUCCESSFULLY");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[900], 
      body: Stack(
        children: [
          // 1. BACKGROUND GRADIENT
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF81D4FA), Color(0xFF42A5F5)], 
                ),
              ),
            ),
          ),
          
          // 2. SETTINGS PANEL (RETRO STYLE)
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.90,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                // Dark Blue-Grey Background (RPG Menu Style)
                color: const Color(0xFF1A237E).withValues(alpha: 0.9), 
                border: Border.all(color: Colors.white, width: 4),
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(color: Colors.black54, offset: Offset(8, 8), blurRadius: 0)
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- TITLE ---
                  Text(
                    "SETTINGS",
                    style: GoogleFonts.pressStart2p(
                      color: Colors.yellowAccent,
                      fontSize: 22,
                      shadows: [const Shadow(color: Colors.black, offset: Offset(3, 3))],
                      letterSpacing: 2,
                    ),
                  ),
                  
                  const SizedBox(height: 10),
                  const Divider(color: Colors.white54, thickness: 2),
                  const SizedBox(height: 30),

                  // --- MUSIC CONTROL ---
                  _buildPixelSlider(
                    label: "MUSIC",
                    icon: Icons.music_note,
                    color: Colors.orangeAccent,
                    value: _musicVolume,
                    onChanged: (val) {
                      setState(() {
                        _musicVolume = val;
                        AudioManager().setBGMVolume(val);
                      });
                    },
                  ),

                  const SizedBox(height: 25),

                  // --- SFX CONTROL ---
                  _buildPixelSlider(
                    label: "SOUND FX",
                    icon: Icons.volume_up,
                    color: Colors.greenAccent,
                    value: _sfxVolume,
                    onChanged: (val) {
                      setState(() {
                        _sfxVolume = val;
                        AudioManager().setSFXVolume(val);
                      });
                    },
                    onChangeEnd: (val) {
                      AudioManager().playSFX('snd_click.wav');
                    },
                  ),

                  const SizedBox(height: 40),

                  // --- RESET BUTTON (DANGER ZONE) ---
                  GestureDetector(
                    onTap: () {
                        AudioManager().playSFX('snd_click.wav');
                        _showResetConfirmation(context);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        color: Colors.red[700],
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: const [BoxShadow(color: Colors.black45, offset: Offset(4, 4))],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
                          const SizedBox(width: 10),
                          Text(
                            "RESET DATA",
                            style: GoogleFonts.pressStart2p(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. BACK BUTTON
          Positioned(
            top: 40,
            left: 20,
            child: GestureDetector(
              onTap: () {
                AudioManager().playSFX('snd_click.wav');
                Navigator.pop(context); 
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  border: Border.all(color: Colors.black, width: 3),
                  boxShadow: const [BoxShadow(color: Colors.black54, offset: Offset(4, 4))],
                ),
                child: const Icon(Icons.arrow_back, color: Colors.black, size: 28),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- CUSTOM WIDGET PARA SA SLIDER ---
  Widget _buildPixelSlider({
    required String label,
    required IconData icon,
    required Color color,
    required double value,
    required Function(double) onChanged,
    Function(double)? onChangeEnd,
  }) {
    return Column(
      children: [
        // Label Row
        Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.pressStart2p(color: Colors.white, fontSize: 12),
            ),
            const Spacer(),
            Text(
              "${(value * 100).toInt()}%", // Show percentage
              style: GoogleFonts.pressStart2p(color: color, fontSize: 10),
            ),
          ],
        ),
        const SizedBox(height: 5),
        
        // Custom Theme for CHUNKY Slider
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            inactiveTrackColor: Colors.black26,
            trackHeight: 12.0, // Makapal na track
            thumbColor: Colors.white,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10.0), // Malaking bilog
            overlayColor: color.withValues(alpha: 0.2),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20.0),
          ),
          child: Slider(
            value: value,
            min: 0.0,
            max: 1.0,
            onChanged: onChanged,
            onChangeEnd: onChangeEnd,
          ),
        ),
      ],
    );
  }

  void _showResetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A237E), // Match Settings BG
        shape: const RoundedRectangleBorder(
            side: BorderSide(color: Colors.white, width: 4)),
        title: Text("WARNING!", style: GoogleFonts.pressStart2p(color: Colors.red, fontSize: 16)),
        content: Text(
          "Are you sure you want to delete all progress?",
          style: GoogleFonts.pressStart2p(color: Colors.white, fontSize: 10, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("CANCEL", style: GoogleFonts.pressStart2p(color: Colors.white, fontSize: 12)),
          ),
          TextButton(
            onPressed: () async { // GAWING ASYNC
              Navigator.pop(context); // Close dialog first
              
              await _wipeData(); // TAWAGIN ANG DELETE FUNCTION

              if (context.mounted) {
                 AudioManager().playSFX('snd_correct.wav'); 
                 ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.red,
                    content: Text("DATA WIPED! RESTART GAME.", style: GoogleFonts.pressStart2p(fontSize: 10, color: Colors.white)),
                  ),
                );
              }
            },
            child: Text("WIPE", style: GoogleFonts.pressStart2p(color: Colors.redAccent, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}