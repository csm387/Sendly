import 'package:flutter/material.dart';
import '../../models/request.dart';

class HistoryList extends StatelessWidget {
  final List<Request> history;
  final String searchQuery;
  final Request? selectedRequest;
  final Function(Request) onRequestSelected;
  final Function(Request) onRequestDeleted;
  final Function(String) onSearchChanged;

  const HistoryList({
    super.key,
    required this.history,
    required this.searchQuery,
    required this.selectedRequest,
    required this.onRequestSelected,
    required this.onRequestDeleted,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredHistory = history.where((request) {
      return request.url.toLowerCase().contains(searchQuery.toLowerCase()) ||
          request.method.toLowerCase().contains(searchQuery.toLowerCase());
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
                  'HISTORY',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_sweep),
                  onPressed: () {
                    // TODO: Implement clear history
                  },
                  tooltip: 'Clear History',
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: TextEditingController(text: searchQuery),
              decoration: const InputDecoration(
                hintText: 'Search history...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: onSearchChanged,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: filteredHistory.length,
                itemBuilder: (context, index) {
                  final request = filteredHistory[index];
                  final isSelected = selectedRequest?.url == request.url;
                  
                  return ListTile(
                    selected: isSelected,
                    title: Text(request.url),
                    subtitle: Text(
                      '${request.method} - ${request.createdAt.toString()}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => onRequestDeleted(request),
                      tooltip: 'Delete from History',
                    ),
                    onTap: () => onRequestSelected(request),
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