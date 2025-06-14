import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/project.dart';
import '../models/request.dart';
import '../models/environment.dart';

class StorageService {
  static const String _projectsKey = 'projects';
  static const String _historyKey = 'history';
  static const String _templatesKey = 'templates';
  static const String _environmentsKey = 'environments';
  static const String _favoritesKey = 'favorites';

  // Projects
  Future<List<Project>> loadProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_projectsKey);
    if (data == null) return [];
    
    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((json) => Project.fromJson(json)).toList();
  }

  Future<void> saveProjects(List<Project> projects) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = projects.map((project) => project.toJson()).toList();
    await prefs.setString(_projectsKey, jsonEncode(jsonList));
  }

  // History
  Future<List<Request>> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_historyKey);
    if (data == null) return [];
    
    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((json) => Request.fromJson(json)).toList();
  }

  Future<void> saveHistory(List<Request> history) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = history.map((request) => request.toJson()).toList();
    await prefs.setString(_historyKey, jsonEncode(jsonList));
  }

  // Templates
  Future<List<Request>> loadTemplates() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_templatesKey);
    if (data == null) return [];
    
    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((json) => Request.fromJson(json)).toList();
  }

  Future<void> saveTemplates(List<Request> templates) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = templates.map((template) => template.toJson()).toList();
    await prefs.setString(_templatesKey, jsonEncode(jsonList));
  }

  // Environments
  Future<List<Environment>> loadEnvironments() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_environmentsKey);
    if (data == null) return [];
    
    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((json) => Environment.fromJson(json)).toList();
  }

  Future<void> saveEnvironments(List<Environment> environments) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = environments.map((env) => env.toJson()).toList();
    await prefs.setString(_environmentsKey, jsonEncode(jsonList));
  }

  // Favorites
  Future<List<String>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_favoritesKey);
    if (data == null) return [];
    
    return List<String>.from(jsonDecode(data));
  }

  Future<void> saveFavorites(List<String> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_favoritesKey, jsonEncode(favorites));
  }

  // Clear all data
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_projectsKey);
    await prefs.remove(_historyKey);
    await prefs.remove(_templatesKey);
    await prefs.remove(_environmentsKey);
    await prefs.remove(_favoritesKey);
  }
} 