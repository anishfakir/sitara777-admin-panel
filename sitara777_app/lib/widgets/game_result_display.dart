import 'package:flutter/material.dart';

class GameResultDisplay extends StatelessWidget {
  final String title;
  final String result;
  final Color? color;
  final VoidCallback? onTap;

  const GameResultDisplay({
    Key? key,
    required this.title,
    required this.result,
    this.color,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                (color ?? Colors.blue).withOpacity(0.1),
                (color ?? Colors.blue).withOpacity(0.05),
              ],
            ),
          ),
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color ?? Colors.blue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                result,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color ?? Colors.blue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 