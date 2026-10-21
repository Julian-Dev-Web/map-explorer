import 'dart:async'; // Needed for Timer
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import 'package:confetti/confetti.dart'; 
import 'region_data_visayas.dart'; // Ensure correct import
import 'audio_manager.dart'; 
import 'island_selection_screen.dart'; 

class VisayasQuizScreen extends StatefulWidget {
  // 1. ACCEPT HISTORY FROM GAME MAP
  final List<Map<String, String>> history; 

  const VisayasQuizScreen({super.key, required this.history});

  @override
  State<VisayasQuizScreen> createState() => _VisayasQuizScreenState();
}

class _VisayasQuizScreenState extends State<VisayasQuizScreen> {
  int currentQuestionIndex = 0;
  int score = 0;
  late List<Map<String, dynamic>> quizData;
  bool isLoading = true; 
  
  late ConfettiController _confettiController; 

  // --- VISUAL FEEDBACK VARS ---
  bool _showCorrectIcon = false;
  bool _showWrongIcon = false;
  bool _buttonsLocked = false; 

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _generateQuiz();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _generateQuiz() {
    // --- HYBRID LOGIC: HISTORY + RANDOM FILLER ---
    
    // 1. Start with the history from the game (usually 3 items for Visayas)
    List<Map<String, String>> sourceList = List.from(widget.history);

    // 2. If history is less than 5 (which is true for Visayas), fill the rest with random data
    if (sourceList.length < 5) {
      // Create a pool of all possible facts
      List<Map<String, String>> allFacts = [];
      for (var region in visayasRegions) {
        for (var fact in region.facts) {
          allFacts.add({'regionName': region.name, 'fact': fact});
        }
      }
      
      allFacts.shuffle(); // Shuffle the pool

      // Add unique facts until we reach 5
      for (var item in allFacts) {
        if (sourceList.length >= 5) break;
        
        // Avoid duplicate facts
        bool exists = sourceList.any((existing) => existing['fact'] == item['fact']);
        if (!exists) {
          sourceList.add(item);
        }
      }
    }

    // Shuffle the final list so history questions aren't always first
    sourceList.shuffle();
    
    // Ensure we have exactly 5 questions (or less if data is scarce)
    var selectedItems = sourceList.take(5).toList();

    quizData = selectedItems.map((item) {
      String fact = item['fact']!;
      String correctRegion = item['regionName']!;
      
      // --- MASKING LOGIC ---
      String questionText = fact;
      questionText = questionText.replaceAll(correctRegion, "rehiyong ito");
      questionText = questionText.replaceAll("Region 6", "rehiyong ito"); 
      questionText = questionText.replaceAll("Region 7", "rehiyong ito");
      questionText = questionText.replaceAll("Region 8", "rehiyong ito");
      questionText = questionText.replaceAll("Western Visayas", "rehiyong ito");
      questionText = questionText.replaceAll("Central Visayas", "rehiyong ito");
      questionText = questionText.replaceAll("Eastern Visayas", "rehiyong ito");
      questionText = questionText.replaceAll("Kanlurang Kabisayaan", "rehiyong ito");
      questionText = questionText.replaceAll("Gitnang Kabisayaan", "rehiyong ito");
      questionText = questionText.replaceAll("Silangang Kabisayaan", "rehiyong ito");

      questionText = "Anong rehiyon ang tinutukoy nito?\n\n\"$questionText\"";

      return {
        'question': questionText, 
        'correctAnswer': correctRegion,
        'options': _generateOptions(correctRegion),
      };
    }).toList();

    setState(() {
      isLoading = false; 
    });
  }

  // Generate Choices (Since Visayas only has 3 regions, we show all of them)
  List<String> _generateOptions(String correctAnswer) {
    var allRegions = visayasRegions.map((r) => r.name).toSet().toList();
    allRegions.shuffle();
    return allRegions;
  }

