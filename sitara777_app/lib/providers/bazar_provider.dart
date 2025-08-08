import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/bazar.dart';

class BazarProvider with ChangeNotifier {
  List<Bazar> _bazaars = [
    // Kalyan Markets
    Bazar(
      id: 'kalyan',
      name: 'Kalyan',
      shortName: 'KL',
      openTime: '04:30 PM',
      closeTime: '06:30 PM',
      status: BazarStatus.betting,
      todayResult: BazarResult(
        open: '678',
        close: '123',
        jodi: '91',
        date: DateTime.now(),
      ),
      primaryColor: const Color(0xFF663399),
      secondaryColor: const Color(0xFF442266),
      icon: Icons.local_fire_department,
      isPopular: true,
      gameTypes: ['single_panna', 'double_panna', 'triple_panna', 'jodi', 'sangam'],
    ),
    Bazar(
      id: 'kalyan_night',
      name: 'Kalyan Night',
      shortName: 'KN',
      openTime: '09:00 PM',
      closeTime: '11:00 PM',
      status: BazarStatus.open,
      primaryColor: const Color(0xFF336699),
      secondaryColor: const Color(0xFF224466),
      icon: Icons.nightlight_round,
      isPopular: true,
      gameTypes: ['single_panna', 'double_panna', 'jodi', 'sangam'],
    ),
    
    // Milan Markets
    Bazar(
      id: 'milan_day',
      name: 'Milan Day',
      shortName: 'MD',
      openTime: '01:00 PM',
      closeTime: '03:00 PM',
      status: BazarStatus.closed,
      todayResult: BazarResult(
        open: '456',
        close: '789',
        jodi: '34',
        date: DateTime.now(),
      ),
      primaryColor: const Color(0xFF009688),
      secondaryColor: const Color(0xFF00695C),
      icon: Icons.wb_sunny,
      isPopular: true,
      gameTypes: ['single_panna', 'double_panna', 'triple_panna', 'jodi'],
    ),
    Bazar(
      id: 'milan_night',
      name: 'Milan Night',
      shortName: 'MN',
      openTime: '10:00 PM',
      closeTime: '12:00 AM',
      status: BazarStatus.open,
      primaryColor: const Color(0xFF512DA8),
      secondaryColor: const Color(0xFF311B92),
      icon: Icons.nights_stay,
      gameTypes: ['single_panna', 'double_panna', 'jodi'],
    ),
    
    // Rajdhani Markets
    Bazar(
      id: 'rajdhani_day',
      name: 'Rajdhani Day',
      shortName: 'RD',
      openTime: '02:00 PM',
      closeTime: '04:00 PM',
      status: BazarStatus.closed,
      todayResult: BazarResult(
        open: '234',
        close: '567',
        jodi: '01',
        date: DateTime.now(),
      ),
      primaryColor: const Color(0xFFD32F2F),
      secondaryColor: const Color(0xFFB71C1C),
      icon: Icons.account_balance,
      isPopular: true,
      gameTypes: ['single_panna', 'double_panna', 'triple_panna', 'jodi', 'sangam'],
    ),
    Bazar(
      id: 'rajdhani_night',
      name: 'Rajdhani Night',
      shortName: 'RN',
      openTime: '08:30 PM',
      closeTime: '10:30 PM',
      status: BazarStatus.betting,
      primaryColor: const Color(0xFF7B1FA2),
      secondaryColor: const Color(0xFF4A148C),
      icon: Icons.nights_stay,
      gameTypes: ['single_panna', 'double_panna', 'jodi', 'sangam'],
    ),
    
    // Time Bazar
    Bazar(
      id: 'time_bazar',
      name: 'Time Bazar',
      shortName: 'TB',
      openTime: '11:30 AM',
      closeTime: '01:30 PM',
      status: BazarStatus.closed,
      todayResult: BazarResult(
        open: '890',
        close: '345',
        jodi: '23',
        date: DateTime.now(),
      ),
      primaryColor: const Color(0xFFFF5722),
      secondaryColor: const Color(0xFFD84315),
      icon: Icons.access_time,
      isPopular: true,
      gameTypes: ['single_panna', 'double_panna', 'triple_panna', 'jodi'],
    ),
    
    // Main Mumbai
    Bazar(
      id: 'main_mumbai',
      name: 'Main Mumbai',
      shortName: 'MM',
      openTime: '03:00 PM',
      closeTime: '05:00 PM',
      status: BazarStatus.betting,
      primaryColor: const Color(0xFF1976D2),
      secondaryColor: const Color(0xFF0D47A1),
      icon: Icons.location_city,
      gameTypes: ['single_panna', 'double_panna', 'jodi', 'sangam'],
    ),
    
    // Main Ratan
    Bazar(
      id: 'main_ratan',
      name: 'Main Ratan',
      shortName: 'MR',
      openTime: '05:00 PM',
      closeTime: '07:00 PM',
      status: BazarStatus.open,
      primaryColor: const Color(0xFFFFB300),
      secondaryColor: const Color(0xFFFF8F00),
      icon: Icons.diamond,
      gameTypes: ['single_panna', 'double_panna', 'triple_panna', 'jodi'],
    ),
    
    // Sridevi
    Bazar(
      id: 'sridevi',
      name: 'Sridevi',
      shortName: 'SD',
      openTime: '12:00 PM',
      closeTime: '02:00 PM',
      status: BazarStatus.closed,
      todayResult: BazarResult(
        open: '567',
        close: '890',
        jodi: '45',
        date: DateTime.now(),
      ),
      primaryColor: const Color(0xFFE91E63),
      secondaryColor: const Color(0xFFAD1457),
      icon: Icons.star,
      gameTypes: ['single_panna', 'double_panna', 'jodi'],
    ),
    
    // Madhur Morning
    Bazar(
      id: 'madhur_morning',
      name: 'Madhur Morning',
      shortName: 'MM',
      openTime: '10:00 AM',
      closeTime: '12:00 PM',
      status: BazarStatus.closed,
      todayResult: BazarResult(
        open: '123',
        close: '456',
        jodi: '78',
        date: DateTime.now(),
      ),
      primaryColor: const Color(0xFF4CAF50),
      secondaryColor: const Color(0xFF2E7D32),
      icon: Icons.wb_sunny_outlined,
      gameTypes: ['single_panna', 'double_panna', 'jodi'],
    ),
    
    // Madhuri
    Bazar(
      id: 'madhuri',
      name: 'Madhuri',
      shortName: 'MDR',
      openTime: '06:00 PM',
      closeTime: '08:00 PM',
      status: BazarStatus.open,
      primaryColor: const Color(0xFF795548),
      secondaryColor: const Color(0xFF5D4037),
      icon: Icons.favorite,
      gameTypes: ['single_panna', 'double_panna', 'triple_panna', 'jodi'],
    ),
    
    // Supreme Day
    Bazar(
      id: 'supreme_day',
      name: 'Supreme Day',
      shortName: 'SPD',
      openTime: '01:30 PM',
      closeTime: '03:30 PM',
      status: BazarStatus.closed,
      primaryColor: const Color(0xFF607D8B),
      secondaryColor: const Color(0xFF37474F),
      icon: Icons.military_tech,
      gameTypes: ['single_panna', 'double_panna', 'jodi', 'sangam'],
    ),
    
    // Kuber
    Bazar(
      id: 'kuber',
      name: 'Kuber',
      shortName: 'KB',
      openTime: '07:00 PM',
      closeTime: '09:00 PM',
      status: BazarStatus.betting,
      primaryColor: const Color(0xFF8BC34A),
      secondaryColor: const Color(0xFF689F38),
      icon: Icons.attach_money,
      gameTypes: ['single_panna', 'double_panna', 'jodi'],
    ),
    
    // Kuber Express
    Bazar(
      id: 'kuber_express',
      name: 'Kuber Express',
      shortName: 'KE',
      openTime: '11:00 PM',
      closeTime: '01:00 AM',
      status: BazarStatus.open,
      primaryColor: const Color(0xFFFF9800),
      secondaryColor: const Color(0xFFEF6C00),
      icon: Icons.flash_on,
      gameTypes: ['single_panna', 'double_panna', 'triple_panna', 'jodi'],
    ),
  ];

  List<Bazar> get bazaars => _bazaars;

  void updateStatus(String id, BazarStatus status) {
    final index = _bazaars.indexWhere((bazar) => bazar.id == id);
    if (index != -1) {
      _bazaars[index] = Bazar(
        id: _bazaars[index].id,
        name: _bazaars[index].name,
        shortName: _bazaars[index].shortName,
        openTime: _bazaars[index].openTime,
        closeTime: _bazaars[index].closeTime,
        status: status,
        todayResult: _bazaars[index].todayResult,
        primaryColor: _bazaars[index].primaryColor,
        secondaryColor: _bazaars[index].secondaryColor,
        icon: _bazaars[index].icon,
        isPopular: _bazaars[index].isPopular,
        gameTypes: _bazaars[index].gameTypes,
      );
      notifyListeners();
    }
  }
}

