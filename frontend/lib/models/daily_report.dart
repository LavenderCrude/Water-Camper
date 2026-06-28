class DeliveryEntry {
  final String customerId;
  final String? customerName;
  final String status;
  final String? reason;

  DeliveryEntry({
    required this.customerId,
    this.customerName,
    required this.status,
    this.reason,
  });

  factory DeliveryEntry.fromJson(Map<String, dynamic> json) {
    final customer = json['customerId'];
    return DeliveryEntry(
      customerId: customer is Map ? customer['_id'] ?? '' : customer?.toString() ?? '',
      customerName: customer is Map ? customer['name'] : null,
      status: json['status'] ?? '',
      reason: json['reason'],
    );
  }
}

class QuantityEntry {
  final String customerId;
  final String? customerName;
  final int quantity;

  QuantityEntry({
    required this.customerId,
    this.customerName,
    required this.quantity,
  });

  factory QuantityEntry.fromJson(Map<String, dynamic> json) {
    final customer = json['customerId'];
    return QuantityEntry(
      customerId: customer is Map ? customer['_id'] ?? '' : customer?.toString() ?? '',
      customerName: customer is Map ? customer['name'] : null,
      quantity: json['quantity'] ?? 0,
    );
  }
}

class PaymentEntry {
  final String customerId;
  final String? customerName;
  final double amount;
  final String paymentMode;

  PaymentEntry({
    required this.customerId,
    this.customerName,
    required this.amount,
    required this.paymentMode,
  });

  factory PaymentEntry.fromJson(Map<String, dynamic> json) {
    final customer = json['customerId'];
    return PaymentEntry(
      customerId: customer is Map ? customer['_id'] ?? '' : customer?.toString() ?? '',
      customerName: customer is Map ? customer['name'] : null,
      amount: (json['amount'] ?? 0).toDouble(),
      paymentMode: json['paymentMode'] ?? 'cash',
    );
  }
}

class DailyReportModel {
  final String id;
  final String date;
  final String status;
  final int filledOut;
  final List<DeliveryEntry> deliveries;
  final List<QuantityEntry> emptyIn;
  final List<QuantityEntry> extra;
  final List<QuantityEntry> notReceived;
  final List<PaymentEntry> payments;
  final int totalDelivered;
  final int totalUndelivered;
  final int totalEmptyIn;
  final int totalExtra;
  final int totalNotReceived;
  final double totalCollectedAmount;

  DailyReportModel({
    required this.id,
    required this.date,
    required this.status,
    required this.filledOut,
    required this.deliveries,
    required this.emptyIn,
    required this.extra,
    required this.notReceived,
    required this.payments,
    this.totalDelivered = 0,
    this.totalUndelivered = 0,
    this.totalEmptyIn = 0,
    this.totalExtra = 0,
    this.totalNotReceived = 0,
    this.totalCollectedAmount = 0,
  });

  factory DailyReportModel.fromJson(Map<String, dynamic> json) {
    return DailyReportModel(
      id: json['_id'] ?? '',
      date: json['date'] ?? '',
      status: json['status'] ?? 'draft',
      filledOut: json['filledOut'] ?? 0,
      deliveries: (json['deliveries'] as List? ?? [])
          .map((e) => DeliveryEntry.fromJson(e))
          .toList(),
      emptyIn: (json['emptyIn'] as List? ?? [])
          .map((e) => QuantityEntry.fromJson(e))
          .toList(),
      extra: (json['extra'] as List? ?? [])
          .map((e) => QuantityEntry.fromJson(e))
          .toList(),
      notReceived: (json['notReceived'] as List? ?? [])
          .map((e) => QuantityEntry.fromJson(e))
          .toList(),
      payments: (json['payments'] as List? ?? [])
          .map((e) => PaymentEntry.fromJson(e))
          .toList(),
      totalDelivered: json['totalDelivered'] ?? 0,
      totalUndelivered: json['totalUndelivered'] ?? 0,
      totalEmptyIn: json['totalEmptyIn'] ?? 0,
      totalExtra: json['totalExtra'] ?? 0,
      totalNotReceived: json['totalNotReceived'] ?? 0,
      totalCollectedAmount: (json['totalCollectedAmount'] ?? 0).toDouble(),
    );
  }

  bool get isSubmitted => status == 'submitted';

  int getQuantityFor(List<QuantityEntry> list, String customerId) {
    return list
        .where((e) => e.customerId == customerId)
        .fold(0, (sum, e) => sum + e.quantity);
  }
}

class DashboardSummary {
  final int totalCustomers;
  final int todayDeliveries;
  final int undeliveredCount;
  final int emptyCampersReceived;
  final int extraCampers;
  final int notReceivedCampers;
  final double todayCollection;
  final double totalPendingAmount;
  final String date;

  DashboardSummary({
    required this.totalCustomers,
    required this.todayDeliveries,
    required this.undeliveredCount,
    required this.emptyCampersReceived,
    required this.extraCampers,
    required this.notReceivedCampers,
    required this.todayCollection,
    required this.totalPendingAmount,
    required this.date,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      totalCustomers: json['totalCustomers'] ?? 0,
      todayDeliveries: json['todayDeliveries'] ?? 0,
      undeliveredCount: json['undeliveredCount'] ?? 0,
      emptyCampersReceived: json['emptyCampersReceived'] ?? 0,
      extraCampers: json['extraCampers'] ?? 0,
      notReceivedCampers: json['notReceivedCampers'] ?? 0,
      todayCollection: (json['todayCollection'] ?? 0).toDouble(),
      totalPendingAmount: (json['totalPendingAmount'] ?? 0).toDouble(),
      date: json['date'] ?? '',
    );
  }
}

class ChartPoint {
  final String date;
  final double value;

  ChartPoint({required this.date, required this.value});
}
