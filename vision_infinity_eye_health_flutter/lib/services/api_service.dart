import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/app_constants.dart';

class ApiService {
  final String baseUrl;
  final Map<String, String> _headers = {'Content-Type': 'application/json'};

  ApiService({String? baseUrl}) : baseUrl = baseUrl ?? AppConstants.apiBaseUrl;

  void setAuthToken(String token) {
    _headers['Authorization'] = 'Bearer $token';
  }

  void removeAuthToken() {
    _headers.remove('Authorization');
  }

  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
        body: json.encode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
        body: json.encode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> uploadFile(
    String endpoint,
    String filePath,
    String fieldName, {
    Map<String, String>? additionalFields,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl$endpoint'),
      );

      request.headers.addAll(_headers);
      request.files.add(await http.MultipartFile.fromPath(fieldName, filePath));

      if (additionalFields != null) {
        request.fields.addAll(additionalFields);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final body = json.decode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    switch (response.statusCode) {
      case 401:
        throw UnauthorizedException(body['message'] ?? 'Unauthorized');
      case 403:
        throw ForbiddenException(body['message'] ?? 'Forbidden');
      case 404:
        throw NotFoundException(body['message'] ?? 'Not found');
      case 422:
        throw ValidationException(body['message'] ?? 'Validation failed');
      default:
        throw ApiException(
          body['message'] ?? 'Something went wrong',
          response.statusCode,
        );
    }
  }

  Exception _handleError(dynamic error) {
    if (error is ApiException) {
      return error;
    }
    return ApiException('Network error occurred', 0);
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => message;
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(String message) : super(message, 401);
}

class ForbiddenException extends ApiException {
  ForbiddenException(String message) : super(message, 403);
}

class NotFoundException extends ApiException {
  NotFoundException(String message) : super(message, 404);
}

class ValidationException extends ApiException {
  ValidationException(String message) : super(message, 422);
}
