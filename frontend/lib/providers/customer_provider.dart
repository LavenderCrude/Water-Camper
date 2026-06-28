import 'package:flutter/foundation.dart';
import '../models/customer.dart';
import '../services/api_service.dart';

class CustomerProvider extends ChangeNotifier {
  ApiService? _api;
  List<CustomerModel> _customers = [];
  bool _loading = false;
  String? _error;

  List<CustomerModel> get customers => _customers;
  bool get isLoading => _loading;
  String? get error => _error;

  void setApi(ApiService api) => _api = api;

  Future<void> fetchCustomers({String? search}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await _api!.get('/customers', query: search != null ? {'search': search} : null);
      _customers = (res['data'] as List).map((e) => CustomerModel.fromJson(e)).toList();
    } catch (e) {
      _error = e.toString().replaceAll('ApiException: ', '');
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> fetchAssignedCustomers() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final res = await _api!.get('/customers/assigned');
      _customers = (res['data'] as List).map((e) => CustomerModel.fromJson(e)).toList();
    } catch (e) {
      _error = e.toString().replaceAll('ApiException: ', '');
    }
    _loading = false;
    notifyListeners();
  }

  Future<bool> createCustomer(CustomerModel customer) async {
    try {
      await _api!.post('/customers', body: customer.toJson());
      await fetchCustomers();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('ApiException: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCustomer(String id, Map<String, dynamic> data) async {
    try {
      await _api!.put('/customers/$id', body: data);
      await fetchCustomers();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('ApiException: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteCustomer(String id) async {
    try {
      await _api!.delete('/customers/$id');
      await fetchCustomers();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('ApiException: ', '');
      notifyListeners();
      return false;
    }
  }
}
