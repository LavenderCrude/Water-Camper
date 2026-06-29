import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/daily_report_provider.dart';
import '../auth/login_screen.dart';
import 'filled_out_screen.dart';
import 'delivery_screen.dart';
import 'quantity_screen.dart';
import 'payment_screen.dart';
import 'submit_screen.dart';

class LabourHomeScreen extends StatefulWidget {
  const LabourHomeScreen({super.key});

  @override
  State<LabourHomeScreen> createState() => _LabourHomeScreenState();
}

class _LabourHomeScreenState extends State<LabourHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  Future<void> _init() async {
    final api = context.read<AuthProvider>().api;
    context.read<CustomerProvider>().setApi(api);
    context.read<DailyReportProvider>().setApi(api);

    await context.read<DailyReportProvider>().fetchTodayReport();
    await context.read<CustomerProvider>().fetchAssignedCustomers();
  }

  @override
  Widget build(BuildContext context) {
    final reportProvider = context.watch<DailyReportProvider>();
    final report = reportProvider.report;
    final auth = context.watch<AuthProvider>();
    final submitted = report?.isSubmitted ?? false;

    if (reportProvider.isLoading && report == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // if (report?.isSubmitted == true) {
    //   return Scaffold(
    //     appBar: AppBar(
    //       title: const Text("Daily Report"),
    //       actions: [
    //         IconButton(
    //           icon: const Icon(Icons.logout),
    //           onPressed: () async {
    //             await auth.logout();

    //             if (context.mounted) {
    //               Navigator.pushAndRemoveUntil(
    //                 context,
    //                 MaterialPageRoute(
    //                   builder: (_) => const LoginScreen(),
    //                 ),
    //                 (route) => false,
    //               );
    //             }
    //           },
    //         ),
    //       ],
    //     ),
    //     body: Center(
    //       child: Padding(
    //         padding: const EdgeInsets.all(24),
    //         child: Column(
    //           mainAxisAlignment: MainAxisAlignment.center,
    //           children: [
    //             Icon(
    //               Icons.check_circle,
    //               color: Colors.green[600],
    //               size: 80,
    //             ),
    //             const SizedBox(height: 15),
    //             const Text(
    //               "Report Submitted!",
    //               style: TextStyle(
    //                 fontSize: 24,
    //                 fontWeight: FontWeight.bold,
    //               ),
    //             ),
    //             const SizedBox(height: 10),
    //             Text(
    //               "Date : ${report!.date}",
    //               style: const TextStyle(fontSize: 16),
    //             ),
    //             const SizedBox(height: 25),
    //             _SummaryRow(
    //               "Delivered",
    //               "${report.totalDelivered}",
    //             ),
    //             _SummaryRow(
    //               "Undelivered",
    //               "${report.totalUndelivered}",
    //             ),
    //             _SummaryRow(
    //               "Collection",
    //               "₹${report.totalCollectedAmount.toStringAsFixed(0)}",
    //             ),
    //           ],
    //         ),
    //       ),
    //     ),
    //   );
    // }

    final steps = [
      _StepInfo(
        "Filled Out",
        Icons.local_shipping,
        report?.filledOut == 0,
      ),
      _StepInfo(
        "Delivery",
        Icons.local_shipping,
        false,
      ),
      _StepInfo(
        "Extra Campers",
        Icons.add_box,
        false,
      ),
      _StepInfo(
        "Not Received",
        Icons.remove_circle,
        false,
      ),
      _StepInfo(
        "Empty In",
        Icons.inbox,
        false,
      ),
      _StepInfo(
        "Payments",
        Icons.payments,
        false,
      ),
      _StepInfo(
        "Submit",
        Icons.send,
        false,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Hello, ${auth.user?.name ?? "Labour"}",
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await auth.logout();

              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    "Today : ${report?.date ?? ""}",
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Filled Out : ${report?.filledOut ?? 0}",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Daily Workflow",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _WorkflowTile(
            step: steps[0],
            onTap: submitted
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FilledOutScreen(),
                      ),
                    );
                  },
          ),
          _WorkflowTile(
            step: steps[1],
            onTap: submitted
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DeliveryScreen(),
                      ),
                    );
                  },
          ),
          _WorkflowTile(
            step: steps[2],
            onTap: submitted
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const QuantityScreen(
                          type: QuantityType.extra,
                          title: 'Extra Campers',
                        ),
                      ),
                    );
                  },
          ),
          _WorkflowTile(
            step: steps[3],
            onTap: submitted
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const QuantityScreen(
                          type: QuantityType.notReceived,
                          title: 'Not Received',
                        ),
                      ),
                    );
                  },
          ),
          _WorkflowTile(
            step: steps[4],
            onTap: submitted
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const QuantityScreen(
                          type: QuantityType.emptyIn,
                          title: 'Empty Campers Received',
                        ),
                      ),
                    );
                  },
          ),
          _WorkflowTile(
            step: steps[5],
            onTap: submitted
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PaymentScreen(),
                      ),
                    );
                  },
          ),
          _WorkflowTile(
            step: steps[6],
            onTap: submitted
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SubmitScreen(),
                      ),
                    );
                  },
          ),
        ],
      ),
    );
  }
}

class _StepInfo {
  final String title;
  final IconData icon;
  final bool highlight;

  _StepInfo(
    this.title,
    this.icon,
    this.highlight,
  );
}

class _WorkflowTile extends StatelessWidget {
  final _StepInfo step;
  final VoidCallback? onTap;

  const _WorkflowTile({
    required this.step,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        enabled: onTap != null,
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Icon(
            step.icon,
            color: Colors.white,
          ),
        ),
        title: Text(
          step.title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: onTap == null ? Colors.grey : null,
          ),
        ),
        trailing: onTap == null
            ? const Icon(
                Icons.lock,
                color: Colors.red,
                size: 28,
              )
            : const Icon(
                Icons.chevron_right,
                size: 32,
              ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow(
    this.label,
    this.value,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 4,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
