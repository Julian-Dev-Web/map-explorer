import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';

// Import your files
import 'game_map_luzon.dart'; 
// import 'audio_manager.dart'; // Uncomment if fixed

class LuzonIntroScreen extends StatefulWidget {
  final String selectedCharacter;

  const LuzonIntroScreen({super.key, required this.selectedCharacter});

  @override
  State<LuzonIntroScreen> createState() => _LuzonIntroScreenState();
}

class _LuzonIntroScreenState extends State<LuzonIntroScreen> {
  FlutterTts flutterTts = FlutterTts();
  int _currentIndex = 0;
  
  final List<String> script = [
    "Nandito na tayo sa unang yugto!",
    "Welcome sa isla ng Luzon!",
    "Ito ang pinakamalaking isla sa buong Pilipinas.",
    "Ang Luzon ay binubuo ng walong (8) rehiyon.",
    "Dito rin matatagpuan ang Maynila, ang kabisera ng ating bansa.",
    "Ang goal mo ay buuin ang mapa ng Luzon.",
    "Handa ka na ba? Tara, simulan na natin!"
  ];

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage("fil-PH");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);

    if (widget.selectedCharacter == 'boy') {
      await flutterTts.setPitch(0.7);
    } else {
      await flutterTts.setPitch(1.2);
    }

    _speakLine();
  }

  Future<void> _speakLine() async {
    await flutterTts.stop();
    if (_currentIndex < script.length) {
      await flutterTts.speak(script[_currentIndex]);
    }
  }

  void _nextLine() {
    // AudioManager().playSFX('snd_click.wav'); 
    setState(() {
      if (_currentIndex < script.length - 1) {
        _currentIndex++;
        _speakLine();
      } else {
        _startGame();
      }
    });
  }

  void _startGame() {
    flutterTts.stop();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LuzonGameMap(
          selectedCharacter: widget.selectedCharacter
        )
      ),
    );
  }

  void _goBack() {
    flutterTts.stop(); 
    // AudioManager().playSFX('snd_click.wav');
    Navigator.pop(context); 
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String charImage = widget.selectedCharacter == 'boy' 
        ? 'assets/images/characters/2boy.png' 
        : 'assets/images/characters/2girl.png';

    Color themeColor = widget.selectedCharacter == 'boy' ? Colors.blue : Colors.pink;

    return Scaffold(
      body: GestureDetector(
        onTap: _nextLine,
        child: Stack(
          children: [
            
            // 1. BACKGROUND (CORRECTED PATH & FIT)
            Container(
              decoration: const BoxDecoration(
                // Light Blue Background representing the sea
                color: Color(0xFF81D4FA), 
                image: DecorationImage(
                  // CORRECT PATH based on your screenshot
                  image: AssetImage('assets/images/islands/luzon.png'),
                  
                  // Use 'contain' so the whole island is visible and not cropped
                  fit: BoxFit.contain, 
                  
                  // Center the map
                  alignment: Alignment.center, 
                ),
              ),
            ),

            // 2. CHARACTER
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: SizedBox(
                height: 450, 
                child: Image.asset(charImage, fit: BoxFit.contain),
              ),
            ),

            // 3. DIALOGUE BOX
            Positioned(
              bottom: 30, left: 20, right: 20,
              child: Container(
                padding: const EdgeInsets.all(20),
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  border: Border.all(color: themeColor, width: 4),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [BoxShadow(color: Colors.black26, offset: Offset(4, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.selectedCharacter == 'boy' ? "ANDRES" : "GABRIELA",
                      style: GoogleFonts.pressStart2p(color: themeColor, fontSize: 12),
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          script[_currentIndex],
                          style: GoogleFonts.pressStart2p(
                            color: Colors.black, 
                            fontSize: 13, 
                            height: 1.5
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text("TAP TO CONTINUE ▼", 
                        style: GoogleFonts.pressStart2p(color: Colors.grey, fontSize: 8)
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 4. TOP BUTTONS (BACK & SKIP)
            
            // BACK BUTTON (Left)
            Positioned(
              top: 50, left: 20,
              child: GestureDetector(
                onTap: _goBack,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black, width: 2),
                    boxShadow: const [BoxShadow(color: Colors.black26, offset: Offset(2, 2))]
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
                ),
              ),
            ),

            // SKIP BUTTON (Right)
            Positioned(
              top: 50, right: 20,
              child: GestureDetector(
                onTap: _startGame,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8)
                  ),
                  child: Text("SKIP >>", 
                    style: GoogleFonts.pressStart2p(color: Colors.white, fontSize: 10)
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}