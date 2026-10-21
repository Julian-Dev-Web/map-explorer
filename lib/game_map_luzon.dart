import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart'; 
import 'audio_manager.dart';
import 'region_data.dart';
import 'luzon_quiz_screen.dart';

class LuzonGameMap extends StatefulWidget {
  final String selectedCharacter;

  const LuzonGameMap({super.key, required this.selectedCharacter});

  @override
  State<LuzonGameMap> createState() => _LuzonGameMapState();
}

class _LuzonGameMapState extends State<LuzonGameMap> with SingleTickerProviderStateMixin {
  // GAME STATE
  List<RegionItem> pendingPieces = [];
  List<RegionItem> activePieces = []; 
  List<String> solvedRegions = [];
  
  bool firstPieceAchievementShown = false;
  int lives = 5;

  // SESSION DATA
  List<Map<String, String>> sessionTrivia = [];

  // ANIMATION & VISUALS
  bool _showCorrectIcon = false;
  bool _showWrongIcon = false;
  late AnimationController _cloudController;
  FlutterTts flutterTts = FlutterTts(); 

  @override
  void initState() {
    super.initState();
    _cloudController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _startNewGame();
  }

  @override
  void dispose() {
    _cloudController.dispose();
    flutterTts.stop();
    super.dispose();
  }

  void _startNewGame() {
    setState(() {
      lives = 5;
      solvedRegions.clear();
      activePieces.clear();
      sessionTrivia.clear();
      pendingPieces = List.from(luzonRegions)..shuffle();
    });

    // START: Show first trivia immediately
    Future.delayed(const Duration(milliseconds: 500), () {
      _startNextTurn();
    });
  }

  // --- LOGIC: START TURN ---
  void _startNextTurn() {
    if (pendingPieces.isEmpty) {
      _showWinDialog();
      return;
    }

    // Get the next region to solve
    RegionItem nextRegion = pendingPieces.first;

    // Show the trivia/intro dialog FIRST
    _showIntroDialog(nextRegion);
  }

  // --- LOGIC: UNLOCK PIECE ---
  void _unlockPieceForDrag(RegionItem region) {
    setState(() {
      // Show ONLY this piece in the tray
      activePieces = [region]; 
    });
  }

  // --- HANDLE DRAG SUCCESS ---
  Future<void> _handlePiecePlaced(RegionItem region) async {
    setState(() {
      solvedRegions.add(region.id);
      activePieces.clear(); // Clear tray
      pendingPieces.remove(region); // Remove from queue
    });

    AudioManager().playSFX('snd_correct.wav');
    _triggerFeedback(true);

    if (solvedRegions.length == 1) {
      final prefs = await SharedPreferences.getInstance();
      bool alreadyUnlocked = prefs.getBool('first_step') ?? false;
      if (!alreadyUnlocked) {
        await prefs.setBool('first_step', true);
        if (!firstPieceAchievementShown) {
           _showAchievement("🏆 FIRST STEP!", "Nailagay ang unang piraso!");
           firstPieceAchievementShown = true;
        }
      }
    }

    // Move to next turn/trivia
    Future.delayed(const Duration(milliseconds: 1000), () {
       _startNextTurn();
    });
  }

  void _onDragCancelled() {
    _deductLife();
  }

