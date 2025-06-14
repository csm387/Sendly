import 'package:flutter/material.dart';
import '../models/request.dart';
import '../models/environment.dart';
import '../services/http_service.dart';
import '../services/storage.dart';
import 'request_screen.dart';
import 'response_screen.dart';

class AppScreen extends StatefulWidget {
  const AppScreen({super.key});

  @override
  State<AppScreen> createState() => _AppScreenState();
}

class _AppScreenState extends State<AppScreen> {
  final _storage = StorageService();
  final _http = HttpService();
  
  late Request _request;
  Environment? _environment;
  List<String> _environments = [];
  HttpResponse? _response;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final environments = await _storage.loadEnvironments();
    setState(() {
      _environments = environments.map((e) => e.name).toList();
      if (_environments.isNotEmpty) {
        _environment = environments.first;
      }
      _request = Request(
        method: 'GET',
        url: '',
        headers: {},
        params: {},
        authType: 'none',
        authData: {},
        timeout: 30,
      );
    });
  }

  Future<void> _sendRequest() async {
    if (_request.url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a URL'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _http.sendRequest(_request, _environment ?? Environment(name: 'default', baseUrl: '', variables: {}));
      setState(() {
        _response = response;
      });

      // Save to history
      final history = await _storage.loadHistory();
      history.insert(0, _request);
      await _storage.saveHistory(history);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: RequestScreen(
              request: _request,
              environment: _environment,
              environments: _environments,
              onRequestChanged: (request) {
                setState(() {
                  _request = request;
                });
              },
              onEnvironmentChanged: (name) {
                setState(() {
                  _environment = _storage.loadEnvironments().then(
                    (environments) => environments.firstWhere((e) => e.name == name),
                  ) as Environment?;
                });
              },
              onAddEnvironment: () async {
                final name = await showDialog<String>(
                  context: context,
                  builder: (context) {
                    final controller = TextEditingController();
                    return AlertDialog(
                      title: const Text('New Environment'),
                      content: TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                          labelText: 'Environment Name',
                          hintText: 'e.g. Development, Production',
                        ),
                        autofocus: true,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, controller.text),
                          child: const Text('Create'),
                        ),
                      ],
                    );
                  },
                );

                if (name != null && name.isNotEmpty) {
                  final environments = await _storage.loadEnvironments();
                  final newEnvironment = Environment(
                    name: name,
                    baseUrl: '',
                    variables: {},
                  );
                  environments.add(newEnvironment);
                  await _storage.saveEnvironments(environments);
                  setState(() {
                    _environments = environments.map((e) => e.name).toList();
                    _environment = newEnvironment;
                  });
                }
              },
              onEditEnvironment: (name) async {
                final environments = await _storage.loadEnvironments();
                final environment = environments.firstWhere((e) => e.name == name);
                
                final result = await showDialog<Environment>(
                  context: context,
                  builder: (context) {
                    final nameController = TextEditingController(text: environment.name);
                    final baseUrlController = TextEditingController(text: environment.baseUrl);
                    final variables = Map<String, String>.from(environment.variables);
                    
                    return StatefulBuilder(
                      builder: (context, setState) {
                        return AlertDialog(
                          title: const Text('Edit Environment'),
                          content: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextField(
                                  controller: nameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Environment Name',
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextField(
                                  controller: baseUrlController,
                                  decoration: const InputDecoration(
                                    labelText: 'Base URL',
                                    hintText: 'e.g. https://api.example.com',
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ...variables.entries.map((entry) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: TextField(
                                            controller: TextEditingController(text: entry.key),
                                            decoration: const InputDecoration(
                                              labelText: 'Variable Name',
                                            ),
                                            onChanged: (value) {
                                              if (value.isNotEmpty) {
                                                variables.remove(entry.key);
                                                variables[value] = entry.value;
                                              }
                                            },
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: TextField(
                                            controller: TextEditingController(text: entry.value),
                                            decoration: const InputDecoration(
                                              labelText: 'Variable Value',
                                            ),
                                            onChanged: (value) {
                                              variables[entry.key] = value;
                                            },
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed: () {
                                            setState(() {
                                              variables.remove(entry.key);
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () {
                                    setState(() {
                                      variables[''] = '';
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(
                                  context,
                                  Environment(
                                    name: nameController.text,
                                    baseUrl: baseUrlController.text,
                                    variables: variables,
                                  ),
                                );
                              },
                              child: const Text('Save'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );

                if (result != null) {
                  final index = environments.indexWhere((e) => e.name == name);
                  environments[index] = result;
                  await _storage.saveEnvironments(environments);
                  setState(() {
                    _environments = environments.map((e) => e.name).toList();
                    if (_environment?.name == name) {
                      _environment = result;
                    }
                  });
                }
              },
              onDeleteEnvironment: (name) async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('Delete Environment'),
                      content: Text('Are you sure you want to delete "$name"?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Delete'),
                        ),
                      ],
                    );
                  },
                );

                if (confirmed == true) {
                  final environments = await _storage.loadEnvironments();
                  environments.removeWhere((e) => e.name == name);
                  await _storage.saveEnvironments(environments);
                  setState(() {
                    _environments = environments.map((e) => e.name).toList();
                    if (_environment?.name == name) {
                      _environment = environments.isNotEmpty ? environments.first : null;
                    }
                  });
                }
              },
              onSendRequest: _sendRequest,
            ),
          ),
          const VerticalDivider(),
          Expanded(
            child: ResponseScreen(
              response: _response,
              isLoading: _isLoading,
            ),
          ),
        ],
      ),
    );
  }
} 