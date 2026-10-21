import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart'; 
import 'audio_manager.dart';
import 'island_selection_screen.dart';
import 'main.dart'; 

// --- ACHIEVEMENT MODEL ---
class Achievement {
  final String id;
  final String title;
  final String description;
  final String imagePath; 
  final IconData fallbackIcon; 
  bool isUnlocked; 

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.fallbackIcon,
    this.isUnlocked = false, 
  });
}

class CharacterSelectionScreen extends StatefulWidget {
  const CharacterSelectionScreen({super.key});

  @override
  State<CharacterSelectionScreen> createState() => _CharacterSelectionScreenState();
}

class _CharacterSelectionScreenState extends State<CharacterSelectionScreen> {
  String? selectedCharacter; // 'boy' or 'girl'
  
  // --- NEW: CONTROLLER PARA SA NAME INPUT ---
  final TextEditingController _nameController = TextEditingController();

  // --- LISTAHAN NG TROPHIES ---
 final List<Achievement> achievements = [
    Achievement(
      id: 'first_step', 
      title: 'FIRST STEP',
      description: 'Nailagay ang unang piraso ng puzzle!', 
      imagePath: 'assets/images/achievements/badge_first.png',
      fallbackIcon: Icons.extension,
    ),
    Achievement(
      id: 'quiz_whiz', 
      title: 'QUIZ WHIZ',
      description: 'Nakakuha ng perpektong iskor sa lahat ng Quiz!', 
      imagePath: 'assets/images/achievements/badge_quiz.png',
      fallbackIcon: Icons.psychology,
    ),
    Achievement(
      id: 'luzon_completed', 
      title: 'LUZON HERO',
      description: 'Nabuo ang Mapa ng Luzon.', 
      imagePath: 'assets/images/achievements/trophy_luzon.png',
      fallbackIcon: Icons.wb_sunny,
    ),
    Achievement(
      id: 'visayas_completed', 
      title: 'VISAYAS VOYAGER',
      description: 'Nabuo ang Mapa ng Visayas.', 
      imagePath: 'assets/images/achievements/trophy_visayas.png',
      fallbackIcon: Icons.sailing,
    ),
    Achievement(
      id: 'mindanao_completed', 
      title: 'MINDANAO MASTER',
      description: 'Nabuo ang Mapa ng Mindanao.', 
      imagePath: 'assets/images/achievements/trophy_mindanao.png',
      fallbackIcon: Icons.landscape,
    ),
    Achievement(
      id: 'bayani',
      title: 'BAYANI',
      description: 'Napag-isa ang buong Pilipinas!', 
      imagePath: 'assets/images/achievements/badge_bayani.png',
      fallbackIcon: Icons.star,
    ),
  ];

  @override
  void initState() {
    super.initState();
    AudioManager().playBGM();
    _loadAchievements(); 
  }

  @override
  void dispose() {
    _nameController.dispose(); // Clean up controller
    super.dispose();
  }

