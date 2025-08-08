import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'screens/new_home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/wallet_screen.dart';
import 'screens/add_points_screen.dart';
import 'screens/withdraw_points_screen.dart';
import 'screens/transfer_points_screen.dart';
import 'screens/bids_screen.dart';
import 'screens/win_history_screen.dart';
import 'screens/game_rate_screen.dart';
import 'screens/share_screen.dart';
import 'screens/contact_us_screen.dart';
import 'screens/rating_screen.dart';
import 'screens/change_password_screen.dart';
import 'screens/game_chart_screen.dart';
import 'screens/settings_screen.dart';
import 'providers/jodi_screen_provider.dart';
import 'providers/wallet_provider.dart';
import 'providers/withdrawal_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/market_result_provider.dart';
import 'providers/bazaar_provider.dart';
import 'screens/withdraw_request_screen.dart';
import 'screens/withdrawal_history_screen.dart';
import 'screens/admin_withdrawal_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/admin_panel_screen.dart';
import 'screens/market_results_screen.dart';
import 'screens/bazaar_filter_demo_screen.dart';
import 'screens/bazaar_list_screen.dart';
import 'screens/user_auto_create_demo_screen.dart';
import 'screens/live_integration_demo_screen.dart';
import 'theme/app_theme.dart';
import 'widgets/performance_optimizations.dart';
import 'services/notification_service.dart';
import 'services/app_lock_service.dart';
import 'services/game_chart_service.dart';
import 'services/fcm_token_service.dart';
import 'services/onesignal_service.dart';
import 'services/permission_service.dart';
import 'services/performance_monitor.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('⚠️ Firebase initialization failed: $e');
    print('📱 App will run in demo mode without Firebase');
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => WalletProvider()),
        ChangeNotifierProvider(create: (_) => WithdrawalProvider()),
        ChangeNotifierProvider(create: (_) => JodiScreenProvider()),
        ChangeNotifierProvider(create: (_) => MarketResultProvider()),
        ChangeNotifierProvider(create: (_) => BazaarProvider()),
      ],
      child: MaterialApp(
        title: 'Sitara777',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
        routes: {
          '/home': (context) => const NewHomeScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/wallet': (context) => const WalletScreen(),
          '/add-points': (context) => const AddPointsScreen(),
          '/withdraw-points': (context) => const WithdrawPointsScreen(),
          '/transfer-points': (context) => const TransferPointsScreen(),
          '/bids': (context) => const BidsScreen(),
          '/win-history': (context) => const WinHistoryScreen(),
          '/game-rate': (context) => const GameRateScreen(),
          '/share': (context) => const ShareScreen(),
          '/contact-us': (context) => const ContactUsScreen(),
          '/rating': (context) => const RatingScreen(),
          '/change-password': (context) => const ChangePasswordScreen(),
          '/game-chart': (context) => const GameChartScreen(),
          '/settings': (context) => const SettingsScreen(),
          '/withdraw-request': (context) => WithdrawRequestScreen(),
          '/withdrawal-history': (context) => WithdrawalHistoryScreen(),
          '/admin-withdrawal': (context) => AdminWithdrawalScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/admin-panel': (context) => const AdminPanelScreen(),
          '/market-results': (context) => const MarketResultsScreen(),
                            '/bazaar-filter-demo': (context) => const BazaarFilterDemoScreen(),
                  '/bazaar-list': (context) => BazaarListScreen(),
                  '/user-auto-create-demo': (context) => const UserAutoCreateDemoScreen(),
                  '/live-integration-demo': (context) => LiveIntegrationDemoScreen(),
        },
      ),
    );
  }
}
