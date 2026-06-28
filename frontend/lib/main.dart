import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/customer_provider.dart';
import 'providers/daily_report_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/owner/owner_home_screen.dart';
import 'screens/labour/labour_home_screen.dart';

void main() {
  runApp(const WaterCamperApp());
}

class WaterCamperApp extends StatelessWidget {
  const WaterCamperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => DailyReportProvider()),
      ],
      child: MaterialApp(
        title: 'Water Camper',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const SplashScreen(),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final auth = context.read<AuthProvider>();
    await auth.init();

    if (!mounted) return;

    Widget nextScreen;
    if (auth.isAuthenticated) {
      nextScreen = auth.user!.isOwner ? const OwnerHomeScreen() : const LabourHomeScreen();
    } else {
      nextScreen = const LoginScreen();
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => nextScreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.water_drop, size: 64, color: Color(0xFF1565C0)),
            SizedBox(height: 16),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