  void _deductLife() {
    if (lives <= 0) return;
    setState(() {
      lives--;
      _triggerFeedback(false);
    });
    AudioManager().playSFX('snd_wrong.wav');

    if (lives == 0) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _showGameOverDialog();
      });
    }
  }

  void _triggerFeedback(bool isCorrect) {
    setState(() {
      if (isCorrect) {
        _showCorrectIcon = true;
        _showWrongIcon = false;
      } else {
        _showCorrectIcon = false;
        _showWrongIcon = true;
      }
    });

    Timer(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _showCorrectIcon = false;
          _showWrongIcon = false;
        });
      }
    });
  }

  // --- DIALOG: INTRO/TRIVIA BEFORE PUZZLE ---
  void _showIntroDialog(RegionItem region) {
    String randomFact = (List.from(region.facts)..shuffle()).first;
    
    sessionTrivia.add({
      'regionName': region.name,
      'fact': randomFact,
    });

    String openEyes = widget.selectedCharacter == 'boy' ? 'assets/images/characters/2boy.png' : 'assets/images/characters/2girl.png';
    String closedEyes = widget.selectedCharacter == 'boy' ? 'assets/images/characters/1boy.png' : 'assets/images/characters/1girl.png';

    showDialog(
      context: context,
      barrierDismissible: false, 
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(top: 40),
              padding: const EdgeInsets.fromLTRB(15, 60, 15, 20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A237E),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 15, offset: Offset(0, 10))]
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("HANAPIN:", textAlign: TextAlign.center, style: GoogleFonts.pressStart2p(color: Colors.white70, fontSize: 10)),
                  const SizedBox(height: 5),
                  Text(region.name, textAlign: TextAlign.center, style: GoogleFonts.pressStart2p(color: Colors.yellow, fontSize: 16)),
                  const SizedBox(height: 20),
                  
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                       SizedBox(
                         width: 100,
                         height: 120,
                         child: BlinkingCharacter(openPath: openEyes, closedPath: closedEyes),
                       ),
                       const SizedBox(width: 10),
                       Expanded(
                         child: Container(
                           padding: const EdgeInsets.all(15),
                           decoration: BoxDecoration(
                             color: Colors.white,
                             borderRadius: BorderRadius.circular(15),
                             border: Border.all(color: Colors.grey.shade400, width: 2),
                             boxShadow: const [BoxShadow(color: Colors.black26, offset: Offset(2,2))]
                           ),
                           child: Text(
                             "TRIVIA:\n$randomFact",
                             style: GoogleFonts.pressStart2p(color: Colors.black, fontSize: 10, height: 1.5),
                             textAlign: TextAlign.left,
                           ),
                         ),
                       )
                    ],
                  ),
                  
                  const SizedBox(height: 25),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: Colors.white, width: 2))
                    ),
                    onPressed: () {
                      Navigator.pop(context); 
                      _unlockPieceForDrag(region); 
                    },
                    child: Text("ILAGAY SA MAPA", style: GoogleFonts.pressStart2p(fontSize: 10, color: Colors.white)),
                  ),
                ],
              ),
            ),
            
            Positioned(
              top: -20,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.amber, width: 5),
                  boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10, offset: Offset(0, 5))]
                ),
                child: Image.asset(region.imagePath, height: 80, width: 80, fit: BoxFit.contain),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAchievement(String title, String desc) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.orangeAccent,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(top: 50, left: 20, right: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.emoji_events, color: Colors.white),
                const SizedBox(width: 8),
                Text(title, style: GoogleFonts.pressStart2p(fontSize: 10, color: Colors.black)),
              ],
            ),
            const SizedBox(height: 5),
            Text(desc, textAlign: TextAlign.center, style: GoogleFonts.pressStart2p(fontSize: 8, color: Colors.black87)),
          ],
        ),
      ),
    );
  }

  void _showGameOverDialog() {
    AudioManager().playSFX('snd_wrong.wav');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFB71C1C),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.white, width: 4),
        ),
        title: Column(
          children: [
            const Icon(Icons.heart_broken, size: 60, color: Colors.white),
            const SizedBox(height: 10),
            Text("GAME OVER", textAlign: TextAlign.center, style: GoogleFonts.pressStart2p(color: Colors.white, fontSize: 16)),
          ],
        ),
        content: Text(
          "Naubusan ka ng buhay! Huwag sumuko, subukan muli.",
          textAlign: TextAlign.center,
          style: GoogleFonts.pressStart2p(color: Colors.white, fontSize: 10, height: 1.5)
        ),
        actions: [
          Center(
            child: SizedBox(
              width: 200,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _startNewGame();
                },
                child: Text("TRY AGAIN", style: GoogleFonts.pressStart2p(fontSize: 12, color: Colors.black)),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _showWinDialog() {
    AudioManager().playSFX('snd_level_complete.wav');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.green[800],
        title: Text("🏆 LUZON COMPLETED!", textAlign: TextAlign.center, style: GoogleFonts.pressStart2p(color: Colors.white, fontSize: 14)),
        content: Text("You've mastered the map! Pass the quiz to unlock Visayas.", textAlign: TextAlign.center, style: GoogleFonts.pressStart2p(color: Colors.white, fontSize: 10, height: 1.5)),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LuzonQuizScreen(
                      history: sessionTrivia
                    )
                  )
                );
              },
              child: Text("START QUIZ", style: GoogleFonts.pressStart2p(fontSize: 10)),
            ),
          )
        ],
      ),
    );
  }

  void _showReviewerDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFFFFF3E0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.brown, width: 4)
        ),
        child: const ReviewerWidget(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // 1. OCEAN BACKGROUND
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF81D4FA), Color(0xFF42A5F5)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // 2. ANIMATED CLOUDS
          Positioned.fill(
             child: AnimatedBuilder(
               animation: _cloudController,
               builder: (context, child) {
                 return Stack(
                   children: [
                     _buildMovingCloud(size, 0.1, 50, 0.5, 80),
                     _buildMovingCloud(size, 0.4, 150, 0.8, 60),
                     _buildMovingCloud(size, 0.7, 100, 1.2, 70),
                     _buildMovingCloud(size, 0.2, 250, 0.6, 90),
                   ],
                 );
               },
             ),
          ),

          // 3. MAIN GAME CONTENT
          Column(
            children: [
              // Header & Heart Bar
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                            onPressed: () => Navigator.pop(context),
                          ),
                          Expanded(
                            child: Text("LUZON PUZZLE", textAlign: TextAlign.center, style: GoogleFonts.pressStart2p(color: Colors.white, fontSize: 16)),
                          ),
                          const SizedBox(width: 40),
                        ],
                      ),
                      
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: Icon(
                              index < lives ? Icons.favorite : Icons.favorite_border,
                              color: index < lives ? Colors.redAccent : Colors.white54,
                              size: 24,
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),

              // Map Area
              Expanded(
                flex: 6,
                child: RepaintBoundary(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 800 / 1200,
                      child: Stack(
                        children: [
                          Positioned.fill(child: Opacity(opacity: 0.3, child: Image.asset('assets/images/maps/luzon_outline.png', fit: BoxFit.contain, cacheHeight: 600))),
                          
                          // Solved Regions
                          ...luzonRegions.map((region) {
                            bool isSolved = solvedRegions.contains(region.id);
                            return Positioned.fill(
                              child: IgnorePointer(
                                child: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 300),
                                  opacity: isSolved ? 1.0 : 0.0,
                                  child: Image.asset(region.imagePath, fit: BoxFit.contain, cacheHeight: 600),
                                ),
                              ),
                            );
                          }),

                          // Drop Targets
                          ...luzonRegions.map((region) {
                              if (solvedRegions.contains(region.id)) return const SizedBox.shrink();
                              // Only show drop target if this piece is currently active
                              bool isActive = activePieces.any((p) => p.id == region.id);
                              if (!isActive) return const SizedBox.shrink();

                              return Align(
                                alignment: region.alignment,
                                child: DragTarget<RegionItem>(
                                  onWillAcceptWithDetails: (details) => details.data.id == region.id,
                                  onAcceptWithDetails: (details) => _handlePiecePlaced(region),
                                  builder: (context, candidate, rejected) {
                                    return Container(
                                      width: 100,
                                      height: 100,
                                      // FIXED: Colors.transparent para hindi kita yung box
                                      color: Colors.transparent, 
                                    );
                                  },
                                ),
                              );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              
              // Tray (Only shows the active piece)
              Container(
                height: 180,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFF5D4037),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
                  border: Border(top: BorderSide(color: Colors.amber, width: 3))
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center, 
                  children: activePieces.map((p) => Draggable<RegionItem>(
                    data: p,
                    feedback: Material(
                      color: Colors.transparent,
                      child: Transform.scale(scale: 3.5, child: Image.asset(p.imagePath, width: 100, cacheHeight: 400)),
                    ),
                    childWhenDragging: Opacity(opacity: 0.3, child: Image.asset(p.imagePath, width: 100, cacheHeight: 200)),
                    onDragEnd: (details) {
                       if (!details.wasAccepted) _onDragCancelled();
                    },
                    // FIXED: Removed Column/Arrow. Just the image container now.
                    child: Container(
                      width: 130,
                      height: 130,
                      alignment: Alignment.center,
                      child: Transform.scale(
                        scale: 3.0,
                        child: Image.asset(p.imagePath, width: 80, height: 80, fit: BoxFit.contain, cacheHeight: 400),
                      ),
                    ),
                  )).toList(),
                ),
              ),
            ],
          ),

          // 4. REVIEWER BUTTON
          Positioned(
            top: 50,
            right: 20,
            child: GestureDetector(
              onTap: () {
                AudioManager().playSFX('snd_click.wav');
                _showReviewerDialog();
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 5, offset: Offset(0, 3))]
                ),
                child: const Icon(Icons.menu_book, color: Colors.black, size: 24),
              ),
            ),
          ),

          // 5. VISUAL FEEDBACK
          if (_showCorrectIcon)
            Center(
              child: TweenAnimationBuilder(
                duration: const Duration(milliseconds: 500),
                tween: Tween<double>(begin: 0.0, end: 1.0),
                curve: Curves.elasticOut,
                builder: (context, value, child) => Transform.scale(scale: value, child: child),
                child: const Icon(Icons.check_circle, color: Colors.greenAccent, size: 150, shadows: [Shadow(color: Colors.black, blurRadius: 10)]),
              ),
            ),

          if (_showWrongIcon)
            Center(
              child: TweenAnimationBuilder(
                duration: const Duration(milliseconds: 500),
                tween: Tween<double>(begin: 0.0, end: 1.0),
                curve: Curves.elasticOut,
                builder: (context, value, child) => Transform.scale(scale: value, child: child),
                child: const Icon(Icons.cancel, color: Colors.redAccent, size: 150, shadows: [Shadow(color: Colors.black, blurRadius: 10)]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMovingCloud(Size size, double startOffset, double top, double speed, double iconSize) {
    double xPos = ((_cloudController.value * speed) + startOffset) % 1.0 * (size.width + 200) - 100;
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

// --- BLINKING CHARACTER WIDGET ---
class BlinkingCharacter extends StatefulWidget {
  final String openPath;
  final String closedPath;

  const BlinkingCharacter({
    super.key,
    required this.openPath,
    required this.closedPath,
  });

  @override
  State<BlinkingCharacter> createState() => _BlinkingCharacterState();
}

class _BlinkingCharacterState extends State<BlinkingCharacter> with SingleTickerProviderStateMixin {
  late AnimationController _blinkController;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _startBlinking();
  }

  void _startBlinking() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _blinkController.forward().then((_) {
          _blinkController.reverse().then((_) {
            _startBlinking();
          });
        });
      }
    });
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _blinkController,
      builder: (context, child) {
        bool isClosed = _blinkController.value > 0.5;
        return Image.asset(
          isClosed ? widget.closedPath : widget.openPath,
          fit: BoxFit.contain,
        );
      },
    );
  }
}

