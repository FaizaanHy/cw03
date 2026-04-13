import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';

class TaskService {
  final CollectionReference _tasksCollection =
      FirebaseFirestore.instance.collection('tasks');

  // 🔹 CREATE
  Future<void> addTask(String title) async {
    await _tasksCollection.add({
      'title': title.trim(),
      'isCompleted': false,
      'subtasks': [],
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  // 🔹 READ (REAL-TIME STREAM)
  Stream<List<Task>> streamTasks() {
    return _tasksCollection
        .orderBy('createdAt')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Task.fromMap(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();
    });
  }

  // 🔹 UPDATE
  Future<void> toggleTask(Task task) async {
    await _tasksCollection.doc(task.id).update({
      'isCompleted': !task.isCompleted,
    });
  }

  // 🔹 DELETE
  Future<void> deleteTask(String id) async {
    await _tasksCollection.doc(id).delete();
  }
}


// 🔹 Add subtask
Future<void> addSubtask(Task task, String title) async {
  final updatedSubtasks = List<Map<String, dynamic>>.from(task.subtasks);

  updatedSubtasks.add({
    'title': title.trim(),
    'isCompleted': false,
  });

  await _tasksCollection.doc(task.id).update({
    'subtasks': updatedSubtasks,
  });
}

// 🔹 Toggle subtask
Future<void> toggleSubtask(Task task, int index) async {
  final updatedSubtasks = List<Map<String, dynamic>>.from(task.subtasks);

  updatedSubtasks[index]['isCompleted'] =
      !(updatedSubtasks[index]['isCompleted'] ?? false);

  await _tasksCollection.doc(task.id).update({
    'subtasks': updatedSubtasks,
  });
}

// 🔹 Delete subtask
Future<void> deleteSubtask(Task task, int index) async {
  final updatedSubtasks = List<Map<String, dynamic>>.from(task.subtasks);

  updatedSubtasks.removeAt(index);

  await _tasksCollection.doc(task.id).update({
    'subtasks': updatedSubtasks,
  });
}