import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/daily_report_provider.dart';

class SubmitScreen extends StatelessWidget {
  const SubmitScreen({super.key});

  Future<void> _submit(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Submit Daily Report?'),
        content: const Text('Once submitted, the report cannot be edited.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Submit')),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final provider = context.read<DailyReportProvider>();
    final success = await provider.submitReport();

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report submitted successfully!')),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? 'Submit failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final report = context.watch<DailyReportProvider>().report;

    if (report == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final delivered = report.deliveries.where((d) => d.status == 'delivered').length;
    final undelivered = report.deliveries.where((d) => d.status == 'undelivered').length;
    final emptyIn = report.emptyIn.fold(0, (s, e) => s + e.quantity);
    final extra = report.extra.fold(0, (s, e) => s + e.quantity);
    final notReceived = report.notReceived.fold(0, (s, e) => s + e.quantity);
    final collected = report.payments.fold(0.0, (s, p) => s + p.amount);

    return Scaffold(
      appBar: AppBar(title: const Text('Review & Submit')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Daily Summary', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Date: ${report.date}', style: const TextStyle(fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 24),
            _Row('Filled Out', '${report.filledOut}'),
            _Row('Delivered', '$delivered'),
            _Row('Undelivered', '$undelivered'),
            _Row('Empty In', '$emptyIn'),
            _Row('Extra Campers', '$extra'),
            _Row('Not Received', '$notReceived'),
            _Row('Collection', '₹${collected.toStringAsFixed(0)}'),
            const Spacer(),
            if (report.filledOut <= 0)
              const Text(
                'Please set filled out count before submitting',
                style: TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: report.filledOut > 0 ? () => _submit(context) : null,
              child: const Text('Submit Daily Report'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 18)),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
