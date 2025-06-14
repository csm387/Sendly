import 'package:flutter/material.dart';
import 'dart:convert';

class ResponseBody extends StatelessWidget {
  final String body;
  final bool isJson;
  final Function() onCopy;

  const ResponseBody({
    super.key,
    required this.body,
    this.isJson = true,
    required this.onCopy,
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
                  'RESPONSE BODY',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    if (isJson)
                      IconButton(
                        icon: const Icon(Icons.format_align_left),
                        onPressed: () {
                          try {
                            final json = jsonDecode(body);
                            final formatted = const JsonEncoder.withIndent('  ').convert(json);
                            // TODO: Update formatted body
                          } catch (e) {
                            // TODO: Show error
                          }
                        },
                        tooltip: 'Format JSON',
                      ),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: onCopy,
                      tooltip: 'Copy Response',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.outline,
                  ),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    body,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 