import 'dart:convert';

class Request {
  final String method;
  final String url;
  final Map<String, String> headers;
  final String? body;
  final Map<String, String> params;
  final String? authType;
  final Map<String, String>? authData;
  final int timeout;
  final DateTime createdAt;
  final DateTime updatedAt;

  Request({
    required this.method,
    required this.url,
    Map<String, String>? headers,
    this.body,
    Map<String, String>? params,
    this.authType,
    this.authData,
    this.timeout = 30,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : headers = headers ?? {},
        params = params ?? {},
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'method': method,
      'url': url,
      'headers': headers,
      'body': body,
      'params': params,
      'authType': authType,
      'authData': authData,
      'timeout': timeout,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Request.fromJson(Map<String, dynamic> json) {
    return Request(
      method: json['method'] as String,
      url: json['url'] as String,
      headers: Map<String, String>.from(json['headers'] as Map? ?? {}),
      body: json['body'] as String?,
      params: Map<String, String>.from(json['params'] as Map? ?? {}),
      authType: json['authType'] as String?,
      authData: json['authData'] != null
          ? Map<String, String>.from(json['authData'] as Map)
          : null,
      timeout: json['timeout'] as int? ?? 30,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Request copyWith({
    String? method,
    String? url,
    Map<String, String>? headers,
    String? body,
    Map<String, String>? params,
    String? authType,
    Map<String, String>? authData,
    int? timeout,
    DateTime? updatedAt,
  }) {
    return Request(
      method: method ?? this.method,
      url: url ?? this.url,
      headers: headers ?? this.headers,
      body: body ?? this.body,
      params: params ?? this.params,
      authType: authType ?? this.authType,
      authData: authData ?? this.authData,
      timeout: timeout ?? this.timeout,
      createdAt: this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
} 