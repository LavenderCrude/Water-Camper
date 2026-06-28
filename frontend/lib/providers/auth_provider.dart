import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  UserModel? _user;
  String? _token;
  bool _loading = false;
  String? _error;

  UserModel? get user => _user;
  String? get token => _token;
  bool get isLoading => _loading;
  String? get error => _error;
  bool get isAuthenticated => _token != null && _user != null;

  ApiService get api => _api;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(ApiConstants.tokenKey);
    final userJson = prefs.getString(ApiConstants.userKey);
    if (_token != null && userJson != null) {
      _api.setToken(_token);
      _user = UserModel.fromJson(jsonDecode(userJson));
      notifyListeners();
    }
  }

  Future<bool> login(String mobile, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _api.post('/auth/login', body: {
        'mobile': mobile,
        'password': password,
      });
      final data = res['data'] as Map<String, dynamic>;
      _token = data['token'];
      _user = UserModel.fromJson(data['user']);
      _api.setToken(_token);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(ApiConstants.tokenKey, _token!);
      await prefs.setString(ApiConstants.userKey, jsonEncode(_user!.toJson()));

      _loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('ApiException: ', '');
      _loading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    _api.setToken(null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(ApiConstants.tokenKey);
    await prefs.remove(ApiConstants.userKey);
    notifyListeners();
  }
}
