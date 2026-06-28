import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/daily_report_provider.dart';
import '../auth/login_screen.dart';
import 'dashboard_screen.dart';
import 'customers_screen.dart';
import 'labour_accounts_screen.dart';

class OwnerHomeScreen extends StatefulWidget {
  const OwnerHomeScreen({super.key});

  @override
  State<OwnerHomeScreen> createState() => _OwnerHomeScreenState();
}

class _OwnerHomeScreenState extends State<OwnerHomeScreen> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  Future<void> _init() async {
    final api = context.read<AuthProvider>().api;
    context.read<CustomerProvider>().setApi(api);
    context.read<DailyReportProvider>().setApi(api);
    await context.read<DailyReportProvider>().fetchDashboard();
    await context.read<CustomerProvider>().fetchCustomers();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final screens = [
      const DashboardScreen(),
      const CustomersScreen(),
      const LabourAccountsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, ${auth.user?.name ?? "Owner"}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await context.read<DailyReportProvider>().fetchDashboard();
              await context.read<CustomerProvider>().fetchCustomers();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.logout();

              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (_) => const LoginScreen(),
                  ),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: screens[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
              icon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.people), label: 'Customers'),
          NavigationDestination(icon: Icon(Icons.engineering), label: 'Labour'),
        ],
      ),
    );
  }
}
