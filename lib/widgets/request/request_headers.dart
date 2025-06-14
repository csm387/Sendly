import 'package:flutter/material.dart';

class RequestHeaders extends StatelessWidget {
  final Map<String, String> headers;
  final Function(Map<String, String>) onHeadersChanged;

  const RequestHeaders({
    super.key,
    required this.headers,
    required this.onHeadersChanged,
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
                  'HEADERS',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    final newHeaders = Map<String, String>.from(headers);
                    newHeaders[''] = '';
                    onHeadersChanged(newHeaders);
                  },
                  tooltip: 'Add Header',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: headers.length,
                itemBuilder: (context, index) {
                  final key = headers.keys.elementAt(index);
                  final value = headers[key]!;
                  
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
                                final newHeaders = Map<String, String>.from(headers);
                                newHeaders.remove(key);
                                newHeaders[newKey] = value;
                                onHeadersChanged(newHeaders);
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
                              final newHeaders = Map<String, String>.from(headers);
                              newHeaders[key] = newValue;
                              onHeadersChanged(newHeaders);
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            final newHeaders = Map<String, String>.from(headers);
                            newHeaders.remove(key);
                            onHeadersChanged(newHeaders);
                          },
                          tooltip: 'Remove Header',
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