import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../core/constants.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class ApiService {
  String? _token;

  void setToken(String? token) => _token = token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }
    throw ApiException(
        body['message']?.toString() ?? 'Request failed', response.statusCode);
  }

  Future<Map<String, dynamic>> get(String path,
      {Map<String, String>? query}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$path')
        .replace(queryParameters: query);
    final response = await http.get(uri, headers: _headers);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(String path,
      {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$path');

    debugPrint("POST URL: $uri");
    debugPrint("POST BODY: ${jsonEncode(body)}");

    final response = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode(body ?? {}),
    );

    debugPrint("STATUS: ${response.statusCode}");
    debugPrint("BODY: ${response.body}");

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> put(String path,
      {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$path');
    final response =
        await http.put(uri, headers: _headers, body: jsonEncode(body ?? {}));
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> patch(String path,
      {Map<String, dynamic>? body}) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$path');
    final response =
        await http.patch(uri, headers: _headers, body: jsonEncode(body ?? {}));
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> delete(String path) async {
    final uri = Uri.parse('${ApiConstants.baseUrl}$path');
    final response = await http.delete(uri, headers: _headers);
    return _handleResponse(response);
  }
}
