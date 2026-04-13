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
    _taskController.dispose(); // Prevent memory leaks
    super.dispose();
  }

  // 🔹 Add Task to Firestore
  void _addTask() async {
    final title = _taskController.text.trim();
    if (title.isEmpty) return;

    await _taskService.addTask(title);
    _taskController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
      ),
      body: Column(
        children: [
          // ── Input Row ─────────────────────────────
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

          // ── Firestore Task List ───────────────────
          Expanded(
            child: StreamBuilder<List<Task>>(
              stream: _taskService.streamTasks(),
              builder: (context, snapshot) {
                // 🔹 Loading State
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // 🔹 Error State
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }

                final tasks = snapshot.data ?? [];

                // 🔹 Empty State
                if (tasks.isEmpty) {
                  return const Center(
                    child: Text('No tasks yet — add one above!'),
                  );
                }

                // 🔹 Data State
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
    onPressed: () {
      _taskService.deleteTask(task.id);
    },
  ),

  children: [
    // 🔹 Subtask List
    ...task.subtasks.asMap().entries.map((entry) {
      final index = entry.key;
      final subtask = entry.value;

      return ListTile(
        title: Text(
          subtask['title'] ?? '',
          style: TextStyle(
            decoration: (subtask['isCompleted'] ?? false)
                ? TextDecoration.lineThrough
                : null,
          ),
        ),
        leading: Checkbox(
          value: subtask['isCompleted'] ?? false,
          onChanged: (_) {
            _taskService.toggleSubtask(task, index);
          },
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () {
            _taskService.deleteSubtask(task, index);
          },
        ),
      );
    }),

    // 🔹 Add Subtask Input
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Expanded(
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