  Future<void> _loadAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      for (var achievement in achievements) {
        achievement.isUnlocked = prefs.getBool(achievement.id) ?? false;
      }
    });
  }

  void _goBackToMain() {
    AudioManager().playSFX('snd_click.wav');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LandingPage()), 
    );
  }

  // --- SAVE NAME & CHARACTER ---
  Future<void> _confirmSelection() async {
    if (selectedCharacter == null) return;

    AudioManager().playSFX('snd_correct.wav');

    // 1. Determine Final Name (Custom or Default)
    String finalName = _nameController.text.trim();
    if (finalName.isEmpty) {
      finalName = selectedCharacter == 'boy' ? 'ANDRES' : 'GABRIELA';
    }

    // 2. Save to SharedPreferences (Important for Certificate later)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('player_name', finalName);
    await prefs.setString('selected_character', selectedCharacter!);

    // 3. Navigate
    if (mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => IslandSelectionScreen(
            selectedCharacter: selectedCharacter! 
          ),
        ),
      );
    }
  }

  // --- POPUP FOR LOCKED ITEMS ---
  void _showLockedDetails(Achievement item) {
    AudioManager().playSFX('snd_click.wav');
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey[900]!.withOpacity(0.95),
                Colors.grey[800]!.withOpacity(0.95),
              ],
            ),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 2),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 3,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // LOCK ICON
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.8, end: 1.0),
                duration: const Duration(milliseconds: 400),
                curve: Curves.bounceOut,
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[700]!.withOpacity(0.5),
                        border: Border.all(
                          color: Colors.grey[400]!.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.lock_outlined,
                        color: Colors.grey,
                        size: 40,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              Text(
                "LOCKED ACHIEVEMENT",
                textAlign: TextAlign.center,
                style: GoogleFonts.pressStart2p(
                  color: Colors.grey[400],
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),

              Text(
                item.title,
                textAlign: TextAlign.center,
                style: GoogleFonts.pressStart2p(
                  color: Colors.amber[300],
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  border: Border.all(
                    color: Colors.amber[700]!.withOpacity(0.3),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      "How to unlock:",
                      style: GoogleFonts.pressStart2p(
                        color: Colors.amber[200],
                        fontSize: 10,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      item.description,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                        height: 1.6,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.grey[700]!, Colors.grey[800]!],
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "GOT IT",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.pressStart2p(
                      color: Colors.white,
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _goBackToMain();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.blue[900],
        // WRAP WITH GESTURE DETECTOR TO DISMISS KEYBOARD
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: [
              // 1. ANIMATED BACKGROUND
              const Positioned.fill(
                child: AnimatedWaveBackground(),
              ),

              // 2. BACK BUTTON
              Positioned(
                top: 40, left: 20,
                child: _buildIconButton(
                  icon: Icons.arrow_back,
                  color: Colors.grey,
                  onTap: _goBackToMain,
                ),
              ),

              // 3. ACHIEVEMENTS BUTTON
              Positioned(
                top: 40, right: 20,
                child: _buildIconButton(
                  icon: Icons.emoji_events, 
                  color: Colors.amber[700]!,
                  onTap: () {
                    AudioManager().playSFX('snd_click.wav');
                    _loadAchievements();
                    _showAchievementsDialog(context);
                  },
                ),
              ),

              // 4. MAIN CONTENT
              Center(
                child: SingleChildScrollView( // Added ScrollView for smaller screens/keyboard
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "CHOOSE HERO",
                        style: GoogleFonts.pressStart2p(
                          color: Colors.white,
                          fontSize: 20,
                          shadows: [const Shadow(color: Colors.black, offset: Offset(4, 4))],
                        ),
                      ),
                      const SizedBox(height: 30),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildCharacterCard(
                            id: 'boy',
                            label: 'ANDRES',
                            color: Colors.blueAccent,
                            openEyesPath: 'assets/images/characters/2boy.png', 
                            closedEyesPath: 'assets/images/characters/1boy.png', 
                          ),
                          const SizedBox(width: 20), 
                          _buildCharacterCard(
                            id: 'girl',
                            label: 'GABRIELA',
                            color: Colors.pinkAccent,
                            openEyesPath: 'assets/images/characters/2girl.png',
                            closedEyesPath: 'assets/images/characters/1girl.png',
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // --- NEW: NAME INPUT FIELD ---
                      AnimatedOpacity(
                        opacity: selectedCharacter != null ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          width: 280,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withOpacity(0.5), width: 2),
                          ),
                          child: TextField(
                            controller: _nameController,
                            style: GoogleFonts.pressStart2p(color: Colors.white, fontSize: 12),
                            textAlign: TextAlign.center,
                            maxLength: 12, // Limit name length
                            decoration: InputDecoration(
                              counterText: "", // Hide counter
                              border: InputBorder.none,
                              hintText: selectedCharacter == 'boy' ? "NAME: ANDRES" : "NAME: GABRIELA",
                              hintStyle: GoogleFonts.pressStart2p(color: Colors.white54, fontSize: 10),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // CONFIRM BUTTON
                      AnimatedOpacity(
                        opacity: selectedCharacter != null ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: GestureDetector(
                          onTap: selectedCharacter != null ? _confirmSelection : null,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              border: Border.all(color: Colors.white, width: 4),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: const [BoxShadow(color: Colors.black54, offset: Offset(4, 4))],
                            ),
                            child: Text(
                              "CONFIRM",
                              style: GoogleFonts.pressStart2p(color: Colors.white, fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildCharacterCard({
    required String id,
    required String label,
    required Color color,
    required String openEyesPath,
    required String closedEyesPath,
  }) {
    bool isSelected = selectedCharacter == id;

    return GestureDetector(
      onTap: () {
        if (!isSelected) AudioManager().playSFX('snd_click.wav');
        setState(() {
          selectedCharacter = id;
          // Reset text if character changes to suggest new default
          // _nameController.clear(); // Optional: Clear name when switching char
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 160, // Slightly smaller to fit keyboard
        height: 240,
        clipBehavior: Clip.hardEdge, 
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color.withOpacity(0.9), color.withOpacity(0.6)],
                )
              : LinearGradient(
                  colors: [Colors.white.withOpacity(0.15), Colors.white.withOpacity(0.05)],
                ),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
            width: isSelected ? 4 : 2,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected 
              ? [
                  BoxShadow(color: color.withOpacity(0.6), blurRadius: 30, spreadRadius: 4, offset: const Offset(0, 10)),
                  BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 5)),
                ]
              : [BoxShadow(color: Colors.black.withOpacity(0.1), offset: const Offset(3, 3), blurRadius: 10)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Transform.scale(
                  scale: isSelected ? 1.3 : 1.2,
                  child: isSelected 
                      ? BlinkingCharacter(openPath: openEyesPath, closedPath: closedEyesPath)
                      : Image.asset(openEyesPath, fit: BoxFit.contain, filterQuality: FilterQuality.none),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.7) : Colors.black.withOpacity(0.4),
                border: Border(top: BorderSide(color: Colors.white.withOpacity(0.2), width: 1)),
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.pressStart2p(color: Colors.white, fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({required IconData icon, required VoidCallback onTap, required Color color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.black, width: 3),
          boxShadow: const [BoxShadow(color: Colors.black54, offset: Offset(3, 3))],
        ),
        child: Icon(icon, color: Colors.white, size: 30),
      ),
    );
  }

  // --- ACHIEVEMENTS DIALOG ---
  void _showAchievementsDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent, 
        insetPadding: const EdgeInsets.all(15), 
        child: Container(
          width: double.infinity,
          height: 600, 
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF1A237E).withOpacity(0.95),
                const Color(0xFF0D47A1).withOpacity(0.95),
              ],
            ),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 30,
                spreadRadius: 5,
              ),
              BoxShadow(
                color: Colors.blue.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.emoji_events, color: Colors.amber, size: 28),
                  const SizedBox(width: 12),
                  Text("ACHIEVEMENTS", 
                    style: GoogleFonts.pressStart2p(
                      color: Colors.amber,
                      fontSize: 16,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amber.withOpacity(0.3), Colors.amber.withOpacity(0)],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // GRID LIST
              Expanded(
                child: Scrollbar(
                  thumbVisibility: true, 
                  thickness: 6,
                  radius: const Radius.circular(10),
                  child: GridView.builder(
                    padding: const EdgeInsets.only(right: 10, bottom: 20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, 
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.85, 
                    ),
                    itemCount: achievements.length,
                    itemBuilder: (context, index) {
                      final item = achievements[index];
                      return _buildTrophyCard(item);
                    },
                  ),
                ),
              ),
              
              const SizedBox(height: 18),
              
              // CLOSE BUTTON
              GestureDetector(
                onTap: () {
                  AudioManager().playSFX('snd_click.wav');
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.red[600]!, Colors.red[700]!],
                    ),
                    border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.red.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    "CLOSE",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.pressStart2p(
                      color: Colors.white,
                      fontSize: 12,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // --- UPDATED TROPHY CARD (WITH TAP TO REVEAL) ---
  Widget _buildTrophyCard(Achievement item) {
    return GestureDetector(
      onTap: () {
        if (!item.isUnlocked) {
          _showLockedDetails(item);
        } else {
          AudioManager().playSFX('snd_correct.wav');
        }
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: item.isUnlocked
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.amber[700]!.withOpacity(0.2),
                    Colors.amber[600]!.withOpacity(0.1),
                  ],
                )
              : LinearGradient(
                  colors: [
                    Colors.grey[800]!.withOpacity(0.3),
                    Colors.grey[900]!.withOpacity(0.2),
                  ],
                ),
          border: Border.all(
            color: item.isUnlocked ? Colors.amber[300]! : Colors.grey.shade600,
            width: item.isUnlocked ? 2.5 : 1.5,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: item.isUnlocked
              ? [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                  ),
                ],
        ),
        child: Column(
          children: [
            // IMAGE AREA
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: item.isUnlocked
                    ? TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.95, end: 1.0),
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeInOut,
                        builder: (context, scale, child) {
                          return Transform.scale(
                            scale: scale,
                            child: Image.asset(
                              item.imagePath,
                              fit: BoxFit.contain,
                              errorBuilder: (ctx, err, stack) =>
                                  Icon(item.fallbackIcon, size: 50, color: Colors.amber),
                            ),
                          );
                        },
                      )
                    : Opacity(
                        opacity: 0.4,
                        child: ColorFiltered(
                          colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.srcIn),
                          child: Image.asset(
                            item.imagePath,
                            fit: BoxFit.contain,
                            errorBuilder: (ctx, err, stack) =>
                                Icon(item.fallbackIcon, size: 50, color: Colors.grey),
                          ),
                        ),
                      ),
              ),
            ),

            // TITLE AREA
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
              decoration: BoxDecoration(
                gradient: item.isUnlocked
                    ? LinearGradient(
                        colors: [Colors.amber[700]!, Colors.amber[800]!],
                      )
                    : LinearGradient(
                        colors: [Colors.grey[800]!, Colors.grey[900]!],
                      ),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(11),
                  bottomRight: Radius.circular(11),
                ),
              ),
              child: Text(
                item.isUnlocked ? item.title : "???",
                textAlign: TextAlign.center,
                style: GoogleFonts.pressStart2p(
                  color: Colors.white,
                  fontSize: 9,
                  letterSpacing: 0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- ANIMATED WAVE BACKGROUND ---
class AnimatedWaveBackground extends StatefulWidget {
  const AnimatedWaveBackground({super.key});

  @override
  State<AnimatedWaveBackground> createState() => _AnimatedWaveBackgroundState();
}

class _AnimatedWaveBackgroundState extends State<AnimatedWaveBackground>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _particleController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _particleController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF87CEEB),
                Color(0xFF4A90E2),
              ],
            ),
          ),
        ),

        // Animated waves
        AnimatedBuilder(
          animation: _waveController,
          builder: (context, child) {
            return CustomPaint(
              painter: WavePainter(
                wavePhase: _waveController.value * 2 * pi,
                opacity: 0.3,
              ),
              size: Size.infinite,
            );
          },
        ),

        // Secondary wave layer
        AnimatedBuilder(
          animation: _waveController,
          builder: (context, child) {
            return CustomPaint(
              painter: WavePainter(
                wavePhase: _waveController.value * 2 * pi + pi / 4,
                opacity: 0.2,
                waveHeight: 15,
              ),
              size: Size.infinite,
            );
          },
        ),

        // Floating particles
        AnimatedBuilder(
          animation: _particleController,
          builder: (context, child) {
            return CustomPaint(
              painter: ParticlePainter(
                progress: _particleController.value,
              ),
              size: Size.infinite,
            );
          },
        ),
      ],
    );
  }
}

// --- WAVE PAINTER ---
class WavePainter extends CustomPainter {
  final double wavePhase;
  final double opacity;
  final double waveHeight;
  final double frequency;

  WavePainter({
    required this.wavePhase,
    this.opacity = 0.3,
    this.waveHeight = 25,
    this.frequency = 0.015,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(opacity)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.6);

    for (double x = 0; x <= size.width; x += 5) {
      final y = size.height * 0.6 +
          sin((x * frequency) + wavePhase) * waveHeight;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WavePainter oldDelegate) => true;
}

// --- PARTICLE PAINTER ---
class ParticlePainter extends CustomPainter {
  final double progress;
  final Random random = Random(42);

  ParticlePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Create animated particles
    for (int i = 0; i < 15; i++) {
      final seed = i * 1.618;
      final x = (size.width * ((seed % 1.0) + progress)) % size.width;
      final y = size.height * 0.2 + sin(seed) * size.height * 0.3;
      final opacity =
          (1 - ((progress - (seed % 1.0)).abs())).clamp(0.0, 1.0);
      final size_ = 2 + sin(seed) * 1.5;

      paint.color = Colors.white.withOpacity(opacity * 0.4);
      canvas.drawCircle(Offset(x, y), size_, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}

// --- BLINKING ANIMATION WIDGET ---
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
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) setState(() => _isEyesOpen = !_isEyesOpen);
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