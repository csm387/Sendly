import 'package:flutter/material.dart';
import '../../models/environment.dart';

class EnvironmentList extends StatelessWidget {
  final List<Environment> environments;
  final String searchQuery;
  final Environment? selectedEnvironment;
  final Function(Environment) onEnvironmentSelected;
  final Function(Environment) onEnvironmentEdited;
  final Function(Environment) onEnvironmentDeleted;
  final Function(String) onSearchChanged;

  const EnvironmentList({
    super.key,
    required this.environments,
    required this.searchQuery,
    required this.selectedEnvironment,
    required this.onEnvironmentSelected,
    required this.onEnvironmentEdited,
    required this.onEnvironmentDeleted,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredEnvironments = environments.where((env) {
      return env.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          env.baseUrl.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
    
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
                  'ENVIRONMENTS',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    // TODO: Implement add environment
                  },
                  tooltip: 'Add Environment',
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: TextEditingController(text: searchQuery),
              decoration: const InputDecoration(
                hintText: 'Search environments...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: onSearchChanged,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: filteredEnvironments.length,
                itemBuilder: (context, index) {
                  final environment = filteredEnvironments[index];
                  final isSelected = selectedEnvironment?.name == environment.name;
                  
                  return ListTile(
                    selected: isSelected,
                    title: Text(environment.name),
                    subtitle: Text(
                      '${environment.baseUrl} - ${environment.variables.length} variables',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => onEnvironmentEdited(environment),
                          tooltip: 'Edit Environment',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => onEnvironmentDeleted(environment),
                          tooltip: 'Delete Environment',
                        ),
                      ],
                    ),
                    onTap: () => onEnvironmentSelected(environment),
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