import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/daily_report_provider.dart';
import '../../widgets/customer_tile.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _search = '';

  Future<void> _recordPayment(String customerId, String customerName, double pending) async {
    final amountController = TextEditingController();
    String mode = 'cash';

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Payment - $customerName'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (pending > 0)
                Text('Pending: ₹${pending.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount Collected'),
              ),
              const SizedBox(height: 16),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'cash', label: Text('Cash')),
                  ButtonSegment(value: 'upi', label: Text('UPI')),
                  ButtonSegment(value: 'bank_transfer', label: Text('Bank')),
                ],
                selected: {mode},
                onSelectionChanged: (s) => setDialogState(() => mode = s.first),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (result != true || !mounted) return;

    final amount = double.tryParse(amountController.text) ?? 0;
    if (amount <= 0) return;

    final provider = context.read<DailyReportProvider>();
    final success = await provider.addPayment(customerId, amount, mode);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? 'Payment recorded' : provider.error ?? 'Failed')),
      );
      if (success) setState(() {});
    }
  }

  double _getCollected(String customerId) {
    final report = context.read<DailyReportProvider>().report;
    if (report == null) return 0;
    return report.payments
        .where((p) => p.customerId == customerId)
        .fold(0.0, (sum, p) => sum + p.amount);
  }

  @override
  Widget build(BuildContext context) {
    final customers = context.watch<CustomerProvider>().customers;
    final filtered = customers
        .where((c) => c.name.toLowerCase().contains(_search.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Payment Collection')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search customer...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final customer = filtered[index];
                final collected = _getCollected(customer.id);
                return CustomerTile(
                  customer: customer,
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (collected > 0)
                        Text('₹${collected.toStringAsFixed(0)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                      ElevatedButton(
                        onPressed: () => _recordPayment(customer.id, customer.name, customer.pendingAmount),
                        style: ElevatedButton.styleFrom(minimumSize: const Size(80, 40)),
                        child: const Text('Collect'),
                      ),
                    ],
                  ),
                  onTap: () => _recordPayment(customer.id, customer.name, customer.pendingAmount),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
