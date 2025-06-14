import 'package:flutter/material.dart';

class RequestHeader extends StatelessWidget {
  final String method;
  final String url;
  final int? statusCode;
  final Function(String) onMethodChanged;
  final Function(String) onUrlChanged;

  const RequestHeader({
    super.key,
    required this.method,
    required this.url,
    this.statusCode,
    required this.onMethodChanged,
    required this.onUrlChanged,
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
              'REQUEST',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                DropdownButton<String>(
                  value: method,
                  items: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'HEAD', 'OPTIONS']
                      .map((m) => DropdownMenuItem(
                            value: m,
                            child: Text(m),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      onMethodChanged(value);
                    }
                  },
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: TextEditingController(text: url),
                    decoration: const InputDecoration(
                      hintText: 'Enter URL',
                      prefixIcon: Icon(Icons.link),
                    ),
                    onChanged: onUrlChanged,
                  ),
                ),
                if (statusCode != null) ...[
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: statusCode! >= 200 && statusCode! < 300
                          ? Colors.green
                          : Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      statusCode.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
} 