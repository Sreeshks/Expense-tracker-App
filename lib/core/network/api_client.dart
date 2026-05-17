import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';

class ApiClient {
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, String>> _authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(ApiConstants.tokenKey);
    return {
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> get(String endpoint) async {
    final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    final headers = await _authHeaders();
    developer.log('API REQUEST [GET] $url', name: 'ApiClient');
    final response = await _client.get(url, headers: headers);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> postForm(
    String endpoint,
    Map<String, String> fields,
  ) async {
    final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    final headers = await _authHeaders();
    developer.log('API REQUEST [POST FORM] $url\\nFields: $fields', name: 'ApiClient');
    final request = http.MultipartRequest('POST', url);
    request.headers.addAll(headers);
    request.fields.addAll(fields);
    final streamed = await _client.send(request);
    final response = await http.Response.fromStream(streamed);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> postJson(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    final headers = await _authHeaders();
    headers['Content-Type'] = 'application/json';
    developer.log('API REQUEST [POST JSON] $url\\nBody: $body', name: 'ApiClient');
    final response = await _client.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> deleteJson(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    final headers = await _authHeaders();
    headers['Content-Type'] = 'application/json';
    developer.log('API REQUEST [DELETE JSON] $url\\nBody: $body', name: 'ApiClient');
    final request = http.Request('DELETE', url);
    request.headers.addAll(headers);
    request.body = jsonEncode(body);
    final streamed = await _client.send(request);
    final response = await http.Response.fromStream(streamed);
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> deleteForm(
    String endpoint,
    Map<String, String> fields,
  ) async {
    final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');
    final headers = await _authHeaders();
    developer.log('API REQUEST [DELETE FORM] $url\\nFields: $fields', name: 'ApiClient');
    final request = http.MultipartRequest('DELETE', url);
    request.headers.addAll(headers);
    request.fields.addAll(fields);
    final streamed = await _client.send(request);
    final response = await http.Response.fromStream(streamed);
    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    developer.log(
      'API RESPONSE [${response.statusCode}] ${response.request?.method} ${response.request?.url}\\nBody: ${response.body}',
      name: 'ApiClient',
    );
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }
    throw ApiException(
      statusCode: response.statusCode,
      message: body['message']?.toString() ?? 'Request failed',
    );
  }

  void dispose() => _client.close();
}

class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}
