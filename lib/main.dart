import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:intl/intl.dart';
import 'screens/app_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sendly',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: Colors.grey.withOpacity(0.2),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: Colors.grey.withOpacity(0.2),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      home: const AppScreen(),
    );
  }
}

class CurlDesktopApp extends StatefulWidget {
  final bool isDarkMode;
  final Function(bool) onThemeChanged;

  const CurlDesktopApp({
    Key? key,
    required this.isDarkMode,
    required this.onThemeChanged,
  }) : super(key: key);

  @override
  _CurlDesktopAppState createState() => _CurlDesktopAppState();
}

class _CurlDesktopAppState extends State<CurlDesktopApp> with SingleTickerProviderStateMixin {
  final List<String> httpMethods = ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'HEAD', 'OPTIONS'];
  String selectedMethod = 'GET';
  String statusCode = '';
  final TextEditingController urlController = TextEditingController();
  final TextEditingController previewController = TextEditingController();
  final TextEditingController bodyController = TextEditingController();
  final TextEditingController timeoutController = TextEditingController(text: '30');
  Map<String, List<String>> savedProjects = {};
  String selectedProject = '';
  List<String> curls = [];
  List<Map<String, String>> params = [];
  List<Map<String, String>> headers = [];
  List<Map<String, dynamic>> requestHistory = [];
  bool showResponseHeaders = false;
  Map<String, String> responseHeaders = {};
  String responseTime = '';
  String responseSize = '';
  
  // New state variables
  Map<String, Map<String, dynamic>> environments = {
    'Development': {
      'baseUrl': 'http://localhost:3000',
      'variables': {
        'apiKey': 'dev_key_123',
        'token': 'dev_token_123'
      }
    },
    'Production': {
      'baseUrl': 'https://api.example.com',
      'variables': {
        'apiKey': 'prod_key_123',
        'token': 'prod_token_123'
      }
    }
  };
  String selectedEnvironment = 'Development';
  String authType = 'None';
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController tokenController = TextEditingController();
  List<Map<String, dynamic>> requestTemplates = [];
  bool isJsonValid = true;
  String jsonError = '';

  // New state variables for enhanced features
  bool isHistorySearching = false;
  final TextEditingController historySearchController = TextEditingController();
  String historySearchQuery = '';
  bool isTemplateSearching = false;
  final TextEditingController templateSearchController = TextEditingController();
  String templateSearchQuery = '';
  bool showFavoritesOnly = false;
  List<String> favoriteRequests = [];
  String selectedHistoryItem = '';
  String selectedTemplateItem = '';

  // Add new state variables
  bool isProjectSearching = false;
  final TextEditingController projectSearchController = TextEditingController();
  String projectSearchQuery = '';
  bool isCurlSearching = false;
  final TextEditingController curlSearchController = TextEditingController();
  String curlSearchQuery = '';
  bool showProjectSettings = false;
  String selectedProjectDescription = '';
  final TextEditingController projectDescriptionController = TextEditingController();

  late TabController _tabController;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
    loadProjects();
    loadHistory();
    loadTemplates();
    loadFavorites();
    addHeaderField();
    addDefaultHeaders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void addDefaultHeaders() {
    headers.addAll([
      {'key': 'Content-Type', 'value': 'application/json'},
      {'key': 'Accept', 'value': 'application/json'},
    ]);
  }

  Future<void> loadTemplates() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('templates');
    if (data != null) {
      setState(() {
        requestTemplates = List<Map<String, dynamic>>.from(jsonDecode(data));
      });
    }
  }

  Future<void> saveTemplates() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('templates', jsonEncode(requestTemplates));
  }

  void saveAsTemplate() {
    final template = {
      'name': 'Template ${requestTemplates.length + 1}',
      'method': selectedMethod,
      'url': urlController.text,
      'headers': headers,
      'body': bodyController.text,
      'params': params,
    };
    setState(() {
      requestTemplates.add(template);
      saveTemplates();
    });
  }

  void validateJson() {
    if (bodyController.text.isEmpty) {
      setState(() {
        isJsonValid = true;
        jsonError = '';
      });
      return;
    }
    try {
      json.decode(bodyController.text);
      setState(() {
        isJsonValid = true;
        jsonError = '';
      });
    } catch (e) {
      setState(() {
        isJsonValid = false;
        jsonError = 'Invalid JSON: $e';
      });
    }
  }

  String replaceVariables(String text) {
    var result = text;
    final variables = environments[selectedEnvironment]!['variables'] as Map<String, dynamic>;
    variables.forEach((key, value) {
      result = result.replaceAll('{{$key}}', value.toString());
    });
    return result;
  }

  Future<void> sendRequest() async {
    try {
      final startTime = DateTime.now();
      String url = urlController.text;
      
      // Replace variables in URL
      url = replaceVariables(url);
      
      Uri uri = Uri.parse(url);
      if (params.isNotEmpty) {
        final queryParams = Map.fromEntries(params.map((e) => MapEntry(e['key']!, e['value']!)));
        uri = uri.replace(queryParameters: queryParams);
      }

      final requestHeaders = Map.fromEntries(
        headers.map((e) => MapEntry(e['key']!, replaceVariables(e['value']!)))
      );

      // Add authentication headers
      switch (authType) {
        case 'Basic':
          final basicAuth = 'Basic ${base64Encode(utf8.encode('${usernameController.text}:${passwordController.text}'))}';
          requestHeaders['Authorization'] = basicAuth;
          break;
        case 'Bearer':
          requestHeaders['Authorization'] = 'Bearer ${tokenController.text}';
          break;
      }

      final timeout = int.tryParse(timeoutController.text) ?? 30;
      http.Response response;
      
      switch (selectedMethod) {
        case 'POST':
          response = await http.post(
            uri,
            headers: requestHeaders,
            body: bodyController.text,
          ).timeout(Duration(seconds: timeout));
          break;
        case 'PUT':
          response = await http.put(
            uri,
            headers: requestHeaders,
            body: bodyController.text,
          ).timeout(Duration(seconds: timeout));
          break;
        case 'PATCH':
          response = await http.patch(
            uri,
            headers: requestHeaders,
            body: bodyController.text,
          ).timeout(Duration(seconds: timeout));
          break;
        case 'DELETE':
          response = await http.delete(
            uri,
            headers: requestHeaders,
          ).timeout(Duration(seconds: timeout));
          break;
        case 'HEAD':
          response = await http.head(
            uri,
            headers: requestHeaders,
          ).timeout(Duration(seconds: timeout));
          break;
        case 'OPTIONS':
          final request = http.Request('OPTIONS', uri);
          request.headers.addAll(requestHeaders);
          response = await request.send().then((streamedResponse) => http.Response.fromStream(streamedResponse));
          break;
        default:
          response = await http.get(
            uri,
            headers: requestHeaders,
          ).timeout(Duration(seconds: timeout));
      }

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);

      setState(() {
        try {
          final jsonResponse = json.decode(response.body);
          previewController.text = const JsonEncoder.withIndent('  ').convert(jsonResponse);
        } catch (e) {
          previewController.text = response.body;
        }
        statusCode = '${response.statusCode} ${response.reasonPhrase}';
        responseHeaders = response.headers;
        responseTime = '${duration.inMilliseconds}ms';
        responseSize = '${response.body.length} bytes';
        
        requestHistory.insert(0, {
          'method': selectedMethod,
          'url': urlController.text,
          'status': statusCode,
          'time': responseTime,
          'timestamp': DateTime.now().toIso8601String(),
        });
        saveHistory();
      });
    } catch (e) {
      setState(() {
        previewController.text = 'Error: $e';
        statusCode = 'Error';
        responseTime = '';
        responseSize = '';
      });
    }
  }

  Future<void> saveProjects() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('projects', jsonEncode(savedProjects));
  }

  Future<void> loadProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('projects');
    if (data != null) {
      setState(() {
        savedProjects = Map<String, List<String>>.from(jsonDecode(data));
      });
    }
  }

  Future<void> saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('history', jsonEncode(requestHistory));
  }

  Future<void> loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('history');
    if (data != null) {
      setState(() {
        requestHistory = List<Map<String, dynamic>>.from(jsonDecode(data));
      });
    }
  }

  void addProject() {
    setState(() {
      final name = 'Project ${savedProjects.length + 1}';
      savedProjects[name] = [];
      selectedProject = name;
      curls = [];
      saveProjects();
    });
  }

  void addCurl() {
    if (selectedProject.isEmpty) return;
    setState(() {
      savedProjects[selectedProject]!.add(urlController.text);
      curls = savedProjects[selectedProject]!;
      saveProjects();
    });
  }

  void addParamField() {
    setState(() {
      params.add({'key': '', 'value': ''});
    });
  }

  void addHeaderField() {
    setState(() {
      headers.add({'key': '', 'value': ''});
    });
  }

  Widget buildParamEditor() {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
                Text('PARAMETERS', 
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  )
                ),
            Spacer(),
            IconButton(
                  icon: Icon(Icons.add, color: colorScheme.primary),
              onPressed: addParamField,
            ),
          ],
        ),
        Column(
          children: params.asMap().entries.map((entry) {
            final i = entry.key;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (val) => params[i]['key'] = val,
                          decoration: InputDecoration(
                            hintText: 'Key',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: colorScheme.surface,
                          ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    onChanged: (val) => params[i]['value'] = val,
                          decoration: InputDecoration(
                            hintText: 'Value',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: colorScheme.surface,
                          ),
                  ),
                ),
                IconButton(
                        icon: Icon(Icons.remove_circle, color: colorScheme.error),
                  onPressed: () => setState(() => params.removeAt(i)),
                ),
              ],
                  ),
            );
          }).toList(),
        ),
          ],
        ),
      ),
    );
  }

  Widget buildHeaderEditor() {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('HEADERS', 
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  )
                ),
                Spacer(),
                IconButton(
                  icon: Icon(Icons.add, color: colorScheme.primary),
                  onPressed: addHeaderField,
                ),
              ],
            ),
            Column(
              children: headers.asMap().entries.map((entry) {
                final i = entry.key;
    return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: (val) => headers[i]['key'] = val,
                          decoration: InputDecoration(
                            hintText: 'Header Name',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: colorScheme.surface,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          onChanged: (val) => headers[i]['value'] = val,
                          decoration: InputDecoration(
                            hintText: 'Value',
                            border: OutlineInputBorder(),
                            filled: true,
                            fillColor: colorScheme.surface,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.remove_circle, color: colorScheme.error),
                        onPressed: () => setState(() => headers.removeAt(i)),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildBodyEditor() {
    final colorScheme = Theme.of(context).colorScheme;
    if (selectedMethod != 'GET' && selectedMethod != 'DELETE') {
      return Card(
        margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('REQUEST BODY', 
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                )
              ),
              SizedBox(height: 8),
              TextField(
                controller: bodyController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Enter request body (JSON)',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: colorScheme.surface,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return SizedBox.shrink();
  }

  Widget buildResponseInfo() {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
                Text('RESPONSE INFO', 
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  )
                ),
              Spacer(),
                IconButton(
                  icon: Icon(
                    showResponseHeaders ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: colorScheme.primary,
                  ),
                  onPressed: () => setState(() => showResponseHeaders = !showResponseHeaders),
                ),
              ],
            ),
            if (showResponseHeaders) ...[
              SizedBox(height: 8),
              ...responseHeaders.entries.map((e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Text('${e.key}: ${e.value}'),
              )),
            ],
            SizedBox(height: 8),
            Row(
              children: [
                Chip(
                  label: Text('Time: $responseTime'),
                  backgroundColor: colorScheme.surfaceVariant,
                ),
                SizedBox(width: 8),
                Chip(
                  label: Text('Size: $responseSize'),
                  backgroundColor: colorScheme.surfaceVariant,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('favorites');
    if (data != null) {
      setState(() {
        favoriteRequests = List<String>.from(jsonDecode(data));
      });
    }
  }

  Future<void> saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('favorites', jsonEncode(favoriteRequests));
  }

  void toggleFavorite(String requestId) {
    setState(() {
      if (favoriteRequests.contains(requestId)) {
        favoriteRequests.remove(requestId);
      } else {
        favoriteRequests.add(requestId);
      }
      saveFavorites();
    });
  }

  void duplicateRequest(Map<String, dynamic> request) {
    setState(() {
      selectedMethod = request['method'] as String;
      urlController.text = request['url'] as String;
      headers = List<Map<String, String>>.from(request['headers'] as List);
      bodyController.text = request['body'] as String;
      params = List<Map<String, String>>.from(request['params'] as List);
    });
  }

  void deleteHistoryItem(int index) {
    setState(() {
      requestHistory.removeAt(index);
      saveHistory();
    });
  }

  void deleteTemplate(int index) {
    setState(() {
      requestTemplates.removeAt(index);
      saveTemplates();
    });
  }

  void renameTemplate(int index, String newName) {
    setState(() {
      requestTemplates[index]['name'] = newName;
      saveTemplates();
    });
  }

  List<Map<String, dynamic>> getFilteredHistory() {
    var filtered = requestHistory;
    if (historySearchQuery.isNotEmpty) {
      filtered = filtered.where((item) {
        final url = item['url'].toString().toLowerCase();
        final method = item['method'].toString().toLowerCase();
        final status = item['status'].toString().toLowerCase();
        final query = historySearchQuery.toLowerCase();
        return url.contains(query) || method.contains(query) || status.contains(query);
      }).toList();
    }
    if (showFavoritesOnly) {
      filtered = filtered.where((item) => favoriteRequests.contains(item['id'])).toList();
    }
    return filtered;
  }

  List<Map<String, dynamic>> getFilteredTemplates() {
    var filtered = requestTemplates;
    if (templateSearchQuery.isNotEmpty) {
      filtered = filtered.where((template) {
        final name = template['name'].toString().toLowerCase();
        final url = template['url'].toString().toLowerCase();
        final method = template['method'].toString().toLowerCase();
        final query = templateSearchQuery.toLowerCase();
        return name.contains(query) || url.contains(query) || method.contains(query);
      }).toList();
    }
    return filtered;
  }

  Widget buildHistoryList() {
    final colorScheme = Theme.of(context).colorScheme;
    final filteredHistory = getFilteredHistory();
    
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('HISTORY', 
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  )
                ),
                Spacer(),
                IconButton(
                  icon: Icon(
                    isHistorySearching ? Icons.close : Icons.search,
                    color: colorScheme.primary,
                  ),
                  onPressed: () => setState(() => isHistorySearching = !isHistorySearching),
                ),
                IconButton(
                  icon: Icon(
                    showFavoritesOnly ? Icons.star : Icons.star_border,
                    color: showFavoritesOnly ? Colors.amber : colorScheme.primary,
                  ),
                  onPressed: () => setState(() => showFavoritesOnly = !showFavoritesOnly),
                ),
              ],
            ),
            if (isHistorySearching)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextField(
                  controller: historySearchController,
                  decoration: InputDecoration(
                    hintText: 'Search history...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: colorScheme.surface,
                  ),
                  onChanged: (value) => setState(() => historySearchQuery = value),
                ),
              ),
            SizedBox(height: 8),
          Expanded(
              child: ListView.builder(
                itemCount: filteredHistory.length,
                itemBuilder: (context, index) {
                  final item = filteredHistory[index];
                  final timestamp = DateTime.parse(item['timestamp'] as String);
                  final formattedTime = DateFormat('HH:mm:ss').format(timestamp);
                  final isFavorite = favoriteRequests.contains(item['id']);
                  
                  return Dismissible(
                    key: Key(item['id'] as String),
                    background: Container(
                      color: colorScheme.error,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 16),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) => deleteHistoryItem(index),
                    child: ListTile(
                      leading: Icon(
                        item['status'].toString().startsWith('2') ? Icons.check_circle : Icons.error,
                        color: item['status'].toString().startsWith('2') ? Colors.green : Colors.red,
                      ),
                      title: Text('${item['method']} ${item['url']}'),
                      subtitle: Text('${item['status']} • ${item['time']} • $formattedTime'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              isFavorite ? Icons.star : Icons.star_border,
                              color: isFavorite ? Colors.amber : null,
                            ),
                            onPressed: () => toggleFavorite(item['id'] as String),
                          ),
                          IconButton(
                            icon: Icon(Icons.content_copy),
                            onPressed: () => duplicateRequest(item),
                          ),
                        ],
                      ),
                      onTap: () {
                        setState(() {
                          selectedMethod = item['method'] as String;
                          urlController.text = item['url'] as String;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTemplatesList() {
    final colorScheme = Theme.of(context).colorScheme;
    final filteredTemplates = getFilteredTemplates();
    
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('TEMPLATES', 
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  )
                ),
                Spacer(),
                IconButton(
                  icon: Icon(
                    isTemplateSearching ? Icons.close : Icons.search,
                    color: colorScheme.primary,
                  ),
                  onPressed: () => setState(() => isTemplateSearching = !isTemplateSearching),
                ),
              ],
            ),
            if (isTemplateSearching)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextField(
                  controller: templateSearchController,
                  decoration: InputDecoration(
                    hintText: 'Search templates...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: colorScheme.surface,
                  ),
                  onChanged: (value) => setState(() => templateSearchQuery = value),
                ),
              ),
            SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: filteredTemplates.length,
                itemBuilder: (context, index) {
                  final template = filteredTemplates[index];
                  return Dismissible(
                    key: Key(template['name'] as String),
                    background: Container(
                      color: colorScheme.error,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 16),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) => deleteTemplate(index),
                    child: ListTile(
                      leading: Icon(Icons.description, color: colorScheme.primary),
                      title: Text(template['name'] as String),
                      subtitle: Text('${template['method']} ${template['url']}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () => showRenameDialog(index, template['name'] as String),
                          ),
                          IconButton(
                            icon: Icon(Icons.content_copy),
                            onPressed: () {
                              setState(() {
                                selectedMethod = template['method'] as String;
                                urlController.text = template['url'] as String;
                                headers = List<Map<String, String>>.from(template['headers'] as List);
                                bodyController.text = template['body'] as String;
                                params = List<Map<String, String>>.from(template['params'] as List);
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isWideScreen = MediaQuery.of(context).size.width > 1200;
    final isMediumScreen = MediaQuery.of(context).size.width > 800;
    
    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Row(
        children: [
            Icon(Icons.api, color: colorScheme.primary),
            SizedBox(width: 8),
            Text('Insomnia Lite'),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: Icon(Icons.send),
              text: 'Request',
            ),
            Tab(
              icon: Icon(Icons.receipt_long),
              text: 'Response',
            ),
            Tab(
              icon: Icon(Icons.folder),
              text: 'Collections',
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => widget.onThemeChanged(!widget.isDarkMode),
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Settings'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: Icon(Icons.color_lens),
                        title: Text('Theme'),
                        subtitle: Text(widget.isDarkMode ? 'Dark Mode' : 'Light Mode'),
                        onTap: () => widget.onThemeChanged(!widget.isDarkMode),
                      ),
                      ListTile(
                        leading: Icon(Icons.timer),
                        title: Text('Default Timeout'),
                        subtitle: Text('${timeoutController.text} seconds'),
                        onTap: () {
                          final controller = TextEditingController(text: timeoutController.text);
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Set Default Timeout'),
                              content: TextField(
                                controller: controller,
                                decoration: InputDecoration(
                                  labelText: 'Timeout (seconds)',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('Cancel'),
                                ),
                                FilledButton(
                                  onPressed: () {
                                    setState(() => timeoutController.text = controller.text);
                                    Navigator.pop(context);
                                  },
                                  child: Text('Save'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildRequestTab(),
          buildResponseTab(),
          buildCollectionsTab(),
        ],
      ),
      floatingActionButton: _selectedTabIndex == 0
          ? FloatingActionButton.extended(
              onPressed: sendRequest,
              icon: Icon(Icons.send),
              label: Text('Send Request'),
            )
          : null,
    );
  }

  Widget buildCollectionsTab() {
    final isWideScreen = MediaQuery.of(context).size.width > 1200;
    final isMediumScreen = MediaQuery.of(context).size.width > 800;
    
    if (isWideScreen) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SizedBox(
              height: MediaQuery.of(context).size.height - 200, // Account for app bar and tab bar
              child: buildColumn(
                "MY PROJECTS",
                savedProjects.keys.toList(),
                addProject,
                (p) {
                  setState(() {
                    selectedProject = p;
                    curls = savedProjects[p]!;
                    projectDescriptionController.text = selectedProjectDescription;
                  });
                },
              ),
            ),
          ),
          Expanded(
            child: SizedBox(
              height: MediaQuery.of(context).size.height - 200,
              child: buildColumn(
                "CURLS",
                curls,
                addCurl,
                (url) {
                  setState(() => urlController.text = url);
                },
              ),
            ),
          ),
          Expanded(
            child: SizedBox(
              height: MediaQuery.of(context).size.height - 200,
              child: buildHistoryList(),
            ),
          ),
          Expanded(
            child: SizedBox(
              height: MediaQuery.of(context).size.height - 200,
              child: buildTemplatesList(),
            ),
          ),
        ],
      );
    } else if (isMediumScreen) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              children: [
                SizedBox(
                  height: (MediaQuery.of(context).size.height - 200) / 2,
                  child: buildColumn(
                    "MY PROJECTS",
                    savedProjects.keys.toList(),
                    addProject,
                    (p) {
                      setState(() {
                        selectedProject = p;
                        curls = savedProjects[p]!;
                        projectDescriptionController.text = selectedProjectDescription;
                      });
                    },
                  ),
                ),
                SizedBox(
                  height: (MediaQuery.of(context).size.height - 200) / 2,
                  child: buildColumn(
                    "CURLS",
                    curls,
                    addCurl,
                    (url) {
                      setState(() => urlController.text = url);
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              children: [
                SizedBox(
                  height: (MediaQuery.of(context).size.height - 200) / 2,
                  child: buildHistoryList(),
                ),
                SizedBox(
                  height: (MediaQuery.of(context).size.height - 200) / 2,
                  child: buildTemplatesList(),
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      return SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 300,
              child: buildColumn(
                "MY PROJECTS",
                savedProjects.keys.toList(),
                addProject,
                (p) {
                  setState(() {
                    selectedProject = p;
                    curls = savedProjects[p]!;
                    projectDescriptionController.text = selectedProjectDescription;
                  });
                },
              ),
            ),
            SizedBox(
              height: 300,
              child: buildColumn(
                "CURLS",
                curls,
                addCurl,
                (url) {
                  setState(() => urlController.text = url);
                },
              ),
            ),
            SizedBox(
              height: 300,
              child: buildHistoryList(),
            ),
            SizedBox(
              height: 300,
              child: buildTemplatesList(),
            ),
          ],
        ),
      );
    }
  }

  Widget buildRequestTab() {
    final isWideScreen = MediaQuery.of(context).size.width > 1200;
    final isMediumScreen = MediaQuery.of(context).size.width > 800;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isWideScreen)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        buildEnvironmentSelector(),
                        buildAuthSettings(),
                        buildRequestSettings(),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        buildRequestHeader(),
                        buildParamEditor(),
                        buildHeaderEditor(),
                        buildBodyEditor(),
                      ],
                    ),
                  ),
                ],
              )
            else
              Column(
                children: [
                  buildEnvironmentSelector(),
                  buildAuthSettings(),
                  buildRequestSettings(),
                  buildRequestHeader(),
                  buildParamEditor(),
                  buildHeaderEditor(),
                  buildBodyEditor(),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget buildResponseTab() {
    final colorScheme = Theme.of(context).colorScheme;
    final isWideScreen = MediaQuery.of(context).size.width > 1200;
    
    return Column(
      children: [
        buildResponseInfo(),
        Expanded(
          child: Card(
            margin: EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('RESPONSE', 
                        style: TextStyle(
                          fontWeight: FontWeight.bold, 
                          fontSize: 16,
                          color: colorScheme.primary,
                        )
                      ),
                      Spacer(),
                      if (previewController.text.isNotEmpty)
                        IconButton(
                          icon: Icon(Icons.copy),
                          onPressed: () {
                            // TODO: Implement copy to clipboard
                          },
                        ),
                    ],
                  ),
                  if (!isJsonValid)
          Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                        jsonError,
                        style: TextStyle(color: colorScheme.error),
                      ),
                    ),
                  SizedBox(height: 10),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.all(8),
                      child: HighlightView(
                        previewController.text,
                        language: 'json',
                        theme: widget.isDarkMode ? monokaiSublimeTheme : githubTheme,
                        padding: EdgeInsets.all(12),
                        textStyle: TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 14,
                          color: widget.isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildRequestHeader() {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
            padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('REQUEST', 
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              )
            ),
            SizedBox(height: 8),
            Row(
              children: [
                DropdownButton<String>(
                  value: selectedMethod,
                  items: httpMethods
                      .map((String value) => DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          ))
                      .toList(),
                  onChanged: (val) => setState(() => selectedMethod = val!),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: urlController,
                    decoration: InputDecoration(
                      hintText: 'Enter URL here...',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: colorScheme.surface,
                      prefixIcon: Icon(Icons.link),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusCode.startsWith('2') ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(6)
                  ),
                  child: Text(
                    statusCode,
                    style: TextStyle(color: Colors.white),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildEnvironmentSelector() {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ENVIRONMENT', 
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              )
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: selectedEnvironment,
                    items: environments.keys.map((String env) {
                      return DropdownMenuItem<String>(
                        value: env,
                        child: Text(env),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                    setState(() {
                          selectedEnvironment = newValue;
                        });
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.settings, color: colorScheme.primary),
                  onPressed: () {
                    // TODO: Implement environment settings dialog
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAuthSettings() {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('AUTHENTICATION', 
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  )
                ),
                Spacer(),
                DropdownButton<String>(
                  value: authType,
                  items: ['None', 'Basic', 'Bearer'].map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        authType = newValue;
                      });
                    }
                  },
                ),
              ],
            ),
            if (authType == 'Basic') ...[
              SizedBox(height: 8),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: colorScheme.surface,
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: colorScheme.surface,
                ),
                obscureText: true,
              ),
            ] else if (authType == 'Bearer') ...[
              SizedBox(height: 8),
              TextField(
                controller: tokenController,
                decoration: InputDecoration(
                  labelText: 'Token',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: colorScheme.surface,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget buildRequestSettings() {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('REQUEST SETTINGS', 
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              )
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: timeoutController,
                    decoration: InputDecoration(
                      labelText: 'Timeout (seconds)',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: colorScheme.surface,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 16),
                FilledButton.icon(
                  onPressed: saveAsTemplate,
                  icon: Icon(Icons.save),
                  label: Text('Save as Template'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void showRenameDialog(int index, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Rename Template'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'New Name',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) {
            renameTemplate(index, value);
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              renameTemplate(index, controller.text);
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  // Add new methods for project management
  void renameProject(String oldName, String newName) {
    setState(() {
      final curls = savedProjects[oldName]!;
      savedProjects.remove(oldName);
      savedProjects[newName] = curls;
      if (selectedProject == oldName) {
        selectedProject = newName;
      }
      saveProjects();
    });
  }

  void deleteProject(String name) {
    setState(() {
      savedProjects.remove(name);
      if (selectedProject == name) {
        selectedProject = savedProjects.keys.firstOrNull ?? '';
        curls = selectedProject.isEmpty ? [] : savedProjects[selectedProject]!;
      }
      saveProjects();
    });
  }

  void deleteCurl(String projectName, String curl) {
    setState(() {
      savedProjects[projectName]!.remove(curl);
      if (selectedProject == projectName) {
        curls = savedProjects[projectName]!;
      }
      saveProjects();
    });
  }

  void updateProjectDescription(String name, String description) {
    setState(() {
      if (!savedProjects.containsKey(name)) return;
      final curls = savedProjects[name]!;
      savedProjects.remove(name);
      savedProjects[name] = curls;
      selectedProjectDescription = description;
      saveProjects();
    });
  }

  List<String> getFilteredProjects() {
    var filtered = savedProjects.keys.toList();
    if (projectSearchQuery.isNotEmpty) {
      filtered = filtered.where((name) => 
        name.toLowerCase().contains(projectSearchQuery.toLowerCase())
      ).toList();
    }
    return filtered;
  }

  List<String> getFilteredCurls() {
    if (selectedProject.isEmpty) return [];
    var filtered = savedProjects[selectedProject]!;
    if (curlSearchQuery.isNotEmpty) {
      filtered = filtered.where((curl) => 
        curl.toLowerCase().contains(curlSearchQuery.toLowerCase())
      ).toList();
    }
    return filtered;
  }

  Widget buildColumn(String title, List<String> items, VoidCallback onAdd, Function(String) onSelect) {
    final colorScheme = Theme.of(context).colorScheme;
    final isProjects = title == "MY PROJECTS";
    final isCurls = title == "CURLS";
    final filteredItems = isProjects ? getFilteredProjects() : 
                         isCurls ? getFilteredCurls() : items;

    return Card(
      margin: EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
            Row(
              children: [
                Text(title, 
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: colorScheme.primary,
                  )
                ),
                Spacer(),
                if (isProjects || isCurls)
                  IconButton(
                    icon: Icon(
                      isProjects ? (isProjectSearching ? Icons.close : Icons.search) :
                                (isCurlSearching ? Icons.close : Icons.search),
                      color: colorScheme.primary,
                    ),
                    onPressed: () => setState(() {
                      if (isProjects) {
                        isProjectSearching = !isProjectSearching;
                        if (!isProjectSearching) projectSearchQuery = '';
                      } else {
                        isCurlSearching = !isCurlSearching;
                        if (!isCurlSearching) curlSearchQuery = '';
                      }
                    }),
                  ),
                if (isProjects)
                  IconButton(
                    icon: Icon(
                      showProjectSettings ? Icons.settings : Icons.settings_outlined,
                      color: colorScheme.primary,
                    ),
                    onPressed: () => setState(() => showProjectSettings = !showProjectSettings),
                  ),
                FilledButton.icon(
                  onPressed: onAdd,
                  icon: Icon(Icons.add),
                  label: Text('Add New'),
                ),
              ],
            ),
            if ((isProjects && isProjectSearching) || (isCurls && isCurlSearching))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TextField(
                  controller: isProjects ? projectSearchController : curlSearchController,
                  decoration: InputDecoration(
                    hintText: 'Search ${isProjects ? 'projects' : 'curls'}...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: colorScheme.surface,
                  ),
                  onChanged: (value) => setState(() {
                    if (isProjects) {
                      projectSearchQuery = value;
                    } else {
                      curlSearchQuery = value;
                    }
                  }),
                ),
              ),
            if (isProjects && showProjectSettings && selectedProject.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: projectDescriptionController,
                      decoration: InputDecoration(
                        labelText: 'Project Description',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: colorScheme.surface,
                      ),
                      maxLines: 2,
                      onChanged: (value) => selectedProjectDescription = value,
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () {
                              final controller = TextEditingController(text: selectedProject);
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Rename Project'),
                                  content: TextField(
                                    controller: controller,
                                    decoration: InputDecoration(
                                      labelText: 'New Name',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('Cancel'),
                                    ),
                                    FilledButton(
                                      onPressed: () {
                                        renameProject(selectedProject, controller.text);
                                        Navigator.pop(context);
                                      },
                                      child: Text('Save'),
                        ),
                      ],
                    ),
                              );
                            },
                            icon: Icon(Icons.edit),
                            label: Text('Rename'),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Delete Project'),
                                  content: Text('Are you sure you want to delete "$selectedProject"?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text('Cancel'),
                                    ),
                                    FilledButton(
                                      onPressed: () {
                                        deleteProject(selectedProject);
                                        Navigator.pop(context);
                                      },
                                      style: FilledButton.styleFrom(
                                        backgroundColor: colorScheme.error,
                                      ),
                                      child: Text('Delete'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            icon: Icon(Icons.delete),
                            label: Text('Delete'),
                            style: FilledButton.styleFrom(
                              backgroundColor: colorScheme.error,
                            ),
            ),
          ),
        ],
                    ),
                  ],
                ),
              ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final item = filteredItems[index];
                  return Dismissible(
                    key: Key(item),
                    background: Container(
                      color: colorScheme.error,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 16),
                      child: Icon(Icons.delete, color: Colors.white),
                    ),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      if (isProjects) {
                        deleteProject(item);
                      } else if (isCurls) {
                        deleteCurl(selectedProject, item);
                      }
                    },
                    child: ListTile(
                      title: Text(item),
                      subtitle: isProjects && savedProjects[item] != null
                          ? Text('${savedProjects[item]!.length} requests')
                          : null,
                      onTap: () => onSelect(item),
                      selected: isProjects ? selectedProject == item : false,
                      selectedTileColor: colorScheme.primaryContainer.withOpacity(0.1),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
