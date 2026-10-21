import 'package:flutter/material.dart';

class RegionItem {
  final String id;
  final String name;
  final String imagePath;
  final List<String> facts;
  final Alignment alignment;

  RegionItem({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.facts,
    required this.alignment, 
  });
}

// --- FINALIZED LUZON DATA (ENGLISH NAME + TAGALOG FACTS) ---
final List<RegionItem> luzonRegions = [
  // --- NORTHERN CLUSTER ---
  RegionItem(
    id: 'region1', 
    name: 'Ilocos Region', // ENGLISH NAME
    imagePath: 'assets/images/maps/region1.png',
    alignment: const Alignment(-0.11, -0.31), 
    facts: [
      "Kilala ang Rehiyon 1 sa mga lumang bahay na Kastila sa Vigan.",
      "Ito ang 'Salt-making Capital' ng Pilipinas.",
      "Sikat ang Ilocos sa kanilang Empanada at Bagnet.",
      "Matatagpuan dito ang mga Windmill ng Bangui.",
      "Dito makikita ang Simbahan ng Paoay."
    ],
  ),
  RegionItem(
    id: 'car', 
    name: 'Cordillera (CAR)', // ENGLISH NAME
    imagePath: 'assets/images/maps/car.png',
    alignment: const Alignment(0.11, -0.48), 
    facts: [
      "Ang tanging rehiyon sa Pilipinas na napapaligiran ng lupa.",
      "Tahanan ng sikat na Banaue Rice Terraces.",
      "Ang Baguio City ang tinaguriang 'Summer Capital' ng bansa.",
      "Kilala sa kanilang makulay na katutubong kultura.",
      "Dito matatagpuan ang Bundok Pulag."
    ],
  ),
  RegionItem(
    id: 'region2', 
    name: 'Cagayan Valley', // ENGLISH NAME
    imagePath: 'assets/images/maps/region2.png',
    alignment: const Alignment(0.31, -0.40), 
    facts: [
      "Ang Rehiyon 2 ay ang 'Tilapia Capital ng Pilipinas'.",
      "Ito ang pangunahing prodyuser ng mais sa bansa.",
      "Ang Callao Cave ay isang sikat na pasyalan dito.",
      "Matatagpuan sa pagitan ng bulubundukin ng Cordillera at Sierra Madre.",
      "Ang Batanes ay bahagi ng rehiyong ito."
    ],
  ),
  
  // --- CENTRAL CLUSTER ---
  RegionItem(
    id: 'region3', 
    name: 'Central Luzon', // ENGLISH NAME
    imagePath: 'assets/images/maps/region3.png',
    alignment: const Alignment(0.01, -0.13), 
    facts: [
      "Kilala bilang 'Rice Granary' o Bangan ng Palay ng Pilipinas.",
      "Tahanan ng Bundok Pinatubo.",
      "Pangunahing pinagkukunan ng asukal at mais.",
      "Ang Aurora ay sikat na destinasyon para sa surfing.",
      "Sikat sa mga dambuhalang parol ng Pampanga."
    ],
  ),
  RegionItem(
    id: 'ncr', 
    name: 'NCR (Metro Manila)', // ENGLISH NAME
    imagePath: 'assets/images/maps/ncr.png',
    alignment: const Alignment(0.07, 0.01), 
    facts: [
      "Ang sentro ng pulitika at ekonomiya ng bansa.",
      "Ang tanging rehiyon na walang mga probinsya.",
      "Dito makikita ang Rizal Park at Intramuros.",
      "Ang pinakamaliit na rehiyon base sa lawak ng lupa.",
      "Ang Maynila ay isa sa mga pinakamatandang lungsod."
    ],
  ),
  RegionItem(
    id: 'region4a', 
    name: 'CALABARZON', // ENGLISH NAME
    imagePath: 'assets/images/maps/region4a.png',
    alignment: const Alignment(0.19, 0.07), 
    facts: [
      "Ang rehiyong may pinakamalaking populasyon.",
      "Binubuo ng Cavite, Laguna, Batangas, Rizal, at Quezon.",
      "Tahanan ng Bulkang Taal.",
      "Dito matatagpuan ang Dambana ni Aguinaldo.",
      "Nandito ang Talon ng Pagsanjan."
    ],
  ),

  // --- SOUTHERN ISLANDS ---
  RegionItem(
    id: 'mimaropa', 
    name: 'MIMAROPA', // ENGLISH NAME
    imagePath: 'assets/images/maps/mimaropa.png',
    alignment: const Alignment(0.10, 0.26), 
    facts: [
      "Binubuo ng Mindoro, Marinduque, Romblon, at Palawan.",
      "Tahanan ng Puerto Princesa Underground River.",
      "Ang Romblon ay ang 'Marble Capital' ng Pilipinas.",
      "Ang Apo Reef ay ang pinakamalaking coral reef system dito.",
      "Ang Tubbataha Reefs ay isang UNESCO World Heritage Site."
    ],
  ),
  RegionItem(
    id: 'region5', 
    name: 'Bicol Region', // ENGLISH NAME
    imagePath: 'assets/images/maps/region5.png',
    alignment: const Alignment(0.64, 0.17), 
    facts: [
      "Sikat dahil sa perpektong hugis ng Bulkang Mayon.",
      "Kilala sa anghang ng Bicol Express.",
      "Ang Donsol ay dinadayo para sa mga Butanding (Whale Sharks).",
      "Tahanan ng Peñafrancia Festival.",
      "Pangunahing prodyuser ng Abaca."
    ],
  ),
];