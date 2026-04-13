import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';

class TaskService {
  final CollectionReference _tasksCollection =
      FirebaseFirestore.instance.collection('tasks');

  // CREATE
  Future<void> addTask(String title) async {
    await _tasksCollection.add({
      'title': title.trim(),
      'isCompleted': false,
      'subtasks': [],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // READ
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

  // UPDATE
  Future<void> toggleTask(Task task) async {
    await _tasksCollection.doc(task.id).update({
      'isCompleted': !task.isCompleted,
    });
  }

  // DELETE TASK
  Future<void> deleteTask(String id) async {
    await _tasksCollection.doc(id).delete();
  }

  // ADD SUBTASK
  Future<void> addSubtask(Task task, String title) async {
    final updated = List<Map<String, dynamic>>.from(task.subtasks);

    updated.add({
      'title': title.trim(),
      'isCompleted': false,
    });

    await _tasksCollection.doc(task.id).update({
      'subtasks': updated,
    });
  }

  // TOGGLE SUBTASK
  Future<void> toggleSubtask(Task task, int index) async {
    final updated = List<Map<String, dynamic>>.from(task.subtasks);

    updated[index]['isCompleted'] =
        !(updated[index]['isCompleted'] ?? false);

    await _tasksCollection.doc(task.id).update({
      'subtasks': updated,
    });
  }

  // DELETE SUBTASK
  Future<void> deleteSubtask(Task task, int index) async {
    final updated = List<Map<String, dynamic>>.from(task.subtasks);

    updated.removeAt(index);

    await _tasksCollection.doc(task.id).update({
      'subtasks': updated,
    });
  }
}