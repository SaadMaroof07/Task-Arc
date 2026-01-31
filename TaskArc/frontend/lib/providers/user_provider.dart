import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/api_service.dart';

class UserProvider with ChangeNotifier {
  final storage = const FlutterSecureStorage();
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Map<String, dynamic>> _tasks = [];
  List<Map<String, dynamic>> get tasks => _tasks;

  // Categories storage
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> get categories => _categories;

  Future<bool> loginUser(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    final data = await ApiService.login(username, password);

    if (data != null && data.containsKey('access')) {
      await storage.write(key: 'token', value: data['access']);
      _isLoading = false;
      notifyListeners();
      return true;
    }
    _isLoading = false;
    notifyListeners();
    return false;
  }

  // 2. Fetch Tasks (Updated)
  Future<void> fetchTasks() async {
    _isLoading = true;
    notifyListeners();
    final token = await storage.read(key: 'token');
    if (token != null) {
      final data = await ApiService.fetchTasks(token);
      _tasks = data ?? [];
    }
    _isLoading = false;
    notifyListeners();
  }

  // 3. Fetch Categories (Naya Function)
  Future<void> fetchCategories() async {
    final token = await storage.read(key: 'token');
    if (token != null) {
      final data = await ApiService.fetchCategories(token);
      _categories = data ?? [];
      notifyListeners();
    }
  }

  // 4. Add Task (Naya Function)
  Future<bool> addTask(Map<String, dynamic> taskData) async {
    final token = await storage.read(key: 'token');
    if (token == null) return false;

    final success = await ApiService.createTask(taskData, token);
    if (success) {
      await fetchTasks(); // List ko refresh karein
    }
    return success;
  }

  // 5. Toggle Completion (Aapka logic + Custom Action Support)
  Future<void> toggleTaskStatus(int id) async {
    final token = await storage.read(key: 'token');
    if (token == null) return;

    // Optimistic Update: UI pehle hi badal do
    final idx = _tasks.indexWhere((t) => t['id'] == id);
    if (idx != -1) {
      _tasks[idx]['is_completed'] = !(_tasks[idx]['is_completed'] ?? false);
      notifyListeners();
    }

    // Backend update
    await ApiService.toggleTaskStatus(id, token);
  }

  // Toggle completion with explicit value (used by Checkbox)
  Future<void> toggleTaskCompletion(int id, bool isCompleted) async {
    final token = await storage.read(key: 'token');
    if (token == null) return;

    final idx = _tasks.indexWhere((t) => t['id'] == id);
    if (idx != -1) {
      _tasks[idx]['is_completed'] = isCompleted;
      notifyListeners();
    }

    await ApiService.updateTaskStatus(id, isCompleted, token);
  }

  // Delete a task both locally and via API
  Future<void> deleteTask(int taskId) async {
    final token = await storage.read(key: 'token');
    if (token == null) return;

    final success = await ApiService.deleteTask(taskId, token);
    if (success) {
      _tasks.removeWhere((t) => t['id'] == taskId);
      notifyListeners();
    }
  }
}
