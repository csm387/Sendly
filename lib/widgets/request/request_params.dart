import 'package:flutter/material.dart';

class RequestParams extends StatelessWidget {
  final Map<String, String> params;
  final Function(Map<String, String>) onParamsChanged;

  const RequestParams({
    super.key,
    required this.params,
    required this.onParamsChanged,
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
                  'PARAMETERS',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    final newParams = Map<String, String>.from(params);
                    newParams[''] = '';
                    onParamsChanged(newParams);
                  },
                  tooltip: 'Add Parameter',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: params.length,
                itemBuilder: (context, index) {
                  final key = params.keys.elementAt(index);
                  final value = params[key]!;
                  
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
                                final newParams = Map<String, String>.from(params);
                                newParams.remove(key);
                                newParams[newKey] = value;
                                onParamsChanged(newParams);
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
                              final newParams = Map<String, String>.from(params);
                              newParams[key] = newValue;
                              onParamsChanged(newParams);
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            final newParams = Map<String, String>.from(params);
                            newParams.remove(key);
                            onParamsChanged(newParams);
                          },
                          tooltip: 'Remove Parameter',
                        ),
                      ],
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