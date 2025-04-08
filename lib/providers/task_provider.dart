import '../services/api_service.dart';
import '../models/task.dart';
import 'package:flutter/material.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _error;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;


  Future<void> loadTasks() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _tasks = await ApiService.fetchTasks();
    } catch (e) {
      _error = 'Failed to load tasks: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<void> toggleTask(int id) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index >= 0) {
      final updatedTask = _tasks[index].copyWith(
        completed: !_tasks[index].completed
      );
      try {
        await ApiService.updateTask(updatedTask);
        _tasks[index] = updatedTask;
        _error = null;
        notifyListeners();
      } catch (e) {
        _error = 'Failed to update task: ${e.toString()}';
        notifyListeners();
        rethrow;
      }
    }
  }



  Future<void> removeTask(int id) async {
    try {
      await ApiService.deleteTask(id);
      _tasks.removeWhere((task) => task.id == id);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete task: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }



  Future<void> addTask(String title) async {
    try {
      final newTask = await ApiService.addTask(title);
      _tasks.add(newTask);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to add task: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }


}
