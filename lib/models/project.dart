import 'dart:convert';

class Project {
  final String name;
  final String description;
  final List<String> curls;
  final DateTime createdAt;
  final DateTime updatedAt;

  Project({
    required this.name,
    this.description = '',
    List<String>? curls,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : curls = curls ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'curls': curls,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      curls: List<String>.from(json['curls'] as List? ?? []),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Project copyWith({
    String? name,
    String? description,
    List<String>? curls,
    DateTime? updatedAt,
  }) {
    return Project(
      name: name ?? this.name,
      description: description ?? this.description,
      curls: curls ?? this.curls,
      createdAt: this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
} 