import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/daily_report_provider.dart';
import '../../widgets/counter_button.dart';
import '../../models/daily_report.dart';

enum QuantityType { extra, notReceived, emptyIn }

class QuantityScreen extends StatefulWidget {
  final QuantityType type;
  final String title;

  const QuantityScreen({super.key, required this.type, required this.title});

  @override
  State<QuantityScreen> createState() => _QuantityScreenState();
}

class _QuantityScreenState extends State<QuantityScreen> {
  String _search = '';

  String get _endpoint {
    switch (widget.type) {
      case QuantityType.extra:
        return 'extra';
      case QuantityType.notReceived:
        return 'not-received';
      case QuantityType.emptyIn:
        return 'empty-in';
    }
  }

  List<dynamic> _entries(DailyReportModel? report) {
    if (report == null) return [];

    switch (widget.type) {
      case QuantityType.extra:
        return report.extra;

      case QuantityType.notReceived:
        return report.notReceived;

      case QuantityType.emptyIn:
        return report.emptyIn;
    }
  }

  int _getQuantity(
    DailyReportModel? report,
    String customerId,
  ) {
    try {
      return _entries(report)
          .firstWhere((e) => e.customerId == customerId)
          .quantity;
    } catch (_) {
      return 0;
    }
  }

  Future<void> _update(String customerId, int delta) async {
    final provider = context.read<DailyReportProvider>();

    final ok = await provider.updateQuantity(
      _endpoint,
      customerId,
      delta,
    );

    print(provider.report!.extra.map((e) {
      return "${e.customerId} -> ${e.quantity}";
    }).toList());

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final report = context.watch<DailyReportProvider>().report;
    final customers = context.watch<CustomerProvider>().customers;
    final filtered = customers
        .where((c) => c.name.toLowerCase().contains(_search.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
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
                final qty = _getQuantity(report, customer.id);
                return CounterRow(
                  label: customer.name,
                  value: qty,
                  onIncrement: () => _update(customer.id, 1),
                  onDecrement: () => _update(customer.id, -1),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
