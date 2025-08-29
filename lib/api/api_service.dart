import 'package:app_http_dummydata/data_classes/employee.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static final String baseUrl = 'http://dummy.restapiexample.com/api/v1';
  static const timeout = Duration(seconds: 10);

  final http.Client _client = http.Client();

  Future<List<Employee>> getEmployees() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/employees'))
          .timeout(timeout);

      if (response.statusCode == 200) {
        final parsed = json.decode(response.body);

        final dataList = parsed['data'] as List<dynamic>;

        return dataList.map((data) => Employee.fromJson(data)).toList();
      } else {
        throw Exception('Failed to load employees: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load employees: $e');
    }
  }

  Future<Employee> getEmployee(String id) async {
    debugPrint('Fetching employee with id: $id');

    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/employee/$id'))
          .timeout(timeout);

      if (response.statusCode == 200) {
        final parsed = json.decode(response.body);

        return Employee.fromJson(parsed);
      } else if (response.statusCode == 429) {
        debugPrint('Rate limit exceeded. Use Memory');
        throw Exception('Rate limit exceeded. Use Memory');
      } 
      else {
        throw Exception('Failed to load employee: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load employee: $e');
    }
  }

  Future<Employee> saveEmployee(Employee employee) async {
    final bool isUpdate = employee.id.isNotEmpty;
    final Uri url = isUpdate
        ? Uri.parse('$baseUrl/update/${employee.id}')
        : Uri.parse('$baseUrl/create');

    try {
      final http.Response response = isUpdate
          ? await _client
                .put(
                  url,
                  headers: {'Content-Type': 'application/json'},
                  body: json.encode(employee.toJson()),
                )
                .timeout(timeout)
          : await _client
                .post(
                  url,
                  headers: {'Content-Type': 'application/json'},
                  body: json.encode(employee.toJson()),
                )
                .timeout(timeout);

      if (response.statusCode == 200) {
        final parsed = json.decode(response.body);

        // The API returns the created/updated employee in the 'data' field
        if (parsed['status'] == 'success' && parsed['data'] != null) {
          return Employee.fromJson(parsed['data']);
        } else {
          throw Exception(
            'Failed to save employee: Unexpected response format',
          );
        }
      } else {
        throw Exception('Failed to save employee: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to save employee: $e');
    }
  }

  Future<dynamic> deleteEmployee(String id) async {
    try {
      final response = await _client
          .delete(Uri.parse('$baseUrl/employee/$id'))
          .timeout(timeout);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to delete employee: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to delete employee: $e');
    }
  }

  /// Closes the HTTP client when the service is no longer needed.
  void dispose() {
    _client.close();
  }
}
