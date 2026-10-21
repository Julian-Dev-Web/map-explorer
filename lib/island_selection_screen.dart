import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import 'audio_manager.dart';
import 'character_selection_screen.dart'; 

// --- IMPORTS NG MGA INTRO SCREENS ---
import 'introduction_screen.dart'; // Luzon Intro (Original)
import 'visayas_intro_screen.dart'; // Visayas Intro (New)
import 'mindanao_intro_screen.dart'; // Mindanao Intro (New)

class IslandSelectionScreen extends StatefulWidget {
  final String selectedCharacter; 

  const IslandSelectionScreen({super.key, this.selectedCharacter = ''});

  @override
  State<IslandSelectionScreen> createState() => _IslandSelectionScreenState();
}

class _IslandSelectionScreenState extends State<IslandSelectionScreen>
    with TickerProviderStateMixin {
  bool isVisayasUnlocked = false; 
  bool isMindanaoUnlocked = false; 
  bool isVisayasCompleted = false; 
  
  // Animation Controllers
  late AnimationController _headerAnimationController;
  late Animation<double> _headerFadeAnimation;
  final List<AnimationController> _cardControllers = [];
  final List<Animation<double>> _cardAnimations = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadProgress(); 
    AudioManager().playBGM();
  }

  void _initializeAnimations() {
    // Header Fade In
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _headerFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _headerAnimationController, curve: Curves.easeOut),
    );
    _headerAnimationController.forward();

    // Card Staggered Animations (3 Cards)
    for (int i = 0; i < 3; i++) {
      final controller = AnimationController(
        duration: const Duration(milliseconds: 600),
        vsync: this,
      );
      final animation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: controller, curve: Curves.elasticOut),
      );
      _cardControllers.add(controller);
      _cardAnimations.add(animation);

      // Delay bawat card para sunod-sunod ang pasok
      Future.delayed(Duration(milliseconds: 300 * i), () {
        if (mounted) controller.forward();
      });
    }
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isVisayasUnlocked = prefs.getBool('visayas_unlocked') ?? false; 
      isMindanaoUnlocked = prefs.getBool('mindanao_unlocked') ?? false; 
      isVisayasCompleted = prefs.getBool('visayas_completed') ?? false;
    });
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    for (var controller in _cardControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const CharacterSelectionScreen()),
        );
        return false; 
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF81D4FA), Color(0xFF42A5F5)], 
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // --- ANIMATED HEADER ---
                FadeTransition(
                  opacity: _headerFadeAnimation,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 25.0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            AudioManager().playSFX('snd_click.wav');
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const CharacterSelectionScreen()),
                            );
                          },
                          child: TweenAnimationBuilder(
                            tween: Tween<double>(begin: 1, end: 1),
                            duration: const Duration(milliseconds: 200),
                            builder: (context, value, child) {
                              return Transform.scale(scale: value, child: child);
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.black, width: 3),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: const [BoxShadow(color: Colors.black38, offset: Offset(0, 4), blurRadius: 0)],
                              ),
                              child: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text("SELECT MAP", style: GoogleFonts.pressStart2p(color: Colors.yellowAccent, fontSize: 22, shadows: [const Shadow(color: Colors.black, offset: Offset(4, 4))]))
                          ),
                        ),
                        const SizedBox(width: 50), 
                      ],
                    ),
                  ),
                ),

                // --- ANIMATED ISLAND LIST ---
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    children: [
                      // 1. LUZON CARD
                      ScaleTransition(
                        scale: _cardAnimations.isNotEmpty ? _cardAnimations[0] : const AlwaysStoppedAnimation(1.0),
                        child: _build3DIslandCard(
                          context: context, 
                          label: "LUZON", 
                          subLabel: "Region 1 - 8",
                          imagePath: 'assets/images/islands/luzon.png', 
                          themeColor: Colors.green, 
                          isLocked: false, 
                          onTap: () {
                              AudioManager().playSFX('snd_click.wav');
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => IntroductionScreen( // Intro muna
                                    selectedCharacter: widget.selectedCharacter
                                  ),
                                ),
                              ).then((_) {
                                 _loadProgress(); 
                              });
                          }
                        ),
                      ),

                      const SizedBox(height: 25),

                      // 2. VISAYAS CARD
                      ScaleTransition(
                        scale: _cardAnimations.isNotEmpty ? _cardAnimations[1] : const AlwaysStoppedAnimation(1.0),
                        child: _build3DIslandCard(
                          context: context, 
                          label: isVisayasCompleted ? "VISAYAS 🏆" : "VISAYAS", 
                          subLabel: "Region 6 - 8", 
                          imagePath: 'assets/images/islands/visayas.png', 
                          themeColor: Colors.orange, 
                          isLocked: !isVisayasUnlocked, 
                          onTap: () {
                            if (isVisayasUnlocked) {
                              AudioManager().playSFX('snd_click.wav');
                              Navigator.push(
                                context, 
                                MaterialPageRoute(
                                  // CHANGE: Updated to point to VisayasIntroScreen
                                  builder: (context) => VisayasIntroScreen(
                                    selectedCharacter: widget.selectedCharacter 
                                  )
                                )
                              ).then((_) => _loadProgress()); 

                            } else {
                              AudioManager().playSFX('snd_wrong.wav');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Complete Luzon first to unlock!"),
                                  duration: Duration(milliseconds: 1000),
                                )
                              );
                            }
                          } 
                        ),
                      ),

                      const SizedBox(height: 25),

                      // 3. MINDANAO CARD
                      ScaleTransition(
                        scale: _cardAnimations.isNotEmpty ? _cardAnimations[2] : const AlwaysStoppedAnimation(1.0),
                        child: _build3DIslandCard(
                          context: context, 
                          label: "MINDANAO", 
                          subLabel: "Region 9 - 13 & BARMM",
                          imagePath: 'assets/images/islands/mindanao.png', 
                          themeColor: Colors.red, 
                          isLocked: !isMindanaoUnlocked, 
                          onTap: () {
                             if (isMindanaoUnlocked) {
                              AudioManager().playSFX('snd_click.wav');
                              
                              Navigator.push(
                                context, 
                                MaterialPageRoute(
                                  // CHANGE: Updated to point to MindanaoIntroScreen
                                  builder: (context) => MindanaoIntroScreen(
                                    selectedCharacter: widget.selectedCharacter
                                  )
                                )
                              ).then((_) => _loadProgress());

                             } else {
                               AudioManager().playSFX('snd_wrong.wav');
                               ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Complete Visayas first to unlock!"),
                                  duration: Duration(milliseconds: 1000),
                                )
                              );
                             }
                          }
                        ),
                      ),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- REUSABLE ANIMATED CARD WIDGET ---
  Widget _build3DIslandCard({
    required BuildContext context, 
    required String label, 
    required String subLabel,
    required String imagePath, 
    required Color themeColor, 
    required bool isLocked, 
    required VoidCallback onTap
  }) {
    return _AnimatedCardWrapper(
      isLocked: isLocked,
      onTap: () {
        if (isLocked) {
          AudioManager().playSFX('snd_wrong.wav'); 
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "Complete previous island first!", 
                style: GoogleFonts.pressStart2p(fontSize: 10, color: Colors.white)
              ),
              backgroundColor: Colors.red[700],
              behavior: SnackBarBehavior.floating, 
              margin: const EdgeInsets.all(20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: Colors.white, width: 2)),
              duration: const Duration(milliseconds: 1000),
            ),
          );
        } else {
          onTap(); 
        }
      },
      child: Container(
        height: 130, 
        decoration: BoxDecoration(
          color: isLocked ? Colors.grey[300] : Colors.white, 
          border: Border.all(color: Colors.black, width: 3),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isLocked ? Colors.black38 : Colors.black54, 
              offset: const Offset(0, 8), 
              blurRadius: 0
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 120,
              height: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: isLocked ? Colors.grey[500] : themeColor.withOpacity(0.2),
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(17), bottomLeft: Radius.circular(17)),
                border: const Border(right: BorderSide(color: Colors.black, width: 3)),
              ),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 1.0, end: 1.0),
                duration: const Duration(milliseconds: 300),
                builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain,
                  cacheWidth: 300, 
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.terrain, size: 50, color: isLocked ? Colors.white54 : themeColor);
                  },
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: GoogleFonts.pressStart2p(fontSize: 16, color: isLocked ? Colors.grey[600] : Colors.black)),
                    const SizedBox(height: 8),
                    Text(subLabel, style: GoogleFonts.pressStart2p(fontSize: 9, color: isLocked ? Colors.grey[500] : Colors.black54)),
                    const SizedBox(height: 12),
                    _AnimatedButton(
                      isLocked: isLocked,
                      themeColor: themeColor,
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- ANIMATED CARD WRAPPER ---
class _AnimatedCardWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final bool isLocked;

  const _AnimatedCardWrapper({
    required this.child,
    required this.onTap,
    required this.isLocked,
  });

  @override
  State<_AnimatedCardWrapper> createState() => _AnimatedCardWrapperState();
}

class _AnimatedCardWrapperState extends State<_AnimatedCardWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}

// --- ANIMATED BUTTON ---
class _AnimatedButton extends StatefulWidget {
  final bool isLocked;
  final Color themeColor;

  const _AnimatedButton({
    required this.isLocked,
    required this.themeColor,
  });

  @override
  State<_AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<_AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticIn),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: widget.isLocked ? Colors.grey[600] : widget.themeColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.isLocked ? Icons.lock : Icons.play_arrow,
              color: Colors.white,
              size: 12,
            ),
            const SizedBox(width: 5),
            Text(
              widget.isLocked ? "LOCKED" : "START",
              style: GoogleFonts.pressStart2p(fontSize: 10, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}