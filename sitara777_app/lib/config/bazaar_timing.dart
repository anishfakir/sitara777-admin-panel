import 'package:flutter/material.dart';

class BazaarTiming {
  final String name;
  final String openTime;
  final String closeTime;
  final int openHour;
  final int openMinute;
  final int closeHour;
  final int closeMinute;
  final String lastResult;
  final IconData icon;
  final Color accentColor;

  BazaarTiming({
    required this.name,
    required this.openTime,
    required this.closeTime,
    required this.openHour,
    required this.openMinute,
    required this.closeHour,
    required this.closeMinute,
    required this.lastResult,
    this.icon = Icons.trending_up,
    this.accentColor = Colors.blue,
  });

  bool get isOpen {
    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;
    
    int openMinutes = openHour * 60 + openMinute;
    int closeMinutes = closeHour * 60 + closeMinute;
    
    // Handle overnight markets (close time is next day)
    if (closeMinutes < openMinutes) {
      closeMinutes += 24 * 60; // Add 24 hours
      if (currentMinutes < openMinutes) {
        return currentMinutes + 24 * 60 >= openMinutes && currentMinutes + 24 * 60 <= closeMinutes;
      }
    }
    
    return currentMinutes >= openMinutes && currentMinutes <= closeMinutes;
  }

  String get statusText => isOpen ? 'MARKET OPEN' : 'MARKET CLOSED';
  Color get statusColor => isOpen ? Colors.green : Colors.red;
  
  String get displayTime => '$openTime - $closeTime';
}

