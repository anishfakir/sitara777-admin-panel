enum GameType {
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
}

class GameTypeModel {
  final String id;
  final String name;
  final String description;
  final String iconPath;
  final List<String> rules;

  GameTypeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.iconPath,
    required this.rules,
  });

  static List<GameTypeModel> getAllGameTypes() {
    return [
      GameTypeModel(
        id: 'single_panna',
        name: 'Single Panna',
        description: 'Single digit game play',
        iconPath: 'assets/icons/single_panna.png',
        rules: ['Choose single digits', 'Minimum bet: ₹10', 'Maximum bet: ₹50,000'],
      ),
      GameTypeModel(
        id: 'double_panna',
        name: 'Double Panna',
        description: 'Double digit game play',
        iconPath: 'assets/icons/double_panna.png',
        rules: ['Choose double digits', 'Minimum bet: ₹10', 'Maximum bet: ₹50,000'],
      ),
      GameTypeModel(
        id: 'triple_panna',
        name: 'Triple Panna',
        description: 'Triple digit game play',
        iconPath: 'assets/icons/triple_panna.png',
        rules: ['Choose triple digits', 'Minimum bet: ₹10', 'Maximum bet: ₹50,000'],
      ),
      GameTypeModel(
        id: 'jodi',
        name: 'Jodi',
        description: 'Two digit combination',
        iconPath: 'assets/icons/jodi.png',
        rules: ['Choose two digit combination', 'Minimum bet: ₹10', 'Maximum bet: ₹50,000'],
      ),
      GameTypeModel(
        id: 'sangam',
        name: 'Sangam',
        description: 'Open to close combination',
        iconPath: 'assets/icons/sangam.png',
        rules: ['Open and close combination', 'Minimum bet: ₹10', 'Maximum bet: ₹50,000'],
      ),
      GameTypeModel(
        id: 'dp_motor',
        name: 'DP Motor',
        description: 'Double Panna Motor game',
        iconPath: 'assets/icons/dp_motor.png',
        rules: ['Double Panna Motor play', 'Minimum bet: ₹10', 'Maximum bet: ₹50,000'],
      ),
      GameTypeModel(
        id: 'panel',
        name: 'Panel',
        description: 'Panel number game',
        iconPath: 'assets/icons/panel.png',
        rules: ['Choose panel numbers', 'Minimum bet: ₹10', 'Maximum bet: ₹50,000'],
      ),
      GameTypeModel(
        id: 'full_sangam',
        name: 'Full Sangam',
        description: 'Full Sangam combination',
        iconPath: 'assets/icons/full_sangam.png',
        rules: ['Full Sangam play', 'Minimum bet: ₹10', 'Maximum bet: ₹50,000'],
      ),
      GameTypeModel(
        id: 'single_digit',
        name: 'Single Digit',
        description: 'Single digit selection',
        iconPath: 'assets/icons/single_digit.png',
        rules: ['Choose single digit 0-9', 'Minimum bet: ₹10', 'Maximum bet: ₹50,000'],
      ),
      GameTypeModel(
        id: 'half_sangam',
        name: 'Half Sangam',
        description: 'Half Sangam combination',
        iconPath: 'assets/icons/half_sangam.png',
        rules: ['Half Sangam play', 'Minimum bet: ₹10', 'Maximum bet: ₹50,000'],
      ),
    ];
  }
}
