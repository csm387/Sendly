import 'package:flutter/material.dart';

enum AuthType {
  none,
  basic,
  bearer,
  custom,
}

class RequestAuth extends StatelessWidget {
  final AuthType authType;
  final Map<String, String> authData;
  final Function(AuthType) onAuthTypeChanged;
  final Function(Map<String, String>) onAuthDataChanged;

  const RequestAuth({
    super.key,
    required this.authType,
    required this.authData,
    required this.onAuthTypeChanged,
    required this.onAuthDataChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AUTHENTICATION',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButton<AuthType>(
              value: authType,
              items: AuthType.values.map((type) {
                String label;
                switch (type) {
                  case AuthType.none:
                    label = 'No Auth';
                    break;
                  case AuthType.basic:
                    label = 'Basic Auth';
                    break;
                  case AuthType.bearer:
                    label = 'Bearer Token';
                    break;
                  case AuthType.custom:
                    label = 'Custom';
                    break;
                }
                return DropdownMenuItem(
                  value: type,
                  child: Text(label),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  onAuthTypeChanged(value);
                }
              },
            ),
            const SizedBox(height: 16),
            if (authType == AuthType.basic) ...[
              TextField(
                controller: TextEditingController(text: authData['username'] ?? ''),
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  final newData = Map<String, String>.from(authData);
                  newData['username'] = value;
                  onAuthDataChanged(newData);
                },
              ),
              const SizedBox(height: 8),
              TextField(
                controller: TextEditingController(text: authData['password'] ?? ''),
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                onChanged: (value) {
                  final newData = Map<String, String>.from(authData);
                  newData['password'] = value;
                  onAuthDataChanged(newData);
                },
              ),
            ] else if (authType == AuthType.bearer) ...[
              TextField(
                controller: TextEditingController(text: authData['token'] ?? ''),
                decoration: const InputDecoration(
                  labelText: 'Bearer Token',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  final newData = Map<String, String>.from(authData);
                  newData['token'] = value;
                  onAuthDataChanged(newData);
                },
              ),
            ] else if (authType == AuthType.custom) ...[
              TextField(
                controller: TextEditingController(text: authData['header'] ?? ''),
                decoration: const InputDecoration(
                  labelText: 'Header Name',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  final newData = Map<String, String>.from(authData);
                  newData['header'] = value;
                  onAuthDataChanged(newData);
                },
              ),
              const SizedBox(height: 8),
              TextField(
                controller: TextEditingController(text: authData['value'] ?? ''),
                decoration: const InputDecoration(
                  labelText: 'Header Value',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  final newData = Map<String, String>.from(authData);
                  newData['value'] = value;
                  onAuthDataChanged(newData);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
} 