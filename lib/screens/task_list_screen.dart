import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/task_service.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TextEditingController _taskController = TextEditingController();
  final TaskService _taskService = TaskService();

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }

  void _addTask() async {
    final title = _taskController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Task can't be empty")),
      );
      return;
    }

    await _taskService.addTask(title);
    _taskController.clear();
  }

  Future<void> _confirmDelete(Task task) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Task?"),
          content: const Text("This action cannot be undone."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      _taskService.deleteTask(task.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
      ),
      body: Column(
        children: [
          // ── INPUT ─────────────────────────────
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: const InputDecoration(
                      hintText: 'Enter a task...',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addTask,
                  child: const Text('Add'),
                ),
              ],
            ),
          ),

          // ── LIST ─────────────────────────────
          Expanded(
            child: StreamBuilder<List<Task>>(
              stream: _taskService.streamTasks(),
              builder: (context, snapshot) {
                // Loading
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 10),
                        Text("Loading tasks..."),
                      ],
                    ),
                  );
                }

                // Error
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                final tasks = snapshot.data ?? [];

                // Empty state
                if (tasks.isEmpty) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.task_alt, size: 60, color: Colors.grey),
                      SizedBox(height: 10),
                      Text(
                        'No tasks yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Add your first task above',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  );
                }

                // Data
                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];

                    return ExpansionTile(
                      title: Text(
                        task.title,
                        style: TextStyle(
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),

                      leading: Checkbox(
                        value: task.isCompleted,
                        onChanged: (_) {
                          _taskService.toggleTask(task);
                        },
                      ),

                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _confirmDelete(task),
                      ),

                      children: [
                        // Subtasks
                        ...task.subtasks.asMap().entries.map((entry) {
                          final subIndex = entry.key;
                          final subtask = entry.value;

                          return ListTile(
                            title: Text(
                              subtask['title'] ?? '',
                              style: TextStyle(
                                decoration:
                                    (subtask['isCompleted'] ?? false)
                                        ? TextDecoration.lineThrough
                                        : null,
                              ),
                            ),
                            leading: Checkbox(
                              value: subtask['isCompleted'] ?? false,
                              onChanged: (_) {
                                _taskService.toggleSubtask(task, subIndex);
                              },
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () {
                                _taskService.deleteSubtask(task, subIndex);
                              },
                            ),
                          );
                        }),

                        // Add subtask
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: TextField(
                            onSubmitted: (value) {
                              if (value.trim().isEmpty) return;
                              _taskService.addSubtask(task, value);
                            },
                            decoration: const InputDecoration(
                              hintText: 'Add subtask...',
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}