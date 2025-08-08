import 'package:flutter/material.dart';

enum BazarStatus {
  open,
  closed,
  betting,
}

class BazarResult {
  final String open;
  final String close;
  final String jodi;
  final DateTime date;

  BazarResult({
    required this.open,
    required this.close,
    required this.jodi,
    required this.date,
  });
}

class Bazar {
  final String id;
  final String name;
  final String shortName;
  final String openTime;
  final String closeTime;
  final BazarStatus status;
  final BazarResult? todayResult;
  final Color primaryColor;
  final Color secondaryColor;
  final IconData icon;
  final bool isPopular;
  final List<String> gameTypes;

  Bazar({
    required this.id,
    required this.name,
    required this.shortName,
    required this.openTime,
    required this.closeTime,
    required this.status,
    this.todayResult,
    required this.primaryColor,
    required this.secondaryColor,
    required this.icon,
    this.isPopular = false,
    required this.gameTypes,
  });

  bool get isOpen => status == BazarStatus.open || status == BazarStatus.betting;
}
