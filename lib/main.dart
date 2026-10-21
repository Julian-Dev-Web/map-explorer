import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'settings_screen.dart';
import 'audio_manager.dart';
import 'character_selection_screen.dart'; 
//import 'calibration_screen.dart'; // Uncomment if needed

void main() {
  runApp(const MapExplorerGame());
}

class MapExplorerGame extends StatelessWidget {
  const MapExplorerGame({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Map Explorer PH',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(textTheme: GoogleFonts.pressStart2pTextTheme()),
      home: const LandingPage(),
    );
  }
}

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    
    // START MUSIC (Safe Call)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AudioManager().playBGM();
    });

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20), 
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // 1. STATIC BACKGROUND
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

          // 2. PIXEL PH MAP
          Center(
            child: Opacity(
              opacity: 0.4,
              child: Image.asset(
                'assets/images/maps/pixel_ph_map.png',
                width: size.width * 5.5,
                fit: BoxFit.contain,
                gaplessPlayback: true,
                errorBuilder: (context, error, stackTrace) => 
                    const Icon(Icons.map, size: 200, color: Colors.white24),
              ),
            ),
          ),

          // 2.5 CLOUDS
          Positioned.fill(
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _controller,
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
          ),

          // 3. WAVES
          Positioned(
            bottom: 0, left: 0, right: 0, height: 140,
            child: RepaintBoundary( 
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) => CustomPaint(
                  painter: WavePainter(
                    animationValue: _controller.value,
                    waveColor: Colors.blue[800]!,
                    waveHeight: 25,
                    speedOffset: 3.0,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0, left: 0, right: 0, height: 110,
            child: RepaintBoundary(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) => CustomPaint(
                  painter: WavePainter(
                    animationValue: _controller.value,
                    waveColor: Colors.blue[500]!,
                    waveHeight: 30,
                    speedOffset: 4.5,
                    phaseShift: math.pi,
                  ),
                ),
              ),
            ),
          ),

          // 4. UI OVERLAYS
          SafeArea(
            child: Stack(
              children: [
                // GUIDE BUTTON
                Positioned(
                  top: 10,  
                  right: 10, 
                  child: _buildEasyClickGuideButton(context),
                ),

                SizedBox(
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      
                      // TITLE IMAGE
                      Expanded(
                        flex: 4, 
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Image.asset(
                            'assets/images/drag.png', 
                            fit: BoxFit.contain,
                            gaplessPlayback: true,
                            errorBuilder: (context, error, stackTrace) => 
                                const Text("MAP EXPLORER PH", style: TextStyle(fontSize: 30, color: Colors.white)),
                          ),
                        ),
                      ),
                      
                      // BUTTONS
                      Expanded(
                        flex: 3, 
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // START BUTTON
                            _buildEnhancedButton(
                              context,
                              label: 'START GAME',
                              icon: Icons.play_arrow_rounded, 
                              color: const Color(0xFFFFA000), // Rich Orange
                              onTap: () {
                                AudioManager().playSFX('snd_click.wav'); 
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const CharacterSelectionScreen()),
                                );
                              },
                            ),
                            
                            const SizedBox(height: 25),
                            
                            // SETTINGS BUTTON
                            _buildEnhancedButton(
                              context,
                              label: 'SETTINGS',
                              icon: Icons.settings,
                              color: const Color(0xFF757575), // Grey
                              onTap: () {
                                AudioManager().playSFX('snd_click.wav');
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- ENHANCED BUTTON STYLE ---
  Widget _buildEnhancedButton(BuildContext context, {required String label, required IconData icon, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 280, 
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 10),
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.white, width: 3), 
          borderRadius: BorderRadius.circular(15), 
          boxShadow: const [
            BoxShadow(
              color: Colors.black54, 
              offset: Offset(0, 6), 
              blurRadius: 0, 
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 28), 
            const SizedBox(width: 15),
            Text(
              label, 
              style: GoogleFonts.pressStart2p(
                color: Colors.white, 
                fontSize: 14,
                shadows: [const Shadow(color: Colors.black, offset: Offset(2, 2))]
              ), 
            ),
          ],
        ),
      ),
    );
  }

  // --- MOVING CLOUDS ---
  Widget _buildMovingCloud(Size size, double startOffset, double top, double speed, double iconSize) {
    double xPos = ((_controller.value * speed) + startOffset) % 1.0 * (size.width + 100) - 50;
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

  // --- GUIDE BUTTON ---
  Widget _buildEasyClickGuideButton(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent, 
      onTap: () {
        AudioManager().playSFX('snd_click.wav');
        _showGuideDialog(context);
      },
      child: Container(
        width: 70,
        height: 70,
        alignment: Alignment.center, 
        color: Colors.transparent, 
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.yellow[700],
            border: Border.all(color: Colors.white, width: 3),
            borderRadius: BorderRadius.circular(15), 
            boxShadow: const [BoxShadow(color: Colors.black54, offset: Offset(0, 4), blurRadius: 0)],
          ),
          child: const Text('?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ),
    );
  }

  // --- UPDATED HOW TO PLAY DIALOG ---
  void _showGuideDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1565C0), // Deep Blue Background
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Colors.white, width: 4),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.help_outline, color: Colors.yellowAccent),
            const SizedBox(width: 10),
            Text("PAANO LARUIN", style: GoogleFonts.pressStart2p(color: Colors.yellowAccent, fontSize: 14)),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          constraints: const BoxConstraints(maxHeight: 400),
          child: Scrollbar(
            thumbVisibility: true,
            thickness: 6,
            radius: const Radius.circular(10),
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(right: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGuideItem(
                    icon: Icons.person,
                    title: "1. PUMILI NG BAYANI",
                    desc: "Mamili kina Andres o Gabriela at bigyan sila ng pangalan."
                  ),
                  _buildGuideItem(
                    icon: Icons.map,
                    title: "2. BUUIN ANG MAPA",
                    desc: "Magsisimula sa Luzon, sunod sa Visayas, at huli sa Mindanao. I-drag ang puzzle piece sa tamang pwesto."
                  ),
                  _buildGuideItem(
                    icon: Icons.favorite,
                    title: "3. 5 LIVES LANG!",
                    desc: "Mag-ingat! May 5 lives ka lang sa paglalagay ng puzzle. Kapag naubos, Game Over at uulit ka."
                  ),
                  _buildGuideItem(
                    icon: Icons.menu_book,
                    title: "4. MAG-REVIEW",
                    desc: "Gamitin ang 'Reviewer' button para mag-aral (Listahan) at mag-ensayo (Mock Quiz)."
                  ),
                  _buildGuideItem(
                    icon: Icons.quiz,
                    title: "5. IPASA ANG QUIZ",
                    desc: "Kailangan mong makakuha ng 3/5 score para ma-unlock ang susunod na isla. Kapag 2 pababa, ulitin ang pagsasanay!"
                  ),
                ],
              ),
            ),
          ),
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10), side: const BorderSide(color: Colors.white, width: 2))
              ),
              onPressed: () => Navigator.pop(context),
              child: Text("NAINTINDIHAN KO", style: GoogleFonts.pressStart2p(color: Colors.white, fontSize: 10)),
            ),
          ),
        ],
      ),
    );
  }

  // --- HELPER FOR GUIDE ITEMS ---
  Widget _buildGuideItem({required IconData icon, required String title, required String desc}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.pressStart2p(color: Colors.amberAccent, fontSize: 10, height: 1.5)),
                const SizedBox(height: 5),
                Text(desc, style: const TextStyle(color: Colors.white, fontSize: 12, height: 1.4)), // Normal font for readability
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  final double animationValue;
  final Color waveColor;
  final double waveHeight;
  final double speedOffset;
  final double phaseShift;

  WavePainter({required this.animationValue, required this.waveColor, required this.waveHeight, this.speedOffset = 1.0, this.phaseShift = 0.0});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = waveColor..style = PaintingStyle.fill;
    final path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, size.height - waveHeight);
    
    for (double i = 0; i <= size.width; i += 20) { 
      path.lineTo(i, size.height - waveHeight - math.sin((i / size.width * 2 * math.pi) + (animationValue * 2 * math.pi * speedOffset) + phaseShift) * waveHeight);
    }
    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) => oldDelegate.animationValue != animationValue;
}