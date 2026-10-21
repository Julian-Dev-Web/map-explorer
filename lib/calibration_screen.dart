import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CalibrationScreen extends StatefulWidget {
  const CalibrationScreen({super.key});

  @override
  State<CalibrationScreen> createState() => _CalibrationScreenState();
}

class _CalibrationScreenState extends State<CalibrationScreen> {
  // Ito ang magpapakita ng last na pinindot mo
  String lastCoordinate = "Tap anywhere!";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF81D4FA),
      appBar: AppBar(
        title: Text("COORDINATE FINDER", style: GoogleFonts.pressStart2p(fontSize: 12)),
        backgroundColor: Colors.blue[900],
      ),
      body: Column(
        children: [
          // OUTPUT AREA
          Container(
            padding: const EdgeInsets.all(20),
            color: Colors.black87,
            width: double.infinity,
            child: Text(
              lastCoordinate,
              style: GoogleFonts.pressStart2p(color: Colors.yellow, fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ),

          // MAP AREA (Touch Sensitive)
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 712 / 1200, // IMPORTANTE: Dapat same ratio sa laro
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return GestureDetector(
                      onTapUp: (details) {
                        // DITO ANG MAGIC: Kinukuha natin ang exact position ng tap mo
                        double width = constraints.maxWidth;
                        double height = constraints.maxHeight;
                        double x = (details.localPosition.dx / width) * 2 - 1;
                        double y = (details.localPosition.dy / height) * 2 - 1;

                        // Round off natin para malinis tignan
                        String finalX = x.toStringAsFixed(2);
                        String finalY = y.toStringAsFixed(2);

                        setState(() {
                          lastCoordinate = "Alignment($finalX, $finalY),";
                        });

                        print("COPY THIS: Alignment($finalX, $finalY),"); // Lalabas din sa Debug Console
                      },
                      child: Stack(
                        children: [
                          // Ang Map Image mo
                          Positioned.fill(
                            child: Opacity(
                              opacity: 0.6,
                              child: Image.asset(
                                'assets/images/maps/luzon_outline.png', 
                                fit: BoxFit.contain
                              ),
                            ),
                          ),
                          // Center Guide (Crosshair)
                          Center(child: Container(width: 2, height: 20, color: Colors.red)),
                          Center(child: Container(width: 20, height: 2, color: Colors.red)),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}