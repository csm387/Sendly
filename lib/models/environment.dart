import 'dart:convert';

class Environment {
  final String name;
  final String baseUrl;
  final Map<String, String> variables;
  final DateTime createdAt;
  final DateTime updatedAt;

  Environment({
    required this.name,
    required this.baseUrl,
    Map<String, String>? variables,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : variables = variables ?? {},
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'baseUrl': baseUrl,
      'variables': variables,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Environment.fromJson(Map<String, dynamic> json) {
    return Environment(
      name: json['name'] as String,
      baseUrl: json['baseUrl'] as String,
      variables: Map<String, String>.from(json['variables'] as Map? ?? {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Environment copyWith({
    String? name,
    String? baseUrl,
    Map<String, String>? variables,
    DateTime? updatedAt,
  }) {
    return Environment(
      name: name ?? this.name,
      baseUrl: baseUrl ?? this.baseUrl,
      variables: variables ?? this.variables,
      createdAt: this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  String replaceVariables(String text) {
    var result = text;
    variables.forEach((key, value) {
      result = result.replaceAll('{{$key}}', value);
    });
    return result;
  }
} 