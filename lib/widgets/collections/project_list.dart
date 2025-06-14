import 'package:flutter/material.dart';
import '../../models/project.dart';

class ProjectList extends StatelessWidget {
  final List<Project> projects;
  final String searchQuery;
  final Project? selectedProject;
  final Function(Project) onProjectSelected;
  final Function(Project) onProjectRenamed;
  final Function(Project) onProjectDeleted;
  final Function(String) onSearchChanged;

  const ProjectList({
    super.key,
    required this.projects,
    required this.searchQuery,
    required this.selectedProject,
    required this.onProjectSelected,
    required this.onProjectRenamed,
    required this.onProjectDeleted,
    required this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filteredProjects = projects.where((project) {
      return project.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          project.description.toLowerCase().contains(searchQuery.toLowerCase());
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
                  'PROJECTS',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    // TODO: Implement add project
                  },
                  tooltip: 'Add Project',
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: TextEditingController(text: searchQuery),
              decoration: const InputDecoration(
                hintText: 'Search projects...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: onSearchChanged,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: filteredProjects.length,
                itemBuilder: (context, index) {
                  final project = filteredProjects[index];
                  final isSelected = selectedProject?.name == project.name;
                  
                  return ListTile(
                    selected: isSelected,
                    title: Text(project.name),
                    subtitle: Text(
                      project.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => onProjectRenamed(project),
                          tooltip: 'Rename Project',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => onProjectDeleted(project),
                          tooltip: 'Delete Project',
                        ),
                      ],
                    ),
                    onTap: () => onProjectSelected(project),
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