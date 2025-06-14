import 'package:flutter/material.dart';

class RequestEnvironment extends StatelessWidget {
  final String selectedEnvironment;
  final List<String> environments;
  final Function(String) onEnvironmentChanged;
  final Function() onAddEnvironment;
  final Function(String) onEditEnvironment;
  final Function(String) onDeleteEnvironment;

  const RequestEnvironment({
    super.key,
    required this.selectedEnvironment,
    required this.environments,
    required this.onEnvironmentChanged,
    required this.onAddEnvironment,
    required this.onEditEnvironment,
    required this.onDeleteEnvironment,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ENVIRONMENT',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
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
                    if (selectedEnvironment.isNotEmpty) ...[
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => onEditEnvironment(selectedEnvironment),
                        tooltip: 'Edit Environment',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => onDeleteEnvironment(selectedEnvironment),
                        tooltip: 'Delete Environment',
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButton<String>(
              value: selectedEnvironment.isEmpty ? null : selectedEnvironment,
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
    );
  }
} 