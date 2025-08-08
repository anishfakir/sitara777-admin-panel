class LocalBazaarData {
  /// Sample local bazaar data - this would be your existing local bazaar list
  static List<Map<String, dynamic>> getLocalBazaars() {
    return [
      {
        'name': 'Kalyan',
        'openTime': '09:00 AM',
        'closeTime': '11:00 PM',
        'isOpen': true,
        'description': 'Kalyan Matka - Most popular bazaar',
      },
      {
        'name': 'Milan Day',
        'openTime': '10:00 AM',
        'closeTime': '10:00 PM',
        'isOpen': true,
        'description': 'Milan Day Matka',
      },
      {
        'name': 'Milan Night',
        'openTime': '10:00 PM',
        'closeTime': '10:00 AM',
        'isOpen': false,
        'description': 'Milan Night Matka',
      },
      {
        'name': 'Rajdhani Day',
        'openTime': '11:00 AM',
        'closeTime': '11:00 PM',
        'isOpen': true,
        'description': 'Rajdhani Day Matka',
      },
      {
        'name': 'Rajdhani Night',
        'openTime': '11:00 PM',
        'closeTime': '11:00 AM',
        'isOpen': false,
        'description': 'Rajdhani Night Matka',
      },
      {
        'name': 'Madhur Day',
        'openTime': '12:00 PM',
        'closeTime': '12:00 AM',
        'isOpen': true,
        'description': 'Madhur Day Matka',
      },
      {
        'name': 'Madhur Night',
        'openTime': '12:00 AM',
        'closeTime': '12:00 PM',
        'isOpen': false,
        'description': 'Madhur Night Matka',
      },
      {
        'name': 'Sridevi',
        'openTime': '01:00 PM',
        'closeTime': '01:00 AM',
        'isOpen': true,
        'description': 'Sridevi Matka',
      },
      {
        'name': 'Gali',
        'openTime': '02:00 PM',
        'closeTime': '02:00 AM',
        'isOpen': true,
        'description': 'Gali Matka',
      },
      {
        'name': 'Disawar',
        'openTime': '03:00 PM',
        'closeTime': '03:00 AM',
        'isOpen': true,
        'description': 'Disawar Matka',
      },
    ];
  }

  /// Get bazaar names from local data
  static List<String> getLocalBazaarNames() {
    return getLocalBazaars().map((bazaar) => bazaar['name'].toString()).toList();
  }

  /// Find bazaar by name in local data
  static Map<String, dynamic>? findBazaarByName(String name) {
    try {
      return getLocalBazaars().firstWhere(
        (bazaar) => bazaar['name']?.toString() == name,
      );
    } catch (e) {
      return null;
    }
  }

  /// Check if bazaar exists in local data
  static bool isBazaarInLocalData(String name) {
    return getLocalBazaarNames().contains(name);
  }
} 