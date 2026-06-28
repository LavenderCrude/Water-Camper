import 'package:flutter/foundation.dart';
import '../models/daily_report.dart';
import '../services/api_service.dart';

class DailyReportProvider extends ChangeNotifier {
  ApiService? _api;
  DailyReportModel? _report;
  DashboardSummary? _summary;
  List<ChartPoint> _deliveryChart = [];
  List<ChartPoint> _revenueChart = [];
  bool _loading = false;
  String? _error;

  DailyReportModel? get report => _report;
  DashboardSummary? get summary => _summary;
  List<ChartPoint> get deliveryChart => _deliveryChart;
  List<ChartPoint> get revenueChart => _revenueChart;
  bool get isLoading => _loading;
  String? get error => _error;

  void setApi(ApiService api) => _api = api;

  Future<void> fetchTodayReport() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await _api!.get('/daily-reports/today');
      _report = DailyReportModel.fromJson(res['data']);
    } catch (e) {
      _error = e.toString().replaceAll('ApiException: ', '');
    }
    _loading = false;
    notifyListeners();
  }

  Future<bool> setFilledOut(int count) async {
    if (_report == null) return false;
    try {
      final res = await _api!.patch('/daily-reports/${_report!.id}/filled-out', body: {
        'filledOut': count,
      });
      _report = DailyReportModel.fromJson(res['data']);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('ApiException: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> markDelivery(String customerId, String status, {String? reason}) async {
    if (_report == null) return false;
    try {
      final res = await _api!.post('/daily-reports/${_report!.id}/deliveries', body: {
        'customerId': customerId,
        'status': status,
        if (reason != null) 'reason': reason,
      });
      _report = DailyReportModel.fromJson(res['data']);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('ApiException: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateQuantity(String endpoint, String customerId, int delta) async {
    if (_report == null) return false;
    try {
      final res = await _api!.patch('/daily-reports/${_report!.id}/$endpoint', body: {
        'customerId': customerId,
        'delta': delta,
      });
      _report = DailyReportModel.fromJson(res['data']);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('ApiException: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> addPayment(String customerId, double amount, String mode) async {
    if (_report == null) return false;
    try {
      final res = await _api!.post('/daily-reports/${_report!.id}/payments', body: {
        'customerId': customerId,
        'amount': amount,
        'paymentMode': mode,
      });
      _report = DailyReportModel.fromJson(res['data']);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('ApiException: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> submitReport() async {
    if (_report == null) return false;
    try {
      final res = await _api!.post('/daily-reports/${_report!.id}/submit');
      _report = DailyReportModel.fromJson(res['data']);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('ApiException: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchDashboard() async {
    _loading = true;
    notifyListeners();
    try {
      final summaryRes = await _api!.get('/dashboard/summary');
      _summary = DashboardSummary.fromJson(summaryRes['data']);

      final analyticsRes = await _api!.get('/dashboard/analytics', query: {'range': '7d'});
      final data = analyticsRes['data'] as Map<String, dynamic>;
      _deliveryChart = (data['dailyDeliveries'] as List? ?? [])
          .map((e) => ChartPoint(date: e['date'], value: (e['count'] ?? 0).toDouble()))
          .toList();
      _revenueChart = (data['revenueTrend'] as List? ?? [])
          .map((e) => ChartPoint(date: e['date'], value: (e['amount'] ?? 0).toDouble()))
          .toList();
    } catch (e) {
      _error = e.toString().replaceAll('ApiException: ', '');
    }
    _loading = false;
    notifyListeners();
  }
}
