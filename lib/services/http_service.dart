import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/request.dart';
import '../models/environment.dart';

class HttpResponse {
  final int statusCode;
  final Map<String, String> headers;
  final String body;
  final String? error;
  final Duration duration;

  HttpResponse({
    required this.statusCode,
    required this.headers,
    required this.body,
    this.error,
    required this.duration,
  });

  bool get isSuccess => statusCode >= 200 && statusCode < 300;
  bool get isError => error != null;

  Map<String, dynamic> toJson() {
    return {
      'statusCode': statusCode,
      'headers': headers,
      'body': body,
      'error': error,
      'duration': duration.inMilliseconds,
    };
  }
}

class HttpService {
  Future<HttpResponse> sendRequest(Request request, Environment environment) async {
    final startTime = DateTime.now();
    try {
      // Replace variables in URL and headers
      final url = environment.replaceVariables(request.url);
      final headers = Map<String, String>.from(request.headers);
      headers.forEach((key, value) {
        headers[key] = environment.replaceVariables(value);
      });

      // Add authentication headers
      if (request.authType != null && request.authData != null) {
        switch (request.authType) {
          case 'Basic':
            final username = request.authData!['username'] ?? '';
            final password = request.authData!['password'] ?? '';
            final basicAuth = 'Basic ${base64Encode(utf8.encode('$username:$password'))}';
            headers['Authorization'] = basicAuth;
            break;
          case 'Bearer':
            final token = request.authData!['token'] ?? '';
            headers['Authorization'] = 'Bearer $token';
            break;
        }
      }

      // Build URI with query parameters
      Uri uri = Uri.parse(url);
      if (request.params.isNotEmpty) {
        uri = uri.replace(queryParameters: request.params);
      }

      // Send request
      http.Response response;
      switch (request.method) {
        case 'POST':
          response = await http.post(
            uri,
            headers: headers,
            body: request.body,
          ).timeout(Duration(seconds: request.timeout));
          break;
        case 'PUT':
          response = await http.put(
            uri,
            headers: headers,
            body: request.body,
          ).timeout(Duration(seconds: request.timeout));
          break;
        case 'PATCH':
          response = await http.patch(
            uri,
            headers: headers,
            body: request.body,
          ).timeout(Duration(seconds: request.timeout));
          break;
        case 'DELETE':
          response = await http.delete(
            uri,
            headers: headers,
          ).timeout(Duration(seconds: request.timeout));
          break;
        case 'HEAD':
          response = await http.head(
            uri,
            headers: headers,
          ).timeout(Duration(seconds: request.timeout));
          break;
        case 'OPTIONS':
          final optionsRequest = http.Request('OPTIONS', uri);
          optionsRequest.headers.addAll(headers);
          response = await http.Response.fromStream(
            await optionsRequest.send().timeout(Duration(seconds: request.timeout))
          );
          break;
        default: // GET
          response = await http.get(
            uri,
            headers: headers,
          ).timeout(Duration(seconds: request.timeout));
      }

      final endTime = DateTime.now();
      return HttpResponse(
        statusCode: response.statusCode,
        headers: response.headers,
        body: response.body,
        duration: endTime.difference(startTime),
      );
    } catch (e) {
      final endTime = DateTime.now();
      return HttpResponse(
        statusCode: 0,
        headers: {},
        body: '',
        error: e.toString(),
        duration: endTime.difference(startTime),
      );
    }
  }

  String formatResponse(HttpResponse response) {
    if (response.isError) {
      return 'Error: ${response.error}';
    }

    try {
      // Try to format as JSON
      final json = jsonDecode(response.body);
      return const JsonEncoder.withIndent('  ').convert(json);
    } catch (e) {
      // Return as plain text if not JSON
      return response.body;
    }
  }
} 