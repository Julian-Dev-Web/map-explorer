import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart'; 

// Import your files
import 'audio_manager.dart';
import 'game_map_luzon.dart'; 
import 'luzon_intro_screen.dart'; // <--- IMPORT THIS (Dapat existing na yung file na binigay ko kanina)

class IntroductionScreen extends StatefulWidget {
  final String selectedCharacter;

  const IntroductionScreen({super.key, required this.selectedCharacter});

  @override
  State<IntroductionScreen> createState() => _IntroductionScreenState();
}

class _IntroductionScreenState extends State<IntroductionScreen> with SingleTickerProviderStateMixin {
  late AnimationController _cloudController;
  int _currentDialogueIndex = 0;
  String _displayName = "";

  // TTS Setup
  FlutterTts flutterTts = FlutterTts();

  final List<String> dialogues = [
    "Hi! Kamusta!",
    "Welcome sa Philippine Map Puzzle!",
    "Ito ang Mapa ng Pilipinas.",
    "Ang goal mo ay i-drag ang puzzle piece at ilagay sa tamang pwesto.",
    "Kapag tama ang lagay mo, kusa itong kakabit.",
    "Pagkatapos, may lalabas na trivia tungkol sa rehiyon.",
    "Pag tapos na ang Luzon, sunod ang Visayas, at huli ang Mindanao.",
    "Bago makalipat, kailangan mo munang sagutan ang simpleng quiz.",
    "Handa ka na? Tara, simulan na natin!",
  ];

  @override
  void initState() {
    super.initState();
    _displayName = widget.selectedCharacter == 'boy' ? "ANDRES" : "GABRIELA";
    _loadPlayerName();

    _cloudController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

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

    _speakCurrentDialogue();
  }

  Future<void> _speakCurrentDialogue() async {
    await flutterTts.stop();
    if (_currentDialogueIndex < dialogues.length) {
      await flutterTts.speak(dialogues[_currentDialogueIndex]);
    }
  }

  Future<void> _loadPlayerName() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedName = prefs.getString('player_name');
    if (savedName != null && savedName.isNotEmpty) {
      setState(() {
        _displayName = savedName;
      });
    }
  }

  @override
  void dispose() {
    _cloudController.dispose();
    flutterTts.stop(); 
    super.dispose();
  }

  void _nextDialogue() {
    // AudioManager().playSFX('snd_click.wav'); 

    setState(() {
      if (_currentDialogueIndex < dialogues.length - 1) {
        _currentDialogueIndex++;
        _speakCurrentDialogue();
      } else {
        _startGame();
      }
    });
  }

  // --- ETO ANG NABAGO: PUPUNTA MUNA SA LUZON INTRO ---
  void _startGame() {
    flutterTts.stop(); 
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        // Dito na tayo lilipat sa bagong screen na ginawa natin
        builder: (context) => LuzonIntroScreen(
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
  Widget build(BuildContext context) {
    String openEyesPath = widget.selectedCharacter == 'boy'
        ? 'assets/images/characters/2boy.png'
        : 'assets/images/characters/2girl.png';

    String closedEyesPath = widget.selectedCharacter == 'boy'
        ? 'assets/images/characters/1boy.png'
        : 'assets/images/characters/1girl.png';

    Color charColor = widget.selectedCharacter == 'boy' ? Colors.blue : Colors.pink;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: GestureDetector(
        onTap: _nextDialogue,
        child: Stack(
          children: [
            // 1. BACKGROUND GRADIENT
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF81D4FA), Color(0xFF42A5F5)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),

            // 2. MAP BACKGROUND
            Center(
              child: Opacity(
                opacity: 0.3,
                child: Transform.scale(
                  scale: 1.8,
                  child: Image.asset(
                    'assets/images/maps/pixel_ph_map.png',
                    width: size.width,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),

            // 3. MOVING CLOUDS
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _cloudController,
                builder: (context, child) {
                  return Stack(
                    children: [
                      _buildMovingCloud(size, 0.1, 50, 0.5, 80),
                      _buildMovingCloud(size, 0.4, 150, 0.8, 60),
                      _buildMovingCloud(size, 0.7, 100, 1.2, 70),
                    ],
                  );
                },
              ),
            ),

            // 4. CHARACTER
            Positioned(
              bottom: 0, left: 0, right: 0,
              child: SizedBox(
                height: 400,
                child: BlinkingCharacter(
                  openPath: openEyesPath,
                  closedPath: closedEyesPath
                ),
              ),
            ),

            // 5. DIALOGUE BOX
            Positioned(
              bottom: 30, left: 20, right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                    decoration: BoxDecoration(
                      color: charColor,
                      border: Border.all(color: Colors.black, width: 3),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: const [BoxShadow(color: Colors.black45, offset: Offset(4, 4))],
                    ),
                    child: Text(
                      _displayName,
                      style: GoogleFonts.pressStart2p(color: Colors.white, fontSize: 12)
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    width: double.infinity,
                    height: 130,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black, width: 4),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [BoxShadow(color: Colors.black45, offset: Offset(6, 6))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Scrollbar(
                            thumbVisibility: true,
                            thickness: 5,
                            radius: const Radius.circular(10),
                            child: SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.only(right: 10.0),
                                child: Text(
                                  dialogues[_currentDialogueIndex],
                                  style: GoogleFonts.pressStart2p(color: Colors.black, fontSize: 13, height: 1.5),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text("TAP TO CONTINUE ▼", style: GoogleFonts.pressStart2p(color: Colors.grey, fontSize: 8)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 6. TOP BUTTONS
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
            Positioned(
              top: 50, right: 20,
              child: GestureDetector(
                onTap: () {
                  // AudioManager().playSFX('snd_click.wav');
                  _startGame();
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8)
                  ),
                  child: Text("SKIP >>", style: GoogleFonts.pressStart2p(color: Colors.white, fontSize: 10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMovingCloud(Size size, double startOffset, double top, double speed, double iconSize) {
    double xPos = ((_cloudController.value * speed) + startOffset) % 1.0 * (size.width + 100) - 50;
    return Positioned(
      top: top,
      left: xPos,
      child: Icon(
        Icons.cloud,
        size: iconSize,
        color: Colors.white.withOpacity(0.4),
      ),
    );
  }
}

// Blinking Character (Same as before)
class BlinkingCharacter extends StatefulWidget {
  final String openPath;
  final String closedPath;
  const BlinkingCharacter({super.key, required this.openPath, required this.closedPath});
  @override
  State<BlinkingCharacter> createState() => _BlinkingCharacterState();
}

class _BlinkingCharacterState extends State<BlinkingCharacter> {
  late Timer _timer;
  bool _isEyesOpen = true;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 2500), (timer) {
      if (mounted) {
        setState(() => _isEyesOpen = false); 
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted) setState(() => _isEyesOpen = true); 
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      _isEyesOpen ? widget.openPath : widget.closedPath,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.none,
      gaplessPlayback: true, 
    );
  }
}