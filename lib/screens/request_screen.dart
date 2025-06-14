import 'package:flutter/material.dart';
import '../models/request.dart';
import '../models/environment.dart';

class RequestScreen extends StatelessWidget {
  final Request request;
  final Environment? environment;
  final List<String> environments;
  final Function(Request) onRequestChanged;
  final Function(String) onEnvironmentChanged;
  final Function() onAddEnvironment;
  final Function(String) onEditEnvironment;
  final Function(String) onDeleteEnvironment;
  final Function() onSendRequest;

  const RequestScreen({
    super.key,
    required this.request,
    required this.environment,
    required this.environments,
    required this.onRequestChanged,
    required this.onEnvironmentChanged,
    required this.onAddEnvironment,
    required this.onEditEnvironment,
    required this.onDeleteEnvironment,
    required this.onSendRequest,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'REQUEST',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      DropdownButton<String>(
                        value: request.method,
                        items: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'HEAD', 'OPTIONS']
                            .map((m) => DropdownMenuItem(
                                  value: m,
                                  child: Text(m),
                                ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            onRequestChanged(request.copyWith(method: value));
                          }
                        },
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: TextEditingController(text: request.url),
                          decoration: const InputDecoration(
                            hintText: 'Enter URL',
                            prefixIcon: Icon(Icons.link),
                          ),
                          onChanged: (url) {
                            onRequestChanged(request.copyWith(url: url));
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'REQUEST BODY',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            controller: TextEditingController(text: request.body),
                            maxLines: null,
                            decoration: const InputDecoration(
                              hintText: 'Enter request body',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (body) {
                              onRequestChanged(request.copyWith(body: body));
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'HEADERS',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: request.headers.length,
                            itemBuilder: (context, index) {
                              final key = request.headers.keys.elementAt(index);
                              final value = request.headers[key]!;
                              
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: TextEditingController(text: key),
                                        decoration: const InputDecoration(
                                          hintText: 'Header name',
                                          border: OutlineInputBorder(),
                                        ),
                                        onChanged: (newKey) {
                                          if (newKey.isNotEmpty) {
                                            final newHeaders = Map<String, String>.from(request.headers);
                                            newHeaders.remove(key);
                                            newHeaders[newKey] = value;
                                            onRequestChanged(request.copyWith(headers: newHeaders));
                                          }
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: TextField(
                                        controller: TextEditingController(text: value),
                                        decoration: const InputDecoration(
                                          hintText: 'Header value',
                                          border: OutlineInputBorder(),
                                        ),
                                        onChanged: (newValue) {
                                          final newHeaders = Map<String, String>.from(request.headers);
                                          newHeaders[key] = newValue;
                                          onRequestChanged(request.copyWith(headers: newHeaders));
                                        },
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        final newHeaders = Map<String, String>.from(request.headers);
                                        newHeaders.remove(key);
                                        onRequestChanged(request.copyWith(headers: newHeaders));
                                      },
                                      tooltip: 'Remove Header',
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              final newHeaders = Map<String, String>.from(request.headers);
                              newHeaders[''] = '';
                              onRequestChanged(request.copyWith(headers: newHeaders));
                            },
                            tooltip: 'Add Header',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PARAMETERS',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: request.params.length,
                            itemBuilder: (context, index) {
                              final key = request.params.keys.elementAt(index);
                              final value = request.params[key]!;
                              
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: TextEditingController(text: key),
                                        decoration: const InputDecoration(
                                          hintText: 'Parameter name',
                                          border: OutlineInputBorder(),
                                        ),
                                        onChanged: (newKey) {
                                          if (newKey.isNotEmpty) {
                                            final newParams = Map<String, String>.from(request.params);
                                            newParams.remove(key);
                                            newParams[newKey] = value;
                                            onRequestChanged(request.copyWith(params: newParams));
                                          }
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: TextField(
                                        controller: TextEditingController(text: value),
                                        decoration: const InputDecoration(
                                          hintText: 'Parameter value',
                                          border: OutlineInputBorder(),
                                        ),
                                        onChanged: (newValue) {
                                          final newParams = Map<String, String>.from(request.params);
                                          newParams[key] = newValue;
                                          onRequestChanged(request.copyWith(params: newParams));
                                        },
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        final newParams = Map<String, String>.from(request.params);
                                        newParams.remove(key);
                                        onRequestChanged(request.copyWith(params: newParams));
                                      },
                                      tooltip: 'Remove Parameter',
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              final newParams = Map<String, String>.from(request.params);
                              newParams[''] = '';
                              onRequestChanged(request.copyWith(params: newParams));
                            },
                            tooltip: 'Add Parameter',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AUTHENTICATION',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          DropdownButton<String>(
                            value: request.authType,
                            items: ['none', 'basic', 'bearer', 'custom']
                                .map((type) => DropdownMenuItem(
                                      value: type,
                                      child: Text(type.toUpperCase()),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                onRequestChanged(request.copyWith(authType: value));
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          if (request.authType == 'basic') ...[
                            TextField(
                              controller: TextEditingController(text: request.authData?['username'] ?? ''),
                              decoration: const InputDecoration(
                                labelText: 'Username',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                final newData = Map<String, String>.from(request.authData ?? {});
                                newData['username'] = value;
                                onRequestChanged(request.copyWith(authData: newData));
                              },
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: TextEditingController(text: request.authData?['password'] ?? ''),
                              decoration: const InputDecoration(
                                labelText: 'Password',
                                border: OutlineInputBorder(),
                              ),
                              obscureText: true,
                              onChanged: (value) {
                                final newData = Map<String, String>.from(request.authData ?? {});
                                newData['password'] = value;
                                onRequestChanged(request.copyWith(authData: newData));
                              },
                            ),
                          ] else if (request.authType == 'bearer') ...[
                            TextField(
                              controller: TextEditingController(text: request.authData?['token'] ?? ''),
                              decoration: const InputDecoration(
                                labelText: 'Bearer Token',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                final newData = Map<String, String>.from(request.authData ?? {});
                                newData['token'] = value;
                                onRequestChanged(request.copyWith(authData: newData));
                              },
                            ),
                          ] else if (request.authType == 'custom') ...[
                            TextField(
                              controller: TextEditingController(text: request.authData?['header'] ?? ''),
                              decoration: const InputDecoration(
                                labelText: 'Header Name',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                final newData = Map<String, String>.from(request.authData ?? {});
                                newData['header'] = value;
                                onRequestChanged(request.copyWith(authData: newData));
                              },
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: TextEditingController(text: request.authData?['value'] ?? ''),
                              decoration: const InputDecoration(
                                labelText: 'Header Value',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                final newData = Map<String, String>.from(request.authData ?? {});
                                newData['value'] = value;
                                onRequestChanged(request.copyWith(authData: newData));
                              },
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'ENVIRONMENT',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: onAddEnvironment,
                                    tooltip: 'Add Environment',
                                  ),
                                  if (environment != null) ...[
                                    IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed: () => onEditEnvironment(environment!.name),
                                      tooltip: 'Edit Environment',
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () => onDeleteEnvironment(environment!.name),
                                      tooltip: 'Delete Environment',
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          DropdownButton<String>(
                            value: environment?.name,
                            hint: const Text('Select Environment'),
                            items: environments.map((env) {
                              return DropdownMenuItem(
                                value: env,
                                child: Text(env),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                onEnvironmentChanged(value);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: onSendRequest,
                    icon: const Icon(Icons.send),
                    label: const Text('Send Request'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
} 