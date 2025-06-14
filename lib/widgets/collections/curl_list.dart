import 'package:flutter/material.dart';
import '../../models/request.dart';

class CurlList extends StatelessWidget {
  final List<Request> curls;
  final String searchQuery;
  final Request? selectedCurl;
  final Function(Request) onCurlSelected;
  final Function(Request) onCurlRenamed;
  final Function(Request) onCurlDeleted;
  final Function(String) onSearchChanged;

  const CurlList({
    super.key,
    required this.curls,
    required this.searchQuery,
    required this.selectedCurl,
    required this.onCurlSelected,
    required this.onCurlRenamed,
    required this.onCurlDeleted,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredCurls = curls.where((curl) {
      return curl.url.toLowerCase().contains(searchQuery.toLowerCase()) ||
          curl.method.toLowerCase().contains(searchQuery.toLowerCase());
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
                  'CURLS',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    // TODO: Implement add curl
                  },
                  tooltip: 'Add Curl',
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: TextEditingController(text: searchQuery),
              decoration: const InputDecoration(
                hintText: 'Search curls...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: onSearchChanged,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: filteredCurls.length,
                itemBuilder: (context, index) {
                  final curl = filteredCurls[index];
                  final isSelected = selectedCurl?.url == curl.url;
                  
                  return ListTile(
                    selected: isSelected,
                    title: Text(curl.url),
                    subtitle: Text(
                      '${curl.method} - ${curl.headers.length} headers',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => onCurlRenamed(curl),
                          tooltip: 'Rename Curl',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => onCurlDeleted(curl),
                          tooltip: 'Delete Curl',
                        ),
                      ],
                    ),
                    onTap: () => onCurlSelected(curl),
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