// --- REVIEWER WIDGET (Kept the same) ---
class ReviewerWidget extends StatefulWidget {
  const ReviewerWidget({super.key});

  @override
  State<ReviewerWidget> createState() => _ReviewerWidgetState();
}

class _ReviewerWidgetState extends State<ReviewerWidget> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  String question = "";
  String correctAnswer = "";
  List<String> options = [];
  bool showCorrect = false;
  bool showWrong = false;
  bool isLocked = false;
  bool revealAnswer = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _generateRandomQuestion();
  }

  void _generateRandomQuestion() {
    var randomRegion = (List.from(luzonRegions)..shuffle()).first;
    var randomFact = (List.from(randomRegion.facts)..shuffle()).first;

    setState(() {
      String q = randomFact;
      q = q.replaceAll(randomRegion.name, "_______");
      q = q.replaceAll("Region", "Rehiyon");
      
      question = "Anong rehiyon ang tinutukoy nito?\n\n\"$q\"";
      correctAnswer = randomRegion.name;
      
      var otherNames = luzonRegions
          .where((r) => r.name != randomRegion.name)
          .map((r) => r.name)
          .toList()..shuffle();
          
      options = [correctAnswer, ...otherNames.take(3)]..shuffle();
      
      showCorrect = false;
      showWrong = false;
      isLocked = false;
      revealAnswer = false;
    });
  }

  void _handleAnswer(String selected) {
    if (isLocked) return;

    setState(() {
      isLocked = true;
      if (selected == correctAnswer) {
        showCorrect = true;
        AudioManager().playSFX('snd_correct.wav');
      } else {
        showWrong = true;
        AudioManager().playSFX('snd_wrong.wav');
      }
    });

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        _generateRandomQuestion();
      }
    });
  }

  void _revealAnswer() {
    setState(() {
      revealAnswer = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 600,
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          Text("REVIEWER & PRACTICE", style: GoogleFonts.pressStart2p(fontSize: 12, color: Colors.brown)),
          const SizedBox(height: 15),
          TabBar(
            controller: _tabController,
            labelColor: Colors.brown,
            indicatorColor: Colors.orange,
            labelStyle: GoogleFonts.pressStart2p(fontSize: 10),
            tabs: const [
              Tab(text: "ARALIN"),
              Tab(text: "SANAY"),
            ],
          ),
          const SizedBox(height: 10),
          
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // --- TAB 1: ARALIN ---
                ListView.builder(
                  itemCount: luzonRegions.length,
                  itemBuilder: (context, index) {
                    final region = luzonRegions[index];
                    return Card(
                      color: Colors.white,
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ExpansionTile(
                        leading: Image.asset(region.imagePath, width: 40),
                        title: Text(region.name, style: GoogleFonts.pressStart2p(fontSize: 10, color: Colors.black)),
                        children: region.facts.map((fact) => ListTile(
                          leading: const Icon(Icons.star, size: 10, color: Colors.orange),
                          title: Text(fact, style: const TextStyle(fontSize: 12)),
                        )).toList(),
                      ),
                    );
                  },
                ),

                // --- TAB 2: SANAY ---
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: Colors.brown[50],
                              border: Border.all(color: Colors.brown),
                              borderRadius: BorderRadius.circular(10)
                            ),
                            child: Text(
                              question,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.pressStart2p(fontSize: 10, height: 1.5, color: Colors.black),
                            ),
                          ),
                          const SizedBox(height: 15),
                          
                          ...options.map((opt) {
                            Color btnColor = Colors.white;
                            Color txtColor = Colors.black;
                            if (revealAnswer && opt == correctAnswer) {
                              btnColor = Colors.greenAccent;
                            }
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: btnColor,
                                    foregroundColor: txtColor,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                                  ),
                                  onPressed: () => _handleAnswer(opt),
                                  child: Text(opt, style: GoogleFonts.pressStart2p(fontSize: 9)),
                                ),
                              ),
                            );
                          }).toList(),
                          
                          const SizedBox(height: 20),
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                                onPressed: _revealAnswer,
                                child: const Icon(Icons.visibility, color: Colors.white),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                                onPressed: () => _generateRandomQuestion(),
                                child: Text("NEXT", style: GoogleFonts.pressStart2p(fontSize: 10, color: Colors.white)),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),

                    if (showCorrect)
                      const Icon(Icons.check_circle, color: Colors.green, size: 100),
                    if (showWrong)
                      const Icon(Icons.cancel, color: Colors.red, size: 100),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 10),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("CLOSE", style: GoogleFonts.pressStart2p(fontSize: 10, color: Colors.red)),
          )
        ],
      ),
    );
  }
}