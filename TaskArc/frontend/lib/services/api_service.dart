import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Emulator ke liye localhost ka IP 10.0.2.2 hota hai
  static const String baseUrl = "http://127.0.0.1:8000/api";

  static Future<Map<String, dynamic>?> login(
    String username,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/login/"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({"username": username, "password": password}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Token mil jayega
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Fetch tasks for the authenticated user
  static Future<List<Map<String, dynamic>>?> fetchTasks(String token) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/tasks/"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Toggle/update task status (is_completed)
  static Future<bool> updateTaskStatus(
    int id,
    bool isCompleted,
    String token,
  ) async {
    try {
      final response = await http.patch(
        Uri.parse("$baseUrl/tasks/$id/"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"is_completed": isCompleted}),
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      return false;
    }
  }

  // --- New Functions ---

  // 1. Fetch Categories
  static Future<List<Map<String, dynamic>>?> fetchCategories(
    String token,
  ) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/categories/"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // 2. Create New Task
  static Future<bool> createTask(
    Map<String, dynamic> taskData,
    String token,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/tasks/"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(taskData),
      );

      return response.statusCode == 201; // 201 Created
    } catch (e) {
      return false;
    }
  }

  // 3. Toggle Status (Using our Custom Django Action)
  static Future<bool> toggleTaskStatus(int id, String token) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/tasks/$id/toggle_status/"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // 4. Delete Task
  static Future<bool> deleteTask(int id, String token) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/tasks/$id/"),
        headers: {
          // Authorization only; other headers not strictly necessary for delete
          "Authorization": "Bearer $token",
        },
      );
      return response.statusCode == 204; // 204 No Content means deleted
    } catch (e) {
      return false;
    }
  }
}
