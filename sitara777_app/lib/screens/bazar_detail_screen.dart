import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/bazar_model.dart';
import '../models/game_type_model.dart';
import '../theme/app_theme.dart';
import '../widgets/glassmorphism_card.dart';
import '../widgets/unified_app_bar.dart';
import '../widgets/home_grid_button.dart';
import 'bazar_detail_screen_imports.dart';

class BazarDetailScreen extends StatelessWidget {
  final BazarModel bazar;

  const BazarDetailScreen({Key? key, required this.bazar}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<GameTypeModel> gameTypes = GameTypeModel.getAllGameTypes();

    return Scaffold(
      appBar: UnifiedAppBar(
        title: bazar.name,
        showBackButton: true,
      ),
      backgroundColor: AppTheme.backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlassmorphismCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Open Time: ${bazar.openTime}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        'Close Time: ${bazar.closeTime}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(
                      color: bazar.isOpen
                          ? AppTheme.successColor.withOpacity(0.2)
                          : AppTheme.errorColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      bazar.isOpen ? 'OPEN' : 'CLOSED',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: bazar.isOpen ? AppTheme.successColor : AppTheme.errorColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (bazar.currentResult != null)
                    Text(
                      'Current Result: ${bazar.currentResult}',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.accentColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Charts',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildChartButton(
                    context,
                    'Jodi Chart',
                    Icons.bar_chart,
                    'Weekly jodi results',
                    () => _navigateToJodiChart(context),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildChartButton(
                    context,
                    'Panel Chart',
                    Icons.show_chart,
                    'Daily panel results',
                    () => _navigateToPanelChart(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Games',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemBuilder: (context, index) {
                  final gameType = gameTypes[index];
                  return HomeGridButton(
                    icon: _getGameTypeIcon(gameType.id),
                    title: gameType.name,
                    subtitle: gameType.description,
                    onTap: () {
                      _navigateToGameScreen(context, gameType.id);
                    },
                  );
                },
                itemCount: gameTypes.length,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToGameScreen(BuildContext context, String gameTypeId) {
    Widget? screen;
    
    switch (gameTypeId) {
      case 'single_panna':
        screen = SinglePannaScreen(bazar: bazar);
        break;
      case 'double_panna':
        screen = DoublePannaScreen(bazar: bazar);
        break;
      case 'triple_panna':
        screen = TriplePannaScreen(bazar: bazar);
        break;
      case 'jodi':
        screen = JodiScreen(bazar: bazar);
        break;
      case 'sangam':
        screen = SangamScreen(bazar: bazar);
        break;
      case 'motor':
        screen = DPMotorScreen(bazar: bazar);
        break;
      case 'panel_chart':
        screen = PanelScreen(bazar: bazar);
        break;
      case 'full_sangam':
        screen = FullSangamScreen(bazar: bazar);
        break;
      case 'single_digit':
        screen = const SingleDigitScreen();
        break;
      case 'half_sangam':
        screen = HalfSangamScreen(bazar: bazar);
        break;
      default:
        // Show a coming soon dialog or placeholder screen
        _showComingSoonDialog(context, gameTypeId);
        return;
    }
    
    if (screen != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => screen!),
      );
    }
  }

  void _showComingSoonDialog(BuildContext context, String gameType) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceColor,
        title: const Text('Coming Soon', style: TextStyle(color: AppTheme.textPrimary)),
        content: Text(
          'The $gameType game will be available soon!',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: AppTheme.primaryColor)),
          ),
        ],
      ),
    );
  }

  Widget _buildChartButton(
    BuildContext context,
    String title,
    IconData icon,
    String subtitle,
    VoidCallback onTap,
  ) {
    return GlassmorphismCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: AppTheme.accentColor,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToJodiChart(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JodiChartScreen(bazar: bazar),
      ),
    );
  }

  void _navigateToPanelChart(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PanelChartScreen(bazar: bazar),
      ),
    );
  }

  IconData _getGameTypeIcon(String gameTypeId) {
    switch (gameTypeId) {
      case 'single_panna':
        return Icons.looks_one;
      case 'double_panna':
        return Icons.looks_two;
      case 'triple_panna':
        return Icons.filter_3;
      case 'jodi':
        return Icons.group_work;
      case 'sangam':
        return Icons.merge_type;
      case 'motor':
        return Icons.directions_car;
      case 'panel_chart':
        return Icons.show_chart;
      case 'result_chart':
        return Icons.bar_chart;
      case 'full_sangam':
        return Icons.all_inclusive;
      case 'single_digit':
        return Icons.filter_1;
      case 'half_sangam':
        return Icons.call_split;
      default:
        return Icons.help_outline;
    }
  }
}