  // --- UPDATED ANSWER HANDLER WITH FEEDBACK ---
  void _handleAnswer(String selectedAnswer) {
    if (_buttonsLocked) return; 

    bool isCorrect = selectedAnswer == quizData[currentQuestionIndex]['correctAnswer'];
    
    setState(() {
      _buttonsLocked = true; 
      if (isCorrect) {
        score++;
        _showCorrectIcon = true; 
        AudioManager().playSFX('snd_correct.wav'); 
      } else {
        _showWrongIcon = true; 
        AudioManager().playSFX('snd_wrong.wav');
      }
    });

    // Wait 1 second before next question
    Timer(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _showCorrectIcon = false;
          _showWrongIcon = false;
          _buttonsLocked = false; 

          if (currentQuestionIndex < quizData.length - 1) {
            currentQuestionIndex++;
          } else {
            _showResultDialog();
          }
        });
      }
    });
  }

  Future<void> _unlockAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('visayas_completed', true); 
    await prefs.setBool('mindanao_unlocked', true); 
  }

  void _showResultDialog() {
    bool passed = score >= 3; 
    bool perfect = score == quizData.length;

    if (passed) {
      AudioManager().playSFX('snd_level_complete.wav'); 
      _confettiController.play(); 
      _unlockAchievements();
    } else {
      AudioManager().playSFX('snd_wrong.wav'); 
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Stack(
        alignment: Alignment.center,
        children: [
          // DIALOG BOX
          AlertDialog(
            backgroundColor: passed ? const Color(0xFF1B5E20) : const Color(0xFFB71C1C),
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Colors.white, width: 4), 
              borderRadius: BorderRadius.circular(20)
            ),
            
            title: Column(
              children: [
                Icon(passed ? Icons.emoji_events : Icons.cancel, size: 60, color: Colors.yellowAccent),
                const SizedBox(height: 15),
                Text(
                  perfect ? "🌟 PERFECT! 🌟" : (passed ? "🏆 TAGUMPAY!" : "❌ NABIGO"), 
                  textAlign: TextAlign.center, 
                  style: GoogleFonts.pressStart2p(color: Colors.white, fontSize: 16)
                ),
              ],
            ),
            
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Text("Iskor: $score/${quizData.length}", style: GoogleFonts.pressStart2p(color: Colors.yellow, fontSize: 14)),
                ),
                const SizedBox(height: 20),
                Text(
                  passed 
                    ? "Nakuha mo ang Visayas Trophy!\nBukas na ang Mindanao Region." 
                    : "Kailangan mo ng 3 puntos para mabuksan ang Mindanao.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.pressStart2p(color: Colors.white, fontSize: 10, height: 1.6),
                ),
              ],
            ),
            actions: [
              Center(
                child: Column(
                  children: [
                    if (!passed)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: SizedBox(
                          width: 200,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                            ),
                            onPressed: () {
                              AudioManager().playSFX('snd_click.wav');
                              Navigator.pop(context);
                              setState(() { currentQuestionIndex = 0; score = 0; isLoading = true; });
                              _generateQuiz();
                            },
                            child: Text("ULITIN", style: GoogleFonts.pressStart2p(fontSize: 12, color: Colors.white)),
                          ),
                        ),
                      ),
                    
                    SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                        ),
                        onPressed: () {
                          AudioManager().playSFX('snd_click.wav');
                          if (passed) {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (context) => const IslandSelectionScreen(selectedCharacter: '')), 
                              (Route<dynamic> route) => false,
                            );
                          } else {
                            Navigator.pop(context); 
                            Navigator.pop(context);
                          }
                        },
                        child: Text(
                          passed ? "TAPUSIN" : "SUMUKO", 
                          style: GoogleFonts.pressStart2p(fontSize: 12, color: Colors.black)
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),

          // --- CONFETTI OVERLAY ---
          if (passed)
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive, 
                shouldLoop: false, 
                colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple], 
                gravity: 0.3, 
                numberOfParticles: 30, 
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(backgroundColor: Color(0xFF1A237E), body: Center(child: CircularProgressIndicator()));
    }

    var currentQuestion = quizData[currentQuestionIndex];
    double progress = (currentQuestionIndex + 1) / quizData.length;

    return Scaffold(
      body: Stack(
        children: [
          // MAIN CONTENT
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF42A5F5), Color(0xFF1565C0)], 
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // HEADER
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                          onPressed: () => Navigator.pop(context), 
                        ),
                        Expanded(
                          child: Text("VISAYAS QUIZ", textAlign: TextAlign.center, style: GoogleFonts.pressStart2p(color: Colors.white, fontSize: 16)),
                        ),
                        const SizedBox(width: 40), 
                      ],
                    ),
                  ),

                  // PROGRESS BAR
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.black26,
                          color: Colors.amber, 
                          minHeight: 10,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "TANONG ${currentQuestionIndex + 1} / ${quizData.length}", 
                          style: GoogleFonts.pressStart2p(color: Colors.yellowAccent, fontSize: 12)
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // QUESTION AREA
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // QUESTION CARD
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(25),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0D47A1).withOpacity(0.8), 
                              borderRadius: BorderRadius.circular(20), 
                              border: Border.all(color: Colors.amber, width: 3), 
                              boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 5))]
                            ),
                            child: Text(
                              currentQuestion['question'], 
                              textAlign: TextAlign.center, 
                              style: GoogleFonts.pressStart2p(color: Colors.white, fontSize: 14, height: 1.6)
                            ),
                          ),
                          
                          const SizedBox(height: 30),
                          
                          // BUTTONS
                          ...currentQuestion['options'].map<Widget>((option) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 15),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white, 
                                    foregroundColor: Colors.black, 
                                    elevation: 5,
                                    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 15),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      side: const BorderSide(color: Colors.black, width: 1)
                                    )
                                  ),
                                  onPressed: () => _handleAnswer(option),
                                  child: Text(
                                    option, 
                                    textAlign: TextAlign.center, 
                                    style: GoogleFonts.pressStart2p(fontSize: 12, color: const Color(0xFF1565C0))
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- VISUAL FEEDBACK OVERLAY ---
          if (_showCorrectIcon)
            Center(
              child: TweenAnimationBuilder(
                duration: const Duration(milliseconds: 300),
                tween: Tween<double>(begin: 0.0, end: 1.5),
                curve: Curves.elasticOut,
                builder: (context, value, child) => Transform.scale(scale: value, child: child),
                child: const Icon(Icons.check_circle, color: Colors.greenAccent, size: 150, shadows: [Shadow(color: Colors.black, blurRadius: 10)]),
              ),
            ),

          if (_showWrongIcon)
            Center(
              child: TweenAnimationBuilder(
                duration: const Duration(milliseconds: 300),
                tween: Tween<double>(begin: 0.0, end: 1.5),
                curve: Curves.elasticOut,
                builder: (context, value, child) => Transform.scale(scale: value, child: child),
                child: const Icon(Icons.cancel, color: Colors.redAccent, size: 150, shadows: [Shadow(color: Colors.black, blurRadius: 10)]),
              ),
            ),
        ],
      ),
    );
  }
}