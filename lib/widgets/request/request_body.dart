import 'package:flutter/material.dart';

class RequestBody extends StatelessWidget {
  final String body;
  final Function(String) onBodyChanged;
  final bool isJson;

  const RequestBody({
    super.key,
    required this.body,
    required this.onBodyChanged,
    this.isJson = true,
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
                  'REQUEST BODY',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.format_align_left),
                      onPressed: () {
                        // TODO: Implement format functionality
                      },
                      tooltip: 'Format',
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () {
                        // TODO: Implement copy functionality
                      },
                      tooltip: 'Copy',
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: TextEditingController(text: body),
                maxLines: null,
                expands: true,
                decoration: InputDecoration(
                  hintText: isJson ? 'Enter JSON body' : 'Enter request body',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                ),
                onChanged: onBodyChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 