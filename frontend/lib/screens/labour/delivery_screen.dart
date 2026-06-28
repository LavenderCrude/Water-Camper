import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/daily_report_provider.dart';
import '../../widgets/customer_tile.dart';

class DeliveryScreen extends StatefulWidget {
  const DeliveryScreen({super.key});

  @override
  State<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  String _search = '';

  String? _getDeliveryStatus(String customerId) {
    final report = context.read<DailyReportProvider>().report;

    if (report == null) return null;

    try {
      return report.deliveries
          .firstWhere((e) => e.customerId == customerId)
          .status;
    } catch (_) {
      return null;
    }
  }

  String? _getReason(String customerId) {
    final report = context.read<DailyReportProvider>().report;

    if (report == null) return null;

    try {
      return report.deliveries
          .firstWhere((e) => e.customerId == customerId)
          .reason;
    } catch (_) {
      return null;
    }
  }

  Future<void> _markDelivered(String customerId) async {
    final provider = context.read<DailyReportProvider>();

    final ok = await provider.markDelivery(
      customerId,
      "delivered",
    );

    print(provider.report!.deliveries
        .map((e) => "${e.customerId} -> ${e.status}")
        .toList());

    if (mounted && ok) {
      setState(() {});
    }
  }

  Future<void> _markUndelivered(String customerId) async {
    const reasons = [
      "Shop Closed",
      "Customer Not Available",
      "No Stock Required",
      "Payment Issue",
      "Other",
    ];

    final reason = await showDialog<String>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text("Select Reason"),
          children: reasons
              .map(
                (e) => SimpleDialogOption(
                  onPressed: () {
                    Navigator.pop(context, e);
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      e,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              )
              .toList(),
        );
      },
    );

    if (reason == null) return;

    final provider = context.read<DailyReportProvider>();

    final ok = await provider.markDelivery(
      customerId,
      "undelivered",
      reason: reason,
    );

    if (mounted && ok) {
      setState(() {});
    }
  }

  Future<void> _editStatus(
    String customerId,
    String? currentStatus,
  ) async {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              const Text(
                "Change Delivery Status",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                ),
                title: const Text("Delivered"),
                onTap: () async {
                  Navigator.pop(context);

                  await _markDelivered(customerId);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.cancel,
                  color: Colors.red,
                ),
                title: const Text("Undelivered"),
                onTap: () async {
                  Navigator.pop(context);

                  await _markUndelivered(customerId);
                },
              ),
              const SizedBox(height: 15),
            ],
          ),
        );
      },
    );
  }

  Color _statusColor(String? status) {
    switch (status) {
      case "delivered":
        return Colors.green;

      case "undelivered":
        return Colors.red;

      default:
        return Colors.orange;
    }
  }

  String _statusText(String? status) {
    switch (status) {
      case "delivered":
        return "Delivered";

      case "undelivered":
        return "Undelivered";

      default:
        return "Pending";
    }
  }

  @override
  Widget build(BuildContext context) {
    final customers = context.watch<CustomerProvider>().customers;

    final filtered = customers
        .where(
          (e) => e.name.toLowerCase().contains(
                _search.toLowerCase(),
              ),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Delivery"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: "Search Customer",
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) {
                setState(() {
                  _search = v;
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final customer = filtered[index];

                final status = _getDeliveryStatus(customer.id);

                final reason = _getReason(customer.id);

                return CustomerTile(
                  customer: customer,
                  trailing: SizedBox(
                    width: 140,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: _statusColor(status).withOpacity(.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _statusText(status),
                            style: TextStyle(
                              color: _statusColor(status),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (status == "undelivered" && reason != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Text(
                              reason,
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                fontSize: 11,
                              ),
                            ),
                          ),
                        const SizedBox(height: 8),
                        if (status == null) ...[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(
                                height: 36,
                                child: ElevatedButton(
                                  onPressed: () => _markDelivered(customer.id),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                  child: const Text(
                                    "Done",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              SizedBox(
                                height: 36,
                                child: ElevatedButton(
                                  onPressed: () =>
                                      _markUndelivered(customer.id),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  child: const Text(
                                    "Miss",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ] else ...[
                          SizedBox(
                            width: 90,
                            height: 36,
                            child: OutlinedButton(
                              onPressed: () => _editStatus(
                                customer.id,
                                status,
                              ),
                              child: const Text("Edit"),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
