import 'package:flutter/material.dart';

class MatkaGame {
  final String name;
  final String openTime;
  final String closeTime;
  final bool isOpen;
  final IconData? icon;
  final Color? color;
  final bool isSpecial;

  MatkaGame({
    required this.name,
    required this.openTime,
    required this.closeTime,
    required this.isOpen,
    this.icon,
    this.color,
    this.isSpecial = false,
  });
}
