import 'package:flutter/material.dart';

class RegionItem {
  final String id;
  final String name;
  final String imagePath;
  final List<String> facts;
  final Alignment alignment;
  final double size;

  RegionItem({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.facts,
    required this.alignment,
    this.size = 160, 
  });
}

// --- VISAYAS DATA (TAGALOG VERSION) ---
final List<RegionItem> visayasRegions = [
  RegionItem(
    id: 'region6', 
    name: 'Western Visayas', // Western Visayas
    imagePath: 'assets/images/maps/region6.png', 
    alignment: const Alignment(-0.33, 0.06), 
    size: 150, 
    facts: [
      "Matatagpuan dito ang sikat na isla ng Boracay.",
      "Kilala sa makulay na Dinagyang Festival ng Iloilo.",
      "Tanyag sa pinakamatatamis na mangga ng Guimaras.",
      "Dito ipinagdiriwang ang MassKara Festival.",
      "Dito orihinal na nagmula ang La Paz Batchoy."
    ],
  ),
  RegionItem(
    id: 'region7', 
    name: 'Central Visayas', // Central Visayas
    imagePath: 'assets/images/maps/region7.png',
    alignment: const Alignment(-0.06, 0.17), 
    size: 140, 
    facts: [
      "Dito makikita ang Chocolate Hills ng Bohol.",
      "Ang Cebu City ay tinaguriang 'Queen City of the South'.",
      "Kilala sa grandiyosong Sinulog Festival.",
      "Dito nakatira ang maliliit na Tarsier.",
      "Dito matatagpuan ang makasaysayang Magellan's Cross."
    ],
  ),
  RegionItem(
    id: 'region8', 
    name: ' Eastern Visayas', // Eastern Visayas
    imagePath: 'assets/images/maps/region8.png',
    alignment: const Alignment(0.33, -0.07), 
    size: 160, 
    facts: [
      "Ang San Juanico Bridge ang tulay sa pagitan ng Samar at Leyte.",
      "Dito dumaong si General MacArthur noong World War II.",
      "Kilala sa Pintados-Kasadyaan Festival.",
      "Matatagpuan dito ang Sohoton Caves.",
      "Ito ang rehiyon na nakaharap sa Karagatang Pasipiko."
    ],
  ),
];