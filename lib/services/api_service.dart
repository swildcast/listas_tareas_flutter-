import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';

class ApiService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';

  static Future<List<Task>> fetchTasks() async {
    final response = await http.get(Uri.parse('$baseUrl/todos'));
    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => Task.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  static Future<Task> addTask(String title) async {
    final response = await http.post(
      Uri.parse('$baseUrl/todos'),
      body: json.encode({
        'title': title,
        'completed': false,
      }),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 201) {
      return Task.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to add task');
    }
  }

  static Future<void> updateTask(Task task) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/todos/${task.id}'),
      body: json.encode({
        'completed': task.completed,
      }),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update task');
    }
  }

  static Future<void> deleteTask(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/todos/$id'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to delete task');
    }
  }
}
