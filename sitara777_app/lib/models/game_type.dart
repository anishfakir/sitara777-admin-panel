import 'package:flutter/material.dart';

class GameType {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final int minBet;
  final int maxBet;
  final String description;

  const GameType({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.minBet,
    required this.maxBet,
    required this.description,
  });

  static const GameType singlePanna = GameType(
    id: 'single_panna',
    name: 'Single Panna',
    icon: Icons.looks_one,
    color: Colors.blue,
    minBet: 10,
    maxBet: 50000,
    description: 'Single digit game play',
  );

  static const GameType doublePanna = GameType(
    id: 'double_panna',
    name: 'Double Panna',
    icon: Icons.looks_two,
    color: Colors.green,
    minBet: 10,
    maxBet: 50000,
    description: 'Double digit game play',
  );

  static const GameType triplePanna = GameType(
    id: 'triple_panna',
    name: 'Triple Panna',
    icon: Icons.looks_3,
    color: Colors.orange,
    minBet: 10,
    maxBet: 50000,
    description: 'Triple digit game play',
  );

  static const GameType jodi = GameType(
    id: 'jodi',
    name: 'Jodi',
    icon: Icons.join_inner,
    color: Colors.purple,
    minBet: 10,
    maxBet: 50000,
    description: 'Two digit combination',
  );

  static const GameType sangam = GameType(
    id: 'sangam',
    name: 'Sangam',
    icon: Icons.merge_type,
    color: Colors.red,
    minBet: 10,
    maxBet: 50000,
    description: 'Open to close combination',
  );

  static const GameType dpMotor = GameType(
    id: 'dp_motor',
    name: 'DP Motor',
    icon: Icons.motorcycle,
    color: Colors.teal,
    minBet: 10,
    maxBet: 50000,
    description: 'Double Panna Motor game',
  );

  static const GameType panel = GameType(
    id: 'panel',
    name: 'Panel',
    icon: Icons.dashboard,
    color: Colors.indigo,
    minBet: 10,
    maxBet: 50000,
    description: 'Panel number game',
  );

  static const GameType fullSangam = GameType(
    id: 'full_sangam',
    name: 'Full Sangam',
    icon: Icons.fullscreen,
    color: Colors.pink,
    minBet: 10,
    maxBet: 50000,
    description: 'Full Sangam combination',
  );

  static const GameType singleDigit = GameType(
    id: 'single_digit',
    name: 'Single Digit',
    icon: Icons.filter_1,
    color: Colors.cyan,
    minBet: 10,
    maxBet: 50000,
    description: 'Single digit selection',
  );

  static const GameType halfSangam = GameType(
    id: 'half_sangam',
    name: 'Half Sangam',
    icon: Icons.circle_outlined,
    color: Colors.brown,
    minBet: 10,
    maxBet: 50000,
    description: 'Half Sangam combination',
  );

  static List<GameType> get allGameTypes => [
    singlePanna,
    doublePanna,
    triplePanna,
    jodi,
    sangam,
    dpMotor,
    panel,
    fullSangam,
    singleDigit,
    halfSangam,
  ];

  static GameType? getById(String id) {
    try {
      return allGameTypes.firstWhere((type) => type.id == id);
    } catch (e) {
      return null;
    }
  }
}
