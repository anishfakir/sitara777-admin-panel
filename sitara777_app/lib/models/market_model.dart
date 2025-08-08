import 'package:flutter/material.dart';

class SattaMarket {
  final String id;
  final String name;
  final String whatsappNumber;
  final String resultNumbers; // Format: "569-06-240"
  final String bettingStatus;
  final String openTime;
  final String closeTime;
  final bool isBettingOpen;
  final Color statusColor;

  SattaMarket({
    required this.id,
    required this.name,
    required this.whatsappNumber,
    required this.resultNumbers,
    required this.bettingStatus,
    required this.openTime,
    required this.closeTime,
    required this.isBettingOpen,
    this.statusColor = Colors.red,
  });

  static List<SattaMarket> getSampleMarkets() {
    return [
      SattaMarket(
        id: 'andhra_day',
        name: 'ANDHRA DAY',
        whatsappNumber: '+91 9876543210',
        resultNumbers: '569-06-240',
        bettingStatus: 'Betting is Closed For Today',
        openTime: '3:30 PM',
        closeTime: '5:30 PM',
        isBettingOpen: false,
      ),
      SattaMarket(
        id: 'kamal_day',
        name: 'KAMAL DAY',
        whatsappNumber: '+91 9876543211',
        resultNumbers: '123-45-678',
        bettingStatus: 'Betting is Open',
        openTime: '2:00 PM',
        closeTime: '4:00 PM',
        isBettingOpen: true,
        statusColor: Colors.green,
      ),
      SattaMarket(
        id: 'mahadevi',
        name: 'MAHADEVI',
        whatsappNumber: '+91 9876543212',
        resultNumbers: '789-12-345',
        bettingStatus: 'Betting is Closed For Today',
        openTime: '1:30 PM',
        closeTime: '3:30 PM',
        isBettingOpen: false,
      ),
      SattaMarket(
        id: 'kalyan',
        name: 'KALYAN',
        whatsappNumber: '+91 9876543213',
        resultNumbers: '456-78-901',
        bettingStatus: 'Betting is Open',
        openTime: '4:30 PM',
        closeTime: '6:30 PM',
        isBettingOpen: true,
        statusColor: Colors.green,
      ),
      SattaMarket(
        id: 'milan_day',
        name: 'MILAN DAY',
        whatsappNumber: '+91 9876543214',
        resultNumbers: '234-56-789',
        bettingStatus: 'Betting is Closed For Today',
        openTime: '1:00 PM',
        closeTime: '3:00 PM',
        isBettingOpen: false,
      ),
      SattaMarket(
        id: 'rajdhani_day',
        name: 'RAJDHANI DAY',
        whatsappNumber: '+91 9876543215',
        resultNumbers: '678-90-123',
        bettingStatus: 'Betting is Open',
        openTime: '2:00 PM',
        closeTime: '4:00 PM',
        isBettingOpen: true,
        statusColor: Colors.green,
      ),
    ];
  }
}
