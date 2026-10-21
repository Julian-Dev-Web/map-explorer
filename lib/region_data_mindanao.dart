import 'package:flutter/material.dart';

class RegionItem {
  final String id;
  final String name;
  final String imagePath;
  final Alignment alignment;
  final double size;
  final List<String> facts;

  RegionItem({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.alignment,
    required this.size,
    required this.facts,
  });
}

// --- MINDANAO REGIONS DATA (6 REGIONS) ---
// Note: Lahat naka-Center (0,0) muna para sa Calibration
final List<RegionItem> mindanaoRegions = [
  RegionItem(
    id: 'region9',
    name: 'Zamboanga Peninsula',
    imagePath: 'assets/images/maps/region9.png',
    alignment: const Alignment(0.04, -0.04), // CHANGE LATER IF NEEDED
    size: 135,
    facts: [
      "Ang Rehiyon 9 ay tinatawag na Zamboanga Peninsula.",
      "Matatagpuan dito ang Zamboanga City na kilala bilang 'Asia's Latin City'.",
      "Sikat ang Santa Cruz Island dahil sa pink sand beach nito.",
    ],
  ),
  RegionItem(
    id: 'region10',
    name: 'Northern Mindanao',
    imagePath: 'assets/images/maps/region10.png',
    alignment: const Alignment(0.43, -0.07), // CHANGE LATER IF NEEDED
    size: 135,
    facts: [
      "Ang Rehiyon 10 ay tinatawag na Northern Mindanao.",
      "Matatagpuan dito ang Camiguin na kilala bilang 'Island Born of Fire'.",
      "Kilala ang Bukidnon bilang 'Pineapple Capital of the Philippines'.",
    ],
  ),
  RegionItem(
    id: 'region11',
    name: 'Davao Region',
    imagePath: 'assets/images/maps/region11.png',
    alignment: const Alignment(0.62, 0.07), // CHANGE LATER IF NEEDED
    size: 135,
    facts: [
      "Ang Rehiyon 11 ay tinatawag na Davao Region.",
      "Dito matatagpuan ang Bundok Apo, ang pinakamataas na bundok sa Pilipinas.",
      "Kilala ang Davao bilang 'Durian Capital of the Philippines'.",
    ],
  ),
  RegionItem(
    id: 'region12',
    name: 'SOCCSKSARGEN',
    imagePath: 'assets/images/maps/region12.png',
    alignment: const Alignment(0.42, 0.16), // CHANGE LATER IF NEEDED
    size: 135,
    facts: [
      "Ang Rehiyon 12 ay tinatawag na SOCCSKSARGEN.",
      "Matatagpuan dito ang General Santos City na kilala bilang 'Tuna Capital'.",
      "Ang pangalan ng rehiyon ay mula sa South Cotabato, Cotabato, Sultan Kudarat, Sarangani, at GenSan.",
    ],
  ),
  RegionItem(
    id: 'region13',
    name: 'Caraga',
    imagePath: 'assets/images/maps/region13.png',
    alignment: const Alignment(0.62, -0.12), // CHANGE LATER IF NEEDED
    size: 135,
    facts: [
      "Ang Rehiyon 13 ay tinatawag na Caraga Region.",
      "Matatagpuan dito ang Siargao na kilala bilang 'Surfing Capital of the Philippines'.",
      "Mayaman ang rehiyon sa likas na yaman, lalo na sa pagmimina.",
    ],
  ),
  RegionItem(
    id: 'barmm',
    name: 'BARMM',
    imagePath: 'assets/images/maps/barmm.png',
    alignment: const Alignment(0.32, 0.07), // CHANGE LATER IF NEEDED
    size: 135,
    facts: [
      "Ang BARMM ay nangangahulugang Bangsamoro Autonomous Region in Muslim Mindanao.",
      "Matatagpuan dito ang Grand Mosque sa Cotabato.",
      "Mayaman ang rehiyon sa kulturang Muslim at kasaysayan ng Islam.",
    ],
  ),
];