class BazaarTimingConfig {
  static final List<BazaarTiming> allBazaars = [
    // Time based markets
    BazaarTiming(
      name: 'Time Bazar',
      openTime: '09:30 AM',
      closeTime: '11:30 AM',
      openHour: 9,
      openMinute: 30,
      closeHour: 11,
      closeMinute: 30,
      lastResult: '248-45-167',
      icon: Icons.access_time,
      accentColor: Colors.orange,
    ),
    BazaarTiming(
      name: 'Milan Day',
      openTime: '10:00 AM',
      closeTime: '12:00 PM',
      openHour: 10,
      openMinute: 0,
      closeHour: 12,
      closeMinute: 0,
      lastResult: '356-89-234',
      icon: Icons.wb_sunny,
      accentColor: Colors.amber,
    ),
    BazaarTiming(
      name: 'Rajdhani Day',
      openTime: '11:00 AM',
      closeTime: '01:00 PM',
      openHour: 11,
      openMinute: 0,
      closeHour: 13,
      closeMinute: 0,
      lastResult: '789-34-567',
      icon: Icons.account_balance,
      accentColor: Colors.purple,
    ),
    BazaarTiming(
      name: 'Kalyan',
      openTime: '01:30 PM',
      closeTime: '03:30 PM',
      openHour: 13,
      openMinute: 30,
      closeHour: 15,
      closeMinute: 30,
      lastResult: '123-67-890',
      icon: Icons.star,
      accentColor: Colors.deepOrange,
    ),
    BazaarTiming(
      name: 'Milan Night',
      openTime: '09:00 PM',
      closeTime: '11:00 PM',
      openHour: 21,
      openMinute: 0,
      closeHour: 23,
      closeMinute: 0,
      lastResult: '456-12-789',
      icon: Icons.nights_stay,
      accentColor: Colors.indigo,
    ),
    BazaarTiming(
      name: 'Main Bazar',
      openTime: '02:00 PM',
      closeTime: '04:00 PM',
      openHour: 14,
      openMinute: 0,
      closeHour: 16,
      closeMinute: 0,
      lastResult: '678-45-123',
      icon: Icons.store,
      accentColor: Colors.green,
    ),
    BazaarTiming(
      name: 'Kalyan Night',
      openTime: '10:00 PM',
      closeTime: '12:00 AM',
      openHour: 22,
      openMinute: 0,
      closeHour: 24,
      closeMinute: 0,
      lastResult: '234-89-567',
      icon: Icons.star_outline,
      accentColor: Colors.deepPurple,
    ),
    BazaarTiming(
      name: 'Rajdhani Night',
      openTime: '09:30 PM',
      closeTime: '11:30 PM',
      openHour: 21,
      openMinute: 30,
      closeHour: 23,
      closeMinute: 30,
      lastResult: '567-23-891',
      icon: Icons.account_balance_outlined,
      accentColor: Colors.brown,
    ),
    BazaarTiming(
      name: 'Supreme Day',
      openTime: '12:30 PM',
      closeTime: '02:30 PM',
      openHour: 12,
      openMinute: 30,
      closeHour: 14,
      closeMinute: 30,
      lastResult: '891-56-234',
      icon: Icons.emoji_events,
      accentColor: Colors.teal,
    ),
    BazaarTiming(
      name: 'Supreme Night',
      openTime: '08:30 PM',
      closeTime: '10:30 PM',
      openHour: 20,
      openMinute: 30,
      closeHour: 22,
      closeMinute: 30,
      lastResult: '345-78-912',
      icon: Icons.emoji_events_outlined,
      accentColor: Colors.cyan,
    ),
    BazaarTiming(
      name: 'Sridevi',
      openTime: '11:30 AM',
      closeTime: '01:30 PM',
      openHour: 11,
      openMinute: 30,
      closeHour: 13,
      closeMinute: 30,
      lastResult: '912-34-567',
      icon: Icons.favorite,
      accentColor: Colors.pink,
    ),
    BazaarTiming(
      name: 'Sridevi Night',
      openTime: '08:00 PM',
      closeTime: '10:00 PM',
      openHour: 20,
      openMinute: 0,
      closeHour: 22,
      closeMinute: 0,
      lastResult: '678-91-234',
      icon: Icons.favorite_outline,
      accentColor: Colors.pinkAccent,
    ),
    BazaarTiming(
      name: 'Time Night',
      openTime: '09:45 PM',
      closeTime: '11:45 PM',
      openHour: 21,
      openMinute: 45,
      closeHour: 23,
      closeMinute: 45,
      lastResult: '234-67-891',
      icon: Icons.schedule,
      accentColor: Colors.orangeAccent,
    ),
    BazaarTiming(
      name: 'Dhanlaxmi',
      openTime: '01:00 PM',
      closeTime: '03:00 PM',
      openHour: 13,
      openMinute: 0,
      closeHour: 15,
      closeMinute: 0,
      lastResult: '567-89-123',
      icon: Icons.monetization_on,
      accentColor: Colors.amber,
    ),
    BazaarTiming(
      name: 'Dhanlaxmi Night',
      openTime: '08:15 PM',
      closeTime: '10:15 PM',
      openHour: 20,
      openMinute: 15,
      closeHour: 22,
      closeMinute: 15,
      lastResult: '891-23-456',
      icon: Icons.monetization_on_outlined,
      accentColor: Colors.yellow,
    ),
    BazaarTiming(
      name: 'Kuber Day',
      openTime: '02:15 PM',
      closeTime: '04:15 PM',
      openHour: 14,
      openMinute: 15,
      closeHour: 16,
      closeMinute: 15,
      lastResult: '123-45-678',
      icon: Icons.diamond,
      accentColor: Colors.lime,
    ),
    BazaarTiming(
      name: 'Kuber Night',
      openTime: '10:15 PM',
      closeTime: '12:15 AM',
      openHour: 22,
      openMinute: 15,
      closeHour: 24,
      closeMinute: 15,
      lastResult: '456-78-912',
      icon: Icons.diamond_outlined,
      accentColor: Colors.lightGreen,
    ),
    BazaarTiming(
      name: 'Shree Ganesh',
      openTime: '03:00 PM',
      closeTime: '05:00 PM',
      openHour: 15,
      openMinute: 0,
      closeHour: 17,
      closeMinute: 0,
      lastResult: '789-12-345',
      icon: Icons.temple_hindu,
      accentColor: Colors.orange,  
    ),
    BazaarTiming(
      name: 'Shree Ganesh Night',
      openTime: '10:30 PM',
      closeTime: '12:30 AM',
      openHour: 22,
      openMinute: 30,
      closeHour: 24,
      closeMinute: 30,
      lastResult: '345-67-891',
      icon: Icons.temple_buddhist,
      accentColor: Colors.deepOrangeAccent,
    ),
    BazaarTiming(
      name: 'Gold Star',
      openTime: '03:30 PM',
      closeTime: '05:30 PM',
      openHour: 15,
      openMinute: 30,
      closeHour: 17,
      closeMinute: 30,
      lastResult: '912-34-567',
      icon: Icons.star_rate,
      accentColor: Colors.yellow,
    ),
    BazaarTiming(
      name: 'Gold Star Night',
      openTime: '11:00 PM',
      closeTime: '01:00 AM',
      openHour: 23,
      openMinute: 0,
      closeHour: 25,
      closeMinute: 0,
      lastResult: '678-91-234',
      icon: Icons.star_rate_outlined,
      accentColor: Colors.amber,
    ),
    BazaarTiming(
      name: 'Diamond Day',
      openTime: '04:00 PM',
      closeTime: '06:00 PM',
      openHour: 16,
      openMinute: 0,
      closeHour: 18,
      closeMinute: 0,
      lastResult: '234-56-789',
      icon: Icons.diamond_sharp,
      accentColor: Colors.blue,
    ),
    BazaarTiming(
      name: 'Diamond Night',
      openTime: '11:30 PM',
      closeTime: '01:30 AM',
      openHour: 23,
      openMinute: 30,
      closeHour: 25,
      closeMinute: 30,
      lastResult: '567-89-123',
      icon: Icons.diamond_outlined,
      accentColor: Colors.blueAccent,
    ),
    BazaarTiming(
      name: 'Kalyan Gold',
      openTime: '04:30 PM',
      closeTime: '06:30 PM',
      openHour: 16,
      openMinute: 30,
      closeHour: 18,
      closeMinute: 30,
      lastResult: '891-23-456',
      icon: Icons.stars,
      accentColor: Colors.yellow,
    ),
    BazaarTiming(
      name: 'Kalyan Platinum',
      openTime: '05:00 PM',
      closeTime: '07:00 PM',
      openHour: 17,
      openMinute: 0,
      closeHour: 19,
      closeMinute: 0,
      lastResult: '123-45-678',
      icon: Icons.workspace_premium,
      accentColor: Colors.grey,
    ),
    BazaarTiming(
      name: 'Kalyan Silver',
      openTime: '05:30 PM',
      closeTime: '07:30 PM',
      openHour: 17,
      openMinute: 30,
      closeHour: 19,
      closeMinute: 30,
      lastResult: '456-78-912',
      icon: Icons.military_tech,
      accentColor: Colors.blueGrey,
    ),
    BazaarTiming(
      name: 'Mumbai Star',
      openTime: '06:00 PM',
      closeTime: '08:00 PM',
      openHour: 18,
      openMinute: 0,
      closeHour: 20,
      closeMinute: 0,
      lastResult: '789-12-345',
      icon: Icons.location_city,
      accentColor: Colors.indigo,
    ),
    BazaarTiming(
      name: 'Mumbai Star Night',
      openTime: '12:00 AM',
      closeTime: '02:00 AM',
      openHour: 0,
      openMinute: 0,
      closeHour: 2,
      closeMinute: 0,
      lastResult: '345-67-891',
      icon: Icons.location_city_outlined,
      accentColor: Colors.indigoAccent,
    ),
  ];

  static List<BazaarTiming> get openBazaars {
    return allBazaars.where((bazaar) => bazaar.isOpen).toList();
  }

  static List<BazaarTiming> get closedBazaars {
    return allBazaars.where((bazaar) => !bazaar.isOpen).toList();
  }

  static BazaarTiming? getBazaarByName(String name) {
    try {
      return allBazaars.firstWhere((bazaar) => bazaar.name.toLowerCase() == name.toLowerCase());
    } catch (e) {
      return null;
    }
  }

  static List<BazaarTiming> get dayBazaars {
    return allBazaars.where((bazaar) => 
      bazaar.openHour >= 6 && bazaar.openHour < 18
    ).toList();
  }

  static List<BazaarTiming> get nightBazaars {
    return allBazaars.where((bazaar) => 
      bazaar.openHour >= 18 || bazaar.openHour < 6
    ).toList();
  }
}
