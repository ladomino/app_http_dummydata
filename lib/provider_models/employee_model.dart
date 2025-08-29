import 'package:app_http_dummydata/api/api_service.dart';
import 'package:app_http_dummydata/data_classes/employee.dart';
import 'package:flutter/material.dart';

class EmployeeProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<dynamic> _employees = [];
  Employee? _selectedEmployee;
  bool _isLoading = false;
  String? _error;

  EmployeeProvider(this._apiService);

  List<dynamic> get employees => _employees;
  Employee? get selectedEmployee => _selectedEmployee;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get employee from in-memory list by ID
  Employee? getEmployeeById(String id) {
    try {
      return _employees.firstWhere((employee) => employee.id == id);
    } catch (e) {
      // If not found, return null
      return null;
    }
  }

  Future<void> fetchEmployees() async {
    _isLoading = true;
    _error = null;

    try {
      _employees = await _apiService.getEmployees();
      _isLoading = false;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
    }
    notifyListeners();
  }

  Future<void> fetchEmployee(String id) async {
    _isLoading = true;
    _error = null;
    _selectedEmployee = null;

    try {
      _selectedEmployee = await _apiService.getEmployee(id);
      _isLoading = false;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
    }
    _selectedEmployee ??= getEmployeeById(id);   
    notifyListeners();
  }
}
