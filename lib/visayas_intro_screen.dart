import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';

import 'game_map_visayas.dart'; // Import mo yung game map ng Visayas

class VisayasIntroScreen extends StatefulWidget {
  final String selectedCharacter;

  const VisayasIntroScreen({super.key, required this.selectedCharacter});

  @override
  State<VisayasIntroScreen> createState() => _VisayasIntroScreenState();
}

class _VisayasIntroScreenState extends State<VisayasIntroScreen> {
  FlutterTts flutterTts = FlutterTts();
  int _currentIndex = 0;
  
  // SCRIPT PARA SA VISAYAS
  final List<String> script = [
    "Mahusay! Nasa Visayas na tayo!",
    "Ito ang gitnang bahagi ng Pilipinas.",
    "Binubuo ito ng maraming pulo at magagandang dagat.",
    "Dito matatagpuan ang Chocolate Hills at sikat na Boracay.",
    "Ang Visayas ay may tatlong pangunahing rehiyon.",
    "Handa ka na bang buuin ito? Tara na!"
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
    // LIPAT SA VISAYAS GAME MAP
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => VisayasGameMap( // Change this to your actual file class
          selectedCharacter: widget.selectedCharacter
        )
      ),
    );
  }

  void _goBack() {
    flutterTts.stop();
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

    // ORANGE THEME FOR VISAYAS
    Color themeColor = Colors.orange; 

    return Scaffold(
      body: GestureDetector(
        onTap: _nextLine,
        child: Stack(
          children: [
            // 1. BACKGROUND
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFFFCC80), // Light Orange Background
                image: DecorationImage(
                  image: AssetImage('assets/images/islands/visayas.png'), 
                  fit: BoxFit.contain, 
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
                            fontSize: 12, 
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

            // 4. BUTTONS
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
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
                ),
              ),
            ),